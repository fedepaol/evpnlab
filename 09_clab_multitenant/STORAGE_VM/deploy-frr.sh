#!/bin/bash
set -e

echo "=== Deploying FRR on Storage VM ==="

# Check if FRR is installed, if not, install it
if ! rpm -q frr &> /dev/null; then
    echo "FRR not installed. Installing..."
    sudo dnf install -y frr
else
    echo "FRR is already installed"
fi

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# Make it persistent
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.conf

# Enable FRR daemons
echo "Enabling FRR daemons..."
sudo sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
sudo sed -i 's/zebra=no/zebra=yes/' /etc/frr/daemons

# Start and enable FRR
echo "Starting FRR services..."
sudo systemctl enable frr
sudo systemctl start frr

echo "FRR deployment complete!"
echo "FRR status:"
sudo systemctl status frr --no-pager

echo ""
echo "To configure FRR, use: sudo vtysh"
