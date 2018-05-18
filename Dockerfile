FROM centos:7

MAINTAINER Nico Villanueva <barbas@redbee.io>

RUN yum update -y && \
    yum install -y java-1.8.0-openjdk-headless && \
    yum clean all

# TODO: remove
#COPY caches/.ivy2/ /root/.ivy2/
#COPY caches/.sbt/ /root/.sbt/

RUN yum install -y java-1.8.0-openjdk-devel git wget unzip which && \
    mkdir -p /tmp && \
    cd /tmp && \
    git clone https://github.com/yahoo/kafka-manager --depth 1 && \
    cd /tmp/kafka-manager && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist

# ----

FROM java:openjdk-8-jre
ENV KM_VERSION=1.3.3.17 \
    KM_CONFIGFILE="conf/application.conf"
WORKDIR /kafka-manager-${KM_VERSION}/
COPY --from=0 /tmp/kafka-manager/target/universal/kafka-manager-${KM_VERSION}.zip /tmp/
COPY start-kafka-manager.sh /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
RUN apt-get update && apt-get install -y unzip zookeeper && \
    unzip -d / /tmp/kafka-manager-${KM_VERSION}.zip && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod +x /kafka-manager-${KM_VERSION}/start-kafka-manager.sh
EXPOSE 9000
ENTRYPOINT ["./start-kafka-manager.sh"]
