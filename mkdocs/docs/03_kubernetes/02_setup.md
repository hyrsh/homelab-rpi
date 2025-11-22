## Preparation Of Nodes

Similar to Ceph we need to do some stuff on the nodes before we can start installing k3s.

> Important note:

> - If you did not check out the Raspberry pages you must read at least [this section](../02_raspberry/lp_raspberry.md#general-information) since it is crucial to activate cgroups for memory

First we have to get our k3s config for bootstrapping the cluster to all master nodes.

You can do this by running the playbook "pb-distribute-k3s-config.yml". This will distribute the /etc/rancher/k3s/config.yaml file that gets used with the k3s script.

```shell
ansible-playbook -J -i inventory.yml -e op_mode=install playbooks/pb-distribute-k3s-config.yml
```

`/etc/rancher/k3s/config.yaml`
```YAML
write-kubeconfig-mode: "0644"
tls-san:
  - "myalternative.domain.io"
  - "myalternativeip"
flannel-backend: "none"
disable-kube-proxy: true
disable-network-policy: true
cluster-init: true <-- this is only true on your initial master, other masters are set to "false"
disable:
  - servicelb
  - traefik
```

Since I want my k8s/k3s masters to be behind a loadbalancer I must set further TLS SAN fields that contain my loadbalancer VIP or domain. Otherwise I would get certificate errors.

<span style="color:red"><b>This is a completely different certificate from what we just generated! k3s does create self-signed certificates for the k8s API!</b></span>

<hr>

## Initialize The Control Plane

To start the control plane we do have to pick a initial master. This host is set through our group_vars/all:

`group_vars/all`
```YAML
  (...)
  hl_ceph_05:
userinfos:
  allowed_ssh_users: "ansible-admin ansible"
setupinfos:
  (...)
  k3s:
    cilium_version: "v0.18.8"
    cilium_arch: "arm64"
    helm_version: "v3.19.0"
    helm_arch: "arm64"
    master:
      san_domain: "k3s-master.hyrsh.io"
      registration_host: "hl-master-01" <-- this is where nodes register them to
```

To set it up you can run the playbook "pb-k3s-setup-control-plane.yml" with the op_mode flag "init".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=init playbooks/pb-k3s-setup-control-plane.yml
```

If this succeeds you can join the other masters with same playbook but the op_mode flag "join-master".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=join-master playbooks/pb-k3s-setup-control-plane.yml
```

After a successful run of both playbooks <span style="color:red"><b>does not create a functional cluster yet!</b></span>

<hr>

## Adding Worker Nodes

We have to join at least 1x worker node and setup the container network so that pods can be assigned to IPs and we have traffic.

To join worker nodes you use the same playbook for initiating/joining the masters but with the op_mode flag "join-agent".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=join-agent playbooks/pb-k3s-setup-control-plane.yml
```

> Information:

> - To toggle what worker should join you can toggle "yes" and "no" in the group_vars/all under each worker host

## Installing Cilium

Cilium will be our container network interface (CNI) plugin of choice.

To install the binary we roll it out to all masters with the playbook "pb-k3s-setup-cilium.yml" and the op_mode flag "install".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=install playbooks/pb-k3s-setup-cilium.yml
```

After that we can deploy the CNI with the same playbook but the op_mode flag "deploy".

```shell
ansible-playbook -J -i inventory.yml -e op_mode=deploy playbooks/pb-k3s-setup-cilium.yml
```

If everything above went through without errors you have a very basic k3s cluster.

Congrats.

## Check Nodes & Pods

The kubectl binary is present on all masters so you can check the state e.g. from (in my case) hl-master-01:

```shell
root@hl-master-01:~# kubectl get nodes

NAME           STATUS   ROLES                       AGE     VERSION
hl-master-01   Ready    control-plane,etcd,master   7h32m   v1.33.5+k3s1
hl-master-02   Ready    control-plane,etcd,master   7h31m   v1.33.5+k3s1
hl-master-03   Ready    control-plane,etcd,master   7h31m   v1.33.5+k3s1
hl-worker-01   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-02   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-03   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-04   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-05   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-06   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-07   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-08   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-09   Ready    <none>                      6h29m   v1.33.5+k3s1
hl-worker-10   Ready    <none>                      6h29m   v1.33.5+k3s1
```
```shell
root@hl-master-01:~# kubectl get pod -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   cilium-6ghwp                              1/1     Running   0          6h29m
kube-system   cilium-7rd7k                              1/1     Running   0          6h29m
kube-system   cilium-7wpzk                              1/1     Running   0          6h29m
kube-system   cilium-8hsnc                              1/1     Running   0          6h29m
kube-system   cilium-b2vpt                              1/1     Running   0          6h29m
kube-system   cilium-b6dr6                              1/1     Running   0          6h29m
kube-system   cilium-envoy-2grcs                        1/1     Running   0          6h29m
kube-system   cilium-envoy-4ghrd                        1/1     Running   0          6h29m
kube-system   cilium-envoy-8gxv2                        1/1     Running   0          6h29m
kube-system   cilium-envoy-98r9m                        1/1     Running   0          6h29m
kube-system   cilium-envoy-9b6zp                        1/1     Running   0          6h29m
kube-system   cilium-envoy-bgm9l                        1/1     Running   0          6h29m
kube-system   cilium-envoy-d4684                        1/1     Running   0          6h29m
kube-system   cilium-envoy-gg5xb                        1/1     Running   0          6h29m
kube-system   cilium-envoy-jm2rx                        1/1     Running   0          6h29m
kube-system   cilium-envoy-m4lmf                        1/1     Running   0          6h29m
kube-system   cilium-envoy-r4ts6                        1/1     Running   0          6h29m
kube-system   cilium-envoy-zvwbx                        1/1     Running   0          6h29m
kube-system   cilium-envoy-zwn9r                        1/1     Running   0          6h29m
kube-system   cilium-j8ggg                              1/1     Running   0          6h29m
kube-system   cilium-klzlj                              1/1     Running   0          6h29m
kube-system   cilium-m76g5                              1/1     Running   0          6h29m
kube-system   cilium-m8r94                              1/1     Running   0          6h29m
kube-system   cilium-operator-c76cf58f9-8dsv5           1/1     Running   0          6h29m
kube-system   cilium-tmzz6                              1/1     Running   0          6h29m
kube-system   cilium-txhtk                              1/1     Running   0          6h29m
kube-system   cilium-v4fks                              1/1     Running   0          6h29m
kube-system   coredns-64fd4b4794-6226r                  1/1     Running   0          7h33m
kube-system   local-path-provisioner-774c6665dc-95jxs   1/1     Running   0          7h33m
kube-system   metrics-server-7bfffcd44-ws5w5            1/1     Running   0          7h33m
```

This cluster is already capable of running pods but exposure, storage and security configuration is completely missing.

<hr>