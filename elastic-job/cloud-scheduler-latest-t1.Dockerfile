FROM openjdk:8-jdk-alpine
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","cloud","scheduler","3.3.1"]

EXPOSE 8899
CMD ["/opt/elastic-job-cloud/scheduler/3.3.1/bin/start.sh"]