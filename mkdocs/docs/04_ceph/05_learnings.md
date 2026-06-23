### Infos

Over the time while operating the storage cluster there is some information that arised.

<hr>

### Memory consumption

All Ceph nodes are accumulating memory over time and it is most likely because of the OSD processes.

The only thing (and blunt solution as of now) is to restart the nodes. With that there comes a drawback because I initialized the OSDs with the "unmanaged" approach.

To come by the OSDs have to be restarted via the Ceph shell:

```shell
cephadm shell
ceph orch daemon start osd.4
```

<hr>
