#!/bin/bash

pt=./deployment/job.yml

kubectl -n mkdocs delete -f $pt --ignore-not-found
sleep 3

kubectl -n mkdocs create -f $pt
