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

To set the size we can start with 20GB.

```shell
ceph osd pool set-quota k8s_metadata max_bytes 20000000000
```

> Information:

> - The set-quota command can always be used to expand or shrink osd pools

Now we have to create a pool that holds our actual data. For the start we set the size to 250GB.

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
