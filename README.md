# sysinfo

---

A bash script to quickly enumerate system info

---

### Install

Install both `sysinfo` and `piv` with:

```sh
bash <(curl -s https://raw.githubusercontent.com/norgeous/sysinfo/master/install.sh)
```

---

### Usage

##### sysinfo

```sh
sysinfo -h
watch -n .5 sysinfo -e
```

##### piv

Using data from https://elinux.org/RPi_HardwareHistory and the CPU revision from `/proc/cpuinfo` it determines the hardware version of your Raspberry Pi.

```sh
piv
```
