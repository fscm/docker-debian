FROM debian:stretch as first_stage

ARG OS_CODENAME="stretch"
ARG OS_VERSION="9.11"

ENV \
  LANG=C.UTF-8 \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive

COPY files/ /root/

RUN \
# dependencies
  apt-get -qq update && \
  apt-get -qq -y -o Dpkg::Use-Pty=0 --no-install-recommends install \
    binutils \
    coreutils \
    curl \
    debian-archive-keyring \
    debootstrap \
    dbus \
    dpkg-dev \
    vim \
    wget && \
# replace debootstrap script
  rm /usr/share/debootstrap/scripts/${OS_CODENAME} && \
  cp /root/debootstrap/${OS_CODENAME} /usr/share/debootstrap/scripts/ && \
# build structure
  install --directory --owner=root --group=root --mode=0755 /build/usr/local && \
# copy tests
  cp -R /root/tests /build/usr/local/ && \
  chmod +x /build/usr/local/tests/* && \
# debootstrap first stage
  debootstrap --variant=docker --arch=amd64 --foreign ${OS_CODENAME} /build && \
# clean up...
  echo '' > "/build/etc/resolv.conf" && \
  echo 'host' > "/build/etc/hostname"



FROM scratch as second_stage

ARG OS_CODENAME="stretch"

ENV \
  LANG=C.UTF-8 \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive

COPY --from=first_stage \
  /build .

RUN \
# 'disable' mount command
  mv /bin/mount /bin/mount.orig && \
  ln -s /bin/true /bin/mount && \
# debootstrap second stage
  /debootstrap/debootstrap --second-stage && \
# restore mount command
  mv /bin/mount.orig /bin/mount && \
# recreate the sources file
  echo "deb http://deb.debian.org/debian ${OS_CODENAME} main non-free contrib" > /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ ${OS_CODENAME}/updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb http://deb.debian.org/debian ${OS_CODENAME}-updates main contrib non-free" >> /etc/apt/sources.list && \
# update the system
  apt-get -qq update && \
  apt-get -y -q -o Dpkg::Options::="--force-confdef" --no-install-recommends upgrade && \
# prevent upstart and init script from running
  dpkg-divert --local --rename --add /sbin/initctl && \
  echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
  echo -e '#!/bin/sh\nexit 0' > /sbin/initctl && \
  chmod 0755 /usr/sbin/policy-rc.d /sbin/initctl && \
# clean up and tweaks...
  apt-get clean && \
  rm -f /etc/apt/apt.conf.d/01autoremove-kernels && \
  APT_GET_CLEAN='"rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";' && \
  echo -e "DPkg::Post-Invoke { ${APT_GET_CLEAN} };\nAPT::Update::Post-Invoke { ${APT_GET_CLEAN} };\nDir::Cache::pkgcache \"\";\nDir::Cache::srcpkgcache \"\";" >> /etc/apt/apt.conf.d/90docker-clean && \
  echo -e "DPkg::Use-Pty \"false\";" >> /etc/apt/apt.conf.d/90docker-no-dpkg-output && \
  echo -e "Acquire::Languages \"none\";" >> /etc/apt/apt.conf.d/90docker-no-languages && \
  echo -e "Acquire::GzipIndexes \"true\";\nAcquire::CompressionTypes::Order:: \"gz\";" >> /etc/apt/apt.conf.d/90docker-gzip-indexes && \
  echo -e "APT::AutoRemove::SuggestsImportant \"false\";" >> /etc/apt/apt.conf.d/90docker-autoremove-suggests && \
  echo -e "APT::Install-Recommends \"false\";" >> /etc/apt/apt.conf.d/90docker-no-recommends && \
  echo -e "force-unsafe-io" >> /etc/dpkg/dpkg.cfg.d/90docker-apt-speedup && \
  echo -e "path-exclude=/usr/share/doc/*\npath-exclude=/usr/share/info/*\npath-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  rm -rf /usr/share/info/* && \
  rm -rf /usr/share/locale/* && \
  rm -rf /usr/share/man/* && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/log/* && \
  find /usr/share/doc -mindepth 1 -not -name copyright -not -type d -delete && \
  find /usr/share/doc -mindepth 1 -type d -empty -delete && \
  find /var/cache -type f -delete && \
# check version
  cat /etc/debian_version



FROM scratch

LABEL \
  maintainer="Frederico Martins <https://hub.docker.com/u/fscm/>"

ENV \
  LANG=C.UTF-8 \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive

COPY --from=second_stage \
  / .

CMD ["/bin/bash"]
