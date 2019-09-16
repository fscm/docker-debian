FROM debian:stretch as first_stage

ARG OS_CODENAME="stretch"
ARG OS_VERSION="9.11"

ENV DEBIAN_FRONTEND=noninteractive

COPY files/ /root/

RUN \
  apt-get -qq update && \
  apt-get -qq -y -o Dpkg::Use-Pty=0 --no-install-recommends install binutils coreutils curl debian-archive-keyring debootstrap dbus dpkg-dev vim wget && \
  rm /usr/share/debootstrap/scripts/${OS_CODENAME} && \
  cp /root/debootstrap/${OS_CODENAME} /usr/share/debootstrap/scripts/ && \
  mkdir -p /build/usr/local && \
  cp -R /root/tests /build/usr/local/ && \
  chmod +x /build/usr/local/tests/* && \
  debootstrap --variant=docker --arch=amd64 --foreign ${OS_CODENAME} /build



FROM scratch as second_stage

ARG OS_CODENAME="stretch"

ENV DEBIAN_FRONTEND=noninteractive

COPY --from=first_stage \
  /build .

RUN \
  mv /bin/mount /bin/mount.orig && \
  ln -s /bin/true /bin/mount && \
  /debootstrap/debootstrap --second-stage && \
  mv /bin/mount.orig /bin/mount && \
  /bin/echo "deb http://deb.debian.org/debian ${OS_CODENAME} main non-free contrib" > /etc/apt/sources.list && \
  /bin/echo "deb http://security.debian.org/ ${OS_CODENAME}/updates main contrib non-free" >> /etc/apt/sources.list && \
  /bin/echo "deb http://deb.debian.org/debian ${OS_CODENAME}-updates main contrib non-free" >> /etc/apt/sources.list && \
  apt-get -qq update && \
  apt-get -y -q -o Dpkg::Options::="--force-confdef" --no-install-recommends upgrade && \
  dpkg-divert --local --rename --add /sbin/initctl && \
  /bin/echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
  /bin/echo -e '#!/bin/sh\nexit 0' > /sbin/initctl && \
  chmod 0755 /usr/sbin/policy-rc.d /sbin/initctl && \
  apt-get clean && \
  rm -f /etc/apt/apt.conf.d/01autoremove-kernels && \
  APT_GET_CLEAN='"rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";' && \
  /bin/echo -e "DPkg::Post-Invoke { ${APT_GET_CLEAN} };\nAPT::Update::Post-Invoke { ${APT_GET_CLEAN} };\nDir::Cache::pkgcache \"\";\nDir::Cache::srcpkgcache \"\";" >> /etc/apt/apt.conf.d/90docker-clean && \
  /bin/echo -e "DPkg::Use-Pty \"false\";" >> /etc/apt/apt.conf.d/90docker-no-dpkg-output && \
  /bin/echo -e "Acquire::Languages \"none\";" >> /etc/apt/apt.conf.d/90docker-no-languages && \
  /bin/echo -e "Acquire::GzipIndexes \"true\";\nAcquire::CompressionTypes::Order:: \"gz\";" >> /etc/apt/apt.conf.d/90docker-gzip-indexes && \
  /bin/echo -e "APT::AutoRemove::SuggestsImportant \"false\";" >> /etc/apt/apt.conf.d/90docker-autoremove-suggests && \
  /bin/echo -e "APT::Install-Recommends \"false\";" >> /etc/apt/apt.conf.d/90docker-no-recommends && \
  /bin/echo -e "force-unsafe-io" >> /etc/dpkg/dpkg.cfg.d/90docker-apt-speedup && \
  /bin/echo -e "path-exclude=/usr/share/doc/*\npath-exclude=/usr/share/info/*\npath-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  rm -rf /usr/share/info/* && \
  rm -rf /usr/share/locale/* && \
  rm -rf /usr/share/man/* && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/log/* && \
  find /usr/share/doc -mindepth 1 -not -name copyright -not -type d -delete && \
  find /usr/share/doc -mindepth 1 -type d -empty -delete && \
  find /var/cache -type f -delete && \
  cat /etc/debian_version



FROM scratch

LABEL \
  maintainer="Frederico Martins <https://hub.docker.com/u/fscm/>"

COPY --from=second_stage \
  / .

CMD ["/bin/bash"]
