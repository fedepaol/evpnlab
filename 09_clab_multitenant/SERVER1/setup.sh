#!/bin/bash
#

ip addr add 10.1.0.1/31 dev eth1

# set the default gw via eth1
ip r del default
ip r add default via 10.1.0.0
sleep INF
