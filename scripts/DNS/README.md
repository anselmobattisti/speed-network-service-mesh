# CORE DNS

Enable that the services executed in one cluster could be accessed by another cluster using a name instead of the IP.

## Check if DNS is configured

Verify in each cluster if there an entry pointing to the another server

```sh
kubectl --context=kind-cluster1  describe configmap coredns -n kube-system

kubectl --context=kind-cluster2  describe configmap coredns -n kube-system
```

The CoreDNS config file must have the plugin k8s_external it allow that the services executed in the cluster can be executed via another FQN instead of cluster.local.

In our case, it should be possible to execute the service using the my.cluster(n) url, for example: nginx.default.my.cluster2 in the cluster 1 and in the cluster2 to.

For each cluster it should be have a block with the extenal name configured in the cluster. All the request with this name should be forwareded to the DNS in the configured IP.

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

        k8s_external my.cluster2

        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        loop
        reload 5s
    }
    my.cluster1:53 {
      log
      forward . 172.19.0.101:53 {
        force_tcp
      }
    }
```

## Debug

The logs.sh file receive the cluster id and show the logs from all the coredns pods.

When you execute a request for the DNS one of the pods is selected, thus its necessary to watch the log in both pods.