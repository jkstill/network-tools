#!/bin/bash

for f in client-example.c server-example.c
do
	base=$(echo $f | cut -f 1 -d\.)
	echo Compiling: "$f -> $base"
	gcc -I . $f -o $base
done

