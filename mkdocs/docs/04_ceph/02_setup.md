## Bootstrapping the initial cluster

First we have to pick a initial "master" node that gives birth to some crucial information that we later need for all other nodes. This information is entered in our Ansible vault to keep it safe and make it accessible for eventual roles in the future.

I pick my host "hl-ceph-01" as initial master node. At the time of writing it has the IP "192.168.1.30".

<hr>

## Preparation of nodes

To make all nodes capable of joining the ceph cluster we must install some packages before anything. I also install the ceph-management package "cephadm" on all nodes to be able to switch admin nodes if another one fails.

This can be rolled out with the Ansible playbook "pb-prepare-ceph.yml". If you have cloned this repository navigate to the "./ansible" directory and execute the playbook.

`Navigate to the ./ansible directory`

```shell
git clone https://github.com/hyrsh/homelab-rpi && cd homelab-rpi/ansible
```

`Install packages on all nodes`

```shell
ansible-playbook -J -i inventory.yml -e op_mode=install playbooks/pb-prepare-ceph.yml
```

The playbook expects a vault file at "./vault/av_homelab" and executes the run on hosts in the group "hl_ceph" so be aware that you may have to change that if you have custom paths/groups.

Wait for the Ansible playbook to finish and check for errors.

> Important note:

> - I use the root user within my Ceph installation which some may find too dangerous but these nodes are never exposed to anything else than my local k8s workers. In addition they have an internal SSH key for root that is only present on these 5x nodes. Ansible already has root access.

Next we generate a SSH key for the root user to be used accross our Ceph nodes.

`Generate keys`

```shell
ssh-keygen
```

Confirm with 2x enter for an empty passphrase.


`Convert keys to base64 to be handled better`

```shell
cat /root/.ssh/id_ed25519 | base64 -w0
cat /root/.ssh/id_ed25519.pub | base64 -w0
```

Save both outputs in your Ansible vault under "vault.ceph.ssh_key_private" and "vault.ceph.ssh_key_public".

`ansible-vault edit vault/av_homelab`

```yaml
vault:
  ceph:
    ssh_key_private: "<YOUR VALUE>"
    ssh_key_public: "<YOUR VALUE>"
```

Now you can execute the Ansible playbook "pb-distribute-ceph-keys.yml".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=install playbooks/pb-distribute-ceph-keys.yml
```

After that connect to your master node (in my case "hl-ceph-01") and try to reach all other nodes by SSH.

```shell
root@underwood:~# ssh -i $SSHPRIV ansible-admin@hl-ceph-01
ansible-admin@hl-ceph-01:~ $ sudo -i
root@hl-ceph-01:~# ssh hl-ceph-02
root@hl-ceph-02:~#
```

If this succeeds for all your nodes you have setup all SSH keys correctly.

> Info:

> - if there is a prompt for "The authenticity of host (...)" is shown answer with yes. This is a security warning if you can trust this host and want to add its identity (fingerprint hash) to your list of trusted endpoints. Since this is a homelab we know our hosts and enter "yes"

> - in a production environment if we do not know who controls the unknown host it is advised to enter "no" and re-check who setup and controls it




