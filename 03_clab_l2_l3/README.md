# Topology

This is a followup of the previous [01_clab_l3](./01_clab_l3) and [02_clab_l2](./02_clab_l2) labs, mixing all togheter:

- one single L3 VRF
- two separate L2 VRFs (192.168.10.0/24 and 192.168.11.0/24), under the same L3 VRF
- two other hosts connected via L3 to the leaves

```raw




                            ┌─────────┐
                            │         │
                            │ spine   │
                            │         │
                            └────┬────┘
                                 │
                                 │
                         ┌───────┴────────┐
                         │                │
     ┌──────────┐   ┌────┴────┐      ┌────┴────┐    ┌──────────┐
     │          │L3 │         │      │         │    │          │
     │ HostL3   ├───┤  leaf1  │      │  leaf2  ├────┤ HostL3   │
     │          │   │         │      │         │    │          │
     └──────────┘   └──┬──┬───┘      └────┬─┬──┘    └──────────┘
                       │  │               │ │
              ┌────────┘  │               │ │
              │   L2      │ L2         L2 │ └──────────┐ L2
              │           │               │            │
        ┌─────┴────┐  ┌───┴──────┐  ┌─────┴────┐  ┌────┴─────┐
        │          │  │          │  │          │  │          │
        │ HostL2_1 │  │ HostL2_2 │  │ HostL2_2 │  │ HostL2_1 │
        │          │  │          │  │          │  │          │
        └──────────┘  └──────────┘  └──────────┘  └──────────┘


```

Logically, the configuration is as follows:

- two separate L2 domains belonging to the same L3 domain
- two extra hosts connected via L3 to the L3 VRF

```raw

               ┌────────────────────────────┐
               │                            │
               │       L3 VRF               │
               │ │                        │ │
               │ │                        │ │
┌──────────┐   │ │ ┌────────────────────┐ │ │   ┌──────────┐
│          │L3 │ │ │          L2 VRF    │ │ │   │          │
│ HostL3   ├───┼─┘ │  ┌───────────────┐ │ └─┼───┤ HostL3   │
│          │   │   │  │               │ │   │   │          │
└──────────┘   └───┼──┼───────────────┼─┼───┘   └──────────┘
                   │  │               │ │
          ┌────────┘  │               │ │
          │   L2      │ L2         L2 │ └──────────┐ L2
          │           │               │            │
    ┌─────┴────┐  ┌───┴──────┐  ┌─────┴────┐  ┌────┴─────┐
    │          │  │          │  │          │  │          │
    │ HostL2_1 │  │ HostL2_2 │  │ HostL2_2 │  │ HostL2_1 │
    │          │  │          │  │          │  │          │
    └──────────┘  └──────────┘  └──────────┘  └──────────┘

```

## How to start

The lab leverages [containerlab](https://containerlab.dev/). The [clab file](./l2-l3.clab.yaml) contains the definition
of the FRR containers and of the two "host" containers, plus how they are connected together.

A convenience [setup.sh](./setup.sh) script is provided, to start the lab and execute the various setup commands inside the containers.


## The configuration

Each subfolder contains the frr configuration file related to the corresponding container, plus a setup.sh script used to assign IPs and
to create the VXLan and what FRR needs to make EVPN work.

For example, in the [leaf1 setup configuration file](./leaf1/setup.sh) we:

- assign the VTEP IP address to the loopback interface
- Assign IPs to the veth connecting the leaf to the spine
- Create a linux VRF corresponding to the L3 VRF
- Create all the machinery to make the EVPN / VXLan tunnel work, including a linux bridge and a VXLan interface
- Enslave the veth leg connected to the HOST to the bridge connected to the vxlan interface
- Create the linux bridges for the two separate L2 domains
- Create a VXLan interface enslaved to those linux bridges
- Enslave the veths corresponding to the L2 hosts to the respective linux bridge


## Validating

Pinging HOST_L3_2 from HOST_L3_1 should work:

```
docker exec clab-evpnl2-l3-HOST_L3_1 /bin/bash -c "ping -c 1 192.170.10.2"
PING 192.170.10.2 (192.170.10.2) 56(84) bytes of data.
64 bytes from 192.170.10.2: icmp_seq=1 ttl=62 time=0.147 ms

--- 192.170.10.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.147/0.147/0.147/0.000 ms

```

It works! Also, let's make sure it's working through a vxlan tunnel:

```raw
sudo ip netns exec clab-evpnl2-leaf1 tcpdump -nn -i eth1
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), snapshot length 262144 bytes
11:06:19.878187 IP 100.64.0.1.53099 > 100.65.0.2.4789: VXLAN, flags [I] (0x08), vni 110
IP 192.168.10.2 > 192.168.10.4: ICMP echo request, id 21, seq 1, length 64
11:06:19.878249 IP 100.65.0.2.53099 > 100.64.0.1.4789: VXLAN, flags [I] (0x08), vni 110
IP 192.168.10.4 > 192.168.10.2: ICMP echo reply, id 21, seq 1, length 64
```
