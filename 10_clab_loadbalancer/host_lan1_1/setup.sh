#!/bin/bash
#

sleep 3

ip addr add 192.168.10.2/24 dev eth1

# set the default gw via eth1
ip r del default
ip r add default via 192.168.10.0 dev eth1

# Start HTTP server with nginx
mkdir -p /usr/share/nginx/html
echo "Response from HOST_LAN1_1 (192.168.10.2)" > /usr/share/nginx/html/index.html
nginx -g 'daemon off;'
