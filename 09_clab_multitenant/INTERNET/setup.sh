#!/bin/bash
#

ip addr add 10.1.0.9/31 dev toborder
ip addr add 8.8.8.9/32 dev lo

ip r del default
ip r add default via 10.1.0.8
sleep INF
