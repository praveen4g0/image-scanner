if [ -f certs ]; then
   rm -rf certs
fi
if [ -f k8s-manifests/validate-tls-secrets.yaml ]; then
   rm -rf k8s-manifests/validate-tls-secrets.yaml
fi

if [ -f k8s-manifests/webhook.yaml ]; then
   rm -rf k8s-manifests/webhook.yaml
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

#generate CA Bundle + inject into template
ca_pem_b64="$(openssl base64 -A <"./certs/ca.pem")"

sed -e 's@${CA_PEM_B64}@'"$ca_pem_b64"'@g' <"webhook-template.yaml" \
    > ./k8s-manifests/webhook.yaml   
