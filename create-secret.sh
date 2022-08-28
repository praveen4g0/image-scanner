# Remove k8s secrets if exists?
oc delete Secret validate-tls --ignore-not-found=true

#make a secret
cat <<EOF > ./k8s-manifests/validate-tls-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: validate-tls
type: Opaque
data:
  tls.crt: $(cat ./certs/validate.pem | base64 | tr -d '\n')
  tls.key: $(cat ./certs/validate-key.pem | base64 | tr -d '\n') 
EOF

# Apply secrets 
oc apply -f ./k8s-manifests/validate-tls-secrets.yaml