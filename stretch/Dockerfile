# global args
ARG __BUILD_DIR__="/build"
ARG OS_CODENAME="stretch"
ARG OS_VERSION="9.12"
ARG __USER__="root"
ARG __WORK_DIR__="/root"



FROM debian:stretch as first_stage

ARG __BUILD_DIR__
ARG OS_CODENAME
ARG OS_VERSION
ARG __USER__
ARG __WORK_DIR__

ENV \
  LANG="C.UTF-8" \
  DEBCONF_NONINTERACTIVE_SEEN="true" \
  DEBIAN_FRONTEND="noninteractive"

USER ${__USER__}

COPY "files/" "${__WORK_DIR__}/"

WORKDIR "${__WORK_DIR__}"

RUN \
# dependencies
  echo '=== instaling dependencies ===' && \
  apt-get -qq update && \
  apt-get -qq -y -o=Dpkg::Use-Pty=0 --no-install-recommends install \
    binutils \
    coreutils \
    curl \
    debian-archive-keyring \
    debootstrap \
    dbus \
    dpkg-dev \
    vim \
    wget \
    > /dev/null 2>&1 && \
# build structure
  echo '=== creating build structure ===' && \
  install --directory --owner=${__USER__} --group=${__USER__} --mode=0755 "${__BUILD_DIR__}" && \
# replace debootstrap script
  echo '=== replacing debootstrap scripts ===' && \
  rm -f "/usr/share/debootstrap/scripts/${OS_CODENAME}" && \
  cp "${__WORK_DIR__}/debootstrap/${OS_CODENAME}" "/usr/share/debootstrap/scripts/" && \
# debootstrap first stage
  echo '=== running debootstrap first stage ===' && \
  debootstrap --variant=docker --arch=amd64 --foreign "${OS_CODENAME}" "${__BUILD_DIR__}" && \
