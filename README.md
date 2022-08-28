# Admission controller use case 
This is an example of custom Kubernetes Controller which scans images from containers and stop pods/deployments spawning with vulnerable images.

Under the hood, it uses trivy <https://github.com/aquasecurity/trivy> to scan image used in the pod definition.

### Buidling admission controller webhook image
`make docker-build`
* Export few of this ENV values to build right target.
```
VERSION ?= "v1"
API ?= "apps"
RESOURCE ?= "deployments"
TAG ?= 0.0.1
IMAGE ?=quay.io/praveen4g0/image-scanner:v(TAG)
```
* As of now webhook supports scanning images for 2 resources `pods` and `deployments`

### Pushing admission controller webhook image
`make docker-build`


### Generate certificates

`make generate-certificates`
* This generates self signed tls certificates for admission webhook service

### only on openshift to run container on privilaged ports
`make run-as-privilaged-user`

### Generate k8s secrets 
`make generate-secrets`
* It does two things as a pre-requsite it generates tls certificates before and convert them to k8s secrets

### Deploy webhooks
`make deploy`
* Deploys webhook service 
* and also depoys `validatingwebhookconfigurations.admissionregistration.k8s.io` 

### How do we test?
 * `oc apply -f k8s-manifests/demo-$RESOURCE.yaml` --> This has image nginx which has vulnerabilites so it stops being created!

### Uninstall webhooks
`make undeploy`
* uninstalls webhook service 
* and also delete `validatingwebhookconfigurations.admissionregistration.k8s.io`