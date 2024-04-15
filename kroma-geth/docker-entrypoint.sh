#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /var/lib/kroma-geth/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/kroma-geth/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/kroma-geth/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/kroma-geth/ee-secret/jwtsecret
fi

# Set verbosity
shopt -s nocasematch
case ${LOG_LEVEL} in
  error)
    __verbosity="--verbosity 1"
    ;;
  warn)
    __verbosity="--verbosity 2"
    ;;
  info)
    __verbosity="--verbosity 3"
    ;;
  debug)
    __verbosity="--verbosity 4"
    ;;
  trace)
    __verbosity="--verbosity 5"
    ;;
  *)
    echo "LOG_LEVEL ${LOG_LEVEL} not recognized"
    __verbosity=""
    ;;
esac

# Prep datadir
if [ -n "${SNAPSHOT}" ] && [ ! -d "/var/lib/kroma-geth/geth/chaindata" ]; then
  mkdir -p /var/lib/kroma-geth/snapshot
  mkdir -p /var/lib/kroma-geth/geth
  cd /var/lib/kroma-geth/snapshot
  aria2c -c -x6 -s6 --auto-file-renaming=false --conditional-get=true --allow-overwrite=true "${SNAPSHOT}"
  filename=$(echo "${SNAPSHOT}" | awk -F/ '{print $NF}')
  tar xzvf "${filename}" -C /var/lib/kroma-geth/geth
  rm -f "${filename}"
fi

if [ ! -d /var/lib/kroma-geth/geth/chaindata ]; then
  echo "Initializing from genesis."
  curl \
    --fail \
    --show-error \
    --silent \
    --retry-connrefused \
    --retry-all-errors \
    --retry 5 \
    --retry-delay 5 \
    "https://raw.githubusercontent.com/kroma-network/kroma-up/main/config/${NETWORK}/genesis.json" \
    -o /var/lib/kroma-geth/config/genesis.json

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  geth ${__verbosity} init --datadir=/var/lib/kroma-geth /var/lib/kroma-geth/config/genesis.json
fi

case "${NETWORK}" in
    mainnet) __chainid="--networkid 255";;
    sepolia) __chainid="--networkid 2358";;
    *) echo "Unsupported network ${NETWORK}, aborting."; exit 1;;
esac

if [ -f /var/lib/kroma-geth/prune-marker ]; then
  rm -f /var/lib/kroma-geth/prune-marker
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec ${__chainid} "$@" snapshot prune-state
else
# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
  exec "$@" ${__chainid} ${__verbosity} ${EL_EXTRAS}
fi