# copy tests
  echo '=== copying test files ===' && \
  install --owner=${__USER__} --group=${__USER__} --mode=0755 --target-directory="${__BUILD_DIR__}/usr/bin" "${__WORK_DIR__}/tests"/* && \
# clean up and tweaks...
  echo '=== first stage settings and tweaks ===' && \
  rm -rf "${__BUILD_DIR__}/boot" && \
  rm -rf "${__BUILD_DIR__}/proc" && \
  rm -rf "${__BUILD_DIR__}/sys" && \
  echo '' > "${__BUILD_DIR__}/etc/resolv.conf" && \
  echo 'host' > "${__BUILD_DIR__}/etc/hostname" && \
# done
  echo '=== first stage done! ==='



FROM scratch as second_stage

ARG __BUILD_DIR__
ARG OS_CODENAME
ARG __WORK_DIR__

ENV \
  LANG="C.UTF-8" \
  DEBCONF_NONINTERACTIVE_SEEN="true" \
  DEBIAN_FRONTEND="noninteractive"

COPY --from=first_stage "${__BUILD_DIR__}" "/"

WORKDIR "${__WORK_DIR__}"

RUN \
# 'disable' mount command
  echo '=== disabling mount command ===' && \
  mv /bin/mount /bin/mount.orig && \
  ln --symbolic /bin/true /bin/mount && \
# debootstrap second stage
  echo '=== running debootstrap second stage ===' && \
  /debootstrap/debootstrap --second-stage && \
# restore mount command
  echo '=== enabling mount command ===' && \
  mv /bin/mount.orig /bin/mount && \
# recreate the sources file
  echo '=== recreating apt sources file ===' && \
  echo "deb http://deb.debian.org/debian ${OS_CODENAME} main non-free contrib" > /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ ${OS_CODENAME}/updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb http://deb.debian.org/debian ${OS_CODENAME}-updates main contrib non-free" >> /etc/apt/sources.list && \
# update the system
  echo '=== updating the system ===' && \
  apt-get -qq update && \
  apt-get -y -q -o Dpkg::Options::="--force-confdef" --no-install-recommends upgrade \
    > /dev/null 2>&1 && \
# prevent upstart and init script from running
  echo '=== disabling upstart and init script ===' && \
  dpkg-divert --local --rename --add /sbin/initctl && \
  echo '#!/bin/sh' > /usr/sbin/policy-rc.d && \
  echo 'exit 101' >> /usr/sbin/policy-rc.d && \
  echo '#!/bin/sh' > /sbin/initctl && \
  echo 'exit 0' >> /sbin/initctl && \
  chmod 0755 /usr/sbin/policy-rc.d /sbin/initctl && \
# clean up and tweaks...
  echo '=== second stage settings and tweaks ===' && \
  apt-get clean && \
  rm -f /etc/apt/apt.conf.d/01autoremove-kernels && \
  APT_GET_CLEAN='"rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";' && \
  echo "DPkg::Post-Invoke { ${APT_GET_CLEAN} };" > /etc/apt/apt.conf.d/90docker-clean && \
  echo "APT::Update::Post-Invoke { ${APT_GET_CLEAN} };" >> /etc/apt/apt.conf.d/90docker-clean && \
  echo "Dir::Cache::pkgcache \"\";" >> /etc/apt/apt.conf.d/90docker-clean && \
  echo "Dir::Cache::srcpkgcache \"\";" >> /etc/apt/apt.conf.d/90docker-clean && \
  echo "DPkg::Use-Pty \"false\";" > /etc/apt/apt.conf.d/90docker-no-dpkg-output && \
  echo "Acquire::Languages \"none\";" > /etc/apt/apt.conf.d/90docker-no-languages && \
  echo "Acquire::GzipIndexes \"true\";" > /etc/apt/apt.conf.d/90docker-gzip-indexes && \
  echo "Acquire::CompressionTypes::Order:: \"gz\";" >> /etc/apt/apt.conf.d/90docker-gzip-indexes && \
  echo "APT::AutoRemove::SuggestsImportant \"false\";" > /etc/apt/apt.conf.d/90docker-autoremove-suggests && \
  echo "APT::Install-Recommends \"false\";" > /etc/apt/apt.conf.d/90docker-no-recommends && \
  echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/90docker-apt-speedup && \
  echo "path-exclude=/usr/share/doc/*" > /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  echo "path-exclude=/usr/share/info/*" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  echo "path-exclude=/usr/share/locale/*" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  echo "path-exclude=/usr/share/man/*" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  echo "path-include=/usr/share/doc/*/copyright" >> /etc/dpkg/dpkg.cfg.d/90docker-excludes && \
  rm -rf "/usr/share/info"/* && \
  rm -rf "/usr/share/locale"/* && \
  rm -rf "/usr/share/man"/* && \
  rm -rf "/var/cache/apt"/* && \
  rm -rf "/var/lib/apt/lists"/* && \
  rm -rf "/var/log"/* && \
  rm -rf "/dev"/.??* && \
  rm -rf "/home"/.??* && \
  rm -rf "/root"/.??* && \
  rm -rf "/tmp"/.??* && \
  find "/usr/share/doc" -mindepth 1 -not -type d -not -name 'copyright' -delete && \
  find "/usr/share/doc" -mindepth 1 -type d -empty -delete && \
  find "/var/cache" -type f -delete && \
# check version
  echo '=== os version ===' && \
  cat "/etc/debian_version" && \
# done
  echo '=== all done! ==='



FROM scratch

LABEL \
  maintainer="Frederico Martins <https://hub.docker.com/u/fscm/>" \
  vendor="fscm" \
  cmd="docker container run --interactive --rm --tty fscm/debian" \
  params=""

COPY --from=second_stage "/" "/"

ENV \
  LANG="C.UTF-8" \
  DEBCONF_NONINTERACTIVE_SEEN="true" \
  DEBIAN_FRONTEND="noninteractive"

CMD ["/bin/bash"]
