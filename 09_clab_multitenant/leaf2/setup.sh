#!/bin/bash
#

ip addr add 100.64.0.2/32 dev lo

# Leaf2 to spine
ip addr add 10.0.0.5/31 dev tospine

ip link add red type vrf table 1100
ip link set red up

ip link set toserver3 master red
ip addr add 10.1.0.4/31 dev toserver3

ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:00:02
ip link add vni100 type vxlan local 100.64.0.2 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up

ip link add blue type vrf table 1200
ip link set blue up
ip link set toserver2 master blue
ip addr add 10.1.0.2/31 dev toserver2

ip link add br200 type bridge
ip link set br200 master blue addrgenmode none
ip link set br200 addr aa:bb:cc:00:00:12
ip link add vni200 type vxlan local 100.64.0.2 dstport 4789 id 200 nolearning
ip link set vni200 master br200 addrgenmode none
ip link set vni200 type bridge_slave neigh_suppress on learning off
ip link set vni200 up
ip link set br200 up

ip link add vrfstorage type vrf table 1300
ip link set vrfstorage up

ip link add br300 type bridge
ip link set br300 master vrfstorage addrgenmode none
ip link set br300 addr aa:bb:cc:00:00:22
ip link add vni300 type vxlan local 100.64.0.2 dstport 4789 id 300 nolearning
ip link set vni300 master br300 addrgenmode none
ip link set vni300 type bridge_slave neigh_suppress on learning off
ip link set vni300 up
ip link set br300 up
