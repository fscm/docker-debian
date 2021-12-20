# global args
ARG __BUILD_DIR__="/build"
ARG OS_VERSION="11.2.0"



FROM debian:bullseye as build

ARG __BUILD_DIR__
ARG OS_VERSION
ARG OS_CODENAME="bullseye"
ARG __USER__="root"
ARG __WORK_DIR__="/root"

ENV \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

USER ${__USER__}

#COPY --chown="${__USER__}":${__USER__} "LICENSE" "files/" "${__WORK_DIR__}/"
COPY "LICENSE" "files/" "${__WORK_DIR__}"/

WORKDIR "${__WORK_DIR__}"

SHELL ["/bin/bash", "-c"]

RUN \
# build env
    echo '--> setting build env' && \
    export __ARCH__="$(case `arch` in x86_64) echo '--arch=amd64';; aarch64) echo '--arch=arm64';; esac)" && \
# build structure
    echo '--> creating build structure' && \
    for folder in '/licenses'; do install --directory --owner="${__USER__}" --group="${__USER__}" --mode=0755 "${__BUILD_DIR__}${folder}"; done && \
# dependencies
    echo '--> instaling dependencies' && \
    apt-get -qq update && \
    apt-get -qq -y -o=Dpkg::Use-Pty=0 --no-install-recommends install \
        binutils \
        ca-certificates \
        coreutils \
        curl \
        dbus \
        debian-archive-keyring \
        debootstrap \
        dpkg-dev \
        wget \
        > /dev/null 2>&1 && \
# build base os
    echo '--> building base os' && \
    debootstrap \
        --variant='minbase' \
        ${__ARCH__} \
        --exclude='sensible-utils' \
        "${OS_CODENAME}" \
        "${__BUILD_DIR__}" && \
    install --directory --owner="${__USER__}" --group="${__USER__}" --mode=0755 "${__BUILD_DIR__}/licenses/debian" && \
    (cd "${__BUILD_DIR__}/licenses/debian" && curl --silent --location --retry 3 --remote-name "http://ftp.debian.org/debian/doc/social-contract.txt") && \
# update base os
    echo '-->  updating base os' && \
    echo "deb http://deb.debian.org/debian ${OS_CODENAME} main non-free contrib" > "${__BUILD_DIR__}/etc/apt/sources.list" && \
    echo "deb http://security.debian.org/debian-security ${OS_CODENAME}-security main contrib non-free" >> "${__BUILD_DIR__}/etc/apt/sources.list" && \
    echo "deb http://deb.debian.org/debian ${OS_CODENAME}-updates main contrib non-free" >> "${__BUILD_DIR__}/etc/apt/sources.list" && \
    chroot "${__BUILD_DIR__}" apt-get -qq update && \
    chroot "${__BUILD_DIR__}" apt-get -qq -y -o Dpkg::Options::="--force-confdef" --no-install-recommends upgrade && \
    chroot "${__BUILD_DIR__}" apt-get clean && \
