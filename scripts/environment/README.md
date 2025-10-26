# Instalation

File to create the environment where the SPEED will be executed

Order to install 

- Clusters
- Load Balancer
- DNS
- Spire
- Basic (Basic NSM configuration)

## Clusters

Contain the scripts to create the clusters where the environment will be configured.

In particular, the cluster.sh file contains the list of the cluster name that will be created.

To create an environment with more clusters just add the name of the cluster inside the array of clusters.

## Load Balancer

We are using the Metallb loadbalancer to expose the services running inside the k8s to outside the cluster.

All the cluster are binded with the same Docker network (kind)

During the configuration of MetalLB, each cluster will be configured to bind IPs for a certain range (10 ips for cluster)

To test if the Load Balancer is running use the test_metallb.sh script. It will create one nginx service in each cluster and associate it with a valid IP. 

Accessing the EXTERNAL-IP of each service in the browser of the host machine should present the welcome nginx message.

## DNS

To access the services using the name and not the EXTERNAL IP, the CoreDNS must be configured in a cluster forwarding the request for the CoreDNS of the respective cluster where the service is executed.

The test created a service in the cluster 1 and the other clusters try to reach the service and compare the IP received via nslookup. All the IPs must be the same.

The test remove the created services after the execution of the test.

## Spire

Enable the execution of workloads in a secure way in different clusters. We are using the static federation configuration where the federation is defined in the server.conf file. If the federation with the same trusted domain is created via dinamic federation, the new federation is removed once the static federation has a high priority.

There is no test implemented yet to check if the spire is working correctly.

## NSM Basic

To install the NSM components inside each cluster to execute the use-cases run the installation inside the script/basic folder.
