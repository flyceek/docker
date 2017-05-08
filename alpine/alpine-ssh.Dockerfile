FROM alpine:latest
MAINTAINER flyceek <flyceek@gmail.com>

RUN apk add --update openssh \
    && rm -rf /etc/ssh/ssh_host_*_key \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -N ''  \
    && ssh-keygen -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' \
    && ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#RSAAuthentication yes/RSAAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config \
    && mkdir -p /var/run/sshd \
    && rm -rf /tmp/* /var/cache/apk/* \
    && echo "root:123321" | chpasswd

EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]