# copy tests
    echo '--> copying test files' && \
    install --owner="${__USER__}" --group="${__USER__}" --mode=0755 --target-directory="${__BUILD_DIR__}/usr/bin" "${__WORK_DIR__}/tests"/* && \
# system settings / cleanup
    echo '--> system settings / cleaning up' && \
    sed -i -s '/.*NeverAutoRemove.*/,/^$/d' "${__BUILD_DIR__}/etc/apt/apt.conf.d/01autoremove" && \
    APT_GET_CLEAN='"rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";' && \
    printf 'DPkg::Post-Invoke { %s };\nAPT::Update::Post-Invoke { %s };\nDir::Cache::pkgcache "";\nDir::Cache::srcpkgcache "";\n' "${APT_GET_CLEAN}" "${APT_GET_CLEAN}" > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-clean" && \
    printf 'DPkg::Use-Pty "false";\n' > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-no-dpkg-output" && \
    printf 'Acquire::Languages "none";\n' > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-no-languages" && \
    printf 'Acquire::GzipIndexes "true";\nAcquire::CompressionTypes::Order:: "gz";\n' > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-gzip-indexes" && \
    printf 'APT::AutoRemove::SuggestsImportant "false";\n' > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-autoremove-suggests" && \
    printf 'APT::Install-Recommends "false";\n' > "${__BUILD_DIR__}/etc/apt/apt.conf.d/90docker-no-recommends" && \
    printf 'force-unsafe-io\n' > "${__BUILD_DIR__}/etc/dpkg/dpkg.cfg.d/90docker-apt-speedup" && \
    printf 'path-exclude=/usr/share/doc/*\npath-exclude=/usr/share/info/*\npath-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-include=/usr/share/doc/*/copyright\n' > "${__BUILD_DIR__}/etc/dpkg/dpkg.cfg.d/90docker-excludes" && \
    echo '' > "${__BUILD_DIR__}/etc/resolv.conf" && \
    echo 'host' > "${__BUILD_DIR__}/etc/hostname" && \
    :> "${__BUILD_DIR__}/etc/machine-id" && \
    find "${__BUILD_DIR__}/etc" -path '*/systemd/system/*.wants/*' \( -type l -o -type f \) -delete && \
    if [ -x "${__BUILD_DIR__}/usr/bin/dpkg-divert" ]; then chroot "${__BUILD_DIR__}/" dpkg-divert --local --rename --add /sbin/initctl; fi && \
    printf '#!/bin/sh\nexit 101\n' > "${__BUILD_DIR__}/usr/sbin/policy-rc.d" && \
    printf '#!/bin/sh\nexit 0\n' > "${__BUILD_DIR__}/sbin/initctl" && \
    chmod 0755 "${__BUILD_DIR__}/usr/sbin/policy-rc.d" "${__BUILD_DIR__}/sbin/initctl" && \
    rm -rf "${__BUILD_DIR__}/usr/share/info"/* && \
    rm -rf "${__BUILD_DIR__}/usr/share/man"/* && \
    rm -rf "${__BUILD_DIR__}/var/cache/apt"/* && \
    rm -rf "${__BUILD_DIR__}/var/lib/apt/lists"/* && \
    rm -rf "${__BUILD_DIR__}/var/log"/* && \
    rm -rf "${__BUILD_DIR__}/dev"/.??* && \
    rm -rf "${__BUILD_DIR__}/home"/.??* && \
    rm -rf "${__BUILD_DIR__}/root"/.??* && \
    rm -rf "${__BUILD_DIR__}/tmp"/.??* && \
    rm -rf "${__BUILD_DIR__}/boot" && \
    rm -rf "${__BUILD_DIR__}/proc" && \
    rm -rf "${__BUILD_DIR__}/sys" && \
    find "${__BUILD_DIR__}/usr/lib/`arch`-linux-gnu/gconv" -mindepth 1 -maxdepth 1 -type f -not -name 'UTF*' -delete && \
    find "${__BUILD_DIR__}/usr/share/locale" -mindepth 1 -maxdepth 1 -type d -not \( -name 'en' -o -name 'en_US' \) -exec rm -r {} + && \
    find "${__BUILD_DIR__}/usr/share/doc" -mindepth 1 -not -type d -not \( -iname 'COPYING*' -o -iname 'GPL' -o -iname '*LICENSE*' -o -iname 'copyright' \) -delete && \
    find "${__BUILD_DIR__}/usr/share/doc" -mindepth 1 -type d -empty -delete && \
    find "${__BUILD_DIR__}/var/cache" -type f -delete && \
# licenses
    echo '--> project licenses' && \
    install --owner=${__USER__} --group=${__USER__} --mode=0644 --target-directory="${__BUILD_DIR__}/licenses" "${__WORK_DIR__}/LICENSE" && \
# check version
    echo '--> os version' && \
    cat "${__BUILD_DIR__}/etc/debian_version" && \
    chroot "${__BUILD_DIR__}" arch && \
# done
    echo '--> all done!'



FROM scratch

ARG __BUILD_DIR__
ARG OS_VERSION

LABEL \
    maintainer="Frederico Martins <https://hub.docker.com/u/fscm/>" \
    vendor="fscm" \
    cmd="docker container run --interactive --rm --tty fscm/debian:bullseye" \
    org.label-schema.schema-version="1.0" \
    org.label-schema.name="fscm/debian" \
    org.label-schema.description="A small Debian Linux image" \
    org.label-schema.url="https://www.debian.org/" \
    org.label-schema.vcs-url="https://github.com/fscm/docker-debian/" \
    org.label-schema.vendor="fscm" \
    org.label-schema.version=${OS_VERSION} \
    org.label-schema.docker.cmd="docker container run --interactive --rm --tty fscm/debian:bullseye" \
    org.label-schema.docker.cmd.test="docker container run --interactive --rm --tty fscm/debian:bullseye in_sanity"

ENV \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

COPY --from=build "${__BUILD_DIR__}" "/"

CMD ["/bin/bash"]
