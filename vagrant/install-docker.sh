#!/usr/bin/env bash
set -xeuo pipefail
export DEBIAN_FRONTEND=noninteractive
rgrep -l archive.ubuntu.com /etc/apt/ | xargs -P0 -I{} sed -i -e 's/archive.ubuntu.com/ru.archive.ubuntu.com/' {}
sysctl net.ipv6.conf.all.forwarding=1
apt-get update
apt-get install -y apt-transport-https software-properties-common apache2-utils git

# docker
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D81803C0EBFCD88
add-apt-repository "deb https://download.docker.com/linux/ubuntu bionic edge"

apt-get update
apt-get install -y docker-ce
apt-get install -y htop ethtool mc iotop
apt-get install -y python-pip
pip install -U docker-compose requests

rm -rf /opt/flamescope/
git clone https://github.com/Netflix/flamescope.git /opt/flamescope/

echo -1 > /proc/sys/kernel/perf_event_paranoid
echo 0 > /proc/sys/kernel/kptr_restrict

printf "kernel.kptr_restrict = 0\nkernel.perf_event_paranoid = -1" > /etc/sysctl.d/99-perf.conf