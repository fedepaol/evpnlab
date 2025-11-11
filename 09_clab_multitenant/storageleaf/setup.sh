#!/bin/bash
#

ip addr add 100.65.0.2/32 dev lo

# Storageleaf to spine
ip addr add 10.0.0.1/31 dev tospine


ip link add red type vrf table 1100
ip link set red up

ip link set eth1 master red
ip addr add 10.1.0.6/31 dev eth1

ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:00:64
ip link add vni100 type vxlan local 100.65.0.2 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up
