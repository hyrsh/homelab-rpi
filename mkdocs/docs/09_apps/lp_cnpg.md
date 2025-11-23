## Info

[CloudNativePG (CNPG)](https://cloudnative-pg.io/documentation/1.27/) is an operator to deploy PostgreSQL database clusters.

<hr>

## Setup

The setup of CNPG is done via Helm. I added the values.yml file with my settings under /kubernetes/helm-cnpg so you can use it as reference.

To install CNPG I used the official helm repo and the namespace "cnpg-system".


```shell
cd kubernetes/helm-cnpg

helm repo add cnpg https://cloudnative-pg.github.io/charts

helm upgrade --install cnpg --namespace cnpg-system --create-namespace cnpg/cloudnative-pg -f values.yml
```
<hr>
