    
FROM node
MAINTAINER Flyceek "flyceek@gmail.com"

RUN mkdir -p /opt/elasticsearch-head/app \
    && cd /opt/elasticsearch-head/app \
    && npm install -g grunt \
    && git clone --depth=1 --single-branch --branch=master https://github.com/mobz/elasticsearch-head.git /opt/elasticsearch-head/app \
    && npm install \
    && echo "root:123321" | chpasswd

EXPOSE 9100

WORKDIR /opt/elasticsearch-head/app
CMD grunt server