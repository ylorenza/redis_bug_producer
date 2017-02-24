#!/bin/bash

CLUSTER_LOCAL_DIR="."
export PATH="${CLUSTER_LOCAL_DIR}/bin/3.2.6:$PATH"

for i in $(ls ${CLUSTER_LOCAL_DIR}/config/redis_100*.conf)
do
    redis-server "$i" &
done
