FROM centos:7
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["/bin/bash","/build.sh","centos","cloud","scheduler","3.3.1"]

EXPOSE 8899
CMD ["launch"]