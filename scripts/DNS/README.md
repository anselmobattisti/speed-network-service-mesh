# CORE DNS

## Check if DNS is configured

Verify in each cluster if there an entry pointing to the another server

```sh
kubectl --context=kind-cluster1  describe configmap coredns -n kube-system
```