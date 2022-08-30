VERSION ?= "v1"
API ?= "apps"
RESOURCE ?= "deployments"
TAG ?= 0.0.1

IMAGE ?= quay.io/praveen4g0/image-scanner:v$(TAG)

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: run-as-privilaged-user
run-as-privilaged-user: ## Applicable only to openhsift, Run application with privilaged permission
	@echo "Run application with privilaged permission..."
	oc adm policy add-scc-to-user privileged -z default

.PHONY: generate-certificates
generate-certificates: ## Genereate certificates for webhook services
	@echo "Generating tls certificates for webhook services..."
	. ./util/generate-certs.sh

.PHONY: generate-secrets
generate-secrets: generate-certificates ## Creates k8s tls secrets for webhook services
	@echo "Creates k8s tls secrets for webhook services.."
	. ./util/create-secret.sh

.PHONY: deploy
deploy: ## Deploy's webhook service and Validating Webhook Configuration
	@echo "Deploy's webhook service and Validating Webhook Configuration..."
	. ./util/create-webhook.sh $(API) $(RESOURCE) $(VERSION) $(IMAGE)

.PHONY: undeploy
undeploy: ## Undeploy's webhook service and Validating Webhook Configuration
	@echo "Uninstall's webhook service..."
	oc delete -f k8s-manifests/webhook-service.yaml --ignore-not-found=true && \
    oc delete validatingwebhookconfigurations.admissionregistration.k8s.io validate-webhook-$(RESOURCE) --ignore-not-found=true

.PHONY: docker-build
docker-build: ## Build docker image of webhook service.
	@echo "Build Docker image of webhook service..."
	docker build -t ${IMAGE} .

.PHONY: docker-push
docker-push: ## Push docker image of webhook service.
	@echo "Push webhook service docker image"
	docker push ${IMAGE}
