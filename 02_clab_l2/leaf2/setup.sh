#!/bin/bash
#

ip addr add 100.65.0.2/32 dev lo
ip addr add 192.168.1.3/24 dev eth1


ip link add red type vrf table 1100
ip link set red up

ip link add br10 type bridge
ip link set br10 master red
ip link set br10 addr aa:bb:cc:00:00:64
ip addr add 192.168.10.1/24 dev br10

ip link add vni110 type vxlan local 100.65.0.2 dstport 4789 id 110 nolearning
ip link set vni110 master br10 addrgenmode none


ip link set vni110 type bridge_slave neigh_suppress on learning off

ip link set vni110 up
ip link set br10 up

ip addr add 192.168.10.9/24 dev eth2
ip addr add 192.168.10.10/24 dev eth3
ip link set eth2 master br10
ip link set eth3 master br10
