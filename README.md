# Test

# Software 

https://networkservicemesh.io/docs/setup/run/

Criação de ligação entre os pods

https://kind.sigs.k8s.io/

Criação dos k8s virtualizados

SPIRE Server in Kubernetes

para comunicação segura entre os k8s cluster

debug 10.244.3.10
debug2 10.244.1.13
debug3 10.244.2.14


iptunnel add tun0 mode ipip remote 10.244.2.14:8080 local 127.0.0.1:8080 ttl 64

socat TCP-LISTEN:8080,reuseaddr,fork TCP:10.244.2.14:8080

nos pods intermediários rodar (onde cada um aponta para o próximo)
socat TCP-LISTEN:8080,reuseaddr,fork TCP:10.244.2.14:8080

rodar isso no último pod
iperf3 -s -p 8080

no cliente que vai testar podemos executar 

iperf3 -c 10.244.2.14 -p 8080

URL da instalação 
https://github.com/networkservicemesh/deployments-k8s/tree/v1.14.0/examples/interdomain/two_cluster_configuration/basic

# Kind 

```sh
# trocar de contexto o kubectl
kubectl cluster-info --context kind-cluster1

kubectl cluster-info --context kind-cluster2
```