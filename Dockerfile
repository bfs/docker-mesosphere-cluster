FROM boritzio/docker-mesosphere-base
RUN apt-get install -y supervisor

ADD zoo.cfg /etc/zookeeper/conf/zoo.cfg
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD start_zookeeper.sh /var/lib/mesos/start_zookeeper.sh
ADD start_mesos_master.sh /var/lib/mesos/start_mesos_master.sh
ADD start_marathon.sh /var/lib/mesos/start_marathon.sh

EXPOSE 2181 2888 3888 5050 8080

VOLUME ["/data/zookeeper","/data/mesos", "/log/zookeeper"]

ADD setup.sh /var/lib/mesos/setup.sh

ENTRYPOINT ["/var/lib/mesos/setup.sh"]
