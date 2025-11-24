#!/bin/bash
# Fix BGP configuration to activate neighbor
# Copy this to the storage VM and run it

echo "Activating BGP neighbor 10.1.0.6..."

vtysh <<'VTYSH_EOF'
configure terminal
router bgp 64515
 address-family ipv4 unicast
  neighbor 10.1.0.6 activate
 exit-address-family
exit
write memory
exit
VTYSH_EOF

echo ""
echo "Done! Checking BGP status..."
sleep 2

vtysh -c "show bgp summary"
echo ""
echo "BGP routes:"
vtysh -c "show ip bgp"
