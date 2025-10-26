#!/bin/bash

# Check if the NSE is ready
echo "Check if the NSM is installed in cluster3"
kubectl get NetworkService -n ns-interdomain-nse-composition --context=kind-cluster3

# Check if the NSE is ready
kubectl --context=kind-cluster2 wait --for=condition=ready --timeout=1m pod -l app=nse-kernel -n ns-interdomain-nse-composition

kubectl --context=kind-cluster1 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-interdomain-nse-composition

kubectl --context=kind-cluster1 exec pods/alpine -n ns-interdomain-nse-composition -- ping -c 4 172.16.1.100

kubectl --context=kind-cluster1 exec pods/alpine -n ns-interdomain-nse-composition -- wget -O /dev/null --timeout 5 "172.16.1.100:80"

kubectl --context=kind-cluster2 exec deployments/nse-kernel -n ns-interdomain-nse-composition -- ping -c 4 172.16.1.101
