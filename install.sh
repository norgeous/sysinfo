#!/bin/bash
[[ $EUID -ne 0 ]] && echo "You must be running as user root." && exit 1

apt install -y sysstat dnsutils

# remove old install
rm -r "/usr/local/bin/sysinfo"

# make install dir
mkdir -p "/usr/local/bin/sysinfo"

# download and install sysinfo script
curl https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/sysinfo.sh --output "/usr/local/bin/sysinfo"
chmod a+x /usr/local/bin/sysinfo/sysinfo.sh
[ ! -L "/usr/bin/sysinfo" ] && ln -s /opt/sysinfo.sh /usr/bin/sysinfo
  
# download and install piv script
curl https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/piv.sh --output "/usr/local/bin/piv"
chmod a+x /opt/piv.sh
[ ! -L "/usr/bin/piv" ] && ln -s /opt/piv.sh /usr/bin/piv
  
