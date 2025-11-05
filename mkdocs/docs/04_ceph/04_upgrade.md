## Staggered upgrading

With "staggered" we upgrade Ceph daemons in a very controlled an precise manner.

The general order is:

1. Manager Nodes (mgr)
2. Monitor Nodes (mon)
2. Crash Service (crash)
3. OSD Nodes (osd)
4. MDS Nodes (mds)

I started with a Ceph Pacific (v16) cluster and had trouble updating the Ceph Manager nodes due to some bugs on Debian 12 (bookworm). I managed to upgrade the cluster to Ceph Quincy (v17) by using the staggered approach so I will document what I did for the Ceph Pacific release.

`Check your current installed versions in the Ceph CLI (already upgraded to Quincy)`
```shell
ceph versions

{
    "mon": {
        "ceph version 17.2.8 (f817ceb7f187defb1d021d6328fa833eb8e943b3) quincy (stable)": 3
    },
    "mgr": {
        "ceph version 17.2.8 (f817ceb7f187defb1d021d6328fa833eb8e943b3) quincy (stable)": 2
    },
    "osd": {
        "ceph version 17.2.8 (f817ceb7f187defb1d021d6328fa833eb8e943b3) quincy (stable)": 10
    },
    "mds": {
        "ceph version 17.2.8 (f817ceb7f187defb1d021d6328fa833eb8e943b3) quincy (stable)": 2
    },
    "overall": {
        "ceph version 17.2.8 (f817ceb7f187defb1d021d6328fa833eb8e943b3) quincy (stable)": 17
    }
}
```
`Always check your upgrade status after each command`
```shell
ceph orch upgrade status

{
    "target_image": null,
    "in_progress": false,
    "which": "<unknown>",
    "services_complete": [],
    "progress": null,
    "message": "",
    "is_paused": false
}
```

I did all upgrades from the Ceph CLI.

`Enter Ceph CLI`
```shell
cephadm shell
```
> Important:

> - I started with my "standby" Ceph Manager node on host "hl-ceph-04" because I knew I shot it to hell with my previous attempt
`Upgrade Ceph Manager nodes`
> - My Ceph cluster did not have any data in any pools at the time of the upgrade
      - If you have loaded OSDs lock the refill mechanic
      - `ceph osd pool set noautoscale`
      - Upgrade the cluster and unlock the mechanic again
      - `ceph osd pool unset noautoscale`
```shell
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mgr --hosts hl-ceph-04
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mgr --hosts hl-ceph-03
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mon --hosts hl-ceph-01
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mon --hosts hl-ceph-02
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mon --hosts hl-ceph-05
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types crash
ceph osd pool set noautoscale
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types osd --hosts hl-ceph-01
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types osd --hosts hl-ceph-02
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types osd --hosts hl-ceph-03
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types osd --hosts hl-ceph-04
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types osd --hosts hl-ceph-05
ceph orch upgrade start --ceph-version 17.2.8 --daemon-types mds
ceph osd pool unset noautoscale
```

## Version Jumps

I did not see any warning about big upgrades with multiple major/minor/patch versions in between.

My path was `v16.2.5 (Pacific)` to `17.2.8 (Quincy)` to `19.2.3 (Squid)` and the cluster is healthy.

> Note:

> - There was a warning about v18 on Debian Bookworm with arm64 so I directly went from v17 to v19

<hr>

## Ceph State v19 Squid

```shell
ceph versions

{
    "mon": {
        "ceph version 19.2.3 (c92aebb279828e9c3c1f5d24613efca272649e62) squid (stable)": 3
    },
    "mgr": {
        "ceph version 19.2.3 (c92aebb279828e9c3c1f5d24613efca272649e62) squid (stable)": 2
    },
    "osd": {
        "ceph version 19.2.3 (c92aebb279828e9c3c1f5d24613efca272649e62) squid (stable)": 10
    },
    "mds": {
        "ceph version 19.2.3 (c92aebb279828e9c3c1f5d24613efca272649e62) squid (stable)": 2
    },
    "overall": {
        "ceph version 19.2.3 (c92aebb279828e9c3c1f5d24613efca272649e62) squid (stable)": 17
    }
}

ceph status

  cluster:
    id:     <FSID>
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum hl-ceph-05,hl-ceph-02,hl-ceph-01 (age 20m)
    mgr: hl-ceph-03.vaogpo(active, since 20m), standbys: hl-ceph-04.djedoy
    mds: 1/1 daemons up, 1 standby
    osd: 10 osds: 10 up (since 2m), 10 in (since 4d)
         flags noautoscale

  data:
    volumes: 1/1 healthy
    pools:   4 pools, 290 pgs
    objects: 24 objects, 481 KiB
    usage:   368 MiB used, 18 TiB / 18 TiB avail
    pgs:     290 active+clean
```
