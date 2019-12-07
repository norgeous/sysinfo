#!/bin/bash
[[ $EUID -ne 0 ]] && echo "You must be running as user root." && exit 1

echo "installing sysstat and dnsutils..."
apt install -y sysstat dnsutils

echo "remove old sysinfo install..."
rm -r "/opt/sysinfo"

echo "make install dir..."
mkdir -p "/opt/sysinfo"

echo "download and install sysinfo script"
curl https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/sysinfo.sh --output "/opt/sysinfo/sysinfo.sh"
chmod a+x "/opt/sysinfo/sysinfo.sh"
[ ! -L "/usr/bin/sysinfo" ] && ln -s "/opt/sysinfo.sh" "/usr/bin/sysinfo"

echo "download and install piv script"
curl https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/piv.sh --output "/opt/sysinfo/piv.sh"
chmod a+x "/opt/sysinfo/piv.sh"
[ ! -L "/usr/bin/piv" ] && ln -s "/opt/sysinfo/piv.sh" "/usr/bin/piv"
  