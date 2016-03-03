
http = require 'http'
url = require 'url'
child_process = require 'child_process'
path = require 'path'

debug = require('debug')('jsjob:runner')

try
  phantomjs = require 'phantomjs'
catch e
  debug 'Could not load PhantomJS 1', e


# XXX: may need to inject Function.bind polyfill

class Runner
  constructor: (@options={}) ->
    @server = null
    @jobs = {}
    @jobId = 1

    debug 'constructor', @options

    @options.port = 8088 if not @options.port
    polyTimeout = process.env['JSJOB_TIMEOUT']
    @options.timeout = parseInt(polyTimeout)*1000 if polyTimeout and not @options.timeout
    @options.verbose = true if process.env['JSJOB_VERBOSE']
    @options.detailsLog = true
    @options.detailsLog = process.env['JSJOB_DETAILS_LOG'] == 'true' if process.env['JSJOB_DETAILS_LOG']?

  start: (callback) ->
    debug 'start', @options.port
    @server = http.createServer (req, res) =>
      @onRequest req, res
    @server.listen @options.port, (err) =>
      debug 'started', @options.port
      return callback err

  stop: (callback) ->
    debug 'stop', @options.port
    @server.close (err) =>
      debug 'stopped', @options.port
      return callback err if typeof callback == 'function'

  # options is optional, for historical reasons
  performJob: (codeUrl, inputData, jobOptions, callback) ->

    @options.allowedResources = jobOptions.allowedResources
    p = new PhantomProcess @options
    job =
      id: @jobId++
      process: p
      filter: codeUrl
      page: inputData
      options: jobOptions
      solution: null
      details: {}
      screenshots: {}
      events: []
    p.run job, (err) =>
      sol = job.solution
      details = job.details
      details = {} if not details
      if @options.detailsLog
        details.stdout = p.stdout
        details.stderr = p.stderr
      details.screenshots = job.screenshots
      return callback err, sol, details if err
      return callback job.error, sol, details
    @jobs[job.id] = job

  # FIXME: implement communication to and from the JavaScript process



# Mapping of exit code to error. Needs to match behavior of ../bin/phantomjs-loadpage.js
phantomErrors =
  1: 'Wrong arguments'
  2: 'Failed to open solver page'
  3: 'Soft timeout'
  4: 'Uncaught JavaScript Error'

# TODO/PERF: use WebDriver mode and keep a long-running phantomjs instance
class PhantomProcess
  constructor: (@options={}) ->
    @child = null

    @options.port = 8088 if not @options.port
    @options.port = parseInt @options.port if typeof @options.port == 'string'
    browser = process.env.JSJOB_BROWSER
    browser = phantomjs?.path if not browser
    browser = 'phantomjs' if not browser
    @options.phantomjs = browser if not @options.phantomjs
    @options.timeout = 60*1000 if not @options.timeout
    @options.hardtimeout = @options.timeout+(5*1000) if not @options.hardtimeout

    @stdout = ""
    @stderr = ""

  run: (job, callback) ->
    baseUrl = "http://localhost:#{@options.port}/solve/"

    prog = @options.phantomjs
    script = path.join __dirname, '../bin/phantomjs-loadpage.js'
    args = [
      script
      baseUrl + job.id.toString()
    ]
    args.push @options.timeout.toString() if @options.timeout
    if @options.allowedResources
      allowed = [ job.filter, baseUrl ].concat @options.allowedResources
      args.push JSON.stringify(allowed)

    console.log "Running #{prog} " + args.join ' ' if @options.verbose
    @child = child_process.spawn prog, args

    onHardTimeout = () =>
      return if not callback # already returned
      @child.kill 'SIGKILL'
      # should now fire exit handler
    setTimeout onHardTimeout, @options.hardtimeout

    @stdout = ""
    @child.stdout.on 'data', (data) =>
      console.log data.toString() if @options.verbose
      @stdout += data.toString()
    @stderr = ""
    @child.stderr.on 'data', (data) =>
      console.log data.toString() if @options.verbose
      @stderr += data.toString()

    @child.on 'error', (err) =>
      console.log 'child error', err if @options.verbose
      callback err if callback
      callback = null
    @child.on 'exit', (code, signal) =>
      console.log 'exit', code, signal if @options.verbose
      return if not callback

      details = "\n#{@stderr}\n#{@stdout}"
      if code and not signal
        reason = phantomErrors[code]
        err = new Error "PhantomJS exited with #{code} #{signal} '#{reason}':#{details}"
        err.stack = err.stack.replace(details, '...')
        callback err
      else if not code and signal == 'SIGKILL'
        err = new Error "Hit hard timeout limit of #{@options.hardtimeout/1000} seconds:#{details}"
        err.stack = err.stack.replace(details, '...')
        callback err
      else
        callback null, job.id
      callback = null
      return

  stop: () ->
    @child.kill()

module.exports = Runner

