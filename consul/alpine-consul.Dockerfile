FROM alpine:3.7
MAINTAINER Preetha Appan <preetha@hashicorp.com> (@preetapan)

ENV CONSUL_GPG_KEY=D0BC8D8A4E90A40AFDFC43B3E22A746A68E327C1
ENV CONSUL_VERSION=1.3.0
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

RUN addgroup consul \ 
    && adduser -S -G consul consul \
    && set -eux \
    && apk add --no-cache ca-certificates curl dumb-init gnupg libcap openssl su-exec iputils \
    && gpg --keyserver pgp.mit.edu --recv-keys ${CONSUL_GPG_KEY} \
    && mkdir -p /tmp/build \
    && cd /tmp/build \
    && apkArch="$(apk --print-arch)" \
    && case "${apkArch}" in \
        aarch64) consulArch='arm64' ;; \
        armhf) consulArch='arm' ;; \
        x86) consulArch='386' ;; \
        x86_64) consulArch='amd64' ;; \
        *) echo >&2 "error: unsupported architecture: ${apkArch} (see ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/)" && exit 1 ;; \
    && esac \
    && wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_${consulArch}.zip \
    && wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS \
    && wget ${HASHICORP_RELEASES}/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig \
    && gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS \
    && grep consul_${CONSUL_VERSION}_linux_${consulArch}.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c \
    && unzip -d /bin consul_${CONSUL_VERSION}_linux_${consulArch}.zip \
    && cd /tmp \
    && rm -rf /tmp/build \
    && apk del gnupg openssl \
    && rm -rf /root/.gnupg \
    && consul version \
    && mkdir -p /consul/data \
    && mkdir -p /consul/config \
    && chown -R consul:consul /consul \
    && test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

VOLUME /consul/data
EXPOSE 8300
EXPOSE 8301 8301/udp 8302 8302/udp
EXPOSE 8500 8600 8600/udp
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["agent", "-dev", "-client", "0.0.0.0"]