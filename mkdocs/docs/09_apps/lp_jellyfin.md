## Info

Jellyfin is a home cinema software to let your stream media via your network.

<hr>

## Setup

The setup of Jellyfin is done via Helm. I added the values.yml file with my settings under /kubernetes/helm-jellyfin so you can use it as reference.

To install Jellyfin I used the official repo and the namespace "jellyfin".

```shell
cd kubernetes/helm-jellyfin

helm repo add jellyfin https://jellyfin.github.io/jellyfin-helm

kubectl create ns jellyfin

helm -n jellyfin install jellyfin jellyfin/jellyfin -f values.yml
```
