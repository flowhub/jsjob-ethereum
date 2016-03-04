codeHash = 'QmVQ8mn19LkEoXpyEBhZEkk9PtD9zeGbJ7JbCei9CFNCbU'
inputData = 'QmYAXgX8ARiriupMQsbGXtKdDyGzWry1YV3sycKw1qqmgH'

ipfs = require '../src/ipfs'
toHex = ipfs.toHex
toStr = ipfs.toStr

contract 'JobAgency', (accounts) ->
  agency = null

  beforeEach () ->
    #agency = JobAgency.at '0xcd84121483134aadcc3a3fbe3e5b61e3e9d417fa'
    agency = JobAgency.deployed()

  it 'should start with no jobs', (done) ->
    console.log 'agency address', agency.address
    agency.getLastJobId.call().then (jobId) ->
      jobId = jobId.toNumber()
      console.log 'initial id', jobId
      assert.equal jobId, -1
    .then(done).catch done

  describe 'postJob() with valid code and inputs', () ->
  
    it 'should accept and update jobid', (done) ->
      agency.postJob(toHex(codeHash), toHex(inputData)).then (tx) ->
        console.log 'accepttest tx', tx
        agency.getLastJobId.call().then (jobId) ->
          jobId = jobId.toNumber()
          console.log 'accepttest id', jobId
          assert.equal jobId, 0
          return done null
      .catch(done)

    it 'should emit JobPosted event', (done) ->
      events = []
      transaction = null

      checkEvents = () ->
        for e in events
            if transaction and e.transactionHash == transaction
                jobId = e?.args?.jobId.toNumber()
                console.log 'eventtest id', jobId
                assert.equal jobId, 1
                done null
                return true
        return false

      e = agency.JobPosted()
      e.watch (err, event) ->
        console.log 'event', err, event?.transactionHash, event?.args?.jobId.toString()
        events.push event
        e.stopWatching() if checkEvents()

      agency.postJob(toHex(codeHash), toHex(inputData)).then (tx) ->
        console.log 'eventtest tx', tx
        transaction = tx
        e.stopWatching() if checkEvents()
      .catch(done)

    it 'new Job should have input and code hashes', (done) ->
      agency.getJobCode.call(1)
      .then (d) ->
        assert.equal codeHash, toStr(d)
      .then () ->
        return agency.getJobInput.call(1)
      .then (d) ->
        assert.equal inputData, toStr(d)
      .then(done).catch(done)

  describe 'completeJob() with a valid jobid and a result', ->
    resultHash = 'QmYAXgX8ARiriupMQsbGXtKdDyGzWry1YV3sycKw1qqmgH'
    completedJobId = 1

    it 'should be accepted and emit JobPosted event', (done) ->
      events = []
      transaction = null

      checkEvents = () ->
        for e in events
            if transaction and e.transactionHash == transaction
                jobId = e?.args?.jobId.toNumber()
                console.log 'completejob id', jobId
                assert.equal jobId, completedJobId
                done null
                return true
        return false

      e = agency.JobCompleted()
      e.watch (err, event) ->
        events.push event
        e.stopWatching() if checkEvents()

      agency.completeJob(completedJobId, ipfs.toHex(resultHash))
      .then (tx) ->
        console.log 'completejob tx', tx
        transaction = tx
        e.stopWatching() if checkEvents()
      .catch(done)

    it 'results should be fetchable', (done) ->
      agency.getJobResult.call(completedJobId)
      .then (d) ->
        assert.equal resultHash, toStr(d)
      .then(done).catch(done)
