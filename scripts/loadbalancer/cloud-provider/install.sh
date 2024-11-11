#!/bin/bash
rm LICENSE 
rm README.md 
rm cloud-provider-kind_0.4.0_linux_amd64.tar.gz
wget https://github.com/kubernetes-sigs/cloud-provider-kind/releases/download/v0.4.0/cloud-provider-kind_0.4.0_linux_amd64.tar.gz
tar -xzvf cloud-provider-kind_0.4.0_linux_amd64.tar.gz
chmod +x cloud-provider-kind
./cloud-provider-kind