#!/bin/bash
#

# VTEP IP
ip addr add 100.64.0.1/32 dev lo

# Leaf - spine leg
ip addr add 10.0.0.3/31 dev tospine

# L3 VRF
ip link add red type vrf table 1100

# Leaf - host leg
ip link set toserver1 master red
ip addr add 10.1.0.0/31 dev toserver1

ip link set red up
ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:00:01
ip link add vni100 type vxlan local 100.64.0.1 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up

ip link add vrfstorage type vrf table 1300
ip link set vrfstorage up

ip link add br300 type bridge
ip link set br300 master vrfstorage addrgenmode none
ip link set br300 addr aa:bb:cc:00:00:21
ip link add vni300 type vxlan local 100.64.0.1 dstport 4789 id 300 nolearning
ip link set vni300 master br300 addrgenmode none
ip link set vni300 type bridge_slave neigh_suppress on learning off
ip link set vni300 up
ip link set br300 up

ip link add external type vrf table 1400
ip link set external up

ip link add br400 type bridge
ip link set br400 master external addrgenmode none
ip link set br400 addr aa:bb:cc:00:00:31
ip link add vni400 type vxlan local 100.64.0.1 dstport 4789 id 400 nolearning
ip link set vni400 master br400 addrgenmode none
ip link set vni400 type bridge_slave neigh_suppress on learning off
ip link set vni400 up
ip link set br400 up
