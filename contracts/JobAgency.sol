
contract JobAgency {
  struct Job {
    byte[46] code;
    byte[46] input;
    byte[46] result;
  }

  Job[] jobs;

  event JobPosted(uint jobId);

	function JobAgency() {

	}

  function getLastJobId() returns(uint jobid) {
    return jobs.length;
  }

  function getJobData(uint id) returns(byte[46] code, byte[46] input) {
    var job = jobs[id];
    return (job.code, job.input);
  }

  function getJobCode(uint id) returns(byte[46]) {
    return jobs[id].code;
  }
  function getJobInput(uint id) returns(byte[46]) {
    return jobs[id].input;
  }

  // MAYBE: verify format of IPFS hash? starting with Qm
  // FIXME: keep track of job reward
  // TODO: add some way for clients to filter posted jobs (type etc)
  // Hashes are to be
	function postJob(byte[46] codeHash, byte[46] inputHash)
      returns(uint jobid)
  {
		address poster = msg.sender;

    var job = Job({code: codeHash, input: inputHash, result: inputHash});
    uint jobId = jobs.length;
    jobs.push(job);
    JobPosted(jobId);

    return jobs.length;
	}

}
