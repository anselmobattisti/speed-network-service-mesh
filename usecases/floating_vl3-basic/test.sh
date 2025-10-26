#!/bin/bash

echo "Test ping from alpine1 to alpine2"

# get the ip of the pod in cluster2
ipAddr2=$(kubectl --context=kind-cluster2 exec -n ns-floating-vl3-basic pods/alpine -- ifconfig nsm-1 | grep -Eo 'inet addr:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| cut -c 11-)

echo "IP of alpine2: $ipAddr2"

echo "Ping from alpine1 to alpine2"

# ping in the alpine2 from alpine1
kubectl --context=kind-cluster1 exec pods/alpine -n ns-floating-vl3-basic -- ping -c 4 $ipAddr2