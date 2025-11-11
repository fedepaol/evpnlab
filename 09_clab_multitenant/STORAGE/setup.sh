#!/bin/bash
#

ip addr add 10.1.0.7/31 dev eth1

ip r del default
ip r add default via 10.1.0.6
sleep INF
