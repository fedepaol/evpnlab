#!/bin/bash

# wait for the command
nc -l -p 7080 | head -n 0
echo "received the signal"
python3 /usr/lib/frr/frr-reload.py --reload --overwrite --stdout /etc/frr/frr.conf
