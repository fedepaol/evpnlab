#!/bin/bash
# Quick fix to activate the BGP neighbor

echo "Fixing BGP configuration to activate neighbor..."

sudo vtysh <<'VTYSH_COMMANDS'
configure terminal
router bgp 64515
 address-family ipv4 unicast
  neighbor 10.1.0.6 activate
 exit-address-family
exit
write memory
exit
VTYSH_COMMANDS

echo ""
echo "Configuration updated! Checking BGP status..."
sleep 2

sudo vtysh -c "show bgp summary"
echo ""
sudo vtysh -c "show ip bgp"
