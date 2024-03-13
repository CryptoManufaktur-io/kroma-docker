#!/bin/bash
# Rollback script for chain failure encountered 2024-03-12
set -e

SNAPSHOT_ORIGIN=https://snapshot.kroma.network/rollback/snapshot.tar.gz
KROMA_DB_PATH=/var/lib/kroma-geth/geth
SNAPSHOT_PATH=.snapshot_rollback

mkdir -p ${SNAPSHOT_PATH}
wget -P ./${SNAPSHOT_PATH} ${SNAPSHOT_ORIGIN}
tar xvzf ${SNAPSHOT_PATH}/snapshot.tar.gz -C ${SNAPSHOT_PATH}/
rm -rf ${SNAPSHOT_PATH}/snapshot.tar.gz ${SNAPSHOT_PATH}/nodekey

docker compose stop kroma-node

docker compose exec -it kroma-geth sh -c "mv ${KROMA_DB_PATH}/nodekey ../nodekey"
docker compose exec -it kroma-geth sh -c "rm -rf ${KROMA_DB_PATH}/*"
docker compose exec -it kroma-geth sh -c "mv ../nodekey ${KROMA_DB_PATH}/nodekey"

docker compose cp ${SNAPSHOT_PATH}/. kroma-geth:${KROMA_DB_PATH}/
rm -rf ${SNAPSHOT_PATH}

docker compose restart kroma-geth
sleep 5
docker compose start kroma-node
