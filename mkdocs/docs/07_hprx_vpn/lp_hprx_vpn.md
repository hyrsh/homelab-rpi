# HAProxy & VPN

To get a semi-high available entrypoint to our cluster from inside my local net and the public internet I decided to setup [HAProxy](https://www.haproxy.org/) with 2x instances and also install a VPN client ([WireGuard](https://www.wireguard.com/)) on the same nodes to enable simple DNS settings, local controlled policies and connection to my VPS running on a CSP.

The idea behind this is that every URL called that reaches the cluster is controlled by a [load balancer](https://www.geeksforgeeks.org/system-design/what-is-load-balancer-system-design/) policy/restriction **before** it reaches the cluster machines. I apply rate-limiting, maximum connection thresholds and throttling to different URLs to avoid melting my cluster and bandwidth.

Since I want at least one [HAProxy](https://www.haproxy.org/) instance be reachable we need to configure a low-level fail-over using a [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) provided by [KeepaliveD](https://keepalived.readthedocs.io/en/latest/introduction.html).

Our [NICs](https://en.wikipedia.org/wiki/Network_interface_controller) on the RPIs get a [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) assigned and [KeepaliveD](https://keepalived.readthedocs.io/en/latest/introduction.html) checks in a defined interval if the master instance is reachable. If not it switches the [vIP](https://infotracer.com/reverse-ip-lookup/virtual-ip-address/) assignment to the secondary instance. It uses [VRRP](https://networklessons.com/cisco/ccie-routing-switching/vrrp-virtual-router-redundancy-protocol) to do so.

To make this happen we need to install some packages and do some config work.

<hr>

## Ansible configuration

I have configured Ansible that it can reach both HAProxy/VPN nodes with an individual ssh-key and I have enough permissions to configure root-level applications (necessary because of vIP configs and port listening below port 1024).

> Disclaimer:

>My style of Ansible differs a bit from the official structure --> [see here](../08_ansible/lp_ansible.md#structure)

The directory structure for this is pretty straight forward:

- Role for seting up [HAProxy](https://github.com/hyrsh/homelab-rpi/tree/main/ansible/roles/setup_haproxy)
- Role for setting up [WireGuard](https://github.com/hyrsh/homelab-rpi/tree/main/ansible/roles/setup_wireguard)
- Role for setting up [KeepaliveD](https://github.com/hyrsh/homelab-rpi/tree/main/ansible/roles/setup_keepalived)

`Directory tree`
```shell
.
├── ansible.cfg
├── group_vars
│   └── all
├── inventory.yml
├── playbooks
│   ├── pb-install-lb.yml
│   ├── roles -> ../roles
│   └── vault -> ../vault
├── roles
│   ├── setup_haproxy
│   │   ├── files
│   │   │   └── lp_bg.jpg
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       ├── default.j2
│   │       ├── haproxy.cfg.j2
│   │       └── index.nginx-debian.html.j2
│   ├── setup_keepalived
│   │   ├── tasks
│   │   │   └── main.yml
│   │   └── templates
│   │       ├── kd_haproxy.sh.j2
│   │       ├── keepalived.config-opts.j2
│   │       ├── keepalived.conf.j2
│   │       └── keepalived.conf.sample.j2
│   └── setup_wireguard
│       ├── tasks
│       │   └── main.yml
│       └── templates
│           ├── vps.conf
│           └── wg0.conf.j2
└── vault
    └── av_homelab
```

> Note:

> - In our playbook directory we have symbolic links to roles and vault since Ansible expects these directories to be on the same level as the executing playbook. Just point them to the respective paths

We use conditions to be able to install/uninstall and/or toggle a simple config rollout. To control these conditions we can add a flag "-e" with our conditional variable (op_mode) alongside our playbook call.

All our templates are in [Jinja2](https://en.wikipedia.org/wiki/Jinja_(template_engine)) and get their variables from our main configuration file at [/ansible/group_vars/all](https://github.com/hyrsh/homelab-rpi/blob/main/ansible/group_vars/all), the vault (not uploaded) and/or the corresponding playbook that is called.

<hr>

## TLS Certificates

Everything in this setup will be [TLS]() secured. To adhere to international standards I do create a [PKI]() with a root CA, an intermediate CA and a leaf certificate. I do not directly sign leaf certificates from root CAs.

> If you know all about that already you will see how I did integrate the certificates in the Ansible vault and provisioned them with the playbooks.

To ease the TLS bootstrapping for people who want their own self-signed certificates [I provided a script](https://github.com/hyrsh/homelab-rpi/blob/main/scripts/create-pki/create-certs.sh) that can be used for that.

`Script help`
```shell
root@myhost:~# ./create-certs.sh -h

[+] Usage:
----------
- e.g. ./create-certs.sh -domain *.homelab.org -s-exp 1000 -r-exp 10000 -i-exp 8000

[+] Flags:
----------
  -r-exp|-root-expiry         > days of expiration of your root CA
  -i-exp|-intermediate-expiry > days of expiration of your intermediate CA
  -s-exp|-server-expiry       > days of expiration of your server cert
  -d|-domain                  > domain of your server cert
  -c|-country                 > country of your INT/ROOT CA
  -st|-state                  > state of your INT/ROOT CA
  -l|-locality                > locality of your INT/ROOT CA
  -org|-organization          > organization of your INT/ROOT CA
  -ou|-organizational-unit    > organizational unit of your INT/ROOT CA
  -mail                       > mail to use for your server cert
  -h|-help                    > prints this help
```

If parameters are omitted they will be filled with default values.

`Script example overview`
```shell
root@myhost:~# ./create-certs.sh \
  -d *.mydomain.io \
  -c COUNTRY \
  -st STATE \
  -l LOCALITY \
  -org MyOrg \
  -ou MyUnit \
  -mail info@noreply.io \
  -r-exp 10000 \
  -i-exp 8000 \
  -s-exp 7500
```

`Script example one liner`
```shell
root@myhost:~# ./create-certs.sh -d *.mydomain.io -c JP -st Kyoto -l Maizuru -org MyOrg -ou MyUnit -mail info@noreply.ch -r-exp 10000 -i-exp 8000 -s-exp 7500
```

If you execute the script it will generate a directory and all necessary files for your own self-signed TLS infrastructure.

Our focus is on the 6x certificates in the first directory level of the script output:

- root_ca.cert.pem
- root_ca.key.pem
- intermediate_ca.cert.pem
- intermediate_ca.key.pem
- my-testdomain.pub.io.cert.pem *<-- will be named after your chosen domain*
- my-testdomain.pub.io.key.pem *<-- will be named after your chosen domain*

The used Ansible vault has to have a [specific structure to work](../08_ansible/lp_ansible.md#ansible-vault-structure), so make sure you enter the values accordingly.

To create a base64 encoded string to be used in the vault you can do the following:

```shell
root@myhost:~# cat ./root_ca.key.pem | base64 -w0
```

Copy the output to the respective field in the vault:

|base64 output of this file|goes in this Field in your vault|
|-|-|
|root_ca.key.pem|sspki_root_key|
|root_ca.cert.pem|sspki_root_crt|
|intermediate_ca.key.pem|sspki_int_key|
|intermediate_ca.cert.pem|sspki_int_crt|
|my-testdomain.pub.io.key.pem|sspki_srv_key|
|my-testdomain.pub.io.cert.pem |sspki_srv_crt|

<hr>