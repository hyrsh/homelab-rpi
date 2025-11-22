## Info

Grafana is my visualization tool of choice. I works together with a metric database (e.g. Prometheus) to display current metrics of given endpoints.

<hr>

## Setup

The setup of Grafana is done via Helm. I added the values.yml file with my settings under /kubernetes/helm-grafana so you can use it as reference.

To install Grafana I used the official repo and the namespace "grafana".

```shell
cd kubernetes/helm-grafana

helm repo add grafana https://grafana.github.io/helm-charts

kubectl create ns grafana

helm -n grafana install grafana/grafana -f values.yml
```
