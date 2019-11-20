#!/bin/bash
SYSTEM=$1
TYPE=$2
COMPONENT=$3
VERSION=$4

FILE_NAME=''
FILE_URL=''
MAKE_DIR=''
MAKE_TARGET=''

HOME=''
SRC=''


if [ -z "$VERSION" ]; then
    echo 'version param is empty!'
    exit 1001
fi

function installCentOSDependencies(){
    yum update -y
    yum update systemd
    yum install -y tar.x86_64 wget git cppunit-devel 
    yum groupinstall -y "Development Tools"
    yum install -y python-devel python-six python-virtualenv java-1.8.0-openjdk-devel zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel
}

function installAlpineDependencies(){
    apk update upgrade 
    apk --update add --no-cache --virtual=.build-dependencies maven nodejs npm git
    apk --update add --no-cache wget chrony tzdata bash
}

function installDebianDependencies(){
    apt-get update
    apt-get -y install openjdk-8-jdk unzip maven git
}

function installMesosCentOS(){
    echo 'install mesos.'
    echo 'setp 1 download mesos.'
    mkdir -p /tmp/mesos
    cd /tmp
    local mesos_version="1.6.2"
    local mesos_filename="mesos-${mesos_version}.tar.gz"
    local mesos_filesha="57e9fa17e5ce5f19742512671ebdf3b731e780828374b48dac2abe6e54dd1cc6103610a1e90c66cf35ed1da439d2ad71bce901f33fed990731e33d7bdb544285"
    local mesos_fileurl="http://www.apache.org/dist/mesos/${mesos_version}/${mesos_filename}"
    echo 'begin download mesos ! , url :'${mesos_fileurl}'.'
    wget ${mesos_fileurl}
    echo 'begin check mesos sha512sum! , file :'${mesos_filename}', sha512sum:'${mesos_filesha}'.'
    echo "${mesos_filesha}  ${mesos_filename}" | sha512sum -c -
    if [ $? -ne 0 ]; then
        echo 'file :'${mesos_filename}', sha512 :'${mesos_filesha}', is does not match!'
        exit 1002
    fi
    echo 'setp 2 install mesos.'
    tar -xvf ${mesos_filename} -C /tmp/mesos --strip-components=1
    cd /tmp/mesos
    ./configure --prefix=/usr/local/mesos
    make –j6
    make –j6 install
    echo 'setp 3 clean mesos.'
    cd /tmp
    rm -fr mesos
}

function installMaven(){
    echo 'install maven.'
    echo 'setp 1 download maven.'
    local maven_version="3.6.2"
    local maven_dirname="apache-maven-${maven_version}"
    local maven_path="/opt/soft/maven/${maven_dirname}"
    local maven_filename="apache-maven-${maven_version}-bin.tar.gz"
    local maven_filesha="d941423d115cd021514bfd06c453658b1b3e39e6240969caf4315ab7119a77299713f14b620fb2571a264f8dff2473d8af3cb47b05acf0036fc2553199a5c1ee"
    local maven_fileurl="http://mirror.bit.edu.cn/apache/maven/maven-3/${maven_version}/binaries/${maven_filename}"
    mkdir -p ${maven_path}
    cd /opt/soft/maven/
    echo 'begin download maven ! , url :'${maven_fileurl}'.'
    wget ${maven_fileurl}
    echo 'begin check maven sha512sum! , file :'${maven_filename}', sha512sum:'${maven_filesha}'.'
    echo "${maven_filesha}  ${maven_filename}" | sha512sum -c -
    if [ $? -ne 0 ]; then
        echo 'file :'${maven_filename}', sha512 :'${maven_filesha}', is does not match!'
        exit 1002
    fi
    tar -xvf ${maven_filename} -C ${maven_path} --strip-components=1
    rm -fr ${maven_filename}
    echo "setp 2 config maven."
    echo "MAVEN_HOME=${maven_path}">>/etc/profile
    echo "export PATH=${MAVEN_HOME}/bin:${PATH}">>/etc/profile
    source /etc/profile
}

function installMavenCentOS(){
    installMaven
}

function settingUpCentOS(){
    installCentOSDependencies
    installMesosCentOS
    installMavenCentOS
}

