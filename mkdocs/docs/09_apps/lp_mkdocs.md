## Info

MKDocs is the software you see right now. It is a webserver with the ability to present markdown files in a nice and simple manner.

## Setup

I added the deployment file under kubernetes/mkdocs-homelab-rpi/deployment/mkdocs-deploy.yml which is a pretty generic deployment. The trick is to have an updated job, that gets your content and puts it in the same directory your MKDocs expects it.

To make this happen I build a small image myself. The respective Dockefile and Bash script are at kubernetes/mkdocs-homelab-rpi/docker.

To build it I simply used podman.

`Build & push image`
```shell
cd kubernetes/mkdocs-homelab-rpi/docker

podman build -t git-cloner:v1.0 .

podman tag git-cloner:v1.0 harbor.hyrsh.io/own-images/git-cloner:v1.0

podman login harbor.hyrsh.io

podman push harbor.hyrsh.io/own-images/git-cloner:v1.0
```

After that you can use environment variables to control what repository should be pulled and what subpath should be copied to the PVC mounted path.

If you want to pull from private repositories you can create a PAT from GitHub and put the token into a file. Then you must create a secret from it to mount into the pod.

`Create file with GitHub PAT`
```shell
echo "mysupercooltoken" > tokenfile
```
`Create secret for your pod`
```shell
kubectl -n mkdocs create secret generic mkdocs-token --from-file=tokenfile
```
`Adjust the job spec accordingly`
```YAML
apiVersion: batch/v1
kind: Job
metadata:
  name: updater-homelab-rpi
  namespace: mkdocs
spec:
  template:
    metadata:
    spec:
      imagePullSecrets:
        - name: harbor-secret
      containers:
      - image: harbor.hyrsh.io/own-images/git-cloner:v1.0-arm64
        env:
          - name: REPOSITORY_NAME
            value: "yourrepo"
          - name: REPOSITORY_USER
            value: "youruser"
          - name: TOKEN_FILE
            value: "/custom_token/tokenfile"
          - name: SUBPATH
            value: "mkdocs"
        name: cloner
        securityContext:
          runAsNonRoot: true
          runAsUser: 2000
          runAsGroup: 2000
          capabilities:
            drop:
              - ALL
          seccompProfile:
            type: RuntimeDefault
        volumeMounts:
          - name: data
            mountPath: /data
          - name: secret
            mountPath: /custom_token
      securityContext:
        fsGroup: 2000
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: mkdocs-homelab-rpi-data
        - name: secret
          secret:
            secretName: mkdocs-token
      restartPolicy: Never
```

Here the repository https://github.com/youruser/yourrepo.git is being pulled and the top-level directory "mkdocs" gets copied to the PVC. If your MKDocs pod does now mount this PVC to its /docs directory it will display it.

>The content of your repositories /mkdocs directory must at least contain the file mkdocs.yml and the "docs" directory to work. You can take my "mkdocs" directory for reference.
