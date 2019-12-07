#!/bin/bash

TIMESTAMP_START=$(date +%s%N)

function usage {
  echo
  echo "Gather system info and display in a greppable format or json"
  echo
  echo "usage: sysinfo [options]"
  echo
  echo "Options:"
  echo -e "\t-h  Shows this help"
  echo -e "\toperations:"
  echo -e "\t-e  Show extended values"
  echo -e "\toutput:"
  echo -e "\t-p  Show pretty (human readable) values (default)"
  echo -e "\t-v  Show values without labels and as Bytes"
  echo -e "\t-v  Show values without labels and as Bytes"
  echo
}

info_mode="simple"
output_mode="human"
server_mode="no"

OPTIND=1 # Reset shell
while getopts "h?epvj" opt; do
  case "$opt" in
  h|\?)
    usage
    exit 0
    ;;
  e)
    info_mode="extended"
    ;;
  p)
    output_mode="human"       # default output
    ;;
  v)
    output_mode="valuesonly"
    ;;
  j)
    output_mode="json"
    ;;
  s)
    server_mode="netcat"
    ;;
  esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift
args="$*"

# simple
HOST_NAME=$(hostname)
CPU_USAGE=$(cat <(grep 'cpu ' /proc/stat) <(sleep 1 && grep 'cpu ' /proc/stat) | awk -v RS="" '{print ($13-$2+$15-$4)*100/($13-$2+$15-$4+$16-$5)}')
CPU_PROCESSES=$(ps -A --no-headers | wc -l)
CPU_TEMPERATURE=$(echo "2k `cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0` 1000 / p" | dc)
GPU_TEMPERATURE=$(/opt/vc/bin/vcgencmd measure_temp | cut -d'=' -f2 | sed "s|'C||")
RAM_USAGE=$(free -b | grep "Mem:" | awk '{print $3}')
RAM_TOTAL=$(free -b | grep "Mem:" | awk '{print $2}')

# extended
if [ "$info_mode" == "extended" ]; then
  HOST_START=$(uptime -s)
  HOST_UPTIME=$(uptime -p)
  HOST_KERNEL=$(uname -r | cut -d+ -f1 | cut -d- -f1)
  HOST_USERS=$(who -q | grep "# users=" | cut -d'=' -f2)
  CPU_VOLT=$(/opt/vc/bin/vcgencmd measure_volts core | cut -d'=' -f2 | sed 's|V||')
  CPU_FREQ=$(echo "0k `/opt/vc/bin/vcgencmd measure_clock arm | cut -d'=' -f2` 1000000 / p" | dc)
  GPU_RAM_USAGE=$(/opt/vc/bin/vcgencmd get_mem reloc | cut -d'=' -f2 | numfmt --from=auto)
  GPU_RAM_TOTAL=$(/opt/vc/bin/vcgencmd get_mem gpu | cut -d'=' -f2 | numfmt --from=auto)
  DISK_USAGE=$(df -PB1 | grep "/dev/root" | awk '{print $3}')
  DISK_TOTAL=$(df -PB1 | grep "/dev/root" | awk '{print $2}')
  DISK_READ=$(iostat -d | grep "mmcblk0" | awk '{print $5 "K"}' | numfmt --from=auto)
  DISK_WRITTEN=$(iostat -d | grep "mmcblk0" | awk '{print $6 "K"}' | numfmt --from=auto)
  NET_LOCAL_IP=$(ip route get 1 | awk '{print $NF;exit}')
  NET_WAN_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
  NET_ETH_TX=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo 0)
  NET_ETH_RX=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo 0)
  NET_WLAN_TX=$(cat /sys/class/net/wlan0/statistics/tx_bytes 2>/dev/null || echo 0)
  NET_WLAN_RX=$(cat /sys/class/net/wlan0/statistics/rx_bytes 2>/dev/null || echo 0)
  NET_OPEN_PORTS=$(ss -nltpH | sed 's/\[:\]/0.0.0.0/g' | tr -s ' :' | awk -F'[ :"]' '{print $5 "(" $10 ")"}' | sort -g | uniq | paste -sd " " -)
  [ -x "$(command -v node)" ] && NODE_V=$(node -v)
  [ -x "$(command -v npm)" ] && NPM_G_LS=$(npm ls -gp --depth=0 | grep node_modules | sed 's|/usr/local/lib/node_modules/||' | tr '\n' ' ' | sed 's/.$//')
  [ -x "$(command -v npm)" ] && NPM_V=$(npm -v)
