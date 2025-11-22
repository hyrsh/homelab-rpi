# Design

To enable a slightly fault tolerant system we need to take care of redundancy. Of course in a simple home environment we cannot go enterprise-grade with separate power lines, battery packs and so on but the setup will tolerate some hardware failures.

> &#9888 Production note:

> - We also would have to separate the hosts in different availability zones, provide separate power lines on different circuits, make sure that power failures are softened with PSUs, cooling is redundant, network connectivity is redundant (incl. power supply) and access is restricted

The connection to the CSP is (as of now) a single VPS but even if it fails the local connections will remain stable and all services keep running. Maybe in the future I will scale the VPS and register it to my public domain for a simple HA round-robin access.

All other components are redundant and can tank at least one hardware blackout per domain:

- Storage (5x Ceph nodes)
- Access/Routing (2x LB nodes)
- Workloads (10x Kubernetes worker nodes)
- Managements (3x Kubernetes master nodes)
- Network (4x PoE Switches)

> &#9888 Production note:

> - Ceph storage in production must be carefully planned to meet the desired availability, storage and network consumption. Due to its SDS nature, the network exhaustion is a bit different from legacy/traditional storage systems (NAS, SAN)

<hr>

The system has focus on a few specific areas:

|Area|Approach|
|-|-|
|Switch failure|Multiple switches and distributed wiring|
|RPI failure|Redundant hardware per domain (storage, routing, management, workloads)|
|Public access|VPS from swiss CSP|
|Local access|Split DNS settings with TLS bridging/offloading no LB nodes|
|General security|All connections are TLS secured, public traffic is limited through LB|
|Storage provisioning|Ceph CSI driver in k8s for CephFS auto-provisioning|
|Storage failure|Redundant daemons, enough capacity to tank 2x OSD blackouts|
|Workload failure|Pods can move between 10x worker nodes|

<hr>

## Overview

This is a general overview of what is about to be built (right-click and open in new tab to enlarge image):


![image](assets/design_overview.png)
