contract JobAgency {
  // TODO: maybe keep track of jobs?
  uint lastJob;

  event JobPosted(uint jobId);

	function JobAgency() {
		lastJob = 0;
	}

  function getLastJobId() returns(uint jobid) {
    return lastJob;
  }

  // FIXME: use proper datatype for the IPFS hashes. array[48] ?
	function postJob(uint input, uint code) returns(uint jobid) {
		address poster = msg.sender;
    lastJob += 1;
    JobPosted(lastJob);
    return lastJob;
	}
}
