# Alpine

Pod with softwares to test the environment.

## Install 

Execute 

```sh
./install.sh
```

Will create one pod in each cluster with the alpine with some extra apks.

## Install 

Execute 

```sh
./delete.sh
```

Will delete all the alpine pods created.

## Login 

Script to log into the debug pod in the specified cluster.

```sh
# will log into debug pod in cluster1
./login.sh 1

# will log into debug pod in cluster2
./login.sh 2
```