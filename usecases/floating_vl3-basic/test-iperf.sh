#!/bin/bash
echo "Rodando iperf3 no cluster2"

# get the ip of the pod in cluster2
ipAddr2=$(kubectl --context=kind-cluster2 exec -n ns-floating-vl3-basic pods/alpine -- ifconfig nsm-1 | grep -Eo 'inet addr:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| cut -c 11-)
echo "IP of alpine2: $ipAddr2"

echo "Rodando iperf3 no cluster2"
kubectl exec -it alpine -n ns-floating-vl3-basic --context=kind-cluster2 -- iperf3 -s &

echo "Rodando iperf3 no cluster1"
kubectl exec -it alpine -n ns-floating-vl3-basic --context=kind-cluster1 -- iperf3 -c $ipAddr2
