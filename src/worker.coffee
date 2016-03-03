
Web3 = require "web3"
Pudding = require "ether-pudding"
PuddingLoader = require "ether-pudding/loader"

loadContracts = (callback) ->
  contractsDir = './environments/development/contracts'
  contracts = {}

  PuddingLoader.load contractsDir, Pudding, contracts, (err, names) ->
    return callback err if err
    return callback null, contracts

exports.main = main = () ->
  web3 = new Web3()
  Pudding.setWeb3 web3
  p = new Web3.providers.HttpProvider 'http://localhost:8545'
  web3.setProvider p

  seenJobIds = []

  loadContracts (err, contracts) ->
    #agency = contracts.JobAgency.at contracts.JobAgency.address
    agency = contracts.JobAgency.deployed()
    console.log 'JobAgency address:', agency.address

    event = agency.JobPosted()
    event.watch (err, event) ->
      return console.log 'JobPosted error:', err if err
      jobId = event.args.jobId.c[0]

      # Avoid duplicates. Due to multiple confirmations?
      # FIXME: Probably we should wait for a certain number before considering it legit
      if jobId in seenJobIds
        return
      seenJobIds.push jobId
      console.log 'new job posted', err, jobId

      #event.stopWatching()


main() if not module.parent
