FROM centos:latest
MAINTAINER flyceek "flyceek@gmail.com"

ARG NACOS_WORKDIR=/opt/soft/nacos/
ARG NACOS_VERSION=0.5.0
ARG NACOS_FILE_NAME=nacos-server-${NACOS_VERSION}.tar.gz
ARG NACOS_FILE_EXTRACT_DIR=nacos-server-${NACOS_VERSION}
ARG NACOS_HOME=${NACOS_WORKDIR}/${NACOS_FILE_EXTRACT_DIR}
ARG NACOS_FILE_URL=https://github.com/alibaba/nacos/releases/download/${NACOS_VERSION}/${NACOS_FILE_NAME}

ENV MODE=cluster
ENV PREFER_HOST_MODE=ip
ENV CLASSPATH=.:${NACOS_HOME}/conf:$CLASSPATH
ENV CLUSTER_CONF=${NACOS_HOME}/conf/cluster.conf
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
ENV JAVA=/usr/lib/jvm/java-1.8.0-openjdk/bin/java

RUN yum update -y \
    && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel wget iputils nc tzdata vim libcurl\
    && mkdir -p ${NACOS_WORKDIR} \
    && cd ${NACOS_WORKDIR} \
    && wget ${NACOS_FILE_URL} \
    && tar -xzvf ${NACOS_FILE_NAME} -C ${NACOS_HOME} --strip-components=1 \
    && rm ${NACOS_FILE_NAME} \
    && chmod -R 777 ${NACOS_FILE_EXTRACT_DIR} \
    && cd ${NACOS_FILE_EXTRACT_DIR} \
    && mkdir -p logs \
	&& cd logs \
	&& touch start.out \
	&& ln -sf /dev/stdout ${NACOS_HOME}/logs/start.out \
	&& ln -sf /dev/stderr ${NACOS_HOME}/logs/start.out \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && yum autoremove -y wget \
    && yum clean all \
    && echo "root:123321" | chpasswd

WORKDIR ${NACOS_HOME}

EXPOSE 8848
ENTRYPOINT ["bin/docker-startup.sh"]