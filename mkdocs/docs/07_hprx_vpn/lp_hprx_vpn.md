# HAProxy & VPN

To get a semi-high available entrypoint to our cluster from inside my local net and the public internet I decided to setup [HAProxy](https://www.haproxy.org/) with 2x instances and also install a VPN client ([WireGuard](https://www.wireguard.com/)) on the same nodes to enable simple DNS settings and local controlled policies.

The idea behind this is that every URL called that reaches the cluster is controlled by a [load balancer](https://www.geeksforgeeks.org/system-design/what-is-load-balancer-system-design/) policy/restriction **before** it reaches the cluster machines. I apply rate-limiting, maximum connection thresholds and throttling to different URLs to avoid melting my cluster and bandwidth.

Since I want at least one [HAProxy](https://www.haproxy.org/) instance be reachable we need to configure a low-level fail-over using a [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) provided by [KeepaliveD](https://keepalived.readthedocs.io/en/latest/introduction.html).

Our [NICs](https://en.wikipedia.org/wiki/Network_interface_controller) on the RPIs get a [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) assigned and [KeepaliveD](https://keepalived.readthedocs.io/en/latest/introduction.html) checks in a defined interval if the master instance is reachable. If not it switches the [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) assignment to the secondary instance. It uses [VRRP](https://networklessons.com/cisco/ccie-routing-switching/vrrp-virtual-router-redundancy-protocol) to do so.

To make this happen we need to install some packages and do some config work.

<hr>

## Ansible configuration

I have configured Ansible that it can reach both HAProxy/VPN nodes with an individual ssh-key and I have enough permissions to configure root-level applications (necessary because of vIP configs and port listening below port 1024; *more information*).

> Disclaimer:

>My style of Ansible differs a bit from the official structure since I want to have one directory that can be copied everywhere and contains everything needed to execute the playbooks. I use roles as primary config blocks and do not use umbrella-style configurations like global roles or variables that are sourced from somewhere else. My ansible-vault and variables are also within the main directory.

The directory structure for this is pretty straight forward:

- Roles for seting up [HAProxy](https://github.com/hyrsh/homelab-rpi/tree/main/ansible/roles/setup_haproxy)
- Role for setting up [WireGuard](https://github.com/hyrsh/homelab-rpi/tree/main/ansible/roles/setup_wireguard)
- Role for setting up KeepaliveD

`Directory tree`
```shell
-/ansible
  - /group_vars
  - inventory.yml
  - /roles
    - /setup_haproxy
      - /tasks/main.yml
      - /templates/haproxy.cfg.j2
    - /setup_keepalived
      - /tasks/main.yml
      - /templates/keepalived.conf.j2
      - /scripts/haproxy_check.sh
    - /setup_wireguard
      - /tasks/main.yml
      - /templates/wg0.conf.j2
```

We use conditions to be able to install/uninstall and/or toggle a simple config rollout.