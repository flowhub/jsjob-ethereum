
// TODO: a better way of doing the IPFS hash than byte[46]?
// does not seem there are any user-defined typedef/aliases in Solidify...
contract JobAgency {
  struct Job {
    byte[46] code;
    byte[46] input;
    byte[46] result;
    bool completed;
  }

  Job[] jobs;

  event JobPosted(uint jobId);
  event JobCompleted(uint jobId);

	function JobAgency() {

	}

  function getLastJobId() returns(int jobid) {
    return int256(jobs.length)-1;
  }

  // XXX: returning a tuple makes the second bytearray filled with 00??
  function getJobCode(uint id) returns(byte[46]) {
    return jobs[id].code;
  }
  function getJobInput(uint id) returns(byte[46]) {
    return jobs[id].input;
  }
  function getJobResult(uint id) returns(byte[46]) {
    var job = jobs[id];
    if (!job.completed) { // precondition
        throw;
    }
    return job.result;
  }

  // MAYBE: verify format of IPFS hash? starting with Qm
  // FIXME: keep track of job reward
  // TODO: add some way for clients tuso filter posted jobs (type etc)
  function postJob(byte[46] codeHash, byte[46] inputHash)
      returns(uint jobid)
  {
    var job = Job({
      code: codeHash,
      input: inputHash,
      result: inputHash, // FIXME: better sentinel/default
      completed: false
    });
    uint jobId = jobs.length;
    jobs.push(job);
    JobPosted(jobId);

    return jobs.length;
	}

  // TODO: support errors and result details/metadata
  // FIXME: actually restrict who/what can be results.
  // Right now first-responder-wins, which is probably not so useful in a trustless environment ;)
  function completeJob(uint id, byte[46] result) {
    var job = jobs[id];
    if (job.completed) { // precondition: can only be completed once:
        throw;
    }
    job.result = result;
    job.completed = true;
    JobCompleted(id);
  }


}
