# Routing Playground – Large

A 9-router Cisco IOL topology, plus a Layer 2 switch and a simulated ISP —
the bigger sibling to Routing Playground - Small. Two dense clusters
(R1/R2/R9 and R3/R4/R5) are bridged through R6 and R7, R8 hangs off R7 as a
stub, R1/R2/R3 share a switched LAN segment off SW1, and R3 uplinks to
ISP1 ("Volt Communications") as the simulated edge of the network. As with
Small, nothing above Layer 3 addressing is configured yet — every router
boots with its loopbacks and links addressed (IPv4 + IPv6) and nothing
more. OSPF and BGP variants build on top of this same addressing plan.

## Topology

```
         R9
        /  \
      R1----R2------R7------R8
       \   / \      /
        \ /   \    /
        SW1    \  /
        / \     R6
       /   \    /
      R3----+--+
     / |  \
   R4  |   ISP1 (Volt Communications)
    \  |
     R5
```

Schematic only — a 15-link mesh doesn't draw cleanly in ASCII. The link
list and addressing tables below are the definitive source of truth.

**Full link list:** R1–R9, R1–R2, R1–SW1, R2–R6, R2–R7, R2–R9, R2–SW1,
R3–R4, R3–R5, R3–R6, R3–SW1, R3–ISP1, R4–R5, R6–R7, R7–R8

## Requirements

