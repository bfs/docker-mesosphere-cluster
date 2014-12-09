FROM ubuntu:14.04

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    apt-get update

RUN apt-get install -y mesosphere supervisor

ADD zoo.cfg /etc/zookeeper/conf/zoo.cfg
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD start_zookeeper.sh /var/lib/mesos/start_zookeeper.sh
ADD start_mesos_master.sh /var/lib/mesos/start_mesos_master.sh
ADD start_marathon.sh /var/lib/mesos/start_marathon.sh

EXPOSE 2181 2888 3888 5050 8080

VOLUME ["/data/zookeeper/"]

ADD setup.sh /var/lib/mesos/setup.sh

ENTRYPOINT ["/var/lib/mesos/setup.sh"]
