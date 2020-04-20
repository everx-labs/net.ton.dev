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
  
### 4. Create Wallet
Create a wallet:

    $ cd net.ton.dev/scripts/ && ./create_wallet.sh
    
  Details about just created wallet will be available at `~/ton-keys/$(hostname -s)-dump`

### 5. Deploy Wallet
Deploy the wallet (the node should be in sync with the masterchain):

    $ cd net.ton.dev/scripts/ && ./deploy_wallet.sh

### 6. Run Validator
Run the validator script (each 60 sec.), specify a validator stake as first argument (default: 100000):

    $ cd net.ton.dev/scripts/
    $ watch -n 60 ./validator.sh 50000 >> ./validator.log 2>&1
