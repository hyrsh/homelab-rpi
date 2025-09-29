# Homelab with RPI 5

This is a guide to create a homelab using Raspberry Pi 5 SBC's.

Everything will be publicly usable for everyone. Since the topic of Kubernetes kind of exploded since 2016 I wanted to provide a general approach to handle bare-metal installations.

This homelab can easily be extended to a full production-grade setup and I will mention the missing parts that we do not need in a home environment.

I decided to use RPI's because they are very quiet, do not need much power and still can carry basic applications.

<hr>

#### It will cover

- Bootstrapping the RPI's to handle them from a central workstation
    - Shameless plug for [Tuxedo](https://www.tuxedocomputers.com/de) laptops :)
- Bootstrapping Kubernetes with [k3s](https://k3s.io/)
- Installing HA VPN nodes for public internet access to your cluster services
- Bootstrapping a Ceph cluster to use with the Kubernetes cluster for storage
- Deploying several services using Helm (inkl. setup)
- Using and structuring Ansible Playbooks to handle everything in a declarative manner
- Explanations of why and how I decided to do things the way I did
- Deep-dive explanations of the respective technologies used

<hr>

#### The result (in this example) will end in

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
