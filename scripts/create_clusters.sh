#!/bin/bash
sh ./delete_clusters.sh

echo "CREATING CLUSTER 1"
kind create cluster --name cluster1 --image=kindest/node:v1.31.2 --config=kind.yaml

echo "SLEEPING FOR 10s"
sleep 10
echo "CREATING CLUSTER 2"
kind create cluster --name cluster2 --image=kindest/node:v1.31.2 --config=kind.yaml

# echo "
# kind: Cluster
# apiVersion: kind.x-k8s.io/v1alpha4
# nodes:
# - role: control-plane
# - role: worker
# - role: worker" | kind create cluster --name cluster2 --config -
