FROM ubuntu:disco-20190809

LABEL maintainer="pat@patdouble.com"

ENV APT_CACHER_NG_VERSION=3.2 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng \
    DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh /sbin/entrypoint.sh

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    apt-cacher-ng=${APT_CACHER_NG_VERSION}* curl ca-certificates \
    && sed 's/# ForeGround: 0/ForeGround: 1/' -i /etc/apt-cacher-ng/acng.conf \
    && sed 's/# TrackFileUse: 0/TrackFileUse: 1/' -i /etc/apt-cacher-ng/acng.conf \
    && sed 's/# VfileUseRangeOps: 1/VfileUseRangeOps: 0/' -i /etc/apt-cacher-ng/acng.conf \
    && sed -E 's/Remap-fedora:\s+file:fedora_mirrors\s+#/Remap-fedora: file:fedora_mirrors \/fedora #/' -i /etc/apt-cacher-ng/acng.conf \
    && sed -E 's/Remap-epel:\s+file:epel_mirrors\s+#/Remap-epel: file:epel_mirrors \/epel #/' -i /etc/apt-cacher-ng/acng.conf \
    && sed 's/# PassThroughPattern:.*this would allow.*/PassThroughPattern: .* #/' -i /etc/apt-cacher-ng/acng.conf \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'VfilePatternEx: ^(\/mirrorlist\/.*|/\?release=[0-9]+&arch=.*|.*/RPM-GPG-KEY.*)$' >> /etc/apt-cacher-ng/acng.conf \
    && echo 'Remap-centos: file:centos_mirrors /centos' >> /etc/apt-cacher-ng/acng.conf \
    && echo 'DontCache: (mirrorlist.centos.org)|(/mirrorlist/)|(.bz2$)' >> /etc/apt-cacher-ng/acng.conf \
    && chmod 755 /sbin/entrypoint.sh

EXPOSE 3142/tcp

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/apt-cacher-ng"]
