FROM openjdk:8-jre-alpine
MAINTAINER flyceek@gmail.com

ARG VERSION=2.1.0
ARG FILE_NAME=${VERSION}.tar.gz
ARG FILE_URL=https://github.com/xuxueli/xxl-job/archive/${FILE_NAME}

ARG HOME=/opt/xxl-job
ARG SRC=${HOME}/${VERSION}/src

RUN apk --update add --no-cache --virtual=.build-dependencies wget maven \
    && mkdir -p ${SRC} \
    && cd ${HOME} \
    && wget -O ${FILE_NAME} ${FILE_URL} \
    && tar -xvf ${FILE_NAME} -C ${SRC} --strip-components=1 \
    && rm ${FILE_NAME} \
    && cd ${SRC}/xxl-job-admin \
    && mvn clean package -Dmaven.test.skip=true \
    && mv target/xxl-job-admin-${VERSION}.jar ${HOME}/${VERSION}/xxl-job-admin-${VERSION}.jar \
    && cd ${HOME}/${VERSION} \
    && rm -fr ${SRC} \
    && echo 'end'


