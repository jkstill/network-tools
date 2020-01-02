#!/bin/bash

for f in client.c server.c
do
	base=$(echo $f | cut -f 1 -d\.)
	echo Compiling: "$f -> $base"
	gcc $f -o $base
done

