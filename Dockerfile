FROM archlinux:latest
LABEL maintainer "Chris Zervakis"

# Avoid things that systemd does on actual hardware.
ENV container docker

# Install Ansible via pip.
ENV ansible_packages "ansible"

# Temporary work-around for https://gitlab.archlinux.org/archlinux/archlinux-docker/-/issues/56
RUN if [[ $(uname -m) = "x86_64" ]]; then \
      patched_glibc=glibc-linux4-2.33-5-x86_64.pkg.tar.zst && \
      curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
      bsdtar -C / -xvf "$patched_glibc" && \
      sed -i "s/#\(IgnorePkg   =\)/\1 glibc/" /etc/pacman.conf; \
    fi

# Fetch an updated mirrorlist
RUN curl -s "https://archlinux.org/mirrorlist/?country=GB&country=DE&country=US&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' > /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm

RUN pacman -S --noconfirm \
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
    python \
    python-pip \
    which \
    vim \
&& yes | pacman -Scc

RUN pip install -U pip
RUN pip install --no-cache $ansible_packages

VOLUME ["/sys/fs/cgroup"]
CMD [ "/lib/systemd/systemd" ]


