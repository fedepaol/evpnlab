#!/bin/bash
set -e

echo "=== Installing Packages on Storage VM ==="

# Install basic utilities
echo "Installing wget, curl, git..."
sudo dnf install -y wget curl git

echo ""
echo "Package installation complete!"
