RESOURCE=${RESOURCE:-"deployments"}
API=${API:-"apps"}
VERSION=${VERSION:-"v1"}

oc delete -f k8s-manifests/webhook-service.yaml --ignore-not-found=true
oc delete -f webhook-template.yaml --ignore-not-found=true
# Create webhook-service
oc apply -f k8s-manifests/webhook-service.yaml


#generate CA Bundle + inject into template
ca_pem_b64="$(openssl base64 -A <"./certs/ca.pem")"

sed -e "s,\$CA_PEM_B64,$ca_pem_b64,g" \
    -e "s,\$API,$API,g" \
    -e "s,\$VERSION,$VERSION,g" \
    -e "s,\$RESOURCE,$RESOURCE,g" \
    "./webhook-template.yaml" | oc apply -f -