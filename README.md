# (Image scanner) Admission controller
This is an example of custom Kubernetes Controller which scans images from containers and stop pods/deployments spawning with vulnerable images.

Under the hood, it uses trivy <https://github.com/aquasecurity/trivy> to scan image used in the pod definition.

### Buidling admission controller webhook image
`make docker-build`
* Export few of this ENV values to build right target.
```
EXPORT API="apps"
EXPORT RESOURCE="deployments"
EXPORT VERSION="v1"
EXPORT TAG="0.0.1"
EXPORT BASE_IMAGE="quay.io/<user-name>/image-scanner"

```
* As of now webhook supports scanning images for 2 resources `pods` and `deployments`

### Pushing admission controller webhook image
`make docker-build`

### Generate certificates (optional)
`make generate-certificates`

### (Applicable only to openshift) Run containers as privilaged users
`make run-as-privilaged-user`

### Generate k8s secrets 
`make generate-secrets` --> this internally calls `make generate-certificates`

### Deploy webhook service
`make deploy`

### How do we test?
 * `oc apply -f k8s-manifests/demo-$RESOURCE.yaml` --> This has image nginx which has vulnerabilites so it stops being created!
> Note: This validation is only applicable to $RESOURCES with below annotation 
```
annotations:
    scanner.io/owner: image-scanner
```

### Uninstall webhook service
`make undeploy`
