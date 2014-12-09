#Mesosphere Cluster

Creates a cluster with the mesosphere meta package using the mesosphere deb packages

-zookeeper
-mesos master
-marathon

## Config Options

### Environment variables

```bash
HOSTS #comma delimited, defaults to "localhost"

ZK_SERVER_ID #should be set

ZK_CLIENT_PORT #default 2181
ZK_PEER_PORT #default 2888
ZK_ELECTION_PORT #default 3888

MESOS_CLUSTER #default "mesosphere-cluster"

```

You can also use most mesos config options by passing them in as environment variables with the pefix "MESOS_"


### Starting

docker run -e ZK_SERVER_ID=1 -e HOSTS=ops100,ops110,ops120 -p 2188:2188 -p 2888:3888 -p 3888:3888 -p 5050:5050 -p 8080:8080 -e "MESOS_CLUSTER=factual-mesosphere" --name="mesosphere" mesosphere-cluster

