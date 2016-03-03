
Web3 = require "web3"
Pudding = require "ether-pudding"
PuddingLoader = require "ether-pudding/loader"

Runner = require './runner'

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


  subscribeJobsEvent = (agency, callback) ->
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
      return callback null, jobId

    return event

  runner = new Runner {}
  runner.start (err) ->
    throw err if err
    loadContracts (err, contracts) ->
      throw err if err

      agency = contracts.JobAgency.deployed()
      console.log 'JobAgency address:', agency.address
      event = subscribeJobsEvent agency, (err, job) ->
        console.log 'new job', err, job
        throw err if err
        
        codeUrl = 'http://localhost:8080/build/plugin.js'
        inputData = {}
        jobOptions = {}
        runner.performJob codeUrl, inputData, jobOptions, (err, j) ->
          console.log 'js job', err, j

      #event.stopWatching()

main() if not module.parent
