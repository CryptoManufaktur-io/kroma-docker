# Overview

Docker Compose for Kroma RPC node

`cp default.env .env`, then `nano .env` and adjust values for the right network including snapshot and bootnodes.

Meant to be used with [central-proxy-docker](https://github.com/CryptoManufaktur-io/central-proxy-docker) for traefik
and Prometheus remote write; use `:ext-network.yml` in `COMPOSE_FILE` inside `.env` in that case.

If you want the kroma-geth RPC ports exposed locally, use `rpc-shared.yml` in `COMPOSE_FILE` inside `.env`.

The `./kromad` script can be used as a quick-start:

`./kromad install` brings in docker-ce, if you don't have Docker installed already.

`cp default.env .env`

`nano .env` and adjust variables as needed, particularly `NETWORK`, `SNAPSHOT`, `GETH_BOOT_NODES` and `NODE_BOOT_NODES`,
as well as `L1_RPC` and `L1_RPC_KIND`.

`./kromad up`

To update the software, run `./kromad update` and then `./kromad up`

This is Kroma Docker v3.1.0
