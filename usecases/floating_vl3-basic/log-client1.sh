#!/bin/bash
kubectl exec -it alpine -c alpine -n ns-floating-vl3-basic --context=kind-cluster1 -- sh
