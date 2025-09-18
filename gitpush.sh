#!/bin/bash

repo_name=homelab-rpi

cred_file=/datadisk/05_credentials/github-tokens/repo-$repo_name

TOKEN=$(grep token $cred_file | awk '{print $2}')

msg="default update message for $repo_name"

if [ "$1" == "" ]; then
  msg=$1
fi

git add *
git commit -m "$msg"
git push https://${TOKEN}@github.com/hyrsh/homelab-rpi.git
