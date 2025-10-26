# NSE Composition

This usecase shows how to compose multiple NSEs in a single NetworkService.

## Prerequisites

- 3 kind clusters (cluster1, cluster2, cluster3)

## Installation

```bash
./install.sh
```

## Verification

```bash
# Get the NetworkServce 
kubectl get NetworkService -n ns-interdomain-nse-composition --context=kind-cluster3

# Describe NetworkServce 
kubectl describe NetworkService interdomain-nse-composition -n ns-interdomain-nse-composition --context=kind-cluster3

# List pods in the cluster1 and 2
kubectl get pods -n ns-interdomain-nse-composition --context=kind-cluster1

kubectl get pods -n ns-interdomain-nse-composition --context=kind-cluster2
```

## Test connectivity

```bash
kubectl --context=kind-cluster1 exec pods/alpine -n ns-interdomain-nse-composition -- ping -c 4 172.16.1.101
```

```bash
kubectl -n ns-interdomain-nse-composition --context=kind-cluster1 exec -it alpine -- sh

kubectl -n ns-interdomain-nse-composition --context=kind-cluster1 exec -it nse-firewall-vpp-6c6cf6ff6-m7h5s -- sh
