#!/bin/bash

#default
HOSTS=${HOSTS:-"localhost"}


#read HOSTS into HOSTS_ARRAY
IFS=', ' read -a HOSTS_ARRAY <<< "$HOSTS"


#config paths
ZOOKEER_CONF_PATH="/etc/zookeeper/conf"
SUPERVISOR_PATH="/etc/supervisor/conf.d"

#-------zookeeper config----------#

ZK_CLIENT_PORT=${ZK_CLIENT_PORT:-"2181"}
ZK_PEER_PORT=${ZK_PEER_PORT:-"2888"}
ZK_ELECTION_PORT=${ZK_ELECTION_PORT:-"3888"}

MESOS_CLUSTER=${MESOS_CLUSTER:-"mesosphere-cluster"}

echo $ZK_SERVER_ID > /data/zookeeper/myid

echo "clientPort=$ZK_CLIENT_PORT" >> $ZOOKEER_CONF_PATH/zoo.cfg
for i in "${!HOSTS_ARRAY[@]}"; do 
  echo "server.$(($i+1))=${HOSTS_ARRAY[$i]}:$ZK_PEER_PORT:$ZK_ELECTION_PORT" >> $ZOOKEER_CONF_PATH/zoo.cfg
done

#----------------------------------#

#--------mesos config--------------#

#output should look like zk://host1:port,host2:port,host3:port/mesos
ZK_URI="zk://"$(printf "%s:$ZK_CLIENT_PORT," "${HOSTS_ARRAY[@]}" | cut -d "," -f 1-${#HOSTS_ARRAY[@]} )""

MESOS_ZK="$ZK_URI/mesos"

#compute and set zk quorum
NUM_HOSTS=${#HOSTS_ARRAY[@]}
COMPUTED_QUORUM=$(echo NUM_HOSTS | awk '{printf "%i \n", (($1/2) + 1)}')

MESOS_QUORUM=${MESOS_QUORUM:-$COMPUTED_QUORUM}

#----------------------------------#


#--------marathon config-----------#

MARATHON_ZK="$ZK_URI/marathon"

#append config to run script
printf " --zk $MARATHON_ZK --master $MESOS_ZK " >>  /var/lib/mesos/start_marathon.sh

#----------------------------------#


#now we start everything
supervisord --nodaemon -c /etc/supervisor/supervisord.conf
#----------------------------------#



