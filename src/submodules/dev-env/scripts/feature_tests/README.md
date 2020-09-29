# Feature tests framework

## Build Status

[![Ubuntu V1alpha3 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_ubuntu/badge/icon?subject=Feature-tests)](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_ubuntu/)
[![Centos V1alpha3 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_centos/badge/icon?subject=Feature-tests-centos)](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_centos/)
[![Ubuntu V1alpha3 build status](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_upgrade_ubuntu/badge/icon?subject=Feature-tests-upgrade)](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_upgrade_ubuntu/)

Feature tests framework is made to run a set of scripts for testing pivoting,
remediation and upgrade functionalities of Metal3 project.
The framework relies on already existing test scripts of each
feature in Metal3-dev-env. The motivation behind the framework is to be able to
test pivoting/remediation/upgrade features in Metal3-dev-env environment and
detect breaking changes in advance.

Test-framework CI can be triggered from a pull request in CAPM3, BMO,
metal3-dev-env, project-infra, ironic-image, ironic-inspector-image and
ironic-ipa-downloader repositories.
It is recommended to run test-framework CI especially when
introducing a commit related to pivoting/remediation/upgrade, to ensure that new
changes will not break the existing functionalities.

Test-framework can be triggered by leaving `/test-features` and
`/test-features-centos` (Ubuntu and Centos based respectively) comments for
remediation/pivoting and `/test-upgrade-features` comment for upgrade on a pull
request.

The folder structure of the test-framework and its related scripts look
as following:

```ini
feature_tests/
├── cleanup_env.sh
├── feature_test_deprovisioning.sh
├── feature_test_provisioning.sh
├── pivoting
│   ├── Makefile
│   └── pivot.sh
├── README.md
├── remediation
│   ├── Makefile
│   └── remediation.sh
├── setup_env.sh
└── upgrade
    ├── 1cp_1w_bootDiskImage_cluster_upgrade.sh
    ├── clean_setup_env.sh
    ├── combined_tests
    │   └── 1cp_1w_bootDiskImageANDK8sControllers_clusterLevel_upgrade.sh
    ├── controlplane_components_upgrade
    │   └── upgrade_CAPI_and_CAPM3_with_clusterctl.sh
    ├── controlplane_upgrade
    │   └── 3cp_1w_k8sVer_bootDiskImage_scaleInWorker_upgrade.sh
    ├── Makefile
    ├── README.md
    ├── upgrade_common.sh
    ├── upgrade.sh
    ├── upgrade_vars.sh
    └── workers_upgrade
        └── 1cp_3w_bootDiskImage_scaleInWorkers_upgrade_both.sh
```

Each feature has its own Makefile that will call feature specific test steps.
`setup_env.sh` is used to build an environment, i.e. run `make`, that will give
N (from the test-framework perspective N=4) number of ready BMH as an output.
`cleanup_env.sh` is used for intermediate cleaning between each feature test.
`feature_test_provisioning.sh` and `feature_test_deprovisioning.sh` are used by
each feature test to provision/deprovision cluster and BMH.

When the test-framework is triggered with `/test-features` or
`/test-features-centos`, it will:

- setup metal3-dev-env
  - run 01_\*, 02_\*, 03_\*, 04_\* scripts
- run remediation tests
  - provision cluster and BMH
  - run remediation tests
  - deprovision cluster and BMH
- clean up the environment
  - run `cleanup_env.sh`
- run pivoting tests
  - provision cluster and BMH
  - run pivoting tests
  - deprovision cluster and BMH
  - destroy the environment (i.e. run `make clean`)

When the test-framework is triggered with `/test-upgrade-features`, it will:

- setup metal3-dev-env
  - export CAPM3RELEASE and CAPIRELEASE
  - run 01_\*, 02_\*, 03_\*, 04_\* scripts
- run upgrade tests
  - provision cluster and BMH
  - run upgrade tests
  - deprovision cluster and BMH
  - destroy the environment (i.e. run `make clean`)

## Environment variables

Currently the test-framework uses the following environment variables
by default for remediation/pivoting, in case of **Ubuntu** setup:

```bash
export CAPM3_VERSION=v1alpha4
export IMAGE_OS=Ubuntu
export EPHEMERAL_CLUSTER=kind
export CONTAINER_RUNTIME=docker
export NUM_NODES=4
```

while **Centos** uses:

```bash
export CAPM3_VERSION=v1alpha4
export IMAGE_OS=Centos
export EPHEMERAL_CLUSTER=minikube
export CONTAINER_RUNTIME=podman
export NUM_NODES=4
```

Environment variables needed for upgrade tests running clusterctl,
set as default values:

```bash
export CAPM3RELEASE=v0.3.2
export CAPIRELEASE=v0.3.4
```

Recommended resource requirements for the host machine are: 8C CPUs, 32 GB RAM,
300 GB disk space.

## CI jobs configuration

We are running two master jobs for the **remediation/pivoting** framework testing.
One is
[master](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_ubuntu/)
job for Ubuntu and the other
[master](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_centos/)
job for Centos which runs every day.

Similarly two other jobs,
[airship_*_feature_tests_ubuntu](https://jenkins.nordix.org/view/Airship/job/airship_metal3io_metal3_dev_env_feature_tests_ubuntu/)
and
[airship_*_feature_tests_centos](https://jenkins.nordix.org/view/Airship/job/airship_metal3io_metal3_dev_env_feature_tests_centos/)
that can be run when triggered with `/test-features` and `/test-features-centos`
phrases for Ubuntu and Centos, accordingly on a pull request.

We are running two jobs for the **upgrade** framework testing. One is
[master](https://jenkins.nordix.org/view/Airship/job/airship_master_feature_tests_upgrade_ubuntu/)
job which runs every day, and second one is
[airship_*_feature_tests_upgrade_ubuntu](https://jenkins.nordix.org/view/Airship/job/airship_metal3io_metal3_dev_env_feature_tests_upgrade_ubuntu/)
that can be triggered with `/test-upgrade-features` phrase on a pull request.

Depending on where from the job is triggered, **\*** can be:

- metal3io_metal3_dev_env
- metal3io_capi_m3
- metal3io_bmo
- metal3io_project_infra
- metal3io_ironic_ipa_downloader
- metal3io_ironic_inspector
- metal3io_ironic_image
- nordix_capi_m3
- nordix_metal3_dev_env
- nordix_bmo