- [containerlab](https://containerlab.dev)
- `vrnetlab/cisco_iol:17.15.01` — the **standard** IOL image, used for
  every router (R1–R9, ISP1).
- `vrnetlab/cisco_iol:L2.17.15.01` — the **L2** IOL image, used only for
  SW1. Cisco doesn't allow public redistribution of IOL, so both need to
  be built yourself from Cisco's CML refplat via
  [vrnetlab](https://containerlab.dev/manual/vrnetlab/).

## Deploy

```bash
containerlab deploy -t routing-playground-large.clab.yml
```

Deploy again anytime to reset every node back to this baseline —
`enforce-startup-config: true` forces the partial config in
`configs/*.cfg.partial` to be re-applied on every deploy, regardless of
what's saved inside a node's NVRAM. If you've run `write memory` inside a
router and want a guaranteed clean slate, use the heavier reset instead:

```bash
containerlab deploy -t routing-playground-large.clab.yml --reconfigure
```

`--reconfigure` destroys and recreates the whole lab directory (NVRAM
included), which `enforce-startup-config` alone isn't confirmed to override
for IOL specifically — IOL's saved-config behavior is disk-based (NVRAM),
not the flat-file mechanism most other containerlab kinds use.

## Access

```bash
ssh admin@clab-routing-playground-large-r1
```

Default credentials: `admin` / `admin` (all nodes). Container names follow
`clab-routing-playground-large-<node>`.

## Addressing

### Loopbacks (IPv4)

| Router | Lo0 (Router-ID) | Lo1 (/24) | Lo2 (/25) | Lo3 (/26) | Lo4 (/27) |
|---|---|---|---|---|---|
| R1 | 1.1.1.1/32 | 10.1.0.1/24 | 10.1.1.1/25 | 10.1.1.129/26 | 10.1.1.225/27 |
| R2 | 2.2.2.2/32 | 10.2.0.1/24 | 10.2.1.1/25 | 10.2.1.129/26 | 10.2.1.225/27 |
| R3 | 3.3.3.3/32 | 10.3.0.1/24 | 10.3.1.1/25 | 10.3.1.129/26 | 10.3.1.225/27 |
| R4 | 4.4.4.4/32 | 10.4.0.1/24 | 10.4.1.1/25 | 10.4.1.129/26 | 10.4.1.225/27 |
| R5 | 5.5.5.5/32 | 10.5.0.1/24 | 10.5.1.1/25 | 10.5.1.129/26 | 10.5.1.225/27 |
| R6 | 6.6.6.6/32 | 10.6.0.1/24 | 10.6.1.1/25 | 10.6.1.129/26 | 10.6.1.225/27 |
| R7 | 7.7.7.7/32 | 10.7.0.1/24 | 10.7.1.1/25 | 10.7.1.129/26 | 10.7.1.225/27 |
| R8 | 8.8.8.8/32 | 10.8.0.1/24 | 10.8.1.1/25 | 10.8.1.129/26 | 10.8.1.225/27 |
| R9 | 9.9.9.9/32 | 10.9.0.1/24 | 10.9.1.1/25 | 10.9.1.129/26 | 10.9.1.225/27 |

Each router's Lo1–4 nest entirely inside `10.X.0.0/23` — same
summarization exercise as Small, just across nine routers instead of five.

ISP1 gets its own loopback, deliberately in a different range to read as
"outside" the lab: `192.0.2.1/32` (RFC 5737 TEST-NET-1).

### Loopbacks (IPv6)

| Router | Lo0 (/128) | Lo1 (/64) | Lo2 (/64) | Lo3 (/64) | Lo4 (/64) |
|---|---|---|---|---|---|
| R1 | 2001:db8:1:0::1 | 2001:db8:1:1::1 | 2001:db8:1:2::1 | 2001:db8:1:3::1 | 2001:db8:1:4::1 |
| R2 | 2001:db8:2:0::2 | 2001:db8:2:1::1 | 2001:db8:2:2::1 | 2001:db8:2:3::1 | 2001:db8:2:4::1 |
| R3 | 2001:db8:3:0::3 | 2001:db8:3:1::1 | 2001:db8:3:2::1 | 2001:db8:3:3::1 | 2001:db8:3:4::1 |
| R4 | 2001:db8:4:0::4 | 2001:db8:4:1::1 | 2001:db8:4:2::1 | 2001:db8:4:3::1 | 2001:db8:4:4::1 |
| R5 | 2001:db8:5:0::5 | 2001:db8:5:1::1 | 2001:db8:5:2::1 | 2001:db8:5:3::1 | 2001:db8:5:4::1 |
| R6 | 2001:db8:6:0::6 | 2001:db8:6:1::1 | 2001:db8:6:2::1 | 2001:db8:6:3::1 | 2001:db8:6:4::1 |
| R7 | 2001:db8:7:0::7 | 2001:db8:7:1::1 | 2001:db8:7:2::1 | 2001:db8:7:3::1 | 2001:db8:7:4::1 |
| R8 | 2001:db8:8:0::8 | 2001:db8:8:1::1 | 2001:db8:8:2::1 | 2001:db8:8:3::1 | 2001:db8:8:4::1 |
| R9 | 2001:db8:9:0::9 | 2001:db8:9:1::1 | 2001:db8:9:2::1 | 2001:db8:9:3::1 | 2001:db8:9:4::1 |

Same summarization property: each router's full Lo0–4 set nests under
`2001:db8:X::/48`. Still `2001:db8::/32`, the RFC 3849 documentation
prefix. ISP1's loopback mirrors its "outside" IPv4 address:
`2001:db8:ffff:ffff::1/128`.

### Transit links (point-to-point)

Same scheme as Small: `10.0.XY.0/24`, where XY is the two router numbers
concatenated (lower first), host octet = own router number.

| Link | Interfaces | IPv4 network | IPv6 network |
|---|---|---|---|
| R1 – R2 | R1 e0/1 / R2 e0/1 | 10.0.12.0/24 (.1 / .2) | 2001:db8:0:12::/64 (::1 / ::2) |
| R1 – R9 | R1 e0/2 / R9 e0/1 | 10.0.19.0/24 (.1 / .9) | 2001:db8:0:19::/64 (::1 / ::9) |
| R2 – R6 | R2 e0/2 / R6 e0/1 | 10.0.26.0/24 (.2 / .6) | 2001:db8:0:26::/64 (::2 / ::6) |
| R2 – R7 | R2 e0/3 / R7 e0/1 | 10.0.27.0/24 (.2 / .7) | 2001:db8:0:27::/64 (::2 / ::7) |
| R2 – R9 | R2 e1/0 / R9 e0/2 | 10.0.29.0/24 (.2 / .9) | 2001:db8:0:29::/64 (::2 / ::9) |
| R3 – R4 | R3 e0/1 / R4 e0/1 | 10.0.34.0/24 (.3 / .4) | 2001:db8:0:34::/64 (::3 / ::4) |
| R3 – R5 | R3 e0/2 / R5 e0/1 | 10.0.35.0/24 (.3 / .5) | 2001:db8:0:35::/64 (::3 / ::5) |
| R3 – R6 | R3 e0/3 / R6 e0/2 | 10.0.36.0/24 (.3 / .6) | 2001:db8:0:36::/64 (::3 / ::6) |
| R4 – R5 | R4 e0/2 / R5 e0/2 | 10.0.45.0/24 (.4 / .5) | 2001:db8:0:45::/64 (::4 / ::5) |
| R6 – R7 | R6 e0/3 / R7 e0/2 | 10.0.67.0/24 (.6 / .7) | 2001:db8:0:67::/64 (::6 / ::7) |
| R7 – R8 | R7 e0/3 / R8 e0/1 | 10.0.78.0/24 (.7 / .8) | 2001:db8:0:78::/64 (::7 / ::8) |

R2 and R3 both have five neighbors, so their interfaces spill past
Ethernet0/3 into Ethernet1/0 and Ethernet1/1 — IOL groups interfaces in
slots of four, so the fourth and fifth data ports land in slot 1.

### Shared LAN segment (R1, R2, R3 via SW1)

New for Large — a genuine multi-access segment instead of a point-to-point
link, so it gets its own pattern: `10.1.123.0/24`, where the second octet
(`1`) marks it as LAN segment #1 and the third octet (`123`) is every
router on the segment concatenated. Host octet is still own router
number.

| Node | Interface | IPv4 | IPv6 |
|---|---|---|---|
| R1 | Ethernet0/3 | 10.1.123.1/24 | 2001:db8:1:123::1/64 |
| R2 | Ethernet1/1 | 10.1.123.2/24 | 2001:db8:1:123::2/64 |
| R3 | Ethernet1/0 | 10.1.123.3/24 | 2001:db8:1:123::3/64 |
| SW1 | Ethernet0/1–0/3 | — (L2 only) | — (L2 only) |

SW1's three ports are plain access ports on VLAN 1 — no trunking or
distinct VLANs in this baseline lab.

### ISP uplink (R3 – ISP1)

Deliberately addressed outside the lab's private 10.x/2001:db8 space so it
reads as "the edge of the network" — RFC 5737 TEST-NET-3 for IPv4:

| Node | Interface | IPv4 | IPv6 |
|---|---|---|---|
| R3 | Ethernet1/1 | 203.0.113.1/30 | 2001:db8:0:99::1/64 |
| ISP1 | Ethernet0/1 | 203.0.113.2/30 | 2001:db8:0:99::2/64 |

## What's configured

- Loopback0–4 addressing (IPv4 + IPv6) on every router, and a standalone
  loopback on ISP1
- Point-to-point interface addressing (IPv4 + IPv6) on every transit link
- Shared-segment addressing (IPv4 + IPv6) on the R1/R2/R3 LAN via SW1
- QoL: `logging synchronous`, `exec-timeout 0`, `no ip domain-lookup`,
  millisecond-timestamped logs, `ipv6 unicast-routing` (routers and ISP1
  only — SW1 is L2-only, so it's skipped there)
- `no cdp enable` on Ethernet0/0 (mgmt) only, on every node, so `show cdp
  neighbors` reflects the real topology instead of every node on the
  shared mgmt network
- **No routing protocol.** Interfaces are directly connected only — that's
  the next lab.

## Why "partial" configs

Each `configs/<node>.cfg.partial` file is appended on top of IOL's own
default boot config rather than replacing it — the `.partial` in the
filename is what tells containerlab to do this. That default config
already handles the management interface, its VRF, and SSH access, so
none of that needed to be reproduced here.

## Coming next

`routing-playground-large-ospf` and `routing-playground-large-bgp`
variants, built on this exact same addressing plan with baseline
reachability already configured. A separate Hub-and-Spoke playground is
also on deck, exploring the stub-heavy design that didn't make it into
this topology.
