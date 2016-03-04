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
  agency.getLastJobId.call(from: account).then((value) ->
    balance_element = document.getElementById('jobs')
    balance_element.innerHTML = value.valueOf()
  ).catch (e) ->
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

  setStatus 'Starting jobposting transaction... (please wait)'

  console.log 'job data', values.input, values.code
  agency.postJob(toHex(values.code), toHex(values.input), from: account)
  .then(->
    setStatus 'Job posted!'
    refreshJobs()
  ).catch (e) ->
    console.log e
    console.log e.stack
    setStatus 'Error sending coin: ' + e.message

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
