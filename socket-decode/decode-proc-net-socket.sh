#!/usr/bin/env bash


: <<'NET'

  /proc/PID/net/tcp

  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
  80: FE01A8C0:CB4E 5101A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 100395273 1 ffff9d71c9881c80 20 4 12 10 -1

  example usage:

 PID: 1258868
 lrwx------ 1 jkstill jkstill 64 Dec  3 16:07 /proc/1258868/fd/10 -> 'socket:[100413043]'
 inode: 100413043
   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   81: FE01A8C0:A80E E901A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 100413043 1 ffff9d719725d580 20 4 18 10 -1

 localConnection: FE01A8C0:A80E
     Hex IP: FE01A8C0
   Hex Port: A80E

 remoteConnection: E901A8C0:05F1
     Hex IP: E901A8C0
   Hex Port: 05F1

 [root@poirot ~]# ./decode-port.sh
 PID: 1258868
 lrwx------ 1 jkstill jkstill 64 Dec  3 16:07 /proc/1258868/fd/10 -> 'socket:[100413043]'
 inode: 100413043
   sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode
   81: FE01A8C0:A80E E901A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 100413043 1 ffff9d719725d580 20 4 18 10 -1

 localConnection: FE01A8C0:A80E
     Hex IP: FE01A8C0
   Hex Port: A80E

 remoteConnection: E901A8C0:05F1
     Hex IP: E901A8C0
   Hex Port: 05F1

  local: 192.168.1.254:43022
 remote: 192.168.1.233:1521

NET

getIpFromHex() {
	local hexIP=$1
	local octet1=$((16#${hexIP:0:2}))
	local octet2=$((16#${hexIP:2:2}))
	local octet3=$((16#${hexIP:4:2}))
	local octet4=$((16#${hexIP:6:2}))

	echo "$octet4.$octet3.$octet2.$octet1"
}

getPortFromHex() {
	local hexPort=$1
	local port=$((16#$hexPort))
	echo "$port"
}


# hard coded for the first sqlplus session that appears
# alter for your own use
PID=$(ps -eo pid,cmd | grep -v 'rlwrap' | grep [s]qlplus | head -1 | awk '{ print $1 }')

[[ -z $PID ]] && { echo "sqlplus not found"; exit 1; }

echo "PID: $PID"

ls -l /proc/$PID/fd/10

socketInode=$(readlink /proc/$PID/fd/10 | cut -f2 -d: | tr -d '[\[\]]')

echo "inode: $socketInode"

tcpFile="/proc/$PID/net/tcp"

head -1 $tcpFile

grep $socketInode $tcpFile

localConnection=$(grep $socketInode $tcpFile| awk '{ print $2 }')
remoteConnection=$(grep $socketInode $tcpFile| awk '{ print $3 }')

localHexIP=$(echo $localConnection  | cut -f1 -d:)
localHexPort=$(echo $localConnection  | cut -f2 -d:)

remoteHexIP=$(echo $remoteConnection  | cut -f1 -d:)
remoteHexPort=$(echo $remoteConnection  | cut -f2 -d:)

echo 
echo "localConnection: $localConnection"
echo "    Hex IP: $localHexIP"
echo "  Hex Port: $localHexPort"
echo 
echo "remoteConnection: $remoteConnection"
echo "    Hex IP: $remoteHexIP"
echo "  Hex Port: $remoteHexPort"

echo

localIP=$(getIpFromHex $localHexIP)
localPort=$(getPortFromHex $localHexPort)

remoteIP=$(getIpFromHex $remoteHexIP)
remotePort=$(getPortFromHex $remoteHexPort)

echo " local: $localIP:$localPort"
echo "remote: $remoteIP:$remotePort"

echo


