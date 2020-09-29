# Metal³ Development Environment

This repository includes scripts to set up a Metal³ development environment.

## Build Status

[![Ubuntu V1alpha3 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a3_integration_test_ubuntu/badge/icon?subject=Ubuntu%20E2E%20V1alpha3)](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a3_integration_test_ubuntu)
[![CentOS V1alpha3 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a3_integration_test_centos/badge/icon?subject=CentOS%20E2E%20V1alpha3)](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a3_integration_test_centos)
[![Ubuntu V1alpha4 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a4_integration_test_ubuntu/badge/icon?subject=Ubuntu%20E2E%20V1alpha4)](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a4_integration_test_ubuntu)
[![CentOS V1alpha4 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a4_integration_test_centos/badge/icon?subject=CentOS%20E2E%20V1alpha4)](https://jenkins.nordix.org/view/Airship/job/airship_master_v1a4_integration_test_centos)

## Instructions

Instructions can be found here: <https://metal3.io/try-it.html>

## Quickstart

Versions v1alpha3 or v1alpha4 are later referred as **v1alphaX**.

The v1alphaX deployment can be done with Ubuntu 18.04, 20.04 or Centos 8 target host
images. By default, for Ubuntu based target hosts we are using Ubuntu 20.04

### Requirements

#### Dev env size

The requirements for the dev env machine are, when deploying **Ubuntu** target
hosts:

* 8GB of memory
* 4 cpus

And when deploying **Centos** target hosts:

* 16GB of memory
* 4 cpus

The Minikube machine is deployed with 4GB of RAM, and 2 vCPUs, and the target
hosts with 4 vCPUs and 4GB of RAM.

### Environment variables

Select:

```sh
export CAPM3_VERSION=v1alpha3
```

or

```sh
export CAPM3_VERSION=v1alpha4
```

The following environment variables need to be set for **Centos**:

```sh
export IMAGE_OS=Centos
```

And the following environment variables need to be set for **Ubuntu**:

```sh
export IMAGE_OS=Ubuntu
```

You can check a list of all the environment variables [here](vars.md)

### Deploy the metal3 Dev env

```sh
./01_prepare_host.sh
./02_configure_host.sh
./03_launch_mgmt_cluster.sh
```

or

```sh
make
```

### Deploy the target cluster

```sh
./scripts/provision/cluster.sh
./scripts/provision/controlplane.sh
./scripts/provision/worker.sh
```

### Pivot to the target cluster

```sh
./scripts/provision/pivot.sh
```

### Delete the target cluster

```sh
kubectl delete cluster "${CLUSTER_NAME:-"test1"}" -n metal3
```

### Deploying with Tilt

It is possible to use Tilt to run the CAPI and CAPM3 components. For this, run:

```sh
export EPHEMERAL_CLUSTER="tilt"
make
```

Then clone the Cluster API Provider Metal3 repository, and follow the
[instructions](https://github.com/metal3-io/cluster-api-provider-metal3/blob/master/docs/dev-setup.md#tilt-development-environment).
That will mostly be the three following blocks of commands.

```sh
source lib/common.sh
source lib/network.sh
source lib/images.sh
```

and go to the CAPM3 repository and run

```sh
make tilt-settings
```

Please refer to the CAPM3 instructions to include BMO and IPAM. Then run :

```sh
make tilt-up
```

Once the cluster is running, you can create the BareMetalHosts :

```sh
kubectl create namespace metal3
kubectl apply -n metal3 -f /opt/metal3-dev-env/bmhosts_crs.yaml
```

Afterwards, you can deploy a target cluster.

If you are running tilt on a remote machine, you can forward the web interface
by adding the following parameter to the ssh command `-L 10350:127.0.0.1:10350`

Then you can access the Tilt dashboard locally [here](http://127.0.0.1:10350)