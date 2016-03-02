codeHash = 'QmVQ8mn19LkEoXpyEBhZEkk9PtD9zeGbJ7JbCei9CFNCbU'
inputData = 'QmYAXgX8ARiriupMQsbGXtKdDyGzWry1YV3sycKw1qqmgH'
#console.log 'l', codeHash.length, inputData.length

contract 'JobAgency', (accounts) ->

  it 'should start with no jobs', (done) ->
    agency = JobAgency.deployed()
    agency.getLastJobId.call().then (jobid) ->
      assert.equal jobid, 0
    .then(done).catch done

  describe 'postJob() with valid code and inputs', () ->
  
    it 'should accept and update jobid', (done) ->
      agency = JobAgency.deployed()
      agency.postJob(codeHash, inputData).then (tx) ->
        agency.getLastJobId.call().then (jobid) ->
          assert.equal jobid, 1
          return done null
      .catch(done)

    it 'should emit JobPosted event', (done) ->
      agency = JobAgency.deployed()
      e = agency.JobPosted()
      e.watch (err, event) ->
        return done err if err
        console.log event.args
        assert.equal event.args.jobId, 2
        return done null

      agency.postJob(codeHash, inputData).then (jobid) ->
        #console.log 'posted', jobid
        null # ignored
      .catch(done)
