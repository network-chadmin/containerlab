# Routing Playground – Small

A 5-node Cisco IOL topology for practicing IGP/BGP fundamentals. R1–R2–R4–R3–R1
form a redundant loop (two paths between R1 and R4), and R5 hangs off R4 as a
stub. No routing protocol is configured yet — every router boots with its
loopbacks and point-to-point links addressed (IPv4 + IPv6) and nothing more.
That's intentional: this is the "get right to configuring" baseline. OSPF and
BGP variants build on top of this same addressing plan.

## Topology

```
        R1
       /  \
     R2    R3
       \  /
        R4
        |
        R5
```

## Requirements

- [containerlab](https://containerlab.dev)
- `vrnetlab/cisco_iol:17.15.01` — the **standard** IOL image (not the L2/switch
  variant). Cisco doesn't allow public redistribution of IOL, so you need to
  build this yourself from Cisco's CML refplat via
  [vrnetlab](https://containerlab.dev/manual/vrnetlab/).

## Deploy

```bash
containerlab deploy -t routing-playground-small.clab.yml
```

Deploy again anytime to reset every router back to this baseline —
`enforce-startup-config: true` in the topology forces the partial config in
`configs/*.cfg.partial` to be re-applied on every deploy, regardless of what's
saved inside a router's NVRAM. If you've run `write memory` inside a router
and want a guaranteed clean slate, use the heavier reset instead:

```bash
containerlab deploy -t routing-playground-small.clab.yml --reconfigure
```

`--reconfigure` destroys and recreates the whole lab directory (NVRAM
included), which `enforce-startup-config` alone isn't confirmed to override
for IOL specifically — IOL's saved-config behavior is disk-based (NVRAM), not
the flat-file mechanism most other containerlab kinds use.

## Access

```bash
ssh admin@clab-routing-playground-small-r1
```

Default credentials: `admin` / `admin` (all nodes). Container names follow
`clab-routing-playground-small-<node>`.

## Addressing

### Loopbacks (IPv4)

| Router | Lo0 (Router-ID) | Lo1 (/24) | Lo2 (/25) | Lo3 (/26) | Lo4 (/27) |
|---|---|---|---|---|---|
| R1 | 1.1.1.1/32 | 10.1.0.1/24 | 10.1.1.1/25 | 10.1.1.129/26 | 10.1.1.225/27 |
| R2 | 2.2.2.2/32 | 10.2.0.1/24 | 10.2.1.1/25 | 10.2.1.129/26 | 10.2.1.225/27 |
| R3 | 3.3.3.3/32 | 10.3.0.1/24 | 10.3.1.1/25 | 10.3.1.129/26 | 10.3.1.225/27 |
| R4 | 4.4.4.4/32 | 10.4.0.1/24 | 10.4.1.1/25 | 10.4.1.129/26 | 10.4.1.225/27 |
| R5 | 5.5.5.5/32 | 10.5.0.1/24 | 10.5.1.1/25 | 10.5.1.129/26 | 10.5.1.225/27 |

Each router's Lo1–4 nest entirely inside `10.X.0.0/23` — a deliberate
summarization exercise for when OSPF/BGP get added.

### Loopbacks (IPv6)

| Router | Lo0 (/128) | Lo1 (/64) | Lo2 (/64) | Lo3 (/64) | Lo4 (/64) |
|---|---|---|---|---|---|
| R1 | 2001:db8:1:0::1 | 2001:db8:1:1::1 | 2001:db8:1:2::1 | 2001:db8:1:3::1 | 2001:db8:1:4::1 |
| R2 | 2001:db8:2:0::2 | 2001:db8:2:1::1 | 2001:db8:2:2::1 | 2001:db8:2:3::1 | 2001:db8:2:4::1 |
| R3 | 2001:db8:3:0::3 | 2001:db8:3:1::1 | 2001:db8:3:2::1 | 2001:db8:3:3::1 | 2001:db8:3:4::1 |
| R4 | 2001:db8:4:0::4 | 2001:db8:4:1::1 | 2001:db8:4:2::1 | 2001:db8:4:3::1 | 2001:db8:4:4::1 |
| R5 | 2001:db8:5:0::5 | 2001:db8:5:1::1 | 2001:db8:5:2::1 | 2001:db8:5:3::1 | 2001:db8:5:4::1 |

Same summarization property: each router's full Lo0–4 set nests under
`2001:db8:X::/48`. Uses `2001:db8::/32`, the RFC 3849 documentation prefix —
guaranteed never routable, so it's safe to publish.

### Transit links

| Link | Interfaces | IPv4 network | IPv6 network |
|---|---|---|---|
| R1 – R2 | R1 e0/1 / R2 e0/1 | 10.0.12.0/24 (.1 / .2) | 2001:db8:0:12::/64 (::1 / ::2) |
| R1 – R3 | R1 e0/2 / R3 e0/1 | 10.0.13.0/24 (.1 / .3) | 2001:db8:0:13::/64 (::1 / ::3) |
| R2 – R4 | R2 e0/2 / R4 e0/1 | 10.0.24.0/24 (.2 / .4) | 2001:db8:0:24::/64 (::2 / ::4) |
| R3 – R4 | R3 e0/2 / R4 e0/2 | 10.0.34.0/24 (.3 / .4) | 2001:db8:0:34::/64 (::3 / ::4) |
| R4 – R5 | R4 e0/3 / R5 e0/1 | 10.0.45.0/24 (.4 / .5) | 2001:db8:0:45::/64 (::4 / ::5) |

## What's configured

- Loopback0–4 addressing (IPv4 + IPv6) on every router
- Point-to-point interface addressing (IPv4 + IPv6) on every link
- QoL: `logging synchronous`, `exec-timeout 0`, `no ip domain-lookup`,
  millisecond-timestamped logs, `ipv6 unicast-routing`
- **No routing protocol.** Interfaces are directly connected only — that's
  the next lab.

## Why "partial" configs

Each `configs/rX.cfg.partial` file is appended on top of IOL's own default
boot config rather than replacing it — the `.partial` in the filename is
what tells containerlab to do this. That default config already handles the
management interface, its VRF, and SSH access, so none of that needed to be
reproduced here.

## Coming next

`routing-playground-small-ospf` and `routing-playground-small-bgp` variants,
built on this exact same addressing plan with baseline reachability already
configured.
