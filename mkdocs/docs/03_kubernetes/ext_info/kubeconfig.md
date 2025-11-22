## Admin Configurations For Kubeconfigs

The admin config from k3s has (like all admin configs) a certificate instead of a token accociated with the active user. This is by design to always have a backup of emergency access to the cluster because certificates cannot be revoked to block access to the k8s API (afaik).

So the consequence is that if it leaks you have to recreate the k8s API server certificate which basically means you have to rebuild your cluster or precisely change the current certificate in use.

To change the certificate in a running cluster we have to consider a few things:

- All system components require the public CA of the API server
    - Kube-Apiserver
    - ETCD
    - Kube-Controller-Manager
    - Kube-Scheduler
    - Kubelet
    - Kube-Proxy
- Therefore all worker nodes rely on the public CA
- All external kubeconfigs rely on the public CA

In order to change the certificate we must recreate it and consider **major** disruptions in availability since **all** components need to be restarted.

There is an order in which restarts should performed (this is for vanilla k8s but will get the implications and can derive it):

1) Stop your API servers to avoid any connection
2) Stop your ETCD instances to avoid any writes during downtime
3) Stop all Controller Managers, Schedulers
4) Place the new certificate where the old one was on your API server instances
    - you can find that out via your API server binary flags
        - [kube-apiserver](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
5) Place the new certificate where the old one was on your ETCD instances
    - you can find that out via your ETCD server binary flags
        - [ETCD](https://etcd.io/docs/v3.5/op-guide/configuration/)
6) Start the first ETCD instance and see if it comes up
    - check via logs
7) Start the first API server instance and see if it comes up
    - check via logs
8) See if ETCD can connect to the API server
    - check via logs
9) Start the rest of the API server instance
10) Start the rest of the ETCD instances
    - see if clustering in ETCD is successful in the logs
11) Change the kubeconfig of all your Controller Managers and Schedulers
    - check the respective components binary flags for the kubeconfig location
        - [kube-controller-manager](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/)
        - [kube-scheduler](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/)
    - renew all public CA entries with your freshly created one
12) Start the Controller Managers and Schedulers
    - check via logs if they can communicate with the API server(s)
13) Your Control Plane now should be working again
14) Join a **new** worker node to see if basic functionality is given
    - this poor node will get nuked under rescheduling operations so lock it
        - kubectl cordon node my-new-node
15) Change the kubelet kubeconfig on every worker node
    - check the respective components binary flags for the kubeconfig location
        - [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
16) Optional: Change the kube-proxy kubeconfig on every worker node
    - check the respective components binary flags for the kubeconfig location
        - [kube-proxy](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
17) Optional: Restart all kube-proxies one-by-one and see if they can communicate with the API server
    - check via logs
18) Restart the kubelet one-by-one and see if the can join
    - check via logs
    - see on any master if CSRs are recieved
        - kubectl get csr
    - approve any csr (you know that belongs to a worker node)
        - kubectl certificate approve "csr name"
19) If all kubelets can rejoin your cluster is able to serve pods again
    - all of your previous configurations are still the same
    - rebalancing your cluster can take a long time depending on your overall workload (amount of pods)

This is a very delicate and disruptive operation so always keep an eye on your logs of all components and communicate that there will be major outages.

Often times it is just easier to create a second cluster and gradually move pods the new one.

I did this once in production and it took about 4 hours to get everything up and running again (we had a bit more than 1000 pods at the time).
