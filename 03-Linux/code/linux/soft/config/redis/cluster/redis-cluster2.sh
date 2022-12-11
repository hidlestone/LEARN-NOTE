#!/usr/bin/env bash

# Settings
HOST="172.22.6.3"
PORT=7000
TIMEOUT=2000
NODES=12
REPLICAS=1
ENDPORT=$((PORT+NODES))

# You may want to put the above config parameters into config.sh in order to
# override the defaults without modifying this script.

if [[ -a config.sh ]]
then
    source "config.sh"
fi

if [[ "$1" == "create" ]]
then
    HOSTLIST=""
    while [[ $((PORT < ENDPORT)) != "0" ]]; do
        PORT=$((PORT+1))
        HOSTLIST="$HOSTLIST $HOST:$PORT"
    done
    /opt/redis/src/redis-cli --cluster create ${HOSTLIST} --cluster-replicas ${REPLICAS}
    exit 0
fi

if [[ "$1" == "start" ]]
then
    while [[ $((PORT < ENDPORT)) != "0" ]]; do
        PORT=$((PORT+1))
        echo "Starting $PORT"
        /opt/redis/src/redis-server /usr/local/redis/conf/${PORT}/redis.conf
    done
    exit 0
fi

if [[ "$1" == "stop" ]]
then
    while [[ $((PORT < ENDPORT)) != "0" ]]; do
        PORT=$((PORT+1))
        echo "Stopping $PORT"
        /opt/redis/src/redis-cli -p ${PORT} shutdown nosave
    done
    exit 0
fi

if [[ "$1" == "watch" ]]
then
    PORT=$((PORT+1))
    while [ 1 ]; do
        clear
        date
        /opt/redis/src/redis-cli -p ${PORT} cluster nodes | head -30
        sleep 1
    done
    exit 0
fi

if [[ "$1" == "tail" ]]
then
    INSTANCE=$2
    PORT=$((PORT+INSTANCE))
    tail -f ${PORT}.log
    exit 0
fi

if [[ "$1" == "call" ]]
then
    while [[ $((PORT < ENDPORT)) != "0" ]]; do
        PORT=$((PORT+1))
        /opt/redis/src/redis-cli -p ${PORT} $2 $3 $4 $5 $6 $7 $8 $9
    done
    exit 0
fi

if [[ "$1" == "clean" ]]
then
    rm -rf *.log
    rm -rf appendonly*.aof
    rm -rf dump*.rdb
    rm -rf nodes*.conf
    exit 0
fi

if [[ "$1" == "clean-logs" ]]
then
    rm -rf *.log
    exit 0
fi

echo "Usage: $0 [start|create|stop|watch|tail|clean]"
echo "start       -- Launch Redis Cluster instances."
echo "create      -- Create a cluster using redis-cli --cluster create."
echo "stop        -- Stop Redis Cluster instances."
echo "watch       -- Show CLUSTER NODES output (first 30 lines) of first node."
echo "tail <id>   -- Run tail -f of instance at base port + ID."
echo "clean       -- Remove all instances data, logs, configs."
echo "clean-logs  -- Remove just instances logs."
