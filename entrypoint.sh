#!/bin/bash
set -e

create_pid_dir() {
  mkdir -p /run/apt-cacher-ng
  chmod -R 0755 /run/apt-cacher-ng
  chown ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} /run/apt-cacher-ng
}

create_cache_dir() {
  mkdir -p ${APT_CACHER_NG_CACHE_DIR}
  chmod -R 0755 ${APT_CACHER_NG_CACHE_DIR}
  chown -R ${APT_CACHER_NG_USER}:root ${APT_CACHER_NG_CACHE_DIR}
}

create_log_dir() {
  mkdir -p ${APT_CACHER_NG_LOG_DIR}
  chmod -R 0755 ${APT_CACHER_NG_LOG_DIR}
  chown -R ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} ${APT_CACHER_NG_LOG_DIR}
}

create_pid_dir
create_cache_dir
create_log_dir

# Populate mirrors
curl -s 'https://www.centos.org/download/full-mirrorlist.csv' | sed 's/^.*"http:/http:/' | sed 's/".*$//' | grep ^http >/etc/apt-cacher-ng/centos_mirrors

for R in 28 29 30 31 32; do curl -sL "https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-${R}&arch=x86_64"; done | sed 's/^.*"http:/http:/' | sed 's/".*$//' | sed 's:os/$::' | grep ^http >/etc/apt-cacher-ng/fedora_mirrors
cat /etc/apt-cacher-ng/fedora_mirrors | grep -F '/releases/' | sed 's:/releases/:/updates/:' > /tmp/fedora_updates
cat /tmp/fedora_updates >> /etc/apt-cacher-ng/fedora_mirrors

for R in epel-7 epel-8; do curl -sL "http://mirrors.fedoraproject.org/metalink?repo=${R}&arch=x86_64"; done | grep "<url" | sed -e "s/^.*>\(.*\)<.*>/\1/" | grep '^http' | rev | cut -d "/" -f 5- | rev | sort -u | uniq > /etc/apt-cacher-ng/epel_mirrors

# allow arguments to be passed to apt-cacher-ng
if [[ ${1:0:1} = '-' ]]; then
  EXTRA_ARGS="$@"
  set --
elif [[ ${1} == apt-cacher-ng || ${1} == $(which apt-cacher-ng) ]]; then
  EXTRA_ARGS="${@:2}"
  set --
fi

# default behaviour is to launch apt-cacher-ng
if [[ -z ${1} ]]; then
  exec start-stop-daemon --start --chuid ${APT_CACHER_NG_USER}:${APT_CACHER_NG_USER} \
    --exec $(which apt-cacher-ng) -- -c /etc/apt-cacher-ng ${EXTRA_ARGS}
else
  exec "$@"
fi
