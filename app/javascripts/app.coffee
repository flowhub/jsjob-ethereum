accounts = undefined
account = undefined

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

  agency.postJob(codeHash, inputHash, from: account)
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
