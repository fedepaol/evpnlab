# Topology

The idea of this lab is to have a spine - leaves topology where the two hosts are connected to two different leaves
via a L3 connection.


```raw
                     ┌─────────┐
                     │         │
                     │  64612  │
                     │         │
                     └────┬────┘
                          │
                          │
                  ┌───────┴────────┐
                  │                │
             ┌────┴────┐      ┌────┴────┐
             │         │      │         │
             │  64512  │      │  64512  │
             │         │      │         │
             └────┬────┘      └────┬────┘
192.168.10.0/24   │                │ L3     192.168.11.0/24
             ┌────┴────┐      ┌────┴────┐
             │         │      │         │
             │  Host1  │      │  Host2  │
             │         │      │         │
             └─────────┘      └─────────┘
```


We want to connect the two hosts via a VXLan tunnel using L3Evpn routes.

```raw


                  ┌─────────┐              ┌─────────┐
                  │         │              │         │
                  │  64512  │     VXLan    │  64512  │
                  │       ┌─┼──────────────┼─┐       │
                  └────┬──┴─┘              └─┴──┬────┘
     192.168.10.0/24   │                        │ L3     192.168.11.0/24
                  ┌────┴────┐              ┌────┴────┐
                  │         │              │         │
                  │  Host1  │              │  Host2  │
                  │         │              │         │
                  └─────────┘              └─────────┘
```

## How to start

The lab leverages [containerlab](https://containerlab.dev/). The [clab file](./direct.clab.yaml) contains the definition
of the FRR containers and of the two "host" containers, plus how they are connected together.

A convenience [setup.sh](./setup.sh) script is provided, to start the lab and execute the various setup commands inside the containers.


## The configuration

Each subfolder contains the frr configuration file related to the corresponding container, plus a setup.sh script used to assign IPs and
to create the VXLan and what FRR needs to make EVPN work.

For example, in the [leaf1 setup configuration file](./leaf1/setup.sh) we:

- assign the VTEP IP address to the loopback interface
- Assign IPs to both the veth connecting the leaf to the spine and the one connecting the "HOST" to the leaf
- Create a linux VRF corresponding to the L3 VRF and enslave the veth leg connected to the "HOST"
- Create all the machinery to make the EVPN / VXLan tunnel work, including a linux bridge and a VXLan interface


## Validating

Pinging HOST2 from HOST1 should work:

```
# docker exec clab-evpnl3-HOST1 /bin/bash -c "ping 192.168.11.1"
PING 192.168.11.1 (192.168.11.1) 56(84) bytes of data.
64 bytes from 192.168.11.1: icmp_seq=1 ttl=62 time=0.321 ms
64 bytes from 192.168.11.1: icmp_seq=2 ttl=62 time=0.198 ms
```

It works! Also, let's make sure it's working through a vxlan tunnel:

```raw
sudo ip netns exec clab-evpnl3-leaf1 tcpdump -nn -i eth1
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), snapshot length 262144 bytes
12:01:51.759318 IP 100.64.0.1.48561 > 100.65.0.2.4789: VXLAN, flags [I] (0x08), vni 100
IP 192.168.10.1 > 192.168.11.1: ICMP echo request, id 5, seq 1, length 64
12:01:51.759433 IP 100.65.0.2.48561 > 100.64.0.1.4789: VXLAN, flags [I] (0x08), vni 100
IP 192.168.11.1 > 192.168.10.1: ICMP echo reply, id 5, seq 1, length 64
```
