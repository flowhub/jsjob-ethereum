Web3 = require "web3"
Pudding = require "ether-pudding"
PuddingLoader = require "ether-pudding/loader"

ipfs = require './ipfs'

loadContracts = (contractsDir, callback) ->
  contracts = {}
  PuddingLoader.load contractsDir, Pudding, contracts, (err, names) ->
    return callback err if err
    return callback null, contracts

postJob = (address, code, input, callback) ->
  d = './environments/development/contracts'

  code = ipfs.toHex code
  input = ipfs.toHex input
  loadContracts d, (err, contracts) ->
    return callback err if err
    address = contracts.JobAgency.address if not address # deployed 
    agency = contracts.JobAgency.at address
    console.log 'posting new job to', agency.address
    agency.postJob(code, input)
      .nodeify(callback)

exports.main = main = () ->
  try
    [_node, prog, codeHash, inputHash] = process.argv
    agencyAddress = process.argv[4]
  catch e

  if not codeHash or not inputHash
    console.log 'Missing arguments'
    console.log "Usage: #{prog} codehash inputhash [agency]"
    process.exit 1

  web3 = new Web3()
  Pudding.setWeb3 web3
  p = new Web3.providers.HttpProvider 'http://localhost:8545'
  web3.setProvider p

  web3.eth.getAccounts (err, accs) ->
    Pudding.defaults({
      from: accs[0],
      gas: 3141592 # XXX: if this is not sent then we run out of gas??
    })

    postJob agencyAddress, codeHash, inputHash, (err, tx) ->
      throw err if err
      console.log 'posted', tx

main() if not module.parent
