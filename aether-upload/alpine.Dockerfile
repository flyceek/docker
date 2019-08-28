FROM php:7.4-rc-fpm-alpine3.10
MAINTAINER flyceek <flyceek@gmail.com>

ARG WORK_HOME=/opt/soft
ARG USER=paranora
ARG USERID=1090
ARG GROUP=paranora
ARG GROUPID=1090

RUN apk update upgrade \
    && mkdir -p ${WORK_HOME} \
    && cd ${WORK_HOME} \
    && apk add --no-cache bash curl git \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === 'a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && addgroup -g ${GROUPID} ${GROUP} \
    && adduser -h /home/${USER} -u ${USERID} -G ${GROUP} -s /bin/bash -D ${USER} \
    && git clone --depth=1 --single-branch --branch=master https://github.com/peinhu/AetherUpload-Laravel.git \
    && chmod -R 777 ${WORK_HOME} \
    && cd AetherUpload-Laravel 

USER paranora
EXPOSE 8080

