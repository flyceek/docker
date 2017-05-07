FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN apk add --update openssh \
    && rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key \
    && ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa \
    && ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa \
    && mkdir -p /var/run/sshd \
    && rm -rf /tmp/* /var/cache/apk/*

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]