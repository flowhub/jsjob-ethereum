contract Job {
  byte[46] code;
  byte[46] input;
  byte[46] result;

  function Job(byte[46] codeHash, byte[46] inputHash) {
      code = codeHash;
      input = inputHash;
  }
} 

contract JobAgency {

  address[] jobs; // 'Job' addresses

  event JobPosted(uint jobId, address jobAddress);

	function JobAgency() {

	}

  function getLastJobId() returns(uint jobid) {
    return jobs.length;
  }

  function getJob(uint id) returns(address job) {
    return jobs[id];
  }

  // MAYBE: verify format of IPFS hash? starting with Qm
  // FIXME: keep track of job reward
  // TODO: add some way for clients to filter posted jobs (type etc)
  // Hashes are to be
	function postJob(byte[46] inputHash, byte[46] codeHash)
      returns(uint jobid)
  {
		address poster = msg.sender;

    var job = new Job(codeHash, inputHash);
    address jobAddress = job;
    jobs.push(jobAddress);
    uint jobId = jobs.length;
    JobPosted(jobId, jobAddress);

    return jobs.length;
	}

}
