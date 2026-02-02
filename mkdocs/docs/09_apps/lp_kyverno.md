## Info

Kyverno is a policy management tool to define specific resources for namespaces or clusters.

<hr>

## Setup

The setup of Kyverno is done via Helm. As always I added the values.yml under /kubernetes/helm-kyverno/values.yml

To install Kyverno I used the official repo and the namespace "kyverno".


```shell
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```
<hr>

