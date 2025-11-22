# Homelab with RPI 5

> &#9888 Disclaimer:

>The documentation is about 75% ready and is still subject to change. If you want something specific explained in more depth just open a github issue.

This is a beginners guide to create a homelab using Raspberry Pi 5 SBC's to run a stable Kubernetes cluster with Ceph storage.

**Everything will be [publicly](https://github.com/hyrsh/homelab-rpi) usable for everyone.**

Since the topic of Kubernetes kind of exploded since 2016 I wanted to provide a general base of knowledge and support to handle bare-metal installations.

This homelab and its ideas can be extended to a full production-grade setup and I will mention the missing parts that we do not need in a homelab environment.

I decided to use RPI's because they are very quiet, do not need much power and still can carry basic applications.

All installation routines will be done with [Ansible](https://docs.ansible.com/ansible/latest/index.html) but there are still some manual tasks to perform.


Thanks to the software and infrastructure people:

- [Infomaniak](https://www.infomaniak.com/en)
- [The Ceph Foundation](https://ceph.io/en/foundation/about/)
- [The Raspberry Pi Foundation](https://www.raspberrypi.org/about/)
- [The Ansible Community](https://docs.ansible.com/)
- [The Kubernetes Community](https://kubernetes.io/)

Thanks to the shops that everything was in stock:

- [ThePiShop](https://www.pi-shop.ch/) (RPIs & PoE HATs)
- [ThePiHut](https://thepihut.com/) (Heatsinks)
- [Motedis](https://www.motedis.ch/en) (precise cut aluminium rails)
- [Börlin AG (acrylglas24.ch)](https://acrylglas24.ch/) (precise cut plexiglass sheets)
- [Galaxus](https://www.galaxus.ch/) (all of the rest)

I listed most of it in the [material page](05_material/lp_material.md) (if things are missing you will figure it out). The result is all of the RPIs packed in a [box](06_thebox/lp_thebox.md).

<hr>

## Guidance

If you start from scratch you can go through all pages like they are presented on the left hand side navigation from top to bottom.

The page about [HAProxy & VPN](07_hprx_vpn/lp_hprx_vpn.md) is still relevant even if you do not plan on connecting VPN clients to an external source. You can easily ignore the WireGuard topics and roles written for Ansible.

The pages about [material](05_material/lp_material.md) and the [box containing the RPIs](06_thebox/lp_thebox.md) are not necessary for the technical process.

If you start with prior knowledge there is a logical order you should maintain:

1. Raspberry Pi OS installation & SSH key distribution
2. TLS certificate generation
3. Setting all respective values in your Ansible vault
4. HAProxy (optional VPN) configuration
5. Setting up Ceph
6. Setting up Kubernetes
7. Final configurations

<hr>

## General idea

- Bootstrapping the RPI's to handle them from a central workstation
    - Shameless plug for [Tuxedo](https://www.tuxedocomputers.com/de) laptops :)
- Bootstrapping Kubernetes with [k3s](https://k3s.io/)
- Installing HA VPN nodes for public internet access of your cluster services
- Bootstrapping a Ceph cluster to use with Kubernetes for storage
- Deploying several services using Helm (inkl. setup)
- Using and structuring Ansible Playbooks to handle everything in a declarative manner
- Explanations of why and how I decided to do things the way I did

<hr>

## The result (in this example)

- A [Kubernetes](https://kubernetes.io/) cluster with
    - 3x [master nodes](https://kubernetes.io/docs/concepts/overview/components/#control-plane-components)
    - 10x [worker nodes](https://kubernetes.io/docs/concepts/overview/components/#node-components)
    - Ingress Controllers [(NGINX)](https://nginx.org/en/)
        - 2x dedicated ingress nodes
        - a self-signed PKI for general TLS handling
    - [Keycloak](https://www.keycloak.org/)
    - [Harbor](https://goharbor.io/)
    - [MKDocs (Material)](https://squidfunk.github.io/mkdocs-material/)
    - *more to come ...*
- A [Ceph cluster](https://docs.ceph.com/en/latest/rados/) with 5x nodes
    - 10x OSDs with 20TB raw storage for [Kubernetes](https://kubernetes.io/) using the [CSI-driver](https://github.com/ceph/ceph-csi)
    - 3x [monitor nodes](https://docs.ceph.com/en/latest/man/8/ceph-mon/)
    - 2x [manager nodes](https://docs.ceph.com/en/quincy/mgr/index.html)
    - 1x [CephFS](https://docs.ceph.com/en/quincy/cephfs/index.html) for [Kubernetes](https://kubernetes.io/)
    - WebUI inkl. self-signed certificates
- An HA entrypoint for external and local traffic
    - VPN setup with [WireGuard](https://www.wireguard.com/)
    - [HAProxy](https://www.haproxy.org/) setup
    - [KeepaliveD](https://keepalived.org/) setup for vIP switching via VRRP

<hr>

## Technologies

|Name|Type|Description|
|-|-|-|
|Raspberry Pi OS Lite (64bit)|Linux OS (ARM) without GUI|Debian 12 and 13 for Raspberry Pi's|
|Ansible|Configuration Management|Declarative configuration for our hosts|
|SSH|Remote Connection|Used to connect to our hosts|
|Bash|Linux Shell|Used to create scripts|
|Kubernetes|Container Orchestrator|Used to create a cluster across hosts|
|Ceph|Software Defined Storage|Used to provide dynamic storage for our Kubernetes cluster|
|HAProxy|Loadbalancer|Used to route incoming traffic to our Kubernetes cluster|
|WireGuard|Virtual Private Network|Used to connect our VPS to our local network|
|KeepaliveD|VRRP Daemon|Used to enable fault tolerance of services across hosts|
|NGINX|Webserver|Used as Ingress Controller in our Kubernetes cluster|
|Harbor|Container Registry|Used to store container images and helm charts|
|MKDocs|Documentation Software|Used to host MarkDown files in a WebUI|
|Grafana|Monitoring, Visualization|Used to visualize metrics in a WebUI|
|Prometheus|Monitoring, Scraping|Used to gather metrics of all of our components|
