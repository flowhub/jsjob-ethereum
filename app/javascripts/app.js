var accounts;
var account;

function setStatus(message) {
  var status = document.getElementById("status");
  status.innerHTML = message;
};

function refreshJobs() {
  var agency = JobAgency.deployed();
  agency.getLastJobId.call({from: account}).then(function(value) {
    var balance_element = document.getElementById("jobs");
    balance_element.innerHTML = value.valueOf();
  }).catch(function(e) {
    console.log(e);
   setStatus("Error getting balance; see log.");
  });
};

function postJob() {
  var agency = JobAgency.deployed();

  var codeHash = parseInt(document.getElementById("codehash").value);
  var inputHash = document.getElementById("inputhash").value;

  setStatus("Starting jobposting transaction... (please wait)");
  agency.postJob(codeHash, inputHash, {from: account}).then(function() {
    setStatus("Job posted!");
    refreshJobs();
  }).catch(function(e) {
    console.log(e);
    console.log(e.stack);
    setStatus("Error sending coin: " + e.message);
  });
};

window.onload = function() {
  web3.eth.getAccounts(function(err, accs) {
    if (err != null) {
      alert("There was an error fetching your accounts.");
      return;
    }

    if (accs.length == 0) {
      alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
      return;
    }

    accounts = accs;
    account = accounts[0];

    refreshJobs();
  });
}
