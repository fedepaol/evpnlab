#!/bin/bash
#

sleep 3

ip addr add 192.168.10.3/24 dev eth1

ip r del default
sleep INF
