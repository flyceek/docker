FROM debian:stretch-slim

ADD fastdfs-5.11.tar.gz /usr/local/
ADD libfastcommon-1.0.39.tar.gz /usr/local/

ENV FASTDFS_VERSION 5.11
ENV FASTDFS_TRACKER tracker
ENV FASTDFS_STORAGE storage
ENV SERVER storage

RUN apt-get update \
    && apt-get -y install make cmake gcc gcc-6 \
    && set -ex; \
	&& cd /usr/local/libfastcommon-1.0.39 \
    && ./make.sh && ./make.sh install \
    && set -ex; \
    && cd /usr/local/fastdfs-5.11 \
    && ./make.sh \
    && ./make.sh install 


COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]