FROM node:10.6-alpine

RUN npm install -g cnpm --registry=https://registry.npm.taobao.org \
    && cnpm install -g yapi-cli \
    && apk update \
    && apk add --no-cache make python git

WORKDIR /opt/yapi
ENTRYPOINT ["node"]
CMD ["vendors/server/app.js"]