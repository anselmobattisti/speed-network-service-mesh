# Interdomain CoreDNS

Allows that services executed in one cluster could be accessed by another cluster using a name instead of the IP.

The domain requested is resolved in execution time.

The configuration is mainly based on plugins.

The loadbalnce will give one ip for the CoreDNS server to be access from the other clusters.

```sh
kubectl get svc exposed-kube-dns -n kube-system --context=kind-cluster1
```

It should show the external ip used by the CoreDNS to be access from the other clusters.


## Check if DNS is configured

Verify in each cluster if there an entry pointing to the another server

```sh
kubectl --context=kind-cluster1  describe configmap coredns -n kube-system

kubectl --context=kind-cluster2  describe configmap coredns -n kube-system

kubectl --context=kind-cluster3  describe configmap coredns -n kube-system
```

The CoreDNS config file must have the plugin k8s_external it allow that the services executed in the cluster can be executed via another FQN instead of cluster.local. 

In our case, it should be possible to execute the service using the my.cluster(n) url, for example: nginx.default.my.cluster2 in the cluster 1 and in the cluster2 to.

```sh
alpine/login.sh 2

#execute
curl nginx.default.my.cluster1
```

For each cluster, in the CoreDNS configuration file, it must have a block with the extenal name configured in the cluster. All the request with this name will be forwareded to the DNS Server in the configured IP.

```sh
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        chaos
        errors
        log
        health {
            lameduck 5s
        }
        ready

        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }

        k8s_external my.cluster1

        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        loop
        reload 5s
    }
    my.cluster2:53 {
      log
      forward . 172.19.0.112:53 {
        force_tcp
      }
    }
    my.cluster3:53 {
      log
      forward . 172.19.0.123:53 {
        force_tcp
      }
    }
```

## Debug

The logs.sh file receive the cluster id and show the logs from all the coredns pods.

When you execute a request for the DNS one of the pods is selected, thus its necessary to watch the log in both pods.

## Test

After executing the metallb test it is possible to check if the nginx service is accessible outside the cluster where it is executed.

```sh 
alpine/logar.sh 1
nslookup nginx.default.my.cluster1
```

It must show the ip associated with the service metallb.

```sh
Server:		10.96.0.10
Address:	10.96.0.10#53

Name:	nginx.default.my.cluster3
Address: 172.19.0.123
```

The test automaticaly remove the deployment of the nginx in cluster1 that is used to test the DNS configuration.