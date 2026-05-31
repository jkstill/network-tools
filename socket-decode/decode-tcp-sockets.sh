#!/usr/bin/env bash

set -eo pipefail

DEBUG=${DEBUG:-0}

# if DEBUG is set to 0, then redirect output to /dev/null, otherwise redirect to stdout
#[[ $DEBUG -gt 0 ]] && cmdOutputFD='/dev/stdout' || cmdOutputFD='/dev/null'

debugFD=3

if (( DEBUG > 0 )); then
    exec {debugFD}>&1
else
    exec {debugFD}>/dev/null
fi

PID=${1:?'need a pid'}
[[ -z $PID ]] && { echo "session not found"; exit 1; }
echo "PID: $PID"

: <<'NET'

  /proc/PID/net/tcp

  sl	local_address rem_address	 st tx_queue rx_queue tr tm->when retrnsmt	uid  timeout inode
  80: FE01A8C0:CB4E 5101A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000		  0 100395273 1 ffff9d71c9881c80 20 4 12 10 -1

  example usage:

 PID: 1258868
 lrwx------ 1 jkstill jkstill 64 Dec  3 16:07 /proc/1258868/fd/10 -> 'socket:[100413043]'
 inode: 100413043
	sl	 local_address rem_address	  st tx_queue rx_queue tr tm->when retrnsmt	 uid	timeout inode
	81: FE01A8C0:A80E E901A8C0:05F1 01 00000000:00000000 00:00000000 00000000	1000			0 100413043 1 ffff9d719725d580 20 4 18 10 -1

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
	sl	 local_address rem_address	  st tx_queue rx_queue tr tm->when retrnsmt	 uid	timeout inode
	81: FE01A8C0:A80E E901A8C0:05F1 01 00000000:00000000 00:00000000 00000000	1000			0 100413043 1 ffff9d719725d580 20 4 18 10 -1

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

# get all files that are a tcp socket
declare -a socketInodes

for socketFile in $(ls -ld /proc/$PID/fd/* | grep socket | awk '{  filenamePtr=NF-2; print $filenamePtr }'); do
	socketInode=$(readlink $socketFile | cut -f2 -d: | tr -d '[\[\]]')
	[[ $DEBUG -gt 0 ]] && echo "socketFile: $socketFile socketInode: $socketInode"
	{ lsof -p $PID | grep $socketInode | grep TCP && socketInodes+=($socketInode); } >&$debugFD
done

[[ ${#socketInodes[@]} -lt 1 ]] && {
	echo "no TCP sockets found for PID: $PID"
	exit 0
}

[[ $DEBUG -gt 0 ]] && echo "inode: $socketInode"

[[ $DEBUG -gt 0 ]] && {
	echo 
	echo '######################################################'
	echo "Socket Inodes:"
	socketInode=''
	for socketInode in ${socketInodes[*]}; do
		echo socketInode: $socketInode
	done
	echo '######################################################'
	echo

}

tcpFile="/proc/$PID/net/tcp"
echo "tcpFile: $tcpFile"

hdr=$(head -1 $tcpFile)

echo "============================================================================================"
for socketInode in ${socketInodes[*]}; do

	echo $hdr
	grep -h $socketInode $tcpFile*

	localConnection=$(grep -h $socketInode $tcpFile*| awk '{ print $2 }')
	remoteConnection=$(grep -h $socketInode $tcpFile*| awk '{ print $3 }')

	localHexIP=$(echo $localConnection	| cut -f1 -d:)
	localHexPort=$(echo $localConnection  | cut -f2 -d:)

	remoteHexIP=$(echo $remoteConnection  | cut -f1 -d:)
	remoteHexPort=$(echo $remoteConnection	 | cut -f2 -d:)

	echo 
	echo "localConnection: $localConnection"
	echo "	 Hex IP: $localHexIP"
	echo "  Hex Port: $localHexPort"
	echo 
	echo "remoteConnection: $remoteConnection"
	echo "	 Hex IP: $remoteHexIP"
	echo "  Hex Port: $remoteHexPort"

	echo

	localIP=$(getIpFromHex $localHexIP)
	localPort=$(getPortFromHex $localHexPort)

	remoteIP=$(getIpFromHex $remoteHexIP)
	remotePort=$(getPortFromHex $remoteHexPort)

	echo " local: $localIP:$localPort"
	echo "remote: $remoteIP:$remotePort"

	echo "============================================================================================"
done

