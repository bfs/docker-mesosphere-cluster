#!/bin/bash

#default
HOSTS=${HOSTS:-"localhost"}


#read HOSTS into HOSTS_ARRAY
IFS=', ' read -a HOSTS_ARRAY <<< "$HOSTS"


#config paths
ZOOKEEPER_CONF_PATH="/etc/zookeeper/conf"
SUPERVISOR_PATH="/etc/supervisor/conf.d"

#data paths
ZOOKEEPER_DATA_PATH=${ZOOKEEPER_DATA_PATH:-"/data/zookeeper"}
ZOOKEEPER_DATA_LOG_DIR=${ZOOKEEPER_DATA_LOG_DIR:-"/log/zookeeper"}
MESOS_DATA_PATH=${MESOS_DATA_PATH:-"/data/mesos"}

mkdir -p $ZOOKEEPER_DATA_PATH
mkdir -p $ZOOKEEPER_DATA_LOG_DIR
mkdir -p $MESOS_DATA_PATH/log

#-------zookeeper config----------#

ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-"2181"}
ZK_PEER_PORT=${ZK_PEER_PORT:-"2888"}
ZK_ELECTION_PORT=${ZK_ELECTION_PORT:-"3888"}

export MESOS_CLUSTER=${MESOS_CLUSTER:-"mesosphere-cluster"}

echo $ZK_SERVER_ID > $ZOOKEEPER_CONF_PATH/myid
cp $ZOOKEEPER_CONF_PATH/myid $ZOOKEEPER_DATA_PATH/myid

echo "dataDir=$ZOOKEEPER_DATA_PATH" >> $ZOOKEEPER_CONF_PATH/zoo.cfg
echo "dataLogDir=$ZOOKEEPER_DATA_LOG_DIR" >> $ZOOKEEPER_CONF_PATH/zoo.cfg



echo "clientPort=$ZK_CLIENT_PORT" >> $ZOOKEEPER_CONF_PATH/zoo.cfg
for i in "${!HOSTS_ARRAY[@]}"; do 
  echo "server.$(($i+1))=${HOSTS_ARRAY[$i]}:$ZK_PEER_PORT:$ZK_ELECTION_PORT" >> $ZOOKEEPER_CONF_PATH/zoo.cfg
done

#----------------------------------#

#--------mesos config--------------#

#output should look like zk://host1:port,host2:port,host3:port/mesos
ZK_URI="zk://"$(printf "%s:$ZK_CLIENT_PORT," "${HOSTS_ARRAY[@]}" | cut -d "," -f 1-${#HOSTS_ARRAY[@]} )""

export MESOS_ZK="$ZK_URI/mesos"
export MESOS_WORK_DIR="$MESOS_DATA_PATH"
export MESOS_LOG_DIR="$MESOS_DATA_PATH/log"

#compute and set zk quorum
NUM_HOSTS=${#HOSTS_ARRAY[@]}
COMPUTED_QUORUM=$(echo NUM_HOSTS | awk '{printf "%i \n", (($1/2) + 1)}')
export MESOS_QUORUM=${MESOS_QUORUM:-$COMPUTED_QUORUM}

#----------------------------------#


#--------marathon config-----------#

MARATHON_ZK="$ZK_URI/marathon"

#append config to run script
printf " --zk $MARATHON_ZK --master $MESOS_ZK " >>  /var/lib/mesos/start_marathon.sh

#----------------------------------#

#now we start everything
supervisord --nodaemon -c /etc/supervisor/supervisord.conf
#----------------------------------#



