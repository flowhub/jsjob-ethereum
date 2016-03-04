codeHash = 'QmVQ8mn19LkEoXpyEBhZEkk9PtD9zeGbJ7JbCei9CFNCbU'
inputData = 'QmYAXgX8ARiriupMQsbGXtKdDyGzWry1YV3sycKw1qqmgH'

toHex = (str) ->
  a = []
  for c in str
    h = c.charCodeAt(0)
    h = "0x"+h.toString(16)
    a.push h
  return a
toStr = (arr) ->
  return (String.fromCharCode(parseInt(i, 16)) for i in arr).join('')

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
