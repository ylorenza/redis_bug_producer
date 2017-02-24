#!/bin/bash

CLUSTER_LOCAL_DIR="."
export PATH="${CLUSTER_LOCAL_DIR}/bin/3.2.6/:$PATH"

REDIS_HOST="127.0.0.1"
IP_LIST="${REDIS_HOST}:10000 ${REDIS_HOST}:10001 ${REDIS_HOST}:10002 ${REDIS_HOST}:10003 ${REDIS_HOST}:10004 ${REDIS_HOST}:10005"


for i in $(ls ${CLUSTER_LOCAL_DIR}/config/redis_100*.conf)
do
	redis-server "$i" &
done


for ipport in ${IP_LIST}
do
        ip="$( echo ${ipport} | cut -d \: -f 1 )"
        port="$(echo ${ipport} | cut -d \: -f 2)"
        redis-cli -h ${ip} -p ${port} PING
        # Remove all keys
        redis-cli -h ${ip} -p ${port} FLUSHALL
        # Reset cluster data, we can use this redis for a new cluster
        redis-cli -h ${ip} -p ${port} CLUSTER RESET HARD
done

echo "redis-trib.rb create --replicas 1  ${IP_LIST}"
echo "yes" | redis-trib.rb create --replicas 1  ${IP_LIST}
