#!/bin/bash

cat <<EOF

This will not work, even though it is documented to do so

Mist Linux systems do not by default allow creating Bash sockets
due to the security risks,
and so this fails every where I try it

EOF

# from https://blog.chris007.de/using-bash-for-network-socket-operation/

# configuration
HOST="127.0.0.1"
PORT="1337"

# define functions
socksend ()
{
	SENDME="$1"
	echo "sending: $SENDME"
	echo -ne "$SENDME" >&5 &
}

sockread ()
{
	LENGTH="$1"
	RETURN=`dd bs=$1 count=1 <&5 2> /dev/null`
}

echo "trying to open socket"
# try to connect
if ! exec 5<> /dev/udp/$HOST/$PORT; then
  echo "`basename $0`: unable to connect to $HOST:$PORT"
  exit 1
fi
echo "socket is open"

# send request
socksend "TEST"

# read 7 bytes for "success"
sockread 7
echo "RETURN: $RETURN"
