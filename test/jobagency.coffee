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

  it 'should start with no jobs', (done) ->
    agency = JobAgency.deployed()
    agency.getLastJobId.call().then (jobid) ->
      assert.equal jobid, 0
    .then(done).catch done

  describe 'postJob() with valid code and inputs', () ->
  
    it 'should accept and update jobid', (done) ->
      agency = JobAgency.deployed()
      agency.postJob(toHex(codeHash), toHex(inputData)).then (tx) ->
        agency.getLastJobId.call().then (jobid) ->
          assert.equal jobid.e, 0
          return done null
      .catch(done)

    it 'should emit JobPosted event', (done) ->
      agency = JobAgency.deployed()
      e = agency.JobPosted()
      e.watch (err, event) ->
        e.stopWatching()
        return done err if err
        assert.equal event.args.jobId, 1
        return done null

      agency.postJob(toHex(codeHash), toHex(inputData)).then (jobid) ->
        #console.log 'posted', jobid
        null # ignored
      .catch(done)

    it 'new Job should have input and code hashes', (done) ->
      agency = JobAgency.deployed()
      agency.getJobData.call(1)
      .then (d) ->
        assert.equal codeHash, toStr(d)
      .then () ->
        return agency.getJobInput.call(1)
      .then (d) ->
        assert.equal inputData, toStr(d)
      .then(done).catch(done)
