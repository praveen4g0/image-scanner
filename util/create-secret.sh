#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR

# Remove k8s secrets if exists?
oc delete Secret validate-tls --ignore-not-found=true

#make a secret
cat <<EOF > $DIR/../k8s-manifests/validate-tls-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: validate-tls
type: Opaque
data:
  tls.crt: $(cat $DIR/../certs/validate.pem | base64 | tr -d '\n')
  tls.key: $(cat $DIR/../certs/validate-key.pem | base64 | tr -d '\n') 
EOF

# Apply secrets 
oc apply -f $DIR/../k8s-manifests/validate-tls-secrets.yaml