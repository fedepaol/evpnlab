#!/bin/bash
set -euo pipefail

# Underlay and VTEP.
ip addr add 100.64.0.1/32 dev lo
ip addr add 192.168.1.1/24 dev eth1

ip link add red type vrf table 1100
ip link set red up
ip link add blue type vrf table 1200
ip link set blue up

# The two L2VNIs share a VLAN-aware bridge and VXLAN device.
ip link add br0 type bridge vlan_filtering 1 vlan_default_pvid 0
ip link set br0 address aa:bb:cc:00:03:65 addrgenmode none
ip link add vxlan0 type vxlan dstport 4789 local 100.64.0.1 nolearning external vnifilter
ip link set vxlan0 address aa:bb:cc:00:03:65 addrgenmode none master br0
ip link set br0 up
ip link set vxlan0 up
bridge link set dev vxlan0 vlan_tunnel on neigh_suppress on learning off

# L3VNI 100 keeps the traditional bridge and uses a separate UDP port.
ip link add br100 type bridge
ip link set br100 address aa:bb:cc:00:02:65 addrgenmode none master red
ip link add vni100 type vxlan local 100.64.0.1 dstport 4790 id 100 nolearning
ip link set vni100 master br100 addrgenmode none
ip link set vni100 type bridge_slave neigh_suppress on learning off
ip link set vni100 up
ip link set br100 up

# Blue uses a dedicated traditional L3VNI and a dedicated traditional L2VNI.
ip link add br200 type bridge
ip link set br200 address aa:bb:cc:00:04:65 addrgenmode none master blue
ip link add vni200 type vxlan local 100.64.0.1 dstport 4790 id 200 nolearning
ip link set vni200 master br200 addrgenmode none
ip link set vni200 type bridge_slave neigh_suppress on learning off
ip link set vni200 up
ip link set br200 up

ip link add br30 type bridge
ip link set br30 address aa:bb:cc:00:05:65 master blue
ip addr add 192.168.20.0/24 dev br30
ip link add vni130 type vxlan local 100.64.0.1 dstport 4790 id 130 nolearning
ip link set vni130 master br30 addrgenmode none
ip link set vni130 type bridge_slave neigh_suppress on learning off
ip link set vni130 up
ip link set br30 up

# VLANs 10 and 20 map to L2VNIs 110 and 111. Their SVIs provide the gateways.
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
ip link set vlan10 address aa:bb:cc:00:01:10
ip link set vlan20 address aa:bb:cc:00:01:11
ip addr add 192.168.10.0/24 dev vlan10
ip addr add 192.168.11.0/24 dev vlan20

# One tagged trunk connects both LANs to the host-side bridge.
ip link set eth2 master br0
bridge vlan add dev eth2 vid 10
bridge vlan add dev eth2 vid 20

# The routed host remains attached directly to the VRF.
ip link set eth3 master red
ip addr add 192.169.10.0/24 dev eth3

ip link set eth4 master br30
ip link set eth5 master blue
ip addr add 192.171.10.0/24 dev eth5
