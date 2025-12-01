#!/bin/bash
#
# NVUE-based configuration for leaf1
# This replaces the traditional interfaces file and FRR configuration
#

# Wait for NVUE to be ready
sleep 5

# System configuration - Loopback and anycast MAC
nv set interface lo ip address 100.64.0.1/32

# Configure management VRF
nv set vrf mgmt
nv set interface eth0 ip vrf mgmt
nv set interface eth0 ip address dhcp

# Configure spine-facing interface (underlay)
nv set interface swp2 ip address 10.0.0.3/31

# Configure VRFs
nv set vrf red
nv set vrf vrfstorage
nv set vrf external

# Configure L3VNI mappings
nv set vrf red evpn vni 100
nv set vrf vrfstorage evpn vni 300
nv set vrf external evpn vni 400

# Configure server-facing interface in VRF red
nv set interface swp1 ip vrf red
nv set interface swp1 ip address 10.1.0.0/31

# VXLAN configuration
nv set nve vxlan source address 100.64.0.1
nv set nve vxlan arp-nd-suppress on

# Enable EVPN
nv set evpn enable on

# BGP configuration - Underlay
nv set router bgp autonomous-system 64512
nv set router bgp router-id 100.64.0.1
nv set vrf default router bgp neighbor 10.0.0.2 remote-as 64612
nv set vrf default router bgp address-family ipv4-unicast network 100.64.0.1/32
nv set vrf default router bgp neighbor 10.0.0.2 address-family ipv4-unicast aspath allow-my-asn enable on

# BGP EVPN configuration
nv set vrf default router bgp address-family l2vpn-evpn enable on
nv set vrf default router bgp neighbor 10.0.0.2 address-family l2vpn-evpn enable on
nv set evpn route-advertise svi-ip on
nv set vrf default router bgp neighbor 10.0.0.2 address-family l2vpn-evpn aspath allow-my-asn enable on

# VRF red BGP configuration
nv set vrf red router bgp autonomous-system 64512
nv set vrf red router bgp router-id 100.64.0.1
nv set vrf red router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf red router bgp address-family ipv4-unicast route-export to-evpn
nv set vrf red router bgp route-import from-evpn route-target ANY:300
nv set vrf red router bgp route-import from-evpn route-target ANY:400

# VRF vrfstorage BGP configuration
nv set vrf vrfstorage router bgp autonomous-system 64512
nv set vrf vrfstorage router bgp router-id 100.64.0.1
nv set vrf vrfstorage router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf vrfstorage router bgp address-family ipv4-unicast route-export to-evpn
nv set vrf vrfstorage router bgp route-import from-evpn route-target ANY:100

# VRF external BGP configuration
nv set vrf external router bgp autonomous-system 64512
nv set vrf external router bgp router-id 100.64.0.1
nv set vrf external router bgp address-family ipv4-unicast redistribute connected enable on
nv set vrf external router bgp address-family ipv4-unicast route-export to-evpn
nv set vrf external router bgp route-import from-evpn route-target ANY:100

# Apply configuration
nv config apply -y

echo "NVUE configuration applied successfully"
