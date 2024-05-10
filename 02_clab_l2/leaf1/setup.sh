#!/bin/bash
#

# VTEP IP
ip addr add 100.64.0.1/32 dev lo

# Leaf - spine leg
ip addr add 192.168.1.1/24 dev eth1

# L3 VRF
ip link add red type vrf table 1100

# Leaf - host leg

ip link set red up
ip link add br10 type bridge
ip link set br10 master red
ip link set br10 addr aa:bb:cc:00:00:65
ip link add vni110 type vxlan local 100.64.0.1 dstport 4789 id 110 nolearning
ip link set vni110 master br10 addrgenmode none

ip addr add 192.168.10.0/24 dev br10

ip link set vni110 type bridge_slave neigh_suppress on learning off
ip link set vni110 up
ip link set br10 up

ip link set eth2 master br10
