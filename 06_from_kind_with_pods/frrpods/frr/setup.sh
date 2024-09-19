#!/bin/bash
set -x

ip addr add 192.168.11.3/24 dev eth1
ip addr add 100.65.0.2/32 dev lo


# L3 VRF
ip link add red type vrf table 1100

# Leaf - host leg
ip link set frr1 master red
ip addr add dev frr1 192.169.10.1/24
ip link set frr1 up
ip link set eth1 up

ip link set red up
ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:00:66
ip link add vni100 type vxlan local 100.65.0.2 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up


