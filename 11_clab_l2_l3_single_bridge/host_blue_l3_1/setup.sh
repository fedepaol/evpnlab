#!/bin/bash
set -euo pipefail

sleep 3
ip addr add 192.171.10.2/24 dev eth1
ip route replace default via 192.171.10.0 dev eth1
sleep infinity
