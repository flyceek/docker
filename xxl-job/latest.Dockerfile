FROM openjdk:8-jdk-alpine
MAINTAINER flyceek@gmail.com

COPY build.sh /build.sh

RUN ["sh","/build.sh","alpine","2.1.0"]

EXPOSE 8080
CMD ["java","-jar", "/opt/xxl-job/2.1.0/xxl-job-admin-2.1.0.jar"]