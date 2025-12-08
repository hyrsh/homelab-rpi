## Interruptions

|ID|Date|Duration|Cause|Info|Cluster Uptime|
|-|-|-|-|-|-|
|1|2025-12-08 22:15|5min|Blackout of 2x PoE switches|PoE power supply went blank on 2x devices for unknown reason|34d|

## Havoc statistics

|Interrupt ID|Affected devices|Service state|
|-|-|-|
|1|10x (2x master, 5x worker, 1x LB, 2x Ceph)|Full blackout|

## Behaviour

|Interrupt ID|Infos|
|-|-|
|1|Since 2x masters were affected a cluster state freeze was present (intended behaviour due to quorum of ETCD) and no pods could change nodes|
