#!/bin/bash
#

ip addr add 192.168.11.3/24 dev eth1
ip addr add 100.65.0.2/32 dev lo

# L3 VRF
ip link add red type vrf table 1100

# Leaf - host leg
ip link set red1 master red
ip addr add dev red1 192.169.10.1/24
ip link set red1 up
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

# Leaf - host leg
ip link add green type vrf table 1101
ip link set green1 master green
ip addr add dev green1 192.169.11.1/24
ip link set green1 up

ip link set green up
ip link add br200 type bridge
ip link set br200 master green addrgenmode none
ip link set br200 addr aa:bb:cc:00:00:66
ip link add vni200 type vxlan local 100.65.0.2 dstport 4789 id 200 nolearning
ip link set vni200 master br100 addrgenmode none
ip link set vni200 type bridge_slave neigh_suppress on learning off
ip link set vni200 up
ip link set br200 up
