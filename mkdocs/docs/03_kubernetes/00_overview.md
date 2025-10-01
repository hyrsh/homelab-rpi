# Kubernetes overview

This is a simple overview of Kubernetes. It is stongly recommended to make yourself familiar with [containers](01_containers.md).

## Architecture

Kubernetes in its smallest setup can be setup on a single host. In the vanilla version we have 6x binaries that make up the whole system:

|Name|Description|Domain|
|-|-|-|
|Kube-Apiserver|Central component to handle all API requests|Master Plane|
|Kube-Scheduler|Responsible to distribute Pods across nodes|Master Plane|
|Kube-Controller-Manager|Permanently checks & updates states in the cluster|Master Plane|
|ETCD|Database for the whole cluster state|Master Plane|
|Kubelet|Agent for container runtime management|Worker Plane|
|Kube-Proxy|Agent for network management|Worker Plane|

|Tasks|
|-|
|The API server is the only component that is allowed to talk to ETCD. All other components need to send an API request to the API server if they want any information about the desired or current state of the cluster|
|The controller-manager watches API server events with control loops to handle state changes|
|The kube-proxy watches the API server for service events and triggers changes in e.g. iptables|
|The scheduler decides where a container can run and plays that decision back to the API server|
|The kubelet watches the API server for scheduler decisions and talks to the container engine|

![image](assets/k8s_arch_simple.png)

