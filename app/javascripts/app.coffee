accounts = undefined
account = undefined
ipfsGateway = "http://localhost:8090/ipfs/"

# FIXME: use src/ipfs.coffee functions
toHex = (str) ->
  a = []
  for c in str
    h = c.charCodeAt(0)
    h = "0x"+h.toString(16)
    a.push h
  return a
toStr = (arr) ->
  return (String.fromCharCode(parseInt(i, 16)) for i in arr).join('')


setStatus = (message) ->
  status = document.getElementById('status')
  status.innerHTML = message

refreshJobs = ->
  agency = JobAgency.deployed()
  agency.getLastJobId.call(from: account)
  .then (value) ->
    console.log 'v', value
    jobId = value.toNumber()
    balance_element = document.getElementById('jobs')
    balance_element.innerHTML = (jobId+1).valueOf()
    return jobId
  .catch (e) ->
    console.log e
    setStatus 'Error getting balance; see log.'

updateIpfs = ->
  codeHash = document.getElementById('codehash').value
  inputHash = document.getElementById('inputhash').value

  inputHashPreview = document.getElementById('inputhash_preview')
  # TODO: plug in https://github.com/xicombd/is-ipfs for validation

  # Update preview links
  inputHashPreview = document.getElementById('inputhash_preview')
  inputHashPreview.href = "#{ipfsGateway}#{inputHash}"
  codeHashPreview = document.getElementById('codehash_preview')
  codeHashPreview.href = "#{ipfsGateway}#{codeHash}"


  return values =
    code: codeHash
    input: inputHash

window.postJob = ->
  agency = JobAgency.deployed()
  console.log 'agency address', agency.address

  values = updateIpfs()

  setStatus 'Posting job... (please wait)'
  for e in document.getElementsByClassName('results')
    e.className = "results hide"

  console.log 'job data', values.input, values.code
  agency.postJob(toHex(values.code), toHex(values.input), from: account)
  .then (tx) ->
    setStatus 'Job posted!'
    refreshJobs()
  .then (id) ->
    console.log 'posted', id
    Promise.promisify(waitForResult)(agency, id)
  .then (result) ->
    setStatus 'Got job result!!'
    console.log 's'
    resultHash = document.getElementById('resulthash')
    resultHashPreview = document.getElementById('resulthash_preview')
    resultHash.value = result
    resultHashPreview.href = "#{ipfsGateway}#{result}"
    for e in document.getElementsByClassName('results')
      e.className = "results show"
    return result
  .catch (e) ->
    console.log e
    console.log e.stack
    setStatus 'Error posting job: ' + e.message

waitForResult = (agency, requestedJobId, callback) ->
  events = []
  transaction = null

  checkEvents = () ->
    for e in events
        jobId = e?.args?.jobId.toNumber()
        if jobId == requestedJobId && e.event == 'JobCompleted'
            agency.getJobResult.call(jobId)
            .then (r) ->
              return toStr(r)
            .nodeify(callback)
            return true
    return false

  e = agency.JobCompleted()
  e.watch (err, event) ->
    #console.log 'event', err, event?.transactionHash, event?.args?.jobId.toString()
    events.push event
    e.stopWatching() if checkEvents()

window.onload = ->
  codeHashInput = document.getElementById('codehash')
  codeHashInput.addEventListener 'change', updateIpfs
  inputHashInput = document.getElementById('inputhash')
  inputHashInput.addEventListener 'change', updateIpfs
  do updateIpfs

  web3.eth.getAccounts (err, accs) ->
    if err != null
      alert 'There was an error fetching your accounts.'
      return
    if accs.length == 0
      alert 'Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.'
      return
    accounts = accs
    account = accounts[0]

    Pudding.defaults({
      gas: 3141592 # XXX: if this is not sent then we run out of gas??
    })
    refreshJobs()
