#!/bin/bash
set -euo pipefail

ip addr add 100.65.0.2/32 dev lo
ip addr add 192.168.1.3/24 dev eth1

ip link add red type vrf table 1100
ip link set red up
ip link add blue type vrf table 1200
ip link set blue up

ip link add br0 type bridge vlan_filtering 1 vlan_default_pvid 0
ip link set br0 address aa:bb:cc:00:03:64 addrgenmode none
ip link add vxlan0 type vxlan dstport 4789 local 100.65.0.2 nolearning external vnifilter
ip link set vxlan0 address aa:bb:cc:00:03:64 addrgenmode none master br0
ip link set br0 up
ip link set vxlan0 up
bridge link set dev vxlan0 vlan_tunnel on neigh_suppress on learning off

ip link add br100 type bridge
ip link set br100 address aa:bb:cc:00:02:64 addrgenmode none master red
ip link add vni100 type vxlan local 100.65.0.2 dstport 4790 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up

ip link add br200 type bridge
ip link set br200 address aa:bb:cc:00:04:64 addrgenmode none master blue
ip link add vni200 type vxlan local 100.65.0.2 dstport 4790 id 200 nolearning
ip link set vni200 master br200 addrgenmode none
ip link set vni200 type bridge_slave neigh_suppress on learning off
ip link set vni200 up
ip link set br200 up

ip link add br30 type bridge
ip link set br30 address aa:bb:cc:00:05:64 master blue
ip addr add 192.168.20.0/24 dev br30
ip link add vni130 type vxlan local 100.65.0.2 dstport 4790 id 130 nolearning
ip link set vni130 master br30 addrgenmode none
ip link set vni130 type bridge_slave neigh_suppress on learning off
ip link set vni130 up
ip link set br30 up

for mapping in 10:110 20:111; do
  vlan=${mapping%:*}
  vni=${mapping#*:}
  bridge vlan add dev br0 vid "$vlan" self
  bridge vlan add dev vxlan0 vid "$vlan"
  bridge vni add dev vxlan0 vni "$vni"
  bridge vlan add dev vxlan0 vid "$vlan" tunnel_info id "$vni"
  ip link add "vlan$vlan" link br0 type vlan id "$vlan"
  ip link set "vlan$vlan" master red
  ip link set "vlan$vlan" up
done
ip link set vlan10 address aa:bb:cc:00:02:10
ip link set vlan20 address aa:bb:cc:00:02:11
ip addr add 192.168.10.0/24 dev vlan10
ip addr add 192.168.11.0/24 dev vlan20

ip link set eth2 master br0
bridge vlan add dev eth2 vid 10
bridge vlan add dev eth2 vid 20

ip link set eth3 master red
ip addr add 192.170.10.0/24 dev eth3

ip link set eth4 master br30
ip link set eth5 master blue
ip addr add 192.172.10.0/24 dev eth5
