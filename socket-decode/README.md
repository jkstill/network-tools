
Decoding TCP Sockets
====================

This directory contains scripts to decode TCP socket information from the Linux kernel. 

The scripts are designed to extract and interpret data from the `/proc/net/tcp` file, which provides details about active TCP connections.

## decode-proc-net-socket.sh

This is a prototype script that just finds a sqlplus session and decodes the first TCP socket it finds.

## decode-tcp-sockets.sh

Give this script a PID and it will decode all TCP sockets for that process. It will print the local and remote IP addresses and ports in both hexadecimal and human-readable formats.

### Example Usage

Given a local process that has established two TCP connections to a database, you can use this script to decode the socket information as follows:

```bash
$  ./decode-tcp-sockets.sh 4086346

PID: 4086346
tcpFile: /proc/4086346/net/tcp
============================================================================================
sl local_address rem_address st tx_queue rx_queue tr tm->when retrnsmt uid timeout inode
  59: FE01A8C0:6042 3501A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 24716207 1 0000000000000000 20 4 16 10 -1

localConnection: FE01A8C0:6042
	 Hex IP: FE01A8C0
  Hex Port: 6042

remoteConnection: 3501A8C0:05F1
	 Hex IP: 3501A8C0
  Hex Port: 05F1

 local: 192.168.1.254:24642
remote: 192.168.1.53:1521
============================================================================================
sl local_address rem_address st tx_queue rx_queue tr tm->when retrnsmt uid timeout inode
  60: FE01A8C0:6048 3501A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 24716952 1 0000000000000000 20 4 21 10 -1

localConnection: FE01A8C0:6048
	 Hex IP: FE01A8C0
  Hex Port: 6048

remoteConnection: 3501A8C0:05F1
	 Hex IP: 3501A8C0
  Hex Port: 05F1

 local: 192.168.1.254:24648
remote: 192.168.1.53:1521
============================================================================================

PID: 4086346
tcpFile: /proc/4086346/net/tcp
============================================================================================
sl local_address rem_address st tx_queue rx_queue tr tm->when retrnsmt uid timeout inode
  59: FE01A8C0:6042 3501A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 24716207 1 0000000000000000 20 4 16 10 -1                 

localConnection: FE01A8C0:6042
	 Hex IP: FE01A8C0
  Hex Port: 6042

remoteConnection: 3501A8C0:05F1
	 Hex IP: 3501A8C0
  Hex Port: 05F1

 local: 192.168.1.254:24642
remote: 192.168.1.53:1521
============================================================================================
sl local_address rem_address st tx_queue rx_queue tr tm->when retrnsmt uid timeout inode
  60: FE01A8C0:6048 3501A8C0:05F1 01 00000000:00000000 00:00000000 00000000  1000        0 24716952 1 0000000000000000 20 4 21 10 -1                 

localConnection: FE01A8C0:6048
	 Hex IP: FE01A8C0
  Hex Port: 6048

remoteConnection: 3501A8C0:05F1
	 Hex IP: 3501A8C0
  Hex Port: 05F1

 local: 192.168.1.254:24648
remote: 192.168.1.53:1521
============================================================================================
```

Local server 192.168.1.254 has two active TCP connections to the remote database server 192.168.1.53.

The local ports are 24642 and 24648, while the remote port is 1521, which is commonly used for Oracle databases.

## Use ss Instead

If ss is available, the following command will get most of the same information:

```bash
$  ss -tnpe 2>/dev/null | awk 'NR==1 || /pid=4086346/'
State      Recv-Q Send-Q Local Address:Port   Peer Address:Port Process
ESTAB      0      0      192.168.1.254:24642  192.168.1.53:1521  users:(("perl",pid=4086346,fd=7))         uid:1000 ino:24716207 sk:2b cgroup:unreachable:1 <->
ESTAB      0      0      192.168.1.254:24648  192.168.1.53:1521  users:(("perl",pid=4086346,fd=8))         uid:1000 ino:24716952 sk:2c cgroup:unreachable:1 <->
```

