contract 'MetaCoin', (accounts) ->
  it 'should put 10000 MetaCoin in the first account', (done) ->
    meta = MetaCoin.deployed()
    meta.getBalance.call(accounts[0]).then((balance) ->
      assert.equal balance.valueOf(), 10000, '10000 wasn\'t in the first account'
    ).then(done).catch done

  it 'should send coin correctly', (done) ->
    meta = MetaCoin.deployed()
    # Get initial balances of first and second account.
    account_one = accounts[0]
    account_two = accounts[1]
    account_one_starting_balance = undefined
    account_two_starting_balance = undefined
    account_one_ending_balance = undefined
    account_two_ending_balance = undefined
    amount = 10
    meta.getBalance.call(account_one).then((balance) ->
      account_one_starting_balance = balance.toNumber()
      meta.getBalance.call account_two
    ).then((balance) ->
      account_two_starting_balance = balance.toNumber()
      meta.sendCoin account_two, amount, from: account_one
    ).then(->
      meta.getBalance.call account_one
    ).then((balance) ->
      account_one_ending_balance = balance.toNumber()
      meta.getBalance.call account_two
    ).then((balance) ->
      account_two_ending_balance = balance.toNumber()
      assert.equal account_one_ending_balance, account_one_starting_balance - amount, 'Amount wasn\'t correctly taken from the sender'
      assert.equal account_two_ending_balance, account_two_starting_balance + amount, 'Amount wasn\'t correctly sent to the receiver'
    ).then(done).catch done
