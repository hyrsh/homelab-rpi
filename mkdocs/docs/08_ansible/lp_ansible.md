# Ansible


<p align="center"><img src="../assets/ansible-logo.png" /></p>

To configure multiple hosts I ended up using [Ansible](https://docs.ansible.com/ansible/latest/index.html) and I am very happy with it.

The general idea:

- write human readable syntax that invokes specific [modules](https://docs.ansible.com/ansible/2.9/user_guide/modules_intro.html)
- let it run using a [playbook](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- the target host only has to be reachable by [SSH](https://www.ssh.com/academy/ssh)
- the target host only has to have [minimal packages installed](https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html#using-python-3-on-the-managed-machines-with-commands-and-playbooks) an **no agent** (which is what I like)

<hr>

## Structure

I use a structure that is not the official and "correct" way, since the official way is focused on a single host that has all sorts of default roles and variables pre-configured and just uses these information outside the actual directory where the magic happens.

My way is something I call "self-contained" Ansible. It does not rely on external or pre-configured roles and variables but has everything within one "main directory" to execute all respective playbooks (this is the name of the file that describes what Ansible should do). With this approach all my Ansible projects become portable and can be shared.

>*This information uses terms not yet explained so maybe come back to it later:*

>There is one thing that is "unusual" in this setup. In all of my playbooks there is a role called ["expose_ssh_keys"](https://github.com/hyrsh/homelab-rpi/blob/main/ansible/roles/expose_ssh_keys/tasks/main.yml) and sadly it is necessary to add. This role converts the private ssh keys of the respective host (or group of hosts) that is called within a playbook from our vault to a file at "/tmp/ansible_exposed_keys/<HOST>.ssh_key". After the playbook run a post-run handler gets invoked to delete this directory so the keys do not exist on your machine anymore.

>It is ugly but necessary since Ansible cannot work with private ssh keys sourced from a variable.

<hr>

## Basics

The simplest structure of a working Ansible directory (written in my style) looks like this:

```shell
-/ansible
  - /group_vars
    - all <-- variable file
  - /roles
    - /debug/tasks
      - main.yml <-- task file for role "debug"
  - playbook.yml <-- Ansible Playbook
  - myvault <-- vault file
```

We will go through all files and see why they are necessary (with examples).

<hr>

### Variables

`File: /ansible/group_vars/all`

```yaml
myblock1:
  myvar1: "hello"
```

Ansible uses "variable sourcing" which is a way to consume custom configuration from a file, environment variable or extra-variable. The default path for ansible to look for such files is in the "group_vars" directory ([and many more places](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence), but we keep it simple for now).

The variables shown in the */ansible/group_vars/all* file can be accessed with the "dot-notation" (e.g. myblock1.myvar1) representing grouping/hierarchical structures. This is important, since we can make our instructions (tasks in roles) highly dynamic (we want that!).

<hr>

### Roles

`File: /ansible/roles/debug/tasks/main.yml`

```shell
- name: echo output
  debug:
    msg: "My message!"
```

Roles in Ansible are compact instruction sets of tasks that invoke modules to execute specific actions on a host. In this case we are creating a task ("echo output") using the "debug" module to output a simple string "My message!". To use our variable in this example we must alter it a bit.

`File: /ansible/roles/debug/tasks/main.yml`

```shell
- name: echo output
  debug:
    msg: "My message says: {{ myblock1.myvar1 }}"
```

If we want to access our values from our variable files, we need to use double curly braces ([Ansible is using Jinja syntax](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#using-variables)) to do so. Now the output shows the string "My message says: hello".

<hr>

### Playbooks

`File: /ansible/playbook.yml`

```shell
- hosts: localhost
  roles:
    - debug
```

A playbook is a reference on what host we want to execute specific roles.

Here we execute the "debug" role on our localhost. The available roles are looked up from the directories under "/ansible/roles". In our case we created a directory called "debug" and this is where Ansible goes when we want to invoke that role.

Executing this playbook is done with the ansible builtin CLI commands:

```shell
ansible-playbook playbook.yml
```

>We did not provide an inventory file (which is a list of hosts we can address) so the output may mention that. This is not a problem but a warning.

<hr>

### Vault

`File: /ansible/myvault`

```yaml
vault:
  mysecret: "1234"
```

Ansible does provide a small local security solution (that is sufficient for homelabs and smaller setups) called "vault". It is a file like our */ansible/group_vars/all* file with the same structure but encrypted with a 256-bit AES standard.

`Creating a vault:`

```shell
ansible-vault create myvault
```

`Editing a vault:`

```shell
ansible-vault edit myvault
```

I personally choose to prefix the top-level hierarchy with "vault" so I can easily determine what variable in my roles are sourced from the vault.

To use this variable we have to adjust our playbook, our role and the way we execute our playbook.

`File: /ansible/playbook.yml`

```shell
- hosts: localhost
  vars_files:
    - "myvault"
  roles:
    - debug
```

`File: /ansible/roles/debug/tasks/main.yml`

```shell
- name: echo output
  debug:
    msg: "My message says: {{ myblock1.myvar1 }} with the secret: {{ vault.mysecret }}"
```

`Execution`

```shell
ansible-playbook -J playbook.yml
```

In our playbook we included the vault file with "vars_files" by its relative path and extended our debug role with the variable "vault.mysecret". To execute this playbook we added the flag "-J" which is a shorthand flag for asking the vault password to decrypt it.

<hr>

## Wrap-up

If you understand these basics you can handle simple ansible installations. Everything else is a wild ride down the Ansible rabbit hole which consists of learning about its [modules](https://docs.ansible.com/ansible/2.9/user_guide/modules_intro.html), inventories, logic and syntactic trickery that sometimes can be very daunting.

It is one of the easiest configuration tools to learn and its community is really great so don't give up if you are exhausted by it.

And keep in mind to look for native Ansible modules before you use the "shell" module  :D

<hr>

## Ansible group_vars/all Structure

The playbooks expect a certain structure of the used group_vars/all so here is the current layout.

```YAML
hostinfos:
  hl_master_01:
    cluster_init: "yes"
  hl_master_02:
    cluster_init: "no"
  hl_master_03:
    cluster_init: "no"
  hl_lb_01:
    wireguard_ip: "16.16.8.3"
    wireguard_listening_port: "1337"
    wireguard_allowedips_peer: "12.16.10.0/24"
    kd_prio: "101"
  hl_lb_02:
    wireguard_ip: "16.16.8.4"
    wireguard_listening_port: "1337"
    wireguard_allowedips_peer: "12.16.10.0/24"
    kd_prio: "100"
  hl_worker_01:
    active: "yes"
  hl_worker_02:
    active: "yes"
  hl_worker_03:
    active: "yes"
  hl_worker_04:
    active: "yes"
  hl_worker_05:
    active: "yes"
  hl_worker_06:
    active: "yes"
  hl_worker_07:
    active: "yes"
  hl_worker_08:
    active: "yes"
  hl_worker_09:
    active: "yes"
  hl_worker_10:
    active: "yes"
  hl_ceph_01:
  hl_ceph_02:
  hl_ceph_03:
  hl_ceph_04:
  hl_ceph_05:
userinfos:
  allowed_ssh_users: "ansible-admin ansible"
setupinfos:
  lb_master: [ "hl-lb-01" ]
  lb_vip: "192.168.1.13"
  lb_cert_dir: "/etc/haproxy/own-certs"
  ceph_master: [ "hl-ceph-01", "hl-ceph-05" ]
  ingress_nodes: [ "hl-worker-05", "hl-worker-10" ]
  internal_domain: "mycoolinternaldomain.io"
  external_domain: "mycoolpublicdomain.nz"
  haproxy_domains:
    - {domain: "myexposed-url", ip: "192.168.1.3", info: "Page Info", state: "down"} <-- state can be "up" or "down" for maintenance
  max_connections_haproxy: "100"
  local_dns: "192.168.1.1"
  k3s:
    cilium_version: "v0.18.8"
    cilium_arch: "arm64"
    helm_version: "v3.19.0"
    helm_arch: "arm64"
    master:
      san_domain: "k3s-master.hyrsh.io"
      registration_host: "hl-master-01"
```

<hr>

## Ansible Vault Structure

The playbooks expect a certain structure of the used vault so here is the current layout.

- Fields with "#raw" contain the values "as-is" without encoding
- Fields with "#b64" contain the values with base64 encoding

```YAML
vault:
  init_admin_password: "myverysecretsecret" #raw
  k3s_cluster_init_secret: "mycoolandverylongsecret" #raw
  ssh_keys_private:
    hl_ceph_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_04: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_05: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_lb_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_lb_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_04: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_05: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_06: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_07: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_08: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_09: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_10: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
  ssh_keys_public:
    hl_ceph_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_04: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_ceph_05: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_lb_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_lb_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_master_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_01: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_02: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_03: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_04: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_05: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_06: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_07: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_08: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_09: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    hl_worker_10: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
  certs:
    sspki_root_key: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    sspki_root_crt: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    sspki_int_key: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    sspki_int_crt: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    sspki_srv_key: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    sspki_srv_crt: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    public_ca_bundle: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    public_server_bundle: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    pubpki_srv_key: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
    pubpki_srv_crt: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
  wireguard_keys_private:
    csp_vps: "coolwireguardprivatekey" #raw
    hl_lb_01: "coolwireguardprivatekey" #raw
    hl_lb_02: "coolwireguardprivatekey" #raw
  wireguard_keys_public:
    csp_vps: "coolwireguardpublickey" #raw
    hl_lb_01: "coolwireguardpublickey" #raw
    hl_lb_02: "coolwireguardpublickey" #raw
  csp:
    vps_ip: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
  ceph:
   ssh_key_private: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
   ssh_key_public: "Q29vbCBiYXNlNjQgZW5jb2RlZCBzdHJpbmc=" #b64
   fsid: "coolFSIDofCeph" #raw
  haproxy:
    hidden_domains:
      - {domain: "mycooldomain", ip: ["192.168.1.2:8443"], info: "My coold site", state: "up"}
```