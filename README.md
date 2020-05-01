# README
## Introduction
This README contains description of the examples how to build and configure a validator node in `net.ton.dev` blockchain. The instructions and scripts below were verified on Ubuntu 18.04.
## Getting Started
### Prerequisites
#### System Requirements
| Configuration | CPU (cores) | RAM (GiB) | Storage (GiB) | Network (Gbit/s)|
|---|:---|:---|:---|:---|
| Minimal |2|8|1000|1|
| Recommended |16|32|1000|1| 
## Instructions
### 1. Build Node
Adjust (if needed) `net.ton.dev/scripts/env.sh`

Build a node:

    $ cd net.ton.dev/scripts/ && ./build.sh
### 2. Setup Node
Initialize a node:

    $ cd net.ton.dev/scripts/ && ./setup.sh
### 3. Run Node
Run the node:

    $ cd net.ton.dev/scripts/ && ./run.sh
  
  Wait until the node is synced with the masterchain. Depending on network throughput this step may take significant time (up to several hours).
  
### 4. Initialize Multisig Wallet

Multisig wallet is used in validator script to send election requests to the Elector smart contract.

See [multisig documentation](https://www.notion.so/tonlabs/TON-OS-CLI-Tails-13e2279e8d4743689f7a6bdecfaff5f7) 
about how to initialize and deploy multisig using tonos-cli.

Important: use `msig.keys.json` filename when you call 

    tonlabs-cli genaddr ... --genkey msig.keys.json
    
command to generate Multisig address. Take public key from this file as a **custodian key** when you will deploy Multisig.

Put `msig.keys.json` file near `validator.sh` script.

### 6. Run Validator

Define env variable `stake` equal to amount of validator stake in tokens. This amount of tokens will be sent by multisig to Elector smart contract in every validation cycle. Otherwise script will use a hardcoded value (see `stake_hardcoded` v  ar).

Run the validator script (each 60 sec.), specify a validator name as first argument: 

    $ cd net.ton.dev/scripts/
    $ watch -n 60 ./validator.sh ${VALIDATOR_NAME} >> ./validator.log 2>&1

## How validator script works

Script runs every minute.

1. Makes an initial check for masterchain.
2. Checks startup time.
3. Gets address of elector contract and read `election_id` from elector contract.
4. Reads config param -32 from blockchain. // нафига?
5. If `election_id` == 0 (that means no validator elections at the moment):
    1. script requests size of validator stake that can be returned from elector. (by running Elector's `compute_returned_stake` get-method). Returned value will not be 0 if validator won previous elections and was a validator. 
    2. If this value != 0 script submits new transaction in multisig to Elector contract with 1 token and `recover-stake` payload. 
    3. If request to multisig is succeeded script exctracts `transactionId` and prints it to terminal. 
    4. Other multisig custodians should confirm transaction using this Id. Then script exits.
6. If `election_id` != 0 (that means it's time to participate in elections):
    1. script checks wallet's balance //TODO: тут у нас косяк, надо править скрипт
    2. Checks if `stop-election` file exists then exits.
    3. Checks if file `active-election-id` exits. If yes, reads `active_election_id`
    from it and compares it to `election_id`. IF they are equal then exits.
    This means that validator is already sent its stake to Elector in current elctions.
    4. Calls `validator-engine-console` to generate new validator key and adnl address.
    5. Reads config param 15 to get election timeouts.
    6. Runs `validator-elect-req.fif` fift script to generate unsigned validator election request.
    7. Calls `validator-engine-console` to sign election request with newly generated validator keypair.
    8. Submits new transaction in multisig to Elector contract with `$stake` amount of tokens and `process_new_stake` payload.
    9. If request to multisig is succeeded script exctracts `transactionId` and prints it to terminal.
    10. Other multisig custodians should confirm transaction using this Id. When multisig will accumulate required number of confirmations then it sends validator election request to Elector.




