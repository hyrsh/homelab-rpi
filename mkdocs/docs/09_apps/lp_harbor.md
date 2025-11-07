## Info

Harbor is a container registry that you can host yourself. I use it for custom images and helm charts.

## Setup

The setup of Harbor is done via Helm. I added the values.yml file with my settings under /kubernetes/helm-harbor so you can use it as reference.

To install Harbor I used the official repo and the namespace "harbor".

```shell
cd kubernetes/helm-harbor

helm repo add harbor https://helm.goharbor.io

kubectl create ns harbor

helm -n harbor install harbor harbor/harbor -f values.yml
```
