# TheGrid dapp

*Skynet for webdesigners*

![Rise of the Dapp](http://gateway.ipfs.io/ipfs/QmaZDEQB4LrT7CQzEtAfKCDHrqsAgKfdig96QrV7rbNMJw)

## Motivation

A primarily decentralized approach has following benefits

* Increased robustness from service disruption due to failure in central providers (Heroku/AWS)
* Potential of cost savings, by reducing friction in participantion,
and externalizing computational costs to users and volunteers
* Avoids single actors (like a local government and/or ISP) being able to take service away from users

As a AI-based, website producing entity, there are primarily two aspects to decentralize:

* Production of new webpages from content (content analysis, and page solving).
CPU intensive.
* Serving webpages to site visitors.
Bandwidth and disk intensive.

## Status

**Proof-of-concept**. Can distribute jobs through Ethereum blockchain
that can be picked up by workers and executed in browser sandbox

* [Ethereum contract](./contracts/JobAgency.sol) is quick&dirty, absolutely **no security** features
* Input, code and results are distributed using IPFS
* [dapp webui](./app/javascript/app.coffee) and [nodejs CLI tool](./worker/postjob) can post jobs to agency
* [worker](./src/worker.coffee) can listen for jobs and execute them (in PhantomJS)
* Tested with TestRPC virtual network, and go-ethereum on Morden testnet

See TODO section

## Installing

    npm install

## Developing

Start Ethereum testing client, with JSON-RPC enabled. 

    ./node_modules/.bin/testrpc

Run tests

    npm test

We use the [truffle](https://github.com/ConsenSys/truffle) framework, accessed wrapper `./truffle` script.
Refer to their documentation for more interesting testcases.

## Deploying a JobAgency

    ./truffle deploy

## Running a worker

Run an Ethereum node. Make sure `account[0]` is unlocked, that JSON-RPC is enabled.

    geth --rpc --unlock 0xd87e13619....

Run an [IPFS](https://github.com/ipfs/go-ipfs) node, on port 8090
    
    ipfs config Addresses.Gateway /ip4/127.0.0.1/tcp/8090
    ipfs daemon

Run the actual worker. Optionally specify address of the JobAgency to use

    ./bin/worker [0x2f431...]

## Running a job poster

Run an Ethereum node.
Make sure `account[0]` is unlocked, that JSON-RPC is enabled.
For webui CORS also needs to be allowed.

    geth --rpc --unlock 0xd87e13619.... --rpccorsdomain="*"

Serve the webui, then open browser at [http://localhost:8080](http://localhost:8080)

    ./truffle serve

Alternatively, use the CLI tool:

    ./bin/postjob CODEHASH INPUTHASH [JobAgency address]

## Architecture

Components

* Job: input data (IPFS hash), code (IPFS hash, to some JavaScript), result (IPFS hash).
* Agency: Posts new `Job`s, by logging them
* Agent: Subscribed to `Agency`, waiting for new `Job` to perform.

Interactions

* On new `Job`, `Agent` downloads the input and code from IPFS, starts the computation.
* When `Agent` completes a computation done, uploads results to IPFS, then updates the `Job` contract.
The `Job`verifies the result, and assuming it was correct, credits the `Agent`.
* Once in a while (eg weekly or when above N credits), the `Agency` pays out the credits of `Agent`s as Ether.

## TODO

Proof-of-concept

* Add testcases, including one for the "polyfill" feature
* Add some example application(s),
which has some code+data up on IPFS, uses this to compute things
* Document and publish blogpost(s)

Solving capable

* Remove database access from Solve worker
* Port Poly to use the defined worker plugin interface

Production ready

* Tested a lot on the testnet
* Defined & implemented basic security strategy
* Functional tests of solve outputs
* Integration on apis
* Dial to tune Eth/Heroku work-balance (manual or automated)

Distributed ready

* Docker images available, ready-to-run on x86 cloud/home server
* Ready-to-run SD card image for Rasperry Pi
* Worker included in TheGrid client(s)


## Security

`Brainstorming here...`

Attacker returning bad results could

* Put ads on pages
* Put in obscene content
* Remove some or all content, for censoring or denial-of-service
* Try to steal credentials from host-scoped storage (localstorage)

Attacks can also happen by attacking the contracts themselves.
This could allow to bypass security mechanisms to perform any of the above,
as well as steal the Ether currently in the system.

Potential mechanisms

* Functional verification (tests) of results
* Trusted workers replicating the work, comparing it.
For some small, randomized portion of the jobs. "ticket control"
* Reputation system. May still be open for [Sybil attack](https://en.wikipedia.org/wiki/Sybil_attack)
* Require a deposit, for punishment in case of bad/contested results.
* Withholding payout of performed work until a lot of work is verified
* User design review of output, before it goes live


## Related work

* [Ethereum computation market](https://github.com/pipermerriam/ethereum-computation-market)
* [From Smart Contracts to Courts with not so Smart Judges](https://blog.ethereum.org/2016/02/17/smart-contracts-courts-not-smart-judges/).


