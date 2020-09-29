# Metal3Machine

The Metal3Machine contains information related to the deployment of the
BareMetalHost such as the image and the host selector. For each machine, there
must be a Metal3Machine associated to it.

## Metal3Machine Example

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1alpha4
kind: Metal3Machine
metadata:
  name: controlplane-0
spec:
  image:
    url: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
    checksum: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img.md5sum
  hostSelector:
    matchLabels:
      key1: value1
    matchExpressions:
      key: key2
      operator: in
      values: {‘abc’, ‘123’, ‘value2’}
  dataTemplate:
    Name: controlplane-metadata
  metaData:
    Name: controlplane-0-metadata-0
```

## Metal3Machine spec

#### image

This includes two sub-fields, `url` and `checksum`, which
include the URL to the image and the URL to a checksum for that image. These
fields are required. The image will be used for provisioning of the
`BareMetalHost` chosen by the `Machine` actuator.

#### userData

This includes two sub-fields, `name` and `namespace`, which
reference a `Secret` that contains base64 encoded user-data to be written to
a config drive on the provisioned `BareMetalHost`. This field is optional and
is automatically set by CAPM3 with the userData from the machine object. If
you want to overwrite the userData, this should be done in the CAPI machine.

#### dataTemplate

This includes a reference to a Metal3DataTemplate object
containing the metadata and network data templates, and includes two fields,
`name` and `namespace`.

#### metaData 

A reference to a secret containing the metadata rendered from
the Metal3DataTemplate metadata template object automatically. In case this
would not be managed by the Metal3DataTemplate controller, if provided by the
user for example, the ownerreference should be set properly to ensure that the
secret belongs to the cluster ownerReference tree (see
[doc](https://cluster-api.sigs.k8s.io/clusterctl/provider-contract.html#ownerreferences-chain)).

#### networkData

A reference to a secret containing the network data
rendered from the Metal3DataTemplate metadata template object automatically.
In case this would not be managed by the Metal3DataTemplate controller, if
provided by the user for example, the ownerreference should be set properly to
ensure that the secret belongs to the cluster ownerReference tree (see
[doc](https://cluster-api.sigs.k8s.io/clusterctl/provider-contract.html#ownerreferences-chain)).
The content of the secret should be a yaml equivalent of a json object that
follows the format definition that can be found
[here](https://docs.openstack.org/nova/latest/_downloads/9119ca7ac90aa2990e762c08baea3a36/network_data.json).

#### hostSelector

Specifies criteria for matching labels on `BareMetalHost`
objects. This can be used to limit the set of available `BareMetalHost`
objects chosen for this `Machine`.

The `metaData` and `networkData` field in the `spec` section are for the user
to give directly a secret to use as metaData or networkData. The `userData`,
`metaData` and `networkData` fields in the `status` section are for the
controller to store the reference to the secret that is actually being used,
whether it is from one of the spec fields, or somehow generated. This is aimed
at making a clear difference between the desired state from the user (whether
it is with a DataTemplate reference, or direct `metaData` or `userData` secrets)
and what the controller is actually using.

The `dataTemplate` field consists of an object reference to a
Metal3DataTemplate object containing the templates for the metadata and
network data generation for this Metal3Machine. The `renderedData` field is a
reference to the Metal3Data object created for this machine. If the
dataTemplate field is set but either the `renderedData`, `metaData` or
`networkData` fields in the status are unset, then the Metal3Machine
controller will wait until it can find the Metal3Data object and the rendered
secrets. It will then populate those fields.

When CAPM3 controller will set the different fields in the BareMetalHost,
it will reference the metadata secret and the network data secret
in the BareMetalHost. If any of the `metaData` or `networkData` status fields
are unset, that field will also remain unset on the BareMetalHost.

When the Metal3Machine gets deleted, the CAPM3 controller will remove its
ownerreference from the data template object. This will trigger the deletion of
the generated Metal3Data object and the secrets generated for this machine.