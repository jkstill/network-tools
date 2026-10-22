#!/usr/bin/env bash

# use nmcli to take interface down or up
# used to force renegotiation of DHCP IP address

set -u

DRYRUN=${DRYRUN:-0}

scriptName=$(basename $0)

interface=${1:?'Interface Required'}

#read -a interfaces -t 5 < <(ip -o link | tail -n +2| cut -d: -f2| tr -d ' ' | perl -e 'while(<>){chomp;print qq{ $_};}')
# mapfile is simpler
mapfile -t interfaces < <(ip -o link | tail -n +2 | awk -F': ' '{print $2}')

[[ ${#interfaces[@]} -eq 0 ]] && {
	echo
	echo "failed to enumerate interfaces"
	echo
	exit 1
}

listInterfaces () {
	echo 
	echo "Valid Interfaces:"
	echo 

	for testInterface in ${interfaces[@]}; do
		echo "interface: '$testInterface'"
	done
	echo
}

assertInterface () {

	local interface=${1:-}

	#echo "interface: '$interface'"

	for testInterface in ${interfaces[@]}; do
		[[ $interface == $testInterface ]] && return 0
	done


	return 1
}


assertInterface $interface || {
	echo
	echo "'$interface' is not a valid interface"

	listInterfaces

	echo
	exit 1
}

controlWord=''

ip link show $interface >/dev/null 2>&1 || {

	echo
	echo "Failed checking interface"
	echo
	exit 1
}



if [[ $scriptName =~ down ]]; then
	controlWord='down'
elif [[ $scriptName =~ up ]]; then
	controlWord='up'
else
	echo
	echo "some error occurred"
	echo
	exit 1
fi

[[ $DRYRUN -eq 1 ]] && {
	echo
	echo "interface: $interface"
	echo "controlWord: $controlWord"
	echo "DRYRUN: nmcli con $controlWord id $interface"
	echo
	exit 0
}

nmcli con $controlWord id $interface

