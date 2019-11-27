FROM mesosphere/mesos:1.6.2
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["/bin/bash","/build.sh","debian","cloud","scheduler","3.0.0.M1"]

EXPOSE 8899
CMD ["launch"]