## Info

Prometheus is a metric scraper with a time-series database to store metrics about given endpoints.

<hr>

## Setup

The setup of Prometheus is done via Helm. I added the values.yml file with my settings under /kubernetes/helm-prometheus so you can use it as reference.

To install Prometheus I used the community OCI repo and the namespace "prometheus".


```shell
cd kubernetes/helm-prometheus

kubectl create ns prometheus

helm -n prometheus install prometheus oci://ghcr.io/prometheus-community/charts/prometheus -f values.yml
```
<hr>

## Troubleshooting

Since I run on arm64 there was a setting that prevented the "prometheus-server" container from starting called "tcpSocketProbeEnabled". This value is set in the values.yml at "server.tcpSocketProbeEnabled".

I had to set it to "true" to make the server run.
