#!/bin/bash
#

ip addr add 100.64.0.3/32 dev lo

# Storageleaf to spine
ip addr add 10.0.0.1/31 dev tospine

ip addr add 10.1.0.6/31 dev tostorage

ip link add red type vrf table 1100
ip link set red up

ip link add br100 type bridge
ip link set br100 master red addrgenmode none
ip link set br100 addr aa:bb:cc:00:00:03
ip link add vni100 type vxlan local 100.64.0.3 dstport 4789 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up

ip link add blue type vrf table 1200

ip link add br200 type bridge
ip link set br200 master blue addrgenmode none
ip link set br200 addr aa:bb:cc:00:00:13
ip link add vni200 type vxlan local 100.64.0.3 dstport 4789 id 200 nolearning
ip link set vni200 master br100 addrgenmode none
ip link set vni200 type bridge_slave neigh_suppress on learning off
ip link set vni200 up
ip link set br200 up

ip link add vrfstorage type vrf table 1300
ip link set vrfstorage up

ip link set tostorage master vrfstorage

ip link add br300 type bridge
ip link set br300 master vrfstorage addrgenmode none
ip link set br300 addr aa:bb:cc:00:00:23
ip link add vni300 type vxlan local 100.64.0.3 dstport 4789 id 300 nolearning
ip link set vni300 master br300 addrgenmode none
ip link set vni300 type bridge_slave neigh_suppress on learning off
ip link set vni300 up
ip link set br300 up

