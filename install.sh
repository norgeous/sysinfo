#!/bin/bash
[[ $EUID -ne 0 ]] && echo "You must be running as user root." && exit 1


[ ! -x "$(command -v iostat)" ] && echo "installing sysstat/iostat..." && apt install -y sysstat
[ ! -x "$(command -v dig)" ] && echo "installing dnsutils/dig..." && apt install -y dnsutils

echo "remove old sysinfo install..."
rm -r "/opt/sysinfo"

echo "make install dir..."
mkdir -p "/opt/sysinfo"

echo "download and install sysinfo script..."
curl --silent "https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/sysinfo.sh" --output "/opt/sysinfo/sysinfo.sh"
chmod a+x "/opt/sysinfo/sysinfo.sh"
[ -L "/usr/bin/sysinfo" ] && rm "/usr/bin/sysinfo"
ln -s "/opt/sysinfo/sysinfo.sh" "/usr/bin/sysinfo"

echo "download and install piv script..."
curl --silent "https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/piv.sh" --output "/opt/sysinfo/piv.sh"
chmod a+x "/opt/sysinfo/piv.sh"
[ -L "/usr/bin/piv" ] && rm "/usr/bin/piv"
ln -s "/opt/sysinfo/piv.sh" "/usr/bin/piv"

read -p "Install systemd socat server for unprotected network access to sysinfo on port 9009? " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  echo "install socat..."
  apt install -y socat
  
  echo "download and install sysinfo server script..."
  curl --silent "https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/server.sh" --output "/opt/sysinfo/server.sh"
  chmod a+x "/opt/sysinfo/server.sh"
  
  echo "download and install systemd sysinfo.service file..."
  curl --silent "https://raw.githubusercontent.com/norgeous/sysinfo/master/bin/sysinfo.service" --output "/etc/systemd/system/sysinfo.service"

  echo "enable (autostart) and start sysinfo server..."
  systemctl enable sysinfo
  systemctl start sysinfo
fi

echo "done"