fi

TIMESTAMP_END=$(date +%s%N)
ENUM_TIME=$(awk "BEGIN { print ($TIMESTAMP_END - $TIMESTAMP_START) / 1000000000 }")

case "$output_mode" in
  human)
    (
      [ -n "$HOST_NAME" ]       && echo "HOST_NAME       + ${HOST_NAME}"
      [ -n "$HOST_KERNEL" ]     && echo "HOST_KERNEL     + ${HOST_KERNEL}"
      [ -n "$HOST_START" ]      && echo "HOST_START      + ${HOST_START}"
      [ -n "$HOST_UPTIME" ]     && echo "HOST_UPTIME     + ${HOST_UPTIME}"
      [ -n "$HOST_USERS" ]      && echo "HOST_USERS      + ${HOST_USERS}"
      [ -n "$CPU_USAGE" ]       && echo "CPU_USAGE       + ${CPU_USAGE}%"
      [ -n "$CPU_PROCESSES" ]   && echo "CPU_PROCESSES   + ${CPU_PROCESSES}"
      [ -n "$CPU_TEMPERATURE" ] && echo "CPU_TEMPERATURE + ${CPU_TEMPERATURE} Celsius"
      [ -n "$CPU_VOLTAGE" ]     && echo "CPU_VOLTAGE     + ${CPU_VOLT} Volts"
      [ -n "$CPU_FREQUENCY" ]   && echo "CPU_FREQUENCY   + ${CPU_FREQ} MHz"
      [ -n "$GPU_TEMPERATURE" ] && echo "GPU_TEMPERATURE + ${GPU_TEMPERATURE} Celsius"
      [ -n "$GPU_RAM_USAGE" ]   && echo "GPU_RAM_USAGE   + $(numfmt --to=iec --suffix=B $GPU_RAM_USAGE) ($(echo "2k $GPU_RAM_USAGE 100 * $GPU_RAM_TOTAL / p" | dc)%)"
      [ -n "$GPU_RAM_TOTAL" ]   && echo "GPU_RAM_TOTAL   + $(numfmt --to=iec --suffix=B $GPU_RAM_TOTAL)"
      [ -n "$RAM_USAGE" ]       && echo "RAM_USAGE       + $(numfmt --to=iec --suffix=B $RAM_USAGE) ($(echo "2k $RAM_USAGE 100 * $RAM_TOTAL / p" | dc)%)"
      [ -n "$RAM_TOTAL" ]       && echo "RAM_TOTAL       + $(numfmt --to=iec --suffix=B $RAM_TOTAL)"
      [ -n "$DISK_USAGE" ]      && echo "DISK_USAGE      + $(numfmt --to=iec --suffix=B $DISK_USAGE) ($(echo "2k $DISK_USAGE 100 * $DISK_TOTAL / p" | dc)%)"
      [ -n "$DISK_TOTAL" ]      && echo "DISK_TOTAL      + $(numfmt --to=iec --suffix=B $DISK_TOTAL)"
      [ -n "$DISK_READ" ]       && echo "DISK_READ       + $(numfmt --to=iec --suffix=B $DISK_READ)"
      [ -n "$DISK_WRITTEN" ]    && echo "DISK_WRITTEN    + $(numfmt --to=iec --suffix=B $DISK_WRITTEN)"
      [ -n "$NET_LOCAL_IP" ]    && echo "NET_LOCAL_IP    + ${NET_LOCAL_IP}"
      [ -n "$NET_WAN_IP" ]      && echo "NET_WAN_IP      + ${NET_WAN_IP}"
      [ -n "$NET_ETH_TX" ]      && echo "NET_ETH_TX      + $(numfmt --to=iec --suffix=B $NET_ETH_TX)"
      [ -n "$NET_ETH_RX" ]      && echo "NET_ETH_RX      + $(numfmt --to=iec --suffix=B $NET_ETH_RX)"
      [ -n "$NET_WLAN_TX" ]     && echo "NET_WLAN_TX     + $(numfmt --to=iec --suffix=B $NET_WLAN_TX)"
      [ -n "$NET_WLAN_RX" ]     && echo "NET_WLAN_RX     + $(numfmt --to=iec --suffix=B $NET_WLAN_RX)"
      [ -n "$NET_OPEN_PORTS" ]  && echo "NET_OPEN_PORTS  + ${NET_OPEN_PORTS}"
      [ -n "$NPM_G_LS" ]        && echo "NPM_G_LS        + ${NPM_G_LS}"
      [ -n "$TIMESTAMP_START" ] && echo "TIMESTAMP_START + ${TIMESTAMP_START}"
      [ -n "$TIMESTAMP_END" ]   && echo "TIMESTAMP_END   + ${TIMESTAMP_END}"
      [ -n "$ENUM_TIME" ]       && echo "ENUM_TIME       + ${ENUM_TIME} seconds"
    ) | tr -s " " | column -t -s '+'
    ;;
  valuesonly)
    (
      [ -n "$HOST_NAME" ]       && echo "HOST_NAME       + ${HOST_NAME}"
      [ -n "$HOST_KERNEL" ]     && echo "HOST_KERNEL     + ${HOST_KERNEL}"
      [ -n "$HOST_START" ]      && echo "HOST_START      + ${HOST_START}"
      [ -n "$HOST_UPTIME" ]     && echo "HOST_UPTIME     + ${HOST_UPTIME}"
      [ -n "$HOST_USERS" ]      && echo "HOST_USERS      + ${HOST_USERS}"
      [ -n "$CPU_USAGE" ]       && echo "CPU_USAGE       + ${CPU_USAGE}"
      [ -n "$CPU_PROCESSES" ]   && echo "CPU_PROCESSES   + ${CPU_PROCESSES}"
      [ -n "$CPU_TEMPERATURE" ] && echo "CPU_TEMPERATURE + ${CPU_TEMPERATURE}"
      [ -n "$CPU_VOLTAGE" ]     && echo "CPU_VOLTAGE     + ${CPU_VOLT}"
      [ -n "$CPU_FREQUENCY" ]   && echo "CPU_FREQUENCY   + ${CPU_FREQ}"
      [ -n "$GPU_TEMPERATURE" ] && echo "GPU_TEMPERATURE + ${GPU_TEMPERATURE}"
      [ -n "$GPU_RAM_USAGE" ]   && echo "GPU_RAM_USAGE   + ${GPU_RAM_USAGE}"
      [ -n "$GPU_RAM_TOTAL" ]   && echo "GPU_RAM_TOTAL   + ${GPU_RAM_TOTAL}"
      [ -n "$RAM_USAGE" ]       && echo "RAM_USAGE       + ${RAM_USAGE}"
      [ -n "$RAM_TOTAL" ]       && echo "RAM_TOTAL       + ${RAM_TOTAL}"
      [ -n "$DISK_USAGE" ]      && echo "DISK_USAGE      + ${DISK_USAGE}"
      [ -n "$DISK_TOTAL" ]      && echo "DISK_TOTAL      + ${DISK_TOTAL}"
      [ -n "$DISK_READ" ]       && echo "DISK_READ       + ${DISK_READ}"
      [ -n "$DISK_WRITTEN" ]    && echo "DISK_WRITTEN    + ${DISK_WRITTEN}"
      [ -n "$NET_LOCAL_IP" ]    && echo "NET_LOCAL_IP    + ${NET_LOCAL_IP}"
      [ -n "$NET_WAN_IP" ]      && echo "NET_WAN_IP      + ${NET_WAN_IP}"
      [ -n "$NET_ETH_TX" ]      && echo "NET_ETH_TX      + ${NET_ETH_TX}"
      [ -n "$NET_ETH_RX" ]      && echo "NET_ETH_RX      + ${NET_ETH_RX}"
      [ -n "$NET_WLAN_TX" ]     && echo "NET_WLAN_TX     + ${NET_WLAN_TX}"
      [ -n "$NET_WLAN_RX" ]     && echo "NET_WLAN_RX     + ${NET_WLAN_RX}"
      [ -n "$NET_OPEN_PORTS" ]  && echo "NET_OPEN_PORTS  + ${NET_OPEN_PORTS}"
      [ -n "$NPM_G_LS" ]        && echo "NPM_G_LS        + ${NPM_G_LS}"
      [ -n "$TIMESTAMP_START" ] && echo "TIMESTAMP_START + ${TIMESTAMP_START}"
      [ -n "$TIMESTAMP_END" ]   && echo "TIMESTAMP_END   + ${TIMESTAMP_END}"
      [ -n "$ENUM_TIME" ]       && echo "ENUM_TIME       + ${ENUM_TIME}"
    ) | tr -s " " | column -t -s '+'
    ;;
  json)
    (
      echo "{"
      [ -n "$HOST_NAME" ]       && echo "\"HOST_NAME\":       + \"${HOST_NAME}\","
      [ -n "$HOST_KERNEL" ]     && echo "\"HOST_KERNEL\":     + \"${HOST_KERNEL}\","
      [ -n "$HOST_START" ]      && echo "\"HOST_START\":      + \"${HOST_START}\","
      [ -n "$HOST_UPTIME" ]     && echo "\"HOST_UPTIME\":     + \"${HOST_UPTIME}\","
      [ -n "$HOST_USERS" ]      && echo "\"HOST_USERS\":      + ${HOST_USERS},"
      [ -n "$CPU_USAGE" ]       && echo "\"CPU_USAGE\":       + ${CPU_USAGE},"
      [ -n "$CPU_PROCESSES" ]   && echo "\"CPU_PROCESSES\":   + ${CPU_PROCESSES},"
      [ -n "$CPU_TEMPERATURE" ] && echo "\"CPU_TEMPERATURE\": + ${CPU_TEMPERATURE},"
      [ -n "$CPU_VOLTAGE" ]     && echo "\"CPU_VOLTAGE\":     + ${CPU_VOLT},"
      [ -n "$CPU_FREQUENCY" ]   && echo "\"CPU_FREQUENCY\":   + ${CPU_FREQ},"
      [ -n "$GPU_TEMPERATURE" ] && echo "\"GPU_TEMPERATURE\": + ${GPU_TEMPERATURE},"
      [ -n "$GPU_RAM_USAGE" ]   && echo "\"GPU_RAM_USAGE\":   + ${GPU_RAM_USAGE},"
      [ -n "$GPU_RAM_TOTAL" ]   && echo "\"GPU_RAM_TOTAL\":   + ${GPU_RAM_TOTAL},"
      [ -n "$RAM_USAGE" ]       && echo "\"RAM_USAGE\":       + ${RAM_USAGE},"
      [ -n "$RAM_TOTAL" ]       && echo "\"RAM_TOTAL\":       + ${RAM_TOTAL},"
      [ -n "$DISK_USAGE" ]      && echo "\"DISK_USAGE\":      + ${DISK_USAGE},"
      [ -n "$DISK_TOTAL" ]      && echo "\"DISK_TOTAL\":      + ${DISK_TOTAL},"
      [ -n "$DISK_READ" ]       && echo "\"DISK_READ\":       + ${DISK_READ},"
      [ -n "$DISK_WRITTEN" ]    && echo "\"DISK_WRITTEN\":    + ${DISK_WRITTEN},"
      [ -n "$NET_LOCAL_IP" ]    && echo "\"NET_LOCAL_IP\":    + \"${NET_LOCAL_IP}\","
      [ -n "$NET_WAN_IP" ]      && echo "\"NET_WAN_IP\":      + \"${NET_WAN_IP}\","
      [ -n "$NET_ETH_TX" ]      && echo "\"NET_ETH_TX\":      + ${NET_ETH_TX},"
      [ -n "$NET_ETH_RX" ]      && echo "\"NET_ETH_RX\":      + ${NET_ETH_RX},"
      [ -n "$NET_WLAN_TX" ]     && echo "\"NET_WLAN_TX\":     + ${NET_WLAN_TX},"
      [ -n "$NET_WLAN_RX" ]     && echo "\"NET_WLAN_RX\":     + ${NET_WLAN_RX},"
      [ -n "$NET_OPEN_PORTS" ]  && echo "\"NET_OPEN_PORTS\":  + \"${NET_OPEN_PORTS}\","
      [ -n "$NPM_G_LS" ]        && echo "\"NPM_G_LS\":        + \"${NPM_G_LS}\","
      [ -n "$TIMESTAMP_START" ] && echo "\"TIMESTAMP_START\": + ${TIMESTAMP_START}"
      [ -n "$TIMESTAMP_END" ]   && echo "\"TIMESTAMP_END\":   + ${TIMESTAMP_END}"
      [ -n "$ENUM_TIME" ]       && echo "\"ENUM_TIME\":       + ${ENUM_TIME}"
      echo "}"
    ) | tr -s " " | column -t -s '+'
    ;;
  esac

read -r -d '' HTTP_HEAD <<-'EOT'
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
Server: netcat-sysinfo
EOT

if [ "$server_mode" == "netcat" ]; then
  while true; do
    echo "$HTTP_HEAD data here" | nc -l 6060
  done
fi
