#!/bin/bash
set -e

echo "=== Configuring FRR for Storage VM ==="

# Configure loopback interface with IP to advertise
echo "Configuring loopback interface..."
sudo ip addr add 10.200.0.1/32 dev lo 2>/dev/null || echo "Loopback IP already configured"

# Create FRR configuration
echo "Creating FRR configuration..."
sudo tee /etc/frr/frr.conf > /dev/null <<'EOF'
frr version 8.0
frr defaults traditional
hostname storage
log syslog informational
service integrated-vtysh-config
!
router bgp 64515
 bgp router-id 10.1.0.7
 no bgp default ipv4-unicast
 neighbor 10.1.0.6 remote-as 64512
 !
 address-family ipv4 unicast
  network 10.200.0.1/32
  neighbor 10.1.0.6 activate
 exit-address-family
!
line vty
!
EOF

# Set proper permissions
sudo chown frr:frr /etc/frr/frr.conf
sudo chmod 640 /etc/frr/frr.conf

# Restart FRR to apply configuration
echo "Restarting FRR..."
sudo systemctl restart frr

echo ""
echo "FRR configuration complete!"
echo "Advertising 10.200.0.1/32 via BGP to storage-leaf (10.1.0.6)"
echo ""
echo "To verify BGP peering:"
echo "  sudo vtysh -c 'show bgp summary'"
echo ""
echo "To verify advertised routes:"
echo "  sudo vtysh -c 'show bgp ipv4 unicast'"
