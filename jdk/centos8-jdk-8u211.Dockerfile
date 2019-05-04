FROM centos:latest
MAINTAINER flyceek <flyceek@gmail.com>

COPY build.sh /build.sh

RUN ["sh","/build.sh","centos","8","211","b12","478a62b7d4e34b78b671c754eaaf38ab","28a00b9400b6913563553e09e8024c286b506d8523334c93ddec6c9ec7e9d346","1556942251_72573da4b2c39e49d36a8fb54cea64cd"]