function settingUpAlpine(){
    installAlpineDependencies
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

function settingUpDebian(){
    installDebianDependencies
}

function settingUpSystemUser(){
    echo "root:123321" | chpasswd
}

function download(){
    cd ${SRC}
    local path=$(pwd)
    echo 'begin download in path :'${path}', url :'${FILE_URL}'.'
    git clone --depth=1 --single-branch --branch=master ${FILE_URL} ${SRC}
    echo 'end download in path :'${path}', url :'${FILE_URL}'.'
}

function check(){
    echo 'check download ... ...'
}

function prepareInstall(){
    mkdir -p ${SRC}
    cd ${HOME}
    local path=$(pwd)
    echo 'prepare in path :'${path}', url :'${FILE_URL}'.'
    
}

function install() {
    cd ${SRC}
    mvn clean install -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
    if [ ! -f "${MAKE_DIR}/target/${MAKE_TARGET}" ]; then
        echo 'make target , file :'${MAKE_DIR}'/target/'${MAKE_TARGET}' not found!'
        exit 1010
    fi
    mv ${MAKE_DIR}/target/${MAKE_TARGET} ${HOME}/${VERSION}/
    chmod 777 ${HOME}/${VERSION}/${MAKE_TARGET}
    if [[ "${COMPONENT}" = "scheduler" ]]; then
        cd ${HOME}/${VERSION}/
        pwd
        ls -alsh
        tar -xvf ${MAKE_TARGET} -C ${HOME}/${VERSION} --strip-components=1
        rm -fr ${MAKE_TARGET}        
        chmod -R +x ./
    fi
    echo "install file end."
}

function createLaunchShell(){
    if [[ "${COMPONENT}" = "scheduler" ]]; then
        echo -e '#!/bin/bash
chronyd
cd '${HOME}/${VERSION}'/bin
/bin/bash start.sh $@'>/usr/local/bin/launch
    else
        echo -e '#!/bin/bash
chronyd
cd '${HOME}/${VERSION}'
java ${JAVA_OPTS} -jar '${MAKE_TARGET}>/usr/local/bin/launch
    fi
    chmod +x /usr/local/bin/launch 
}

function installCentOSHandle(){
    prepareInstall
    download
    check
    install
    createLaunchShell
}

function installAlpineHandle(){
    prepareInstall
    download
    check
    install
    createLaunchShell
}

function installDebianHandle(){
    prepareInstall
    download
    check
    install
    createLaunchShell
}

function settingUpCentOSFile(){
    echo "settingUpCentOSFile"
}

function settingUpAlpineFile(){
    echo "settingUpAlpineFile"
}

function settingUpDebianFile(){
    echo "settingUpDebianFile"
}

function clearSystem(){
    rm -fr ${SRC} \
    && rm -fr /root/.m2 \
    && rm -fr /build.sh
}

function cleanCentOS(){
    echo "begin clean centOS system."
    clearSystem
}

function cleanAlpine(){
    echo "begin clean alpine system."
    clearSystem
    apk --update del .build-dependencies
}

function cleanDebian(){
    echo "begin clean debian system."
    clearSystem
    apt-get –purge remove maven 
    apt-get –purge remove git
    apt-get clean
}

function installFromAlpine(){
    settingUpAlpine
    installAlpineHandle
    settingUpAlpineFile
    cleanAlpine
    settingUpSystemUser
}

function installFromCentOS(){
    settingUpCentOS
    installCentOSHandle
    settingUpCentOSFile
    cleanCentOS
    settingUpSystemUser
}

function installFromDebian(){
    settingUpDebian
    installDebianHandle
    settingUpDebianFile
    cleanDebian
    settingUpSystemUser
}

function doAction(){
    if [ -z "$SYSTEM" ]; then
        echo 'system is empty!'
        exit 1004
    fi
    if [ -z "$TYPE" ]; then
        echo 'type is empty!'
        exit 1005
    fi
    if [ -z "$COMPONENT" ]; then
        echo 'component is empty!'
        exit 1005
    fi

    case "$TYPE" in
        "cloud")
            echo "make cloud solution."            
            FILE_URL=https://github.com/elasticjob/elastic-job-cloud.git
            ;;
        "lite")
            echo "make lite solution."
            ;;
        *)
            echo "type error,please enter!"
            exit 1005
            ;;
    esac

    case "$COMPONENT" in
        "scheduler")
            echo "make scheduler solution."
            HOME=/opt/elastic-job-cloud/scheduler
            SRC=${HOME}/${VERSION}/src
            MAKE_DIR=elastic-job-cloud-scheduler
            MAKE_TARGET=elastic-job-cloud-scheduler-3.0.0.M1-SNAPSHOT.tar.gz
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac

    case "$SYSTEM" in
        "debian")
            echo "begin install by debian system."
            installFromDebian
            ;;
        "alpine")
            echo "begin install by alpine system."
            installFromAlpine
            ;;
        "centos")
            echo "begin install by CentOS system."
            installFromCentOS
            ;;
        *)
            echo "system error,please enter!"
            exit 1005
            ;;
    esac

    
}

doAction
