#!/bin/bash

delete(){
    kubectl --context=kind-cluster3 delete -k ./cluster3

    kubectl --context=kind-cluster1 delete -k ./cluster1

    kubectl --context=kind-cluster2 delete -k ./cluster2
}

delete