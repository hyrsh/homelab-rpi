## Info

This will be a short collection of information I gathered while operating the RPI cluster.

## The k3s service

Since the cluster is operating 24/7 the master nodes running the control plane via k3s are under constant load.

I noticed some interrupts (timeouts, context deadline exceeded) of pods trying to connect to the API server (provided by the k3s binary) what caused an irregular restart of them. Since I do not like that I looked at my control plane hosts and instantly noticed that the k3s binary is hogging a substiantial amount of RAM (>3GB).

The control plane nodes only have 4GB of memory so the service binary (k3s) ran into strange OOM errors:

- the binary was running
- the API server within the binary was not responding
- no process was killed on the machine
- requests to the binary timed out

I added some memory boundaries within the systemd service file (/etc/systemd/system/k3s.service) under the "service" stanza to keep it stable:

```shell
[Service]
...
MemoryHigh=1500M
MemoryMax=1999M
...
```

As of now it seems to run smoothly.

<hr>

## Manual tuning

Since there are some deployments that do not come with resource limitations and/or nodeSelector settings I was too lazy to adjust every Helm Chart or pipeline to keep a copied version for my cluster so I added them by hand to limit memory and cpu demands and to control that everything is running on worker nodes and not the control plane.

<hr>
