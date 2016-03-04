Web3 = require "web3"
Pudding = require "ether-pudding"
PuddingLoader = require "ether-pudding/loader"

ipfs = require './ipfs'

loadContracts = (contractsDir, callback) ->
  contracts = {}
  PuddingLoader.load contractsDir, Pudding, contracts, (err, names) ->
    return callback err if err
    return callback null, contracts

postJob = (code, input, callback) ->
  d = './environments/development/contracts'
  address = '0xcd84121483134aadcc3a3fbe3e5b61e3e9d417fa'

  code = ipfs.toHex code
  input = ipfs.toHex input
  loadContracts d, (err, contracts) ->
    return callback err if err
    agency = contracts.JobAgency.at address
    console.log 'posting new job to', agency.address
    agency.postJob(code, input)
      .nodeify(callback)

exports.main = main = () ->
  web3 = new Web3()
  Pudding.setWeb3 web3
  p = new Web3.providers.HttpProvider 'http://localhost:8545'
  web3.setProvider p
  web3.eth.defaultAccount = '0xd87e1361990ff74489023ff8e086efd649aa629d'

  i = 'QmRY1QfhyADuDYQM2JXa5QR2WHtwdFsCciD5aRkHMck72p'
  c = 'QmRY1QfhyADuDYQM2JXa5QR2WHtwdFsCciD5aRkHMck72p'
  postJob i, c, (err, tx) ->
    throw err if err
    console.log 'posted', tx

main() if not module.parent
