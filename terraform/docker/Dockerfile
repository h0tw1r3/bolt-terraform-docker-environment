ARG IMAGE_REPO
ARG IMAGE_TAG

FROM $IMAGE_REPO:$IMAGE_TAG as base

ENV container docker
ENV DEBIAN_FRONTEND noninteractive

USER root
WORKDIR /root

RUN set -x
RUN echo 'root:root' | chpasswd
RUN printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
       systemd systemd-sysv systemd-cron\
       util-linux \
       locales \
       udev dbus dbus-user-session apt-transport-https \
       software-properties-common iptables iptables-persistent \
       iproute2 lsb-release wget ca-certificates vim-tiny iputils-ping \
       openssh-server openssh-client \
    && apt-get clean \
    && rm -f /var/run/nologin

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN sed -ri \
    -e "s/^#?PermitRootLogin .*/PermitRootLogin yes/" \
    -e "s/^#?PasswordAuthentication .*/PasswordAuthentication yes/" \
    -e "s/^#?UseDNS .*/UseDNS no/" /etc/ssh/sshd_config \
    /etc/ssh/sshd_config

#RUN find /etc/systemd/system /lib/systemd/system \
#    -path '*.wants/*' \
#    -not -name '*dbus*' \
#    -not -name '*journald*' \
#    -not -name '*systemd-tmpfiles*' \
#    -not -name '*systemd-user-sessions*' \
#    -delete

RUN systemctl set-default multi-user.target
RUN systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount
RUN find /lib/systemd/system -type f -name 'sys-kernel*mount*' -printf '%f\n' | xargs systemctl mask
RUN systemctl enable ssh

VOLUME [ "/sys/fs/cgroup", "/tmp", "/run", "/run/lock" ]

STOPSIGNAL SIGRTMIN+3

CMD [ "/lib/systemd/systemd", "--log-target=journal", "--log-level=info" ]

FROM base as ubuntu-20.04

RUN wget https://apt.puppetlabs.com/puppet5-release-buster.deb \
    && dpkg -i puppet5-release-buster.deb && rm puppet5-release-buster.deb \
    && apt-get update -y \
    && apt-get install -y puppet-agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base as ubuntu-18.04

RUN wget https://apt.puppetlabs.com/puppet5-release-bionic.deb \
    && dpkg -i puppet5-release-bionic.deb && rm puppet5-release-bionic.deb \
    && apt-get update -y \
    && apt-get install -y puppet-agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

FROM base as ubuntu-16.04

RUN wget https://apt.puppetlabs.com/puppet5-release-xenial.deb \
    && dpkg -i puppet5-release-xenial.deb && rm puppet5-release-xenial.deb \
    && apt-get update -y \
    && apt-get install -y puppet-agent \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
