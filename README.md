#Mesosphere Cluster

Creates a cluster with the mesosphere meta package using the mesosphere deb packages.  This is meant for ease of testing, but since running multiple services inside a container is not the "docker way", in production, you should probably use separate Docker containers for each of the services below.

* zookeeper
* mesos master
* marathon

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


```bash
docker run --net=host --publish-all=true -e ZK_SERVER_ID=1 -e HOSTS=pet110,pet110,pet120 -e MESOS_CLUSTER=factual-mesosphere --name=mesosphere -v /data/zookeeper boritzio/docker-mesosphere-cluster
```
