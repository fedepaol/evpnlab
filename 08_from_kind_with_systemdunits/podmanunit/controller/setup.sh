#!/bin/bash

dnf install -y iproute nmap-ncat
FRRPID=$(cat /etc/frr/frrpid)
NETNS=$(ip netns identify $FRRPID)

#emulate changing the config
cp /etc/controller/frr.conf /etc/frr/

ip link add frr0 type veth peer name frr1
ip link set frr0 up
ip link set dev eth1 netns $NETNS
ip link set frr1 netns $NETNS

### Configuring the interfaces in the network namespace
NS_COMMAND="ip netns exec $NETNS"
$NS_COMMAND ip addr add 100.65.0.2/32 dev lo
$NS_COMMAND ip addr add 192.168.11.3/24 dev eth1


# L3 VRF
$NS_COMMAND ip link add red type vrf table 1100

# Leaf - host leg
$NS_COMMAND ip link set frr1 master red
$NS_COMMAND ip addr add dev frr1 192.169.10.1/24
$NS_COMMAND ip link set frr1 up
$NS_COMMAND ip link set eth1 up

$NS_COMMAND ip link set red up
$NS_COMMAND ip link add br100 type bridge
$NS_COMMAND ip link set br100 master red addrgenmode none
$NS_COMMAND ip link set br100 addr aa:bb:cc:00:00:66
$NS_COMMAND ip link add vni100 type vxlan local 100.65.0.2 dstport 4789 id 100 nolearning
$NS_COMMAND ip link set vni100 master br100 addrgenmode none
$NS_COMMAND ip link set vni100 type bridge_slave neigh_suppress on learning off
$NS_COMMAND ip link set vni100 up
$NS_COMMAND ip link set br100 up


sleep 2s

ip addr add dev frr0 192.169.10.0/24

# trigger the reloader
#echo 1 | nc localhost 7080
