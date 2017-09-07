FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

ENV COCOAPODS_WORK_DIR="/opt/data/cocoapods"
ENV COCOAPODS_REPOSITORY_NAME="Specs"
ENV COCOAPODS_GITMIRROR_URL=""
ENV COCOAPODS_GIT_URL="https://github.com/CocoaPods/Specs.git"

RUN apk --update add --no-cache --virtual=.update-dependencies git \
    && mkdir -p /var/cocoapods \
    && echo -e '[core]\nrepositoryformatversion = 0\nfilemode = true\nbare = true\nignorecase = true\nprecomposeunicode = true\n[remote "origin"]\nfetch = +refs/heads/*:refs/heads/*\nfetch = +refs/tags/*:refs/tags/*\nmirror = true\nurl = https://github.com/CocoaPods/Specs.git\n[remote "mirrors"]\nurl = https://git.coding.net/flyceek/cocoapods.git\nmirror = true\nskipDefaultUpdate = true' > /var/cocoapods/config \
    && { \
        echo '#!/bin/bash'; \
        echo 'git clone --mirror https://github.com/CocoaPods/Specs.git ${COCOAPODS_REPOSITORY_NAME}'; \
    } > /usr/local/bin/init-cocoapods-mirror \
    && { \
        echo '#!/bin/sh'; \
        echo 'cd ${COCOAPODS_WORK_DIR}/${COCOAPODS_REPOSITORY_NAME}'; \
        echo 'rm -fr cofnig'; \
        echo 'mv /var/cocoapods/config config'; \
        echo "sed  '/.*mirrors.*/{n;s/url.*/url = '"'${COCOAPODS_GITMIRROR_URL}'"'/}' -i config"; \
        echo 'git fetch origin -p'; \
        echo 'git push mirrors'; \
    } > /usr/local/bin/update-cocoapods-mirror \
    && { \
        echo '#!/bin/sh'; \
        echo 'init-cocoapods-mirror'; \
        echo 'crond -f'; \
    } > /usr/local/bin/init-cocoapods-start \
    && chmod +x /usr/local/bin/init-cocoapods-mirror /usr/local/bin/update-cocoapods-mirror /usr/local/bin/init-cocoapods-start \
    && echo -e '*\t*\t1\t*\t*\tupdate-cocoapods-mirror' >> /var/spool/cron/crontabs/root \
    && echo "root:123321" | chpasswd

WORKDIR ${COCOAPODS_WORK_DIR}
//CMD ["init-cocoapods-start"]