FROM openjdk:8-jre-alpine
MAINTAINER flyceek@gmail.com

ARG VERSION=2.1.0
ARG FILE_NAME=${VERSION}2.1.0.tar.gz
ARG FILE_URL=https://github.com/xuxueli/xxl-job/archive/${FILE_NAME}

ARG HOME=/opt/xxl-job

RUN apk --update add --no-cache --virtual=.build-dependencies wget maven \
    && mkdir -p ${HOME} \
    && cd ${HOME} \
    && wget -O ${FILE_NAME} ${FILE_URL} \
    && mkdir -p ${HOME}/${VERSION} \
    && tar -xvf ${FILE_NAME} -C ${HOME}/${VERSION} --strip-components=1 \
    && cd ${HOME}/${VERSION} \
    && rm -fr xxl-job-executor-samples \
    && rm -fr xxl-job-core \
    && rm -fr doc \
    && cd ${HOME}/${VERSION}/xxl-job-admin \
    && mvn clean package -Dmaven.test.skip=true \
    && echo 'end'


