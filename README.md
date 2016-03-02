# TheGrid dapp

*Skynet for webdesigners*

![Rise of the Dapp](http://gateway.ipfs.io/ipfs/QmaZDEQB4LrT7CQzEtAfKCDHrqsAgKfdig96QrV7rbNMJw)

## Status

*Pre-proof-of-concept*. See TODO section

**Note: some of this will be moved into its own open source project when we know what the pieces are.**

## Installing

    npm install

## Running

Start Ethereum testing client, with JSON-RPC enabled. 

    ./node_modules/.bin/testrpc

Run tests

    npm test

We use the [truffle](https://github.com/ConsenSys/truffle) framework, accessed wrapper `./truffle` script.
Refer to their documentation for more interesting testcases.

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

* Something which posts jobs to Ethereum (MsgFlo participant?)
* Initial JS interface definition
* Something which listens to jobs on Ethereum JobAgency, and performs them. (MsgFlo participant?)
* Some example application, which has some code+data up on IPFS, uses this to compute things

Solving capable

* Remove database access from Solve worker

Production ready

* Tested a lot on the testnet
* Defined & implemented basic security strategy
* Functional tests of solve outputs
* Integration on apis
* Dial to tune Eth/Heroku work-balance (manual or automated)

## Done

* Initial [Ethereum/Solidity contract](./contracts/JobAgency.sol) for a job agency
* Initial [IPFS components for NoFlo](http://github.com/noflo/noflo-ipfs)

