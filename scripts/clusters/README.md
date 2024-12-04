# Creating the Clusters

The cluster that will be created and managed must be defined in the file script/clusters.sh

After execute 

```sh
install.sh
```

There will be a message depicting that each cluster was created with one controller and one worker node. To change the number of worker nodes modify the kind.yaml file.

The install command also delete the previous cluster if exists.

## Requirements

Tested in kind version 0.25.0

## Change Kunctl Context

```shell
kubectl config use-context kind-cluster3
```