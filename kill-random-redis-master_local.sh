#!/bin/bash

CLUSTER_LOCAL_DIR="."
export PATH="${CLUSTER_LOCAL_DIR}/bin/3.2.6:$PATH"


HOST="127.0.0.1"

get_available_node() {
	for port in $(seq 10000 10005)
	do
		if nc -z $HOST ${port} >/dev/null 2>&1; then
			echo $port
			break
		fi
	done
}


kill_master() {
	redis_port=$(get_available_node)
	random_master_port=$(redis-cli -h $HOST -p ${redis_port} cluster nodes | grep master | sort -R | head -1 | awk '{ print $2 }' | cut -d : -f 2)
	echo "kill $HOST:$random_master_port"
	redis-cli -h $HOST -p ${random_master_port} debug segfault
}


while true
do
	kill_master
	sleep 15
	echo "relaunch node"
	${CLUSTER_LOCAL_DIR}/launch_cluster.sh
	sleep 10

done





