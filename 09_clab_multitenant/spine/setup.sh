#!/bin/bash
#

# Spine to storageleaf
ip addr add 10.0.0.0/31 dev tostorageleaf

# Spine to leaf1
ip addr add 10.0.0.2/31 dev toleaf1

# Spine to leaf2
ip addr add 10.0.0.4/31 dev toleaf2

# Spine to borderleaf
ip addr add 10.0.0.6/31 dev toborderleaf
