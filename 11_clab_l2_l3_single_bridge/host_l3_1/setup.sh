#!/bin/bash
#

sleep 3

ip r del default
ip addr add 192.169.10.2/24 dev eth1

# set the default gw via eth1
ip r add default via 192.169.10.0 dev eth1
sleep INF
