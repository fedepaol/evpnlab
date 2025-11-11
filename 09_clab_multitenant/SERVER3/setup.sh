#!/bin/bash
#

ip addr add 10.1.0.5/31 dev eth1

ip r del default
ip r add default via 10.1.0.4
sleep INF
