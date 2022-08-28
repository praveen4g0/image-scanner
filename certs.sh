RESOURCE=${RESOURCE:-"deployments"}
API=${API:-"apps"}
VERSION=${VERSION:-"v1"}

echo $RESOURCE

if [ -f certs ]; then
   rm -rf certs
fi

if [ -f k8s-manifests/validate-tls-secrets.yaml ]; then
   rm -rf k8s-manifests/validate-tls-secrets.yaml
fi

if [ -f k8s-manifests/webhook-$RESOURCE.yaml ]; then
   rm -rf k8s-manifests/webhook-$RESOURCE.yaml
fi

mkdir -p certs
#generate ca in /tmp
cfssl gencert -initca ./tls/ca-csr.json | cfssljson -bare certs/ca

#generate certificate in /tmp
cfssl gencert \
  -ca=./certs/ca.pem \
  -ca-key=./certs/ca-key.pem \
  -config=./tls/ca-config.json \
  -hostname="validate,validate.default.svc.cluster.local,validate.default.svc,localhost,127.0.0.1" \
  -profile=default \
  ./tls/ca-csr.json | cfssljson -bare ./certs/validate

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