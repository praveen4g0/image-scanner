#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR
API=${1:-"apps"}
RESOURCE=${2:-"deployments"}
VERSION=${3:-"v1"}
IMAGE=${4:-"quay.io/praveen4g0/image-scanner:v0.0.1"}

# Create webhook-service
sed -e "s,\$IMAGE,$IMAGE,g" \
    "$DIR/../k8s-manifests/webhook-service.yaml" | oc apply -f -

#generate CA Bundle + inject into template
ca_pem_b64="$(openssl base64 -A <"$DIR/../certs/ca.pem")"

sed -e "s,\$CA_PEM_B64,$ca_pem_b64,g" \
    -e "s,\$API,$API,g" \
    -e "s,\$VERSION,$VERSION,g" \
    -e "s,\$RESOURCE,$RESOURCE,g" \
    "$DIR/../webhook-template.yaml" | oc apply -f -