# JsJob Etereum

*Experiment* in building a computational market on [Ethereum blockchain](https://ethereum.org),
using out-of-chain execution of JavaScript in browser-sandbox using [JsJob](https://github.com/the-grid/jsjob),
and distributed data storage on [IPFS](https://ipfs.io/).

## Motivation

As of 2016, the conventional approach to large-scale, compute-intensive services is:

* Persist data in a relational or NoSQL database
* Farm out compute work using a message broker like RabbitMQ
* Server code exposing an HTTP API
* Clients provide user interface(s) on top of this api
* Deploy it in a private network at some cloud provider

This works, and there exists lots of best-practice around building an maintaining such a service.
However it is a heavily centralized solution, with associated drawbacks.

A primarily decentralized approach may have following benefits:

* Increased robustness from service disruption due to failure in central providers (Heroku/AWS)
* Avoids single actors being able to take service away from users (like a local government and/or ISP).
Service may even be maintained independently of the initial creator.
* Geographical distribution of the service does not require. May give better performance for (some) users
* Potential of cost savings, by enabling small-scale participation with reducing friction.
Some users and volunteers may be willing to take some of the costs, possibly due to improved service quality,
or because they are able to externalize it. Like free/sunk electricity or compute equipment costs.
* Derivative, spin-off and value-add services are more incentivized because of less central control


## Status

**Proof-of-concept**. Can distribute jobs through Ethereum blockchain that can be picked up by workers and executed in browser sandbox.
There is **no reward payments** and **no security** implemented, and only tested on non-production network and data.

* [Ethereum contract](./contracts/JobAgency.sol) is quick&dirty
* Input, code and results are distributed using IPFS
* [dapp webui](./app/javascript/app.coffee) and [nodejs CLI tool](./worker/postjob) can post jobs to agency
* [worker](./src/worker.coffee) can listen for jobs and execute them (in PhantomJS)
* Tested with TestRPC virtual network, and go-ethereum on Morden testnet

See the `TODO` section for milestones and next steps.

## Installing

    npm install

## Developing

Start Ethereum testing client, with JSON-RPC enabled. 

    ./node_modules/.bin/testrpc

Run tests

    npm test

We use the [truffle](https://github.com/ConsenSys/truffle) framework, accessed through wrapper `./truffle` script.
Refer to their documentation for more details on usage.

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

Parts

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

* Add end2end tests
* Add some example application(s),
which has some code+data up on IPFS, uses this to compute things
* Document and publish blogpost(s)

Production ready

* Tested a lot on the testnet
* Defined & implemented basic security strategy
* Integration point for, and existance of, functional tests of results
* A way to tune Ethereum/centralized work-balance (manual or automated)

Distributed ready

* Docker images available, ready-to-run on x86 cloud/home server
* Ready-to-run SD card image for Rasperry Pi
* Worker ready-to-include in browser/mobile applications


## Security

### Threat model

In the case of producing webpages, an attacker returning bad results could for instance:

* Put ads on pages
* Put in obscene content
* Remove some or all content, for censoring or denial-of-service
* Try to steal credentials from host-scoped storage (localstorage)

Attacks can also happen by attacking the contracts themselves.
This could allow to bypass security mechanisms to perform any of the above,
as well as steal the Ether currently in the system.

This means fairly interesting for attackers with finanical, political and fame motivations.


### Potential mechanisms

* Functional verification (tests) of results.
* Trusted workers replicating the work, comparing it.
For some small, randomized portion of the jobs. "ticket control"
* Reputation system. Note, may still be open for [Sybil attack](https://en.wikipedia.org/wiki/Sybil_attack)
* Withholding payout of performed work until a lot of work is verified
* Require a deposit, for punishment in case of bad/contested results.
* User review/approval of output, exposed to visitors
* Not allow executable code (at least not Turing complete) in results.
For websites, maybe [AMP HTML](https://www.ampproject.org/)? Media embedding (iframe, images) is also a vector.


## Related work

* [Ethereum computation market](https://github.com/pipermerriam/ethereum-computation-market)
* [From Smart Contracts to Courts with not so Smart Judges](https://blog.ethereum.org/2016/02/17/smart-contracts-courts-not-smart-judges/).
* [Ethereum and oracles](https://blog.ethereum.org/2014/07/22/ethereum-and-oracles/)

