#!/bin/bash

# to get the AS number first find an IP using
# nslookup www.facebook.com
# Read a facebook IP from the output and issue
# whois -h whois.radb.net IP
# Read the ASXXXXX number and use it below

/usr/bin/whois -h "whois.radb.net" -- '-i origin AS32934' | grep -E "^route:" | awk '{print $NF}' | sed -r 's/(.*)/iptables -I OUTPUT -d \1 -j REJECT/' | source /dev/stdin 

/usr/bin/whois -h "whois.radb.net" -- '-i origin AS32934' | grep -E "^route6:" | awk '{print $NF}' | sed -r 's/(.*)/ip6tables -I OUTPUT -d \1 -j REJECT/' | source /dev/stdin 
