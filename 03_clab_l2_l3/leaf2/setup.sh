#!/bin/bash
#

ip addr add 100.65.0.2/32 dev lo
ip addr add 192.168.1.3/24 dev eth1


ip link add red type vrf table 1100
ip link set red up

ip link add br10 type bridge
ip link set br10 master red
ip link set br10 addr aa:bb:cc:00:00:64
ip addr add 192.168.10.0/24 dev br10
ip link add vni110 type vxlan local 100.65.0.2 dstport 4789 id 110 nolearning
ip link set vni110 master br10 addrgenmode none
ip link set vni110 type bridge_slave neigh_suppress on learning off
ip link set br10 up
ip link set vni110 up

ip link add br11 type bridge
ip link set br11 master red
ip link set br11 addr aa:bb:cc:00:00:65
ip addr add 192.168.11.0/24 dev br11
ip link add vni111 type vxlan local 100.65.0.2 dstport 4789 id 111 nolearning
ip link set vni111 master br11 addrgenmode none
ip link set vni111 type bridge_slave neigh_suppress on learning off
ip link set br11 up
ip link set vni111 up

ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:02:64
ip link add vni100 type vxlan local 100.65.0.2 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up


ip link set eth2 master br10
ip link set eth3 master br11

ip link set eth4 master red
ip addr add 192.170.10.0/24 dev eth4
