# Test

## Final Objective 

Creation of a NSM Composition https://networkservicemesh.io/docs/concepts/architecture/#composition

I have 4 k8s cluster created using kind. 

They are in the same docker network. 

I exposed the services using metallb, each one having a subset of available ips.

I want to create a composed application for only testing the connectivity.

cluster1            cluster2               cluster3          cluster4
 -> k8s pod running socat -> k8s pod running socat -> pode iperf server

# Steps 

a) Create the service in the Registry
b) Create each pod and add the label to bind it with the created service

## Environment 

The environment is composed of k8s clusters created using kind, the services are exposed via metallb loadbalance and the CodeDNS provide the interdomain name resolve FQN. Important, the url of a service is service_name.namespace.my.cluster(n).

* Create the cluster
* Install the metallb load balancer
* Configure the CoreDNS to execute in a interdomain mode
* Configure the spire authentication

## Basic Example 

Three Clusters Interdomain scenario 

https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/interdomain/three_cluster_configuration/basic

The USE Case is the 

https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/interdomain/usecases/floating_nse_composition

# Miscelanea

## Kubectl hints

To know the context of the kubectl

 ```sh
 kubectl config current-context
```

To execute a command inside a specific cluster you can change the cointext

 ```sh
kubectl config use-context kind-cluster2
 ```

Or pass the context in each command.

 ```sh
kubectl get pods -A --context=kind-cluster3
 ```

### kustomization

The kustomization.yaml is the entry point of the configuration (index.html)

```shell
kubectl apply -f ./folder_where_the_kustomization.yaml
```

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

## Requirement in the Host Machine

* kind: Software to create a k8s cluster in Docker
* Docker: container virtualization engine
* kubectl: CLI to interact with a k8s cluster

# Links 

https://events19.linuxfoundation.org/wp-content/uploads/2017/12/Network-Service-Mesh-An-Attempt-to-Reimagine-NFV-in-a-Cloud-Native-Fashion-Kyle-Mestery-Cisco-Frederick-Kautz-Red-Hat.pdf


Artigo que usou NSM e SFC
https://link.springer.com/chapter/10.1007/978-3-031-10419-0_8

Documentos internos sobre NSM 

https://docs.google.com/document/d/1C9NKjo0PWNWypROEO9-Y6haw5h9Xmurvl14SXpciz2Y/edit?tab=t.0

Video bem explicativo sobre NSM
https://www.youtube.com/watch?v=ffMAjwAJ2oc and the post in the blog https://codilime.com/blog/is-network-service-mesh-a-service-mesh/

Achei um demo bem legal 
https://www.youtube.com/watch?v=sLKQSK84DxY