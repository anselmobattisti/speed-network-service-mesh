#!/bin/bash

install(){
    kubectl --context=kind-cluster3 apply -k ./cluster3

    kubectl --context=kind-cluster1 apply -k ./cluster1

    kubectl --context=kind-cluster2 apply -k ./cluster2

    kubectl --context=kind-cluster2 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-floating-vl3-basic

    kubectl --context=kind-cluster1 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-floating-vl3-basic
}

test(){
    ipAddr2=$(kubectl --context=kind-cluster2 exec -n ns-floating-vl3-basic pods/alpine -- ifconfig nsm-1)
    ipAddr2=$(echo $ipAddr2 | grep -Eo 'inet addr:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| cut -c 11-)
    kubectl --kubeconfig=kind-cluster1 exec pods/alpine -n ns-floating-vl3-basic -- ping -c 4 $ipAddr2
}

install 