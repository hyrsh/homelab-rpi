## Creating CephFS for Kubernetes

To create a CephFS we need to configure the size, the name and the authorization of it.

Since I encountered some memory spikes I also re-configured the Ceph mgr daemon memory ratio (but this is optional).

`Enter the Ceph CLI on your host of choice`
```shell
cephadm shell
```
`Change the memory ratio of the mgr`
```shell
ceph config set mgr mgr/cephadm/autotune_memory_target_ratio 0.2
```

A CephFS is built with a metadata pool (for storing information about files) and a data pool (storing the actual files).

To create a metadata pool we also use the Ceph CLI.

```shell
ceph osd pool create k8s_metadata 256 256 replicated --autoscale-mode=on
```

Our name of the pool is "k8s_metadata" and it has initially 256 placement groups with the possibility to expand this number when storage grows. As this time of writing only replicated metadata pools are possible (erasure coded pools would be nicer).

To set the size we can use the "set-quota" command (e.g. here we set the size to 20GB, units are in bytes).

```shell
ceph osd pool set-quota k8s_metadata max_bytes 20000000000
```

> The set-quota command can always be used to expand or shrink osd pools

Now we have to create a pool that holds our actual data. Here we set the size to 250GB.

> The bulk flag is about [placement-group scaling](https://docs.ceph.com/en/latest/rados/operations/placement-groups/#managing-pools-that-are-flagged-with-bulk) of a pool.

```shell
ceph osd pool create k8s_data 256 256 replicated --autoscale-mode=on
ceph osd pool set k8s_data bulk true
ceph osd pool set-quota k8s_data max_bytes 250000000000
```

If both pools are set we can create the actual CephFS. The Ceph mds daemon for it is placed on our nodes "hl-ceph-02" and "hl-ceph-05" and the overall caching limit is set to 2GB of memory (we have 8GB total per RPI).

```shell
ceph fs new k8s_fs k8s_metadata k8s_data
ceph orch apply mds k8s_fs --placement="2 hl-ceph-02 hl-ceph-05"
ceph config set mds mds_cache_memory_limit 2000000000
```

Finally we have to create a client (for Kubernetes) to be able to read and write data in our newly created CephFS.

```shell
ceph auth get-or-create client.k8scephfs mgr "allow rw" mds "allow rw fsname=k8s_fs path=/volumes, allow rw fsname=k8s_fs path=/volumes/csi" mon "allow r fsname=k8s_fs" osd "allow rw tag cephfs data=k8s_fs, allow rw tag cephfs metadata=k8s_fs"
```
Save the output (client key) to your vault.

Another completely new topic is the subvolume group. This group is used by CephFS as additional subdirectory for the requested volumes from Kubernetes with the CSI plugin.

```shell
ceph fs subvolumegroup create k8s_fs k8s
```

The configuration of Ceph for our CephFS is now complete.

> Information:

> - Since we activated "autoscale" on placement groups the k8s_metadata pool will shrink its amount of PGs upon creation. Don't be alarmed since this is normal behaviour

You can see the new created storage pools under the "Pools" section:

![image](assets/ceph_pool_autoscale.jpg)

<hr>

## Creating The Ceph RGW

The creation of the RADOS gateway, at least on my behalf, is tied to selected nodes to distribute load across them.

This is done via the cephadm-shell.

`Set arbitrary label to the nodes`
```shell
ceph orch host label add hl-ceph-03 rgw
ceph orch host label add hl-ceph-04 rgw
```
The setup of the RGW is done via a TLS YAML file (see next chapter).

<hr>

### TLS Setup

The TLS setup on Squid (v19) was **not** like described in the documentation:

  - the field "certificate_source: inline" was not recognized
  - the "certmgr" module to manually setup the certificates was non-existent
  - the fields "ssl_cert" and "ssl_key" were not recognized
  - the default RGW setup command did start the services but **not** the listening ports (I checked the machines with ss -lptn)
    - cmd: ceph orch apply rgw rgw01 '--placement=label:rgw count-per-host:1' --port=1337
    - after that I tried to apply the YAML file but it did not work properly

So I had to do some digging and found a valid YAML specification to get the RGW up and running.

`inline-certs.yml`
```YAML
service_type: rgw
service_id: rgw01
placement:
  label: rgw
  count_per_host: 1
spec:
  ssl: true
  rgw_frontend_port: 1337
  rgw_frontend_ssl_certificate: |
    -----BEGIN PRIVATE KEY-----
    PEM DATA
    -----END PRIVATE KEY-----
    -----BEGIN CERTIFICATE-----
    PEM DATA
    -----END CERTIFICATE-----
```

In this case our RGW will be called "rgw01" our orchestrator service therefore is "rgw.rgw01" and we used the labels give to our nodes to distribute the daemons.

The certificates I used are my private PKI ones.

Since we used self-signed certificates on the RGW instances we need to disable the check from the dashboard:
```shell
ceph dashboard set-rgw-api-ssl-verify False
```

See the [explanation of enabling the RGW frontend](https://documentation.suse.com/ses/7.1/html/ses-all/dashboard-initial-configuration.html#dashboard-ogw-enabling) and read through it.

<hr>

### Ingress Traffic Setup

I did not use the traditional traffic setup for HA as desrcibed in the docs of Ceph because I already have that kind of setup running for the whole cluster.

All I did was to assign a hostname to my chosen nodes (hl-ceph-03 and hl-ceph-04) and created a DNS entry on my router for a general point of connection (cephrgw.hyrsh.io) for all my object storage clients. The HAProxy configuration was set accordingly.

<hr>

### RGW Pool Creation

At first we have to create a rule on how data is stored in our RGW bucket.

> These rules are set via [CRUSH rule profiles](https://docs.ceph.com/en/latest/rados/operations/crush-map/#creating-a-rule-for-an-erasure-coded-pool)

`Enter cephadm shell`
`Check current profiles`
```shell
ceph osd erasure-code-profile ls
```
`Create a new profile`
```shell
ceph osd erasure-code-profile set ecprofile k=2 m=2 plugin=jerasure technique=reed_sol_van crush-failure-domain=host
```

This profile is not very different from the default one but I wanted the failure domain to honor hosts.

`Create new pool with the profile`
```shell
ceph osd pool create rgwdata 256 256 erasure ecprofile --autoscale-mode=on --bulk
```
`Associate the new pool with the RGW`
```shell
ceph osd pool application enable rgwdata rgw
```
`Restart your RGW`
```shell
ceph orch daemon restart rgw.rgw01.hl-ceph-03.ckkjud
ceph orch daemon restart rgw.rgw01.hl-ceph-04.dlnykt
```

Your services and their names can be found using "ceph orch ps".

`ceph orch ps`
```shell
NAME                          HOST        PORTS             STATUS      
alertmanager.hl-ceph-01       hl-ceph-01  *:9093,9094       running (4w)
crash.hl-ceph-01              hl-ceph-01                    running (4w)
crash.hl-ceph-02              hl-ceph-02                    running (4w)
crash.hl-ceph-03              hl-ceph-03                    running (4w)
crash.hl-ceph-04              hl-ceph-04                    running (4w)
crash.hl-ceph-05              hl-ceph-05                    running (4w)
grafana.hl-ceph-01            hl-ceph-01  *:3000            running (4w)
mds.k8s_fs.hl-ceph-02.twizai  hl-ceph-02                    running (4w)
mds.k8s_fs.hl-ceph-05.bzdcnu  hl-ceph-05                    running (4w)
mgr.hl-ceph-03.vaogpo         hl-ceph-03  *:8443,9283,8765  running (4w)
mgr.hl-ceph-04.djedoy         hl-ceph-04  *:8443,9283,8765  running (4w)
mon.hl-ceph-01                hl-ceph-01                    running (4w)
mon.hl-ceph-02                hl-ceph-02                    running (4w)
mon.hl-ceph-05                hl-ceph-05                    running (4w)
node-exporter.hl-ceph-01      hl-ceph-01  *:9100            running (4w)
node-exporter.hl-ceph-02      hl-ceph-02  *:9100            running (4w)
node-exporter.hl-ceph-03      hl-ceph-03  *:9100            running (4w)
node-exporter.hl-ceph-04      hl-ceph-04  *:9100            running (4w)
node-exporter.hl-ceph-05      hl-ceph-05  *:9100            running (4w)
osd.0                         hl-ceph-01                    running (4w)
osd.1                         hl-ceph-01                    running (4w)
osd.2                         hl-ceph-02                    running (4w)
osd.3                         hl-ceph-02                    running (4w)
osd.4                         hl-ceph-03                    running (4w)
osd.5                         hl-ceph-03                    running (4w)
osd.6                         hl-ceph-04                    running (4w)
osd.7                         hl-ceph-04                    running (4w)
osd.8                         hl-ceph-05                    running (4w)
osd.9                         hl-ceph-05                    running (4w)
prometheus.hl-ceph-01         hl-ceph-01  *:9095            running (4w)
rgw.rgw01.hl-ceph-03.ckkjud   hl-ceph-03  *:1337            running (2d)
rgw.rgw01.hl-ceph-04.dlnykt   hl-ceph-04  *:1337            running (2d)
```

<hr>
