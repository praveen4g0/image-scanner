#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR
if [ -f $DIR/../certs ]; then
   rm -rf $DIR/../certs
fi

if [ -f $DIR/../k8s-manifests/validate-tls-secrets.yaml ]; then
   rm -rf $DIR/../k8s-manifests/validate-tls-secrets.yaml
fi

mkdir -p $DIR/../certs
#generate ca in /tmp
cfssl gencert -initca $DIR/../tls/ca-csr.json | cfssljson -bare $DIR/../certs/ca

#generate certificate in /tmp
cfssl gencert \
  -ca=$DIR/../certs/ca.pem \
  -ca-key=$DIR/../certs/ca-key.pem \
  -config=$DIR/../tls/ca-config.json \
  -hostname="validate,validate.default.svc.cluster.local,validate.default.svc,localhost,127.0.0.1" \
  -profile=default \
  $DIR/../tls/ca-csr.json | cfssljson -bare $DIR/../certs/validate