# sysinfo

A bash script to quickly enumerate system info

```sh
bash <(curl -s https://raw.githubusercontent.com/norgeous/sysinfo/master/install.sh)
```

or

```sh
bash <(curl -s https://gitcdn.xyz/repo/norgeous/sysinfo/master/install.sh)
```

then

```sh
sysinfo -h
watch -n .5 sysinfo -e
```

# piv

Using info from https://elinux.org/RPi_HardwareHistory and the revision listed in `/proc/cpuinfo`, it determines the hardware version of your Raspberry Pi.

```sh
piv
```
