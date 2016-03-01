# TheGrid dapp

*Skynet for webdesigners*

![Rise of the Dapp](http://gateway.ipfs.io/ipfs/QmaZDEQB4LrT7CQzEtAfKCDHrqsAgKfdig96QrV7rbNMJw)

## Status

**Note: some of this will be moved into its own open source project when we know what the pieces are.**

## Installing

Download and install [go-ethereum](https://github.com/ethereum/go-ethereum).

    npm install

## Running

Start an Ethereum client, with JSON-RCP enabled. 

    geth --rpc --fast

Run tests

    ./truffle test

## Architecture

Contracts

* Job: input data (IPFS hash), code (IPFS hash, to some JavaScript), result (IPFS hash).
* Agency: Posts new `Job`s, by logging them
* Agent: Subscribed to `Agency`, waiting for new `Job` to perform.

Interactions

* On new `Job`, `Agent` downloads the input and code from IPFS, starts the computation.
* When `Agent` completes a computation done, uploads results to IPFS, then updates the `Job` contract.
The `Job`verifies the result, and assuming it was correct, credits the `Agent`.
* Once in a while (eg weekly or when above N credits), the `Agency` pays out the credits of `Agent`s as Ether.
