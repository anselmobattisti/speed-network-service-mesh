# Spire

Is an implementation of SPIFE. It enable te secure comunication between pods. In prticular pods in different clusters.

It is necessary to configure in each cluster the spire.

The kustomization.yaml is the entry point of the configuration (index.html)

```shell
kubectl apply -f ./folder_where_the_kustomization.yaml
```

## Folder Structure 

* base: has the generic files to configure the environment
* postgress: has the files to instantiate the postgres used by spire
* cluster(n): for each cluster there will be a folder