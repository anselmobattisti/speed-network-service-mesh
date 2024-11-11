#!/bin/bash
kubectl delete deployment nginx
kubectl delete service nginx

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --type=LoadBalancer --port=80

