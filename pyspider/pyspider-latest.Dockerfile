FROM python:3.7
MAINTAINER flyceek <flyceek@gmail.com>

ARG PHANTONJS_WORK_DIR=/opt/phantomjs
ARG PHANTONJS_VERSION=2.1.1
ARG PHANTONJS_FILE_NAME=phantomjs-${PHANTONJS_VERSION}-linux-x86_64.tar.bz2
ARG PHANTONJS_FILE_EXTRACT_DIR=${PHANTONJS_WORK_DIR}/phantomjs-${PHANTONJS_VERSION}
ARG PHANTONJS_FILE_URL=https://bitbucket.org/ariya/phantomjs/downloads/${PHANTONJS_FILE_NAME}

ARG CHROMEDRIVER_WORK_DIR=/opt/chromedriver
ARG CHROMEDRIVER_VERSION=2.2.6
ARG CHROMEDRIVER_FILE_NAME=chromedriver_linux64.zip
ARG CHROMEDRIVER_FILE_EXTRACT_DIR=${CHROMEDRIVER_WORK_DIR}/chromedriver-${CHROMEDRIVER_VERSION}
ARG CHROMEDRIVER_FILE_URL=http://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/${CHROMEDRIVER_FILE_NAME}

ARG PYSPIDER_WORK_DIR=/opt/pyspider
ARG PYSPIDER_VERSION=0.3.10
ARG PYSPIDER_FILE_NAME=pyspider-${PYSPIDER_VERSION}.tar.gz
ARG PYSPIDER_FILE_EXTRACT_DIR=${PYSPIDER_WORK_DIR}/pyspider-${PYSPIDER_VERSION}
ARG PYSPIDER_FILE_SRC_DIR=${PYSPIDER_FILE_EXTRACT_DIR}/pyspider
ARG PYSPIDER_FILE_URL=https://github.com/binux/pyspider/archive/v${PYSPIDER_VERSION}.tar.gz

ENV OPENSSL_CONF=/etc/ssl/
ENV NODEJS_VERSION=8.15.0
ENV PATH=$PATH:/opt/node/bin

RUN apt-get -qq update
    && apt-get -qq install -y unzip curl ca-certificates libx11-xcb1 libxtst6 libnss3 libasound2 libatk-bridge2.0-0 libgtk-3-0 --no-install-recommends 
    # install phantomjs
    &&mkdir -p ${PHANTONJS_FILE_EXTRACT_DIR} \
    && cd ${PHANTONJS_WORK_DIR} \
    && wget -O ${PHANTONJS_FILE_NAME} ${PHANTONJS_FILE_URL} \
    && tar xavf ${PHANTONJS_FILE_NAME} -C ${PHANTONJS_FILE_EXTRACT_DIR} --strip-components 1 \
    && ln -s ${PHANTONJS_FILE_EXTRACT_DIR}/bin/phantomjs /usr/local/bin/phantomjs \
    && rm ${PHANTONJS_FILE_NAME} \
    # install node
    && cd /opt \
    && curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1 \
    && rm -rf /var/lib/apt/lists/* \
    # install chromedriver
    && mkdir -p ${CHROMEDRIVER_WORK_DIR} \
    && wget -O ${CHROMEDRIVER_FILE_NAME} ${CHROMEDRIVER_FILE_URL} \
    && unzip -d ${CHROMEDRIVER_FILE_EXTRACT_DIR} ${CHROMEDRIVER_FILE_NAME} \
    && chmod +x ${CHROMEDRIVER_FILE_EXTRACT_DIR}/chromedriver \
    && ln -s ${CHROMEDRIVER_FILE_EXTRACT_DIR}/chromedriver /usr/local/bin/chromedriver \
    && ln -s ${CHROMEDRIVER_FILE_EXTRACT_DIR}/chromedriver /usr/bin/chromedriver \
    && rm -fr ${CHROMEDRIVER_FILE_NAME} \
    # install requirements
    && pip install -r \
Flask==0.10 \
Jinja2==2.7 \
chardet==2.2.1 \
cssselect==0.9 \
lxml==4.3.3 \
pycurl==7.43.0.3 \
pyquery==1.4.0 \
requests==2.2 \
tornado==4.5.3 \
mysql-connector-python==8.0.16 \
pika==1.1.0 \
pymongo==3.9.0 \
Flask-Login==0.2.11 \
u-msgpack-python==1.6 \
click==6.6 \
SQLAlchemy==1.3.10 \
six==1.10.0 \
amqp==2.4.0 \
redis==2.10.6 \
redis-py-cluster==1.3.6 \
kombu==4.4.0 \
psycopg2==2.8.2 \
elasticsearch==2.3.0 \
tblib==1.4.0 \
selenium \
# add all repo
    && mkdir -p ${PYSPIDER_FILE_EXTRACT_DIR} \
    && cd ${PYSPIDER_WORK_DIR} \
    && wget -O ${PYSPIDER_FILE_NAME} ${PYSPIDER_FILE_URL} \
    && tar xavf ${PYSPIDER_FILE_NAME} -C ${PYSPIDER_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${PYSPIDER_FILE_NAME} \
# run test
    && cd ${PYSPIDER_FILE_SRC_DIR} \
    && pip install -e .[all]
    && ln -s /opt/node/node_modules ./node_modules

WORKDIR ${PYSPIDER_FILE_SRC_DIR}
VOLUME ${PYSPIDER_FILE_SRC_DIR}
ENTRYPOINT ["pyspider"]

EXPOSE 5000 23333 24444 25555