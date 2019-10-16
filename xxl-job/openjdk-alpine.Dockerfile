FROM openjdk:8-jdk-alpine
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
    && chmod +x ${HOME}/${VERSION}/xxl-job-admin-${VERSION}.jar \
    && cd ${HOME}/${VERSION} \
    && rm -fr ${SRC} \
    && cd ~ \
    && pwd \
    && ls -alsh \
    && du -sh . \
    && rm -fr .m2 \
    && echo "begin uninstall maven" \
    && apk del maven \
    && echo -e '#!/bin/sh \
cd '${HOME}/${VERSION}' \
java -jar xxl-job-admin-'${VERSION}'.jar' > /usr/local/bin/launch \
    && chmod +x /usr/local/bin/launch \
    && echo 'end'

EXPOSE 8080
CMD ["launch"]

