# Admission controller use case 
This is an example of custom Kubernetes Controller which scans images from containers and stop pods/deployments spawning with vulnerable images.

Under the hood, it uses trivy <https://github.com/aquasecurity/trivy> to scan image used in the pod definition.

### Generate certificates
API="apps" VERSION="v1" RESOURCE="deployments" ./certs.sh 

### only on openshift to run container on privilaged ports
 oc adm policy add-scc-to-user privileged -z default

### Deploy webhooks
API="apps" VERSION="v1" RESOURCE="deployments" ./create-webhook.sh

### How do we test?
 * `oc apply -f k8s-manifests/demo-$RESOURCE.yaml` --> This has image nginx which has vulnerabilites so it stops being created!
