#!/bin/bash -eE

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

if [ "${INSTALL_DEPENDENCIES}" = "yes" ]; then
    if ! sudo -V >/dev/null ; then
        echo "Looks like sudo is not installed. You need to install it to proceed with dependencies installation"
        exit 0
    fi
    echo "INFO: install dependencies..."
    sudo apt update && sudo apt -y install \
        build-essential \
        git \
        cargo \
        ccache \
        cmake \
        curl \
        gawk \
        gcc \
        gperf \
        g++ \
        jq \
        libgflags-dev \
        libmicrohttpd-dev \
        libreadline-dev \
        libssl-dev \
        libz-dev \
        ninja-build \
        pkg-config \
        zlib1g-dev
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    #shellcheck source=$HOME/.cargo/env
    . "$HOME/.cargo/env"
    rustup update
    echo "INFO: install dependencies... DONE"
fi

if [ -d "${TON_SRC_DIR}" ]; then
    echo "ERROR: ${TON_SRC_DIR} exists, remove it (if needed) before new node build"
    exit 1
fi

echo "INFO: clone ${TON_GITHUB_REPO} (${TON_STABLE_GITHUB_COMMIT_ID})..."
git clone --recursive "${TON_GITHUB_REPO}" "${TON_SRC_DIR}"
cd "${TON_SRC_DIR}" && git checkout "${TON_STABLE_GITHUB_COMMIT_ID}"
echo "INFO: clone ${TON_GITHUB_REPO} (${TON_STABLE_GITHUB_COMMIT_ID})... DONE"

echo "INFO: build a node..."
mkdir -p "${TON_BUILD_DIR}"
cd "${TON_BUILD_DIR}"
#cmake -DCMAKE_BUILD_TYPE=Release ..
#cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
#cmake --build .
#cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo -DPORTABLE=ON
cmake .. -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DPORTABLE=ON
ninja
echo "INFO: build a node... DONE"

echo "INFO: build utils (convert_address)..."
cd "${NET_TON_DEV_SRC_TOP_DIR}/utils/convert_address"
cargo update
cargo build --release
cp "${NET_TON_DEV_SRC_TOP_DIR}/utils/convert_address/target/release/convert_address" "${UTILS_DIR}/"
echo "INFO: build utils (convert_address)... DONE"

echo "INFO: build utils (tonos-cli)..."
if [ -d "${TONOS_CLI_SRC_DIR}" ]; then
    echo "ERROR: ${TONOS_CLI_SRC_DIR} exists, remove it (if needed) before new node build"
    exit 1
fi
git clone https://github.com/tonlabs/tonos-cli.git "${TONOS_CLI_SRC_DIR}"
cd "${TONOS_CLI_SRC_DIR}"
cargo update
cargo build --release
cp "${TONOS_CLI_SRC_DIR}/target/release/tonos-cli" "${UTILS_DIR}/"
echo "INFO: build utils (tonos-cli)... DONE"

rm -rf "${NET_TON_DEV_SRC_TOP_DIR}/ton-labs-contracts"
git clone https://github.com/tonlabs/ton-labs-contracts.git "${NET_TON_DEV_SRC_TOP_DIR}/ton-labs-contracts"
rm -f "${CONFIGS_DIR}/SafeMultisigWallet.tvc"
rm -f "${CONFIGS_DIR}/SafeMultisigWallet.abi.json"
cp "${NET_TON_DEV_SRC_TOP_DIR}/ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.tvc" "${CONFIGS_DIR}"
cp "${NET_TON_DEV_SRC_TOP_DIR}/ton-labs-contracts/solidity/safemultisig/SafeMultisigWallet.abi.json" "${CONFIGS_DIR}"
