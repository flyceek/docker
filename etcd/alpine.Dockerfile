FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ARG ETCD_VERSION=3.3.13
ARG ETCD_FILENAME=etcd-v${ETCD_VERSION}-linux-arm64.tar.gz
ARG ETCD_FILEDIR=etcd-v${ETCD_VERSION}-linux-amd64
ARG ETCD_FILEURL=https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/${ETCD_FILENAME}

RUN apk --update add --no-cache --virtual=.build-dependencies wget ca-certificates unzip \
    && mkdir -p /tmp \
    && cd /tmp \
    && wget ${ETCD_FILEURL} \
    && tar -zxvf ${ETCD_FILENAME} \
    && mv ${ETCD_FILEDIR}/etcd /usr/local/bin/ \
    && mv ${ETCD_FILEDIR}/etcdctl /usr/local/bin/ \
    && mkdir -p /var/etcd/ \
    && mkdir -p /var/lib/etcd/ \
    && rm -fr ${ETCD_FILENAME} \
    && rm -fr ${ETCD_FILEDIR} \
    && echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

EXPOSE 2379 2380

CMD ["/usr/local/bin/etcd"]