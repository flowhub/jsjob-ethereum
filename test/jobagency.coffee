contract 'JobAgency', (accounts) ->

  it 'should start with no jobs', (done) ->
    agency = JobAgency.deployed()
    agency.getLastJobId.call().then (jobid) ->
      assert.equal jobid, 0
    .then(done).catch done

  describe 'postJob() with valid code and inputs', () ->
  
    it 'should accept and update jobid', (done) ->
      agency = JobAgency.deployed()
      agency.postJob(10, 11).then (tx) ->
        agency.getLastJobId.call().then (jobid) ->
          assert.equal jobid, 1
          return done null
      .catch(done)

    it 'should emit JobPosted event', (done) ->
      agency = JobAgency.deployed()
      e = agency.JobPosteusd()
      e.watch (err, event) ->
        return done err if err
        assert.equal event.args.jobId, 2
        return done null

      agency.postJob(12, 13).then (jobid) ->
        #console.log 'posted', jobid
        null # ignored
      .catch(done)
