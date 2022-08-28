# Admission controller use case 
This is an example of custom Kubernetes Controller which scans images from containers and stop pods spawning with vulnerable images.

Under the hood, it uses trivy <https://github.com/aquasecurity/trivy> to scan image used in the pod definition.

### Generate certificates
./certs.sh

### only on openshift to run container on privilaged ports
 oc adm policy add-scc-to-user privileged -z default

### Apply k8s manifest
 * `oc apply -f k8s-manifests/webhook.yaml` --> This is validating webhook configuration
 * `oc apply -f k8s-manifests/webhook-deployment` --> This is validating service underhood

### How do we test?
 * `oc apply -f k8s-manifests/demo-pod.yaml` --> This has image nginx which has vulnerabilites so it stops being created!
