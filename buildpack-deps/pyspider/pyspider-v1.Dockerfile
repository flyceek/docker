FROM python:2.7
MAINTAINER flyceek <flyceek@gmail.com>

ARG PHANTONJS_WORK_DIR=/opt/soft/phantomjs
ARG PHANTONJS_VERSION=2.5.0
ARG PHANTONJS_FILE_NAME=phantomjs-${PHANTONJS_VERSION}-beta-linux-ubuntu-trusty-x86_64.tar.gz
ARG PHANTONJS_FILE_EXTRACT_DIR=${PHANTONJS_WORK_DIR}/phantomjs-${PHANTONJS_VERSION}-beta
ARG PHANTONJS_FILE_URL=https://bitbucket.org/ariya/phantomjs/downloads/${PHANTONJS_FILE_NAME}

ARG MYSQL_WORK_DIR=/opt/soft/mysql
ARG MYSQL_CONNECTOR_PYTHON_VERSION=8.0.15
ARG MYSQL_CONNECTOR_PYTHON_FILE_NAME=mysql-connector-python-${MYSQL_CONNECTOR_PYTHON_VERSION}.zip
ARG MYSQL_CONNECTOR_PYTHON_FILE_URL=https://dev.mysql.com/get/Downloads/Connector-Python/${MYSQL_CONNECTOR_PYTHON_FILE_NAME}
ARG MYSQL_CONNECTOR_PYTHON_FILE_MD5=d8d385202f83d12a371593cbe00a60ba

ARG PYSPIDER_WORK_DIR=/opt/soft/pyspider
ARG PYSPIDER_VERSION=0.3.10
ARG PYSPIDER_FILE_NAME=pyspider-${PYSPIDER_VERSION}.tar.gz
ARG PYSPIDER_FILE_EXTRACT_DIR=${PYSPIDER_WORK_DIR}/pyspider-${PYSPIDER_VERSION}
ARG PYSPIDER_FILE_SRC_DIR=${PYSPIDER_FILE_EXTRACT_DIR}/pyspider
ARG PYSPIDER_FILE_URL=https://github.com/binux/pyspider/archive/v${PYSPIDER_VERSION}.tar.gz

# install phantomjs
RUN mkdir -p ${PHANTONJS_FILE_EXTRACT_DIR} \
    && cd ${PHANTONJS_WORK_DIR} \
    && wget -O ${PHANTONJS_FILE_NAME} ${PHANTONJS_FILE_URL} \
    && tar xavf ${PHANTONJS_FILE_NAME} -C ${PHANTONJS_FILE_EXTRACT_DIR} --strip-components 1 \
    && ln -s ${PHANTONJS_FILE_EXTRACT_DIR}/bin/phantomjs /usr/local/bin/phantomjs \
    && rm ${PHANTONJS_FILE_NAME} \
# install mysql connector python
    && mkdir -p ${MYSQL_WORK_DIR} \
    && cd ${MYSQL_WORK_DIR} \
    && wget -O ${MYSQL_CONNECTOR_PYTHON_FILE_NAME} ${MYSQL_CONNECTOR_PYTHON_FILE_URL} \
    && echo "${MYSQL_CONNECTOR_PYTHON_FILE_MD5} ${MYSQL_CONNECTOR_PYTHON_FILE_NAME}" | md5sum -c - \
    && pip install --egg ${MYSQL_CONNECTOR_PYTHON_FILE_NAME} \
# install requirements
    && pip install -r Flask>=0.10 \
Jinja2>=2.7 \
chardet>=2.2 \
cssselect>=0.9 \
lxml \
pycurl \
pyquery \
requests>=2.2 \
tornado==4.5.3 \
mysql-connector-python>=1.2.2 \
pika>=0.9.14 \
pymongo>=2.7.2 \
unittest2>=0.5.1 \
Flask-Login>=0.2.11 \
u-msgpack-python>=1.6 \
click>=3.3 \
SQLAlchemy>=0.9.7 \
six>=1.5.0 \
amqp>=1.3.0,<2.0 \
redis \
redis-py-cluster \
kombu \
psycopg2 \
elasticsearch \
tblib \
# add all repo
    && mkdir -p ${PYSPIDER_FILE_EXTRACT_DIR} \
    && cd ${PYSPIDER_WORK_DIR} \
    && wget -O ${PYSPIDER_FILE_NAME} ${PYSPIDER_FILE_URL} \
    && tar xavf ${PYSPIDER_FILE_NAME} -C ${PYSPIDER_FILE_EXTRACT_DIR} --strip-components 1 \
    && rm ${PYSPIDER_FILE_NAME} \
    # run test
    && cd ${PYSPIDER_FILE_SRC_DIR} \
    && pip install -e .[all]

WORKDIR ${PYSPIDER_FILE_SRC_DIR}
VOLUME ${PYSPIDER_FILE_SRC_DIR}
ENTRYPOINT ["pyspider"]

EXPOSE 5000 23333 24444 25555