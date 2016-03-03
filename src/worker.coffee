Web3 = require "web3"
Pudding = require "ether-pudding"
PuddingLoader = require "ether-pudding/loader"
Promise = require 'bluebird'
Ipfs = require 'ipfs-api'
url = require 'url'
debug = require('debug')('jobjs:worker')

Runner = require './runner'
ipfs = require './ipfs'

class Worker
  constructor: (@options = {}) ->
    @options.ethereum = {} unless @options.ethereum
    @options.ethereum.rpc = 'http://localhost:8545' unless @options.ethereum.rpc
    @options.ethereum.contractsDir = './environments/development/contracts' unless @options.ethereum.contractsDir

    console.log @options
    @agency = null

    @options.ipfs = {} unless @options.ipfs
    @options.ipfs.apiAddr = '/ip4/127.0.0.1/tcp/5001' unless @options.ipfs.apiAddr
    # FIXME: Default should be 8080?
    @options.ipfs.gateway = 'http://localhost:8090' unless @options.ipfs.gateway

    @options.runner =
      scripts: [
        "window.jsJobRun = function(d, o, cb) { window.polySolvePage(d, o, cb) };"
      ]
    @agencyWatcher = null
    @preparePudding()
    @prepareIpfs()
    @seenJobIds = []
    @runner = new Runner @options.runner

  preparePudding: ->
    @web3 = new Web3()
    Pudding.setWeb3 @web3
    p = new Web3.providers.HttpProvider @options.ethereum.rpc
    @web3.setProvider p

  prepareIpfs: ->
    @ipfs = Ipfs @options.ipfs.apiAddr

  loadContracts: (callback) ->
    contracts = {}
    PuddingLoader.load @options.ethereum.contractsDir, Pudding, contracts, (err, names) ->
      return callback err if err
      return callback null, contracts

  subscribeAgency: (agency, callback) ->
    @agencyWatcher = agency.JobPosted()
    @agencyWatcher.watch (err, event) =>
      return callback err if err
      jobId = event.args.jobId.c[0]

      # Avoid duplicates. Due to multiple confirmations?
      # FIXME: Probably we should wait for a certain number before considering it legit
      if jobId in @seenJobIds
        debug "Duplicate job #{jobId} received"
        return
      @seenJobIds.push jobId

      return callback null, jobId

  startRunner: (callback) ->
    @runner.start (err) ->
      return callback err if err
      do callback

  getJobData: (jobId, callback) ->
    getCode = @agency.getJobCode.call jobId
      .then (d) ->
        return ipfs.toStr d
    getInput = @agency.getJobInput.call jobId
      .then (d) ->
        return ipfs.toStr d
    return Promise.props({
        input: getInput,
        code: getCode,
    }).nodeify(callback)

  getIpfsContents: (hash, callback) ->
    @ipfs.cat hash, (err, data) ->
      return callback err if err
      contents = ''
      data.on 'data', (chunk) ->
        contents += chunk
      data.on 'end', ->
        callback null, contents

  runJob: (jobId, callback) ->
    @getJobData jobId, (err, job) =>
      console.time "Job #{jobId}"
      console.log 'job', jobId, job

      # FIXME: get from IPFS
      gatewayUrl = url.parse @options.ipfs.gateway
      codeUrl = url.format
        protocol: gatewayUrl.protocol
        host: gatewayUrl.host
        pathname: "/ipfs/#{job.code}"

      @getIpfsContents job.input, (err, contents) =>
        console.log err, contents
        return callback err if err
        try
          inputData = JSON.parse contents
        catch e
          return callback e

        jobOptions = {}
        console.log codeUrl, inputData

        @runner.performJob codeUrl, inputData, jobOptions, (err, j) ->
          console.timeEnd "Job #{jobId}"
          return callback err if err
          callback j

  start: (callback) ->
    @startRunner (err) =>
      return callback err if err
      @loadContracts (err, contracts) =>
        console.log err, contracts
        return callback err if err
        @agency = contracts.JobAgency.deployed()
        console.log 'JobAgency address:', @agency.address
        @subscribeAgency @agency, (err, jobId) =>
          @runJob jobId, (err, result) =>
            console.log err, result

  stop: (callback) ->
    @agencyWatcher.stopWatching() if @agencyWatcher
    @agencyWatcher = null
    @runner.stop callback

exports.main = main = () ->
  w = new Worker
  w.start (err) ->
    if err
      console.error err
      process.exit 1

main() if not module.parent
