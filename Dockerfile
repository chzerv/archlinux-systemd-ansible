FROM archlinux:latest
LABEL maintainer "Chris Zervakis"

# Avoid things that systemd does on actual hardware.
ENV container docker

# Fetch an updated mirrorlist
RUN curl -s "https://archlinux.org/mirrorlist/?country=GB&country=DE&country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm \
    sudo \
    systemd \
  && \
  (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -vf $i; done); \
    rm -vf /lib/systemd/system/multi-user.target.wants/*; \
    rm -vf /etc/systemd/system/*.wants/*; \
    rm -vf /lib/systemd/system/local-fs.target.wants/*; \
    rm -vf /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -vf /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -vf /lib/systemd/system/basic.target.wants/*;

RUN pacman -S --noconfirm \
    which \
    vim \
    ansible \
&& yes | pacman -Scc

VOLUME ["/sys/fs/cgroup"]
CMD [ "/sbin/init" ]


