FROM flyceek/alpine-jre:8u131
MAINTAINER flyceek <flyceek@gmail.com>

ARG GPG_KEY=D0BC8D8A4E90A40AFDFC43B3E22A746A68E327C1
ARG ZOOKEEPER_VERSION=3.4.13
ARG ZOOKEEPER_DISTRO_NAME=zookeeper-${ZOOKEEPER_VERSION}
ARG ZOOKEEPER_FILE_NAME=${ZOOKEEPER_DISTRO_NAME}.tar.gz
ARG ZOOKEEPER_FILE_ASC_NAME=${ZOOKEEPER_FILE_NAME}.asc

ENV ZOOKEEPER_USER=zookeeper
ENV ZOOKEEPER_WORK_HOME=/opt/zookeeper
ENV ZOOKEEPER_HOME=${ZOOKEEPER_WORK_HOME}/${ZOOKEEPER_DISTRO_NAME}
ENV ZOOKEEPER_CONF_DIR=${ZOOKEEPER_HOME}/conf
ENV ZOOKEEPER_DATA_DIR=/var/zookeeper/data
ENV ZOOKEEPER_DATA_LOG_DIR=/var/zookeeper/datalog
ENV ZOOKEEPER_PORT=2181
ENV ZOOKEEPER_TICK_TIME=2000
ENV ZOOKEEPER_INIT_LIMIT=5
ENV ZOOKEEPER_SYNC_LIMIT=2
ENV ZOOKEEPER_MAX_CLIENT_CNXNS=100
ENV ZOOKEEPER_SERVERS=''
ENV ZOOKEEPER_MY_ID=0

ENV PATH=$PATH:${ZOOKEEPER_HOME}/bin
ENV ZOOCFGDIR=${ZOOKEEPER_CONF_DIR}

RUN apk add --no-cache bash su-exec \
    && apk add --no-cache --virtual .build-deps ca-certificates gnupg libressl \
    && adduser -D "${ZOOKEEPER_USER}" \
    && mkdir -p "${ZOOKEEPER_WORK_HOME}" "${ZOOKEEPER_DATA_LOG_DIR}" "${ZOOKEEPER_DATA_DIR}" "${ZOOKEEPER_CONF_DIR}" \
    && chown -R "${ZOOKEEPER_USER}:${ZOOKEEPER_USER}" "${ZOOKEEPER_DATA_LOG_DIR}" "${ZOOKEEPER_DATA_DIR}" "${ZOOKEEPER_CONF_DIR}" \
    && cd ${ZOOKEEPER_WORK_HOME} \
    && wget -q "https://www.apache.org/dist/zookeeper/${ZOOKEEPER_DISTRO_NAME}/${ZOOKEEPER_FILE_NAME}" \
    && wget -q "https://www.apache.org/dist/zookeeper/${ZOOKEEPER_DISTRO_NAME}/${ZOOKEEPER_FILE_ASC_NAME}" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-key "${GPG_KEY}" ||  gpg --keyserver pgp.mit.edu --recv-keys "${GPG_KEY}" ||  gpg --keyserver keyserver.pgp.com --recv-keys "${GPG_KEY}" \
    && gpg --batch --verify "${ZOOKEEPER_FILE_ASC_NAME}" "${ZOOKEEPER_FILE_NAME}" \
    && tar -xzf "${ZOOKEEPER_FILE_NAME}" \
    && rm -rf "${GNUPGHOME}" "${ZOOKEEPER_FILE_NAME}" "${ZOOKEEPER_FILE_ASC_NAME}" \
    && mv "${ZOOKEEPER_DISTRO_NAME}/conf/"* "${ZOOKEEPER_CONF_DIR}" \
    && apk del .build-deps \
    && { \
		echo '#!/bin/sh'; \
        echo 'rm -fr ${ZOOKEEPER_CONF_DIR}/zoo.cfg'; \
        echo 'CONFIG=${ZOOKEEPER_CONF_DIR}/zoo.cfg'; \
        echo 'echo clientPort=${ZOOKEEPER_PORT} >> ${CONFIG}'; \
        echo 'echo dataDir=${ZOOKEEPER_DATA_DIR} >> ${CONFIG}'; \
        echo 'echo dataLogDir=${ZOOKEEPER_DATA_LOG_DIR} >> ${CONFIG}'; \
        echo 'echo tickTime=${ZOOKEEPER_TICK_TIME} >> ${CONFIG}'; \
        echo 'echo initLimit=${ZOOKEEPER_INIT_LIMIT} >> ${CONFIG}'; \
        echo 'echo syncLimit=${ZOOKEEPER_SYNC_LIMIT} >> ${CONFIG}'; \
        echo 'echo maxClientCnxns=${ZOOKEEPER_MAX_CLIENT_CNXNS} >> ${CONFIG}'; \
        echo 'for server in ${ZOOKEEPER_SERVERS}; do echo "$server" >> ${CONFIG}; done'; \
        echo '${ZOOKEEPER_MY_ID:-1} > ${ZOOKEEPER_DATA_DIR}/myid'; \
        echo 'exec su-exec ${ZOOKEEPER_USER} ${ZOOKEEPER_HOME}/bin/zkServer.sh start-foreground'; \
	} > /usr/local/bin/zk-start \
    && chmod +x /usr/local/bin/zk-start \
    && echo "root:123321" | chpasswd

WORKDIR ${ZOOKEEPER_HOME}
VOLUME ["${ZOOKEEPER_DATA_DIR}", "${ZOOKEEPER_DATA_LOG_DIR}"]
EXPOSE ${ZOOKEEPER_PORT} 2888 3888

CMD ["zk-start"]