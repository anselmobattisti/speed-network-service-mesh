#!/bin/bash

echo "Deploy NSM"
kubectl apply -k ./cluster3 --context=kind-cluster3

echo "Deploy Cluster2"
kubectl apply -k ./cluster2 --context=kind-cluster2

echo "Waiting for NSE to be ready in cluster2"
kubectl --context=kind-cluster2 wait --for=condition=ready --timeout=1m pod -l app=nse-kernel -n ns-interdomain-nse-composition

kubectl apply -k ./cluster1 --context=kind-cluster1

echo "Waiting for NSC to be ready in cluster1"
kubectl --context=kind-cluster1 wait --for=condition=ready --timeout=5m pod -l app=alpine -n ns-interdomain-nse-composition
