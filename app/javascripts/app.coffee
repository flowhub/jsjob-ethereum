accounts = undefined
account = undefined

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

window.postJob = ->
  agency = JobAgency.deployed()

  codeHash = parseInt(document.getElementById('codehash').value)
  inputHash = document.getElementById('inputhash').value

  setStatus 'Starting jobposting transaction... (please wait)'

  agency.postJob(toHex(codeHash), toHex(inputHash), from: account)
  .then(->
    setStatus 'Job posted!'
    refreshJobs()
  ).catch (e) ->
    console.log e
    console.log e.stack
    setStatus 'Error sending coin: ' + e.message

window.onload = ->
  web3.eth.getAccounts (err, accs) ->
    if err != null
      alert 'There was an error fetching your accounts.'
      return
    if accs.length == 0
      alert 'Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.'
      return
    accounts = accs
    account = accounts[0]
    refreshJobs()
