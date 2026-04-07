## Interruptions

|ID|Date|Duration|Cause|Info|Cluster Uptime|
|-|-|-|-|-|-|
|1|2025-12-08 22:15|5min|Blackout of 2x PoE switches|PoE power supply went blank on 2x devices for unknown reason|34d|
|2|2026-02-26 15:10|10min|DNS names not resolvable|Router (Home) disconnected and lost DNS names|114d|
|3|2026-04-07 18:00|30min|Hosts not reachable|Internal IP restructuring|154d|

## Havoc statistics

|Interrupt ID|Affected devices|Service state|
|-|-|-|
|1|10x (2x master, 5x worker, 1x LB, 2x Ceph)|Full blackout|
|2|all|Up & Running but not reachable|
|3|all|Up & Running but not reachable|

## Behaviour

|Interrupt ID|Infos|
|-|-|
|1|Since 2x masters were affected a cluster state freeze was present (intended behaviour due to quorum of ETCD) and no pods could change nodes|
|2|Since the HAProxy nodes could not resolve DNS names, all exposed services threw 503 (service unavailable)|
|3|All services were returning 504 (gateway timeout) until the new IPs were cached again|
