#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f /var/lib/kroma-node/ee-secret/jwtsecret ]]; then
  echo "Generating JWT secret"
  __secret1=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  __secret2=$(head -c 8 /dev/urandom | od -A n -t u8 | tr -d '[:space:]' | sha256sum | head -c 32)
  echo -n "${__secret1}""${__secret2}" > /var/lib/kroma-node/ee-secret/jwtsecret
fi

if [[ -O "/var/lib/kroma-node/ee-secret/jwtsecret" ]]; then
  chmod 666 /var/lib/kroma-node/ee-secret/jwtsecret
fi

__public_ip="--p2p.advertise.ip $(wget -qO- https://ifconfig.me/ip)"

curl \
  --fail \
  --show-error \
  --silent \
  --retry-connrefused \
  --retry-all-errors \
  --retry 5 \
  --retry-delay 5 \
  https://raw.githubusercontent.com/kroma-network/kroma-up/main/config/${NETWORK}/rollup.json \
  -o /var/lib/kroma-node/config/rollup.json

# Word splitting is desired for the command line parameters
# shellcheck disable=SC2086
exec "$@" ${__public_ip} ${CL_EXTRAS}
