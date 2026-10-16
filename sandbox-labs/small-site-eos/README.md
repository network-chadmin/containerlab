# Small Site – EOS Only (cEOS)

A compact site with two Linux hosts, two Layer 2 access switches, two Layer 3 distribution switches, and two Arista cEOS edge routers. The ISP router is cabled but unconfigured, so learners decide what it does.

This is the EOS-only variant. Every switch and router runs on Arista cEOS. The addressing is the same as the [Cisco-edge variant](../small-site-iol/README.md), so the two can share one lab guide.

> **Warning: NAT is not possible on cEOS.** The edge routers can route, but they can't translate addresses. Hosts reach the ISP by routing alone. For NAT or PAT at the edge, use the [Cisco-edge variant](../small-site-iol/README.md), where the edge routers run IOL.

## Topology

```
 H1 ── SW1 ──┬── D1 ──┬── R1 ── ISP1
             │  ╲   ╱ │
             │   ╳    │   (D1 and D2 each link to R1 and R2)
             │  ╱   ╲ │
 H2 ── SW2 ──┴── D2 ──┴── R2 ── ISP1
```

Each distribution switch connects to both edge routers, so the core has four cross-links. Each access switch connects to both distribution switches.

## Requirements

- [containerlab](https://containerlab.dev)
- `ceos:4.34.4M` for every Arista node: switches, distribution, and edge routers
- `vrnetlab/cisco_iol:17.15.01` for the ISP only. Build it yourself from Cisco's CML refplat using [vrnetlab](https://containerlab.dev/manual/vrnetlab/).
- `networkchadmin/network-host:2.0` for the Linux hosts

## Deploy

```bash
containerlab deploy -t small-site-eos.clab.yml
```

Redeploy to reset every node to this baseline. To wipe saved state too, redeploy with `--reconfigure`.

```bash
containerlab deploy -t small-site-eos.clab.yml --reconfigure
```

## Access

- **Arista nodes (switches, distribution, edge routers):** `docker exec -it clab-small-site-eos-<node> Cli`, for example `clab-small-site-eos-R1`. Login is `admin` / `admin`.
- **ISP:** `ssh admin@172.20.32.9`. Login is `admin` / `admin`.
- **Hosts:** `docker exec -it clab-small-site-eos-H1 bash`, or SSH as `labuser` / `admin`.

| Node | Type | Mgmt IPv4 |
|---|---|---|
| H1 | Linux host | 172.20.32.1 |
| H2 | Linux host | 172.20.32.2 |
| SW1 | cEOS, Layer 2 | 172.20.32.3 |
| SW2 | cEOS, Layer 2 | 172.20.32.4 |
| D1 | cEOS, Layer 3 | 172.20.32.5 |
| D2 | cEOS, Layer 3 | 172.20.32.6 |
| R1 | cEOS, edge | 172.20.32.7 |
| R2 | cEOS, edge | 172.20.32.8 |
| ISP1 | IOL, unconfigured | 172.20.32.9 |

## Addressing

Only the links below are addressed. Everything else is for the learner.

| Link | Subnet | Addresses |
|---|---|---|
| D1 ↔ R1 | `10.0.0.0/30` | D1 `10.0.0.1`, R1 `10.0.0.2` |
| D1 ↔ R2 | `10.0.0.4/30` | D1 `10.0.0.5`, R2 `10.0.0.6` |
| D2 ↔ R1 | `10.0.0.8/30` | D2 `10.0.0.9`, R1 `10.0.0.10` |
| D2 ↔ R2 | `10.0.0.12/30` | D2 `10.0.0.13`, R2 `10.0.0.14` |
| R1 ↔ ISP1 | `203.0.113.0/30` | R1 `203.0.113.1` (ISP side `.2`, left to the learner) |
| R2 ↔ ISP1 | `203.0.113.4/30` | R2 `203.0.113.5` (ISP side `.6`, left to the learner) |

Interface names differ from the Cisco-edge variant:
- Edge routers use `Ethernet1` for D1, `Ethernet2` for D2, and `Ethernet3` for the ISP.
- Everywhere else, interfaces use the same names as the Cisco-edge variant.

## What's not configured

- **No VLANs or SVIs.** Every switch port is a default switchport in VLAN 1. Hosts have no IP addresses.
- **No gateways.** Hosts have no default route, and the distribution switches have no SVIs.
- **No routing protocol.** Only the links listed above are addressed.
- **D1–D2 (Ethernet3) and R1–R2 are cabled but unaddressed.** Only the learner decides where Layer 3 starts.
- **ISP1 is unconfigured.** Its interfaces exist, but nothing is addressed on them. Learners can bring it up as an ISP or use it as another internal device.

Because D1 and D2 both connect to SW1 and SW2, there's a Layer 2 loop in VLAN 1. Spanning tree is on by default, so some ports will block. Learners can use that as a starting point for Layer 2 troubleshooting.

## Coming next

An OSPF variant and a BGP variant, with the same addressing and baseline reachability already configured.
