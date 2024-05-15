#!/bin/bash
#

sleep 3

ip addr add 192.169.10.2/24 dev eth1

# set the default gw via eth1
ip r del default
sleep INF
