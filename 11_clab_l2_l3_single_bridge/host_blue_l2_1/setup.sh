#!/bin/bash
set -euo pipefail

sleep 3
ip addr add 192.168.20.2/24 dev eth1
ip route replace default via 192.168.20.0 dev eth1
sleep infinity
