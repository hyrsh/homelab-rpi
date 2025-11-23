#!/bin/bash

# Availability zones by switch connections for workers
s1=( "hl-worker-01" "hl-worker-02" )
s2=( "hl-worker-03" "hl-worker-04" )
s3=( "hl-worker-05" "hl-worker-06" "hl-worker-07" )
s4=( "hl-worker-08" "hl-worker-09" "hl-worker-10" )

# Label nodes
for HOST in ${s1[@]}; do
  kubectl label node $HOST az=1
  kubectl label node $HOST node-role.kubernetes.io/postgres=
  kubectl label node $HOST node-role.kubernetes.io/worker=
  kubectl label node $HOST node-role.kubernetes.io/az-1= #just for cosmetics in kubectl get nodes
done
for HOST in ${s2[@]}; do
  kubectl label node $HOST az=2
  kubectl label node $HOST node-role.kubernetes.io/postgres=
  kubectl label node $HOST node-role.kubernetes.io/worker=
  kubectl label node $HOST node-role.kubernetes.io/az-2= #just for cosmetics in kubectl get nodes
done
for HOST in ${s3[@]}; do
  kubectl label node $HOST az=3
  kubectl label node $HOST node-role.kubernetes.io/postgres=
  kubectl label node $HOST node-role.kubernetes.io/worker=
  kubectl label node $HOST node-role.kubernetes.io/az-3= #just for cosmetics in kubectl get nodes
done
for HOST in ${s4[@]}; do
  kubectl label node $HOST az=4
  kubectl label node $HOST node-role.kubernetes.io/postgres=
  kubectl label node $HOST node-role.kubernetes.io/worker=
  kubectl label node $HOST node-role.kubernetes.io/az-4= #just for cosmetics in kubectl get nodes
done
