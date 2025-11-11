#!/bin/bash
#

ip addr add 192.168.11.1/24 dev eth1

ip r del default
ip r add default via 192.168.11.2
sleep INF
