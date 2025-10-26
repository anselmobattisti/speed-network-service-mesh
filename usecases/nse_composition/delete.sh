#!/bin/bash

kubectl delete -k ./cluster1 --context=kind-cluster1
kubectl delete -k ./cluster2 --context=kind-cluster2
kubectl delete -k ./cluster3 --context=kind-cluster3