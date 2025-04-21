#!/bin/awk BEGIN { system("t=$(mktemp -d); cat " ARGV[1] " > $t/Dockerfile; cd $t; docker run --rm $(docker build -q .); rm -rf $t") }
# This Dockerfile is based on the following Dockerfile:
# https://github.com/star3am/hashiqube/blob/master/Dockerfile
FROM almalinux:9

# Install packages needed for SSH and interactive OS
RUN dnf -y update --setopt=install_weak_deps=False && \
    dnf -y install \
        openssh-server \
        passwd \
        sudo \
        man-db \
        wget \
        mlocate \
        vim-minimal && \
    dnf clean all && \
    dnf -y install \
     jq unzip  bzip2 git make python3 python3-pip nano \
    dnsutils iptables net-tools telnet mc  psmisc && \
    rm -rf /var/cache/dnf /tmp/* /var/tmp/*
RUN updatedb
# Not found iproute2  iputils-ping software-properties-common swapspace python3-dev python3-venv python3-virtualenv python3-passlib
# Not found cont: golang-go ntp update-motd toilet figlet
#

# Enable systemd (from Matthew Warman's mcwarman/vagrant-provider)
RUN find /lib/systemd/system/sysinit.target.wants -mindepth 1 -not -name "systemd-tmpfiles-setup.service" -delete || true; \
    find /lib/systemd/system/multi-user.target.wants -mindepth 1 -not -name "systemd-user-sessions.service" -delete || true; \
    rm -f /etc/systemd/system/*.wants/* || true; \
    rm -f /lib/systemd/system/local-fs.target.wants/* || true; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* || true; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* || true; \
    rm -f /lib/systemd/system/basic.target.wants/* || true; \
    rm -f /lib/systemd/system/anaconda.target.wants/* || true

# Enable ssh for vagrant
RUN systemctl enable sshd.service
EXPOSE 22

# Create the vagrant user
RUN useradd -m -G wheel -s /bin/bash vagrant && \
    echo "vagrant:vagrant" | chpasswd && \
    echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/vagrant && \
    chmod 440 /etc/sudoers.d/vagrant


# Establish ssh keys for vagrant
RUN mkdir -p /home/vagrant/.ssh; \
    chmod 700 /home/vagrant/.ssh
RUN wget -q -O /home/vagrant/.ssh/authorized_keys https://github.com/iladin.keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys; \
    chown -R vagrant:vagrant /home/vagrant/.ssh

# Run the init daemon
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
