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
    yum install -y tar.x86_64 wget git which
}

function installAlpineDependencies(){
    apk update upgrade 
    apk --update add --no-cache --virtual=.build-dependencies maven git
    apk --update add --no-cache wget chrony tzdata bash
}

function installDebianDependencies(){
    apt-get update
    apt-get -y install unzip git tar wget
}

function installJdkDebian(){
    echo 'uninstall installed jdk.'
    # apt-get purge -y openjdk*
    echo 'install openjdk 8.'
    apt-get -y install openjdk-8-jdk
    local java_home=`dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"`
    echo -e '
export JAVA_HOME='${java_home}'
export JRE_HOME='${java_home}'/jre
export CLASS_PATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JRE_HOME}/lib
PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin'>>/etc/profile
    source /etc/profile
}

function installJdkCentOS(){
    yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    local java_home=`dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"`
    echo -e '
export JAVA_HOME='${java_home}'
export JRE_HOME='${java_home}'/jre
export CLASS_PATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JRE_HOME}/lib
PATH=${PATH}:${JAVA_HOME}/bin:${JRE_HOME}/bin'>>/etc/profile
    source /etc/profile
}

function installMesosSystemRequirementsCentOS(){
    yum install -y tar wget git
    wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
    yum install -y epel-release    
    bash -c 'cat > /etc/yum.repos.d/wandisco-svn.repo <<EOF
[WANdiscoSVN]
name=WANdisco SVN Repo 1.9
enabled=1
baseurl=http://opensource.wandisco.com/centos/7/svn-1.9/RPMS/\$basearch/
gpgcheck=1
gpgkey=http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco
EOF'
    yum update systemd
    yum groupinstall -y "Development Tools"
    yum install -y python-devel python-six python-virtualenv zlib-devel libcurl-devel openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel
}

function installMesosCentOSFromRPM(){
#     echo 'begin install mesos.'
#     cat > /tmp/bintray-mesos-el.repo <<EOF
# #bintray-mesos-el - packages by mesos from Bintray
# [bintray-mesos-el]
# name=bintray-mesos-el
# baseurl=https://dl.bintray.com/apache/mesos/el7/x86_64
# gpgcheck=0
# repo_gpgcheck=0
# enabled=1
# EOF
#     mv /tmp/bintray-mesos-el.repo /etc/yum.repos.d/bintray-mesos-el.repo
#     yum install -y mesos
#     echo 'end install mesos.'
    echo "begin install mesos rpm."
    echo "step 1 install mesos system requirements."
    installMesosSystemRequirementsCentOS

    local mesos_version="1.9.0-1"
    local mesos_filename="mesos-${mesos_version}.el7.x86_64.rpm" 
    local mesos_fileurl="https://bintray.com/apache/mesos/download_file?file_path=el7%2Fx86_64%2F${mesos_filename}"
    echo "step 2 download mesos rpm , url ${mesos_fileurl}"
    mkdir -p /tmp
    cd /tmp
    wget -O ${mesos_filename} ${mesos_fileurl}
    chmod +x ${mesos_filename}
    pwd
    ls -alsh 
    echo "step 3 mesos rpm ${mesos_filename}."
    rpm -ivh ${mesos_filename}
    
    echo "step 4 clear mesos rpm ${mesos_filename}."
    rm ${mesos_filename}

}

function installMesosFromSourceCode(){
    echo 'install mesos.'
    echo 'step 1 install mesos system requirements.'
    installMesosSystemRequirementsCentOS

    echo 'step 2 download mesos.'
    local mesos_src='/tmp/mesos'
    mkdir -p ${mesos_src}
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

    echo 'step 3 install mesos.'
    tar -xvf ${mesos_filename} -C ${mesos_src} --strip-components=1
    rm ${mesos_filename}
    cd ${mesos_src}
    mkdir build
    cd build
    ../configure --prefix=/usr/local/mesos
    make
    make install

    echo 'step 3 config mesos.'
    export MESOS_HOME=/usr/local/mesos
    export PATH=${PATH}:${MESOS_HOME}/sbin:${MESOS_HOME}/bin

    echo 'setp 4 clean mesos.'
    cd /tmp
}

function installMesosCentOS(){
    installMesosCentOSFromRPM
}

function installMaven(){
    echo 'install maven.'

    echo 'step 1 download maven.'
    local maven_main='/opt/soft/maven'
    local maven_version="3.6.2"
    local maven_dirname="apache-maven-${maven_version}"
    local maven_home="${maven_main}/${maven_dirname}"
    local maven_filename="apache-maven-${maven_version}-bin.tar.gz"
    local maven_filesha="d941423d115cd021514bfd06c453658b1b3e39e6240969caf4315ab7119a77299713f14b620fb2571a264f8dff2473d8af3cb47b05acf0036fc2553199a5c1ee"
    local maven_fileurl="http://mirror.bit.edu.cn/apache/maven/maven-3/${maven_version}/binaries/${maven_filename}"
    mkdir -p ${maven_home}
    cd ${maven_main}
    echo 'begin download maven ! , url :'${maven_fileurl}'.'
    wget ${maven_fileurl}
    echo 'begin check maven sha512sum! , file :'${maven_filename}', sha512sum:'${maven_filesha}'.'
    echo "${maven_filesha}  ${maven_filename}" | sha512sum -c -
    if [ $? -ne 0 ]; then
        echo 'file :'${maven_filename}', sha512 :'${maven_filesha}', is does not match!'
        exit 1002
    fi
    tar -xvf ${maven_filename} -C ${maven_home} --strip-components=1
    rm -fr ${maven_filename}
    chmod -R +x ${maven_home}/bin

    echo 'step 2 config maven.'
    echo 'step 2.1 rm defauilt settings.xml'
    ls -alsh ${maven_home}/conf/settings.xml
    rm -fr ${maven_home}/conf/settings.xml
    echo 'step 2.1 create new settings.xml'
    echo -e '
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
	<servers></servers>
	<pluginGroups></pluginGroups>
	<proxies></proxies>
	<mirrors></mirrors>
	<profiles>
	<profile>
		   <id>jdk-1.8</id>
		   <activation>
			   <activeByDefault>true</activeByDefault>
			   <jdk>1.8</jdk>
		   </activation>
		   <properties>
			   <maven.compiler.source>1.8</maven.compiler.source>
			   <maven.compiler.target>1.8</maven.compiler.target>
			   <maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
		   </properties>
	</profile>
	</profiles>
</settings>'>${maven_home}/conf/settings.xml
    ls -alsh ${maven_home}/conf/settings.xml
    cat ${maven_home}/conf/settings.xml
    export MAVEN_HOME=${maven_home}
    export PATH=${MAVEN_HOME}/bin:${PATH}

    echo 'step 3 show maven version.'
    mvn -v
}

function installMavenCentOS(){
    installMaven
}

function installMavenDebian(){
    installMaven
}

function settingUpCentOS(){
    installCentOSDependencies
    installJdkCentOS
    installMavenCentOS
    installMesosCentOS
}

function settingUpAlpine(){
    installAlpineDependencies
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
}

function settingUpDebian(){
    installDebianDependencies
    # installJdkDebian
    installMavenDebian
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
    mvn clean package -Dmaven.javadoc.skip=true -Dmaven.test.skip=true
    if [ ! -f "${MAKE_DIR}/target/${MAKE_TARGET}" ]; then
        echo 'make target , file :'${MAKE_DIR}'/target/'${MAKE_TARGET}' not found!'
        exit 1010
    fi
    mv ${MAKE_DIR}/target/${MAKE_TARGET} ${HOME}/${VERSION}/
    chmod 777 ${HOME}/${VERSION}/${MAKE_TARGET}
    if [[ "${COMPONENT}" = "scheduler" ]]; then
        cd ${HOME}/${VERSION}/
        pwd
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
lib_dir='${HOME}/${VERSION}'/lib/*
conf_dir='${HOME}/${VERSION}'/conf/*
contianer_main=io.elasticjob.cloud.scheduler.Bootstrap
java_opts=" -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Djava.library.path=/usr/local/lib:/usr/lib:/usr/lib64"
java ${JAVA_OPTS} ${java_opts} -classpath ${conf_dir}:${lib_dir}:. ${contianer_main}'>/usr/local/bin/launch
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
    rm -fr /opt/soft/maven
    yum remove -y git
}

function cleanAlpine(){
    echo "begin clean alpine system."
    clearSystem
    apk --update del .build-dependencies
}

function cleanDebian(){
    echo "begin clean debian system."
    clearSystem
    local path=${PATH_BEFORE_MAVEN}
    rm -fr /opt/soft/maven
    apt-get purge -y git
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
