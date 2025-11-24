## Core Functionality 

As we have seen in the [overview](00_overview.md) all communication and dataflow is passed to the API server.

Now we want to shine some light onto this central entity.

<hr>

## External Requests

The API server does handle all requests and writes the given state to the core database (here I am using ETCD). It does not simply accept everything but inspects these requests about authorization, validity and idempotency (that means that the same request gets recognized and the API server does not re-play the changes but just states that it is already existent).

`Idempotency, e.g. trying to create the same namespace twice`
```shell
kubectl create ns mynamespace
namespace/mynamespace created
kubectl create ns mynamespace
Error from server (AlreadyExists): namespaces "mynamespace" already exists
```

External requests are sent via REST to the API server IP, validated by the choice of your [authentication method](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#authentication-methods) and checked internally against rules if the given request is allowed by the sending user.

To keep things simple we use `kubectl` as our primary requesting tool. This binary wraps the Kubernetes API REST requests in a comfortable way by allowing us to write YAML or JSON descriptions of what we want to have changed in the system. There are also a plethora of built-in command to interact with the cluster (like shown in the "Idempotency" example).

As you have seen in the [primitive descriptions](00_overview.md#kubernetes-primitives) there are some default objects every Kubernetes distribution understands.

To get information about a specific object we use the `get` command.

```shell
root@hl-master-01:~# kubectl get pod
NAME                   READY   STATUS    RESTARTS   AGE
ngx-5db967bc7b-hf2f7   1/1     Running   0          18d
```

Here we can see that there is one pod (ngx-5db967bc7b-hf2f7) running in the default namespace and it is 18 days old. To look at pods in other namespaces we must specifiy the respective name and use the "-n" or "--namespace" binary flag of `kubectl`.

```shell
root@hl-master-01:~# kubectl -n grafana get pod
NAME                       READY   STATUS    RESTARTS   AGE
grafana-7c4d8fd664-7qqg2   1/1     Running   0          13d
```
Now we see that there is a pod running in the `grafana` namespace called `grafana-7c4d8fd664-7qqg2` with an age of 13 days.

This is an external request because it is not originating from within the system components or a running workload within the cluster.

<hr>

## YAML & JSON

Besides the built-in commands of `kubectl` we also mentioned a file-based approach. This is one of the standards that are enforced in Kubernetes and guides us how to describe our desired changes.

Most descriptions are written in YAML but JSON is also viable. All files are parsed by kubectl **before** it gets sent to the API server to avoid malformed requests. The parsing adheres to the API specifications of Kubernetes.

For example the `namespace` object we just created [has its own specification](https://kubernetes.io/docs/reference/kubernetes-api/cluster-resources/namespace-v1/).

In YAML it looks like this:

`mynamespace.yml`
```YAML
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: mynamespace
  name: mynamespace
```

To create or delete the namespace you can use the file with the "apply"/"create" or "delete" command and the "-f" flag that expects a path to the file.

```shell
kubectl apply -f mynamespace.yml
```
```shell
kubectl delete -f mynamespace.yml
```

<hr>
