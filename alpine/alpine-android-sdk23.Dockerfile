FROM flyceek/alpine-android-sdk-tools:r25.2.3
MAINTAINER flyceek <flyceek@gmail.com>

ENV BUILD_TOOLS='build-tools-23.0.2'
ENV ANDROID_SDK='android-23'
ENV ANDROID_SDK_UPDATE=tools,platform-tools,build-tools-${BUILD_TOOLS},${ANDROID_SDK},extra-android-support
ENV ANDROID_HOME=/opt/soft/android-sdk

RUN cd ${ANDROID_HOME}/tools \
    && echo y | android update sdk --filter ${ANDROID_SDK_UPDATE} --all --no-ui --force \
    && cd ${ANDROID_HOME}/tools \
    && rm -fr ${ANDROID_HOME}/tools

VOLUME ${ANDROID_HOME}