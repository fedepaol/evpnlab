#!/bin/bash
#

# Wait for eth1 interface to be available
while ! ip link show eth1 &>/dev/null; do
    echo "Waiting for eth1 interface..."
    sleep 1
done

ip addr add 10.1.0.7/31 dev eth1

ip r del default
ip r add default via 10.1.0.6
sleep infinity
