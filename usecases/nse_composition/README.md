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


```
