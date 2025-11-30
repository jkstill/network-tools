Perl Hash of MAC prefixes and their associated manufacturers.
=============================================================

The data is from IEEE's public OUI database, which can be found at:
https://standards-oui.ieee.org/oui.txt

```text
wget https://standards-oui.ieee.org/oui/oui.csv
```

## make-mac-prefix-hash.pl

Use this to convert the oui.csv file into a Perl hash.

```bash
perl make-mac-prefix-hash.pl oui.csv 
```

The file mac-prefix-hash.pl will be created.

## mac-prefix-lookup.pl

Use this to look up a MAC prefix.

```bash
$  ./mac-prefix-lookup.pl 64:9A:63
64:9A:63 Ring LLC
```

## mac-vendor-prefixes.pl

Use this to list all MAC prefixes for a given vendor.

```bashbash
$  ./mac-vendor-prefixes.pl "Ring LLC"
MAC address prefixes for vendor 'Ring LLC':
5C:47:5E
C4:DB:AD
AC:9F:C3
18:7F:88
CC:3B:FB
90:48:6C
9C:76:13
54:E0:19
24:2B:D6
34:3E:A4
64:9A:63
```

## make-mac-prefixes.pl

Not really needed.

This is from the nmap git repository.

It works on the .txt file, which is not being used here.




