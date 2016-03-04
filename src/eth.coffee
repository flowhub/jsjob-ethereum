
Promise = require 'bluebird'

# From http://ethereum.stackexchange.com/questions/1181/how-do-i-know-when-ive-run-out-of-gas
exports.awaitConsensus = (web3, txhash, gasSent, callback) ->
  deferred = Promise.pending();  

  filter = web3.eth.filter 'latest'
  filter.watch (error, result) ->
    # this callback is called multiple times, so can't promise-then it
    web3.eth.getTransactionReceiptAsync(txhash)
    .then (receipt) ->
      # XXX should probably only wait max 2 events before failing XXX 
      if receipt and receipt.transactionHash == txhash
        filter.stopWatching()
        # NOTE: corner case of gasUsed == gasSent.
        # It could mean used EXACTLY that amount of gas and succeeded.
        # This is a limitation of ethereum as of Feb 2016. Hopefully they fix it
        if receipt.gasUsed >= gasSent
          deferred.reject new Error "Transaction #{txhas} ran out of gas, likely failed!"
        deferred.resolve receipt
