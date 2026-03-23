IMAGE_NAME=api003
TAG:=$(shell date +%s)

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

load:
	minikube image load $(IMAGE_NAME):$(TAG)

# 🟢 FS scan (dependências + secrets)
scan-fs:
	trivy fs \
	--scanners vuln,secret \
	--severity HIGH,CRITICAL \
	--exit-code 1 \
	.

# 🟡 Config scan (YAML)
scan-config:
	trivy config \
	--severity HIGH,CRITICAL \
	--exit-code 1 \
	.k8s/

# 🔴 Image scan
scan-image:
	trivy image --severity HIGH,CRITICAL --exit-code 1 $(IMAGE_NAME):$(TAG)

deploy:
	sed "s|IMAGE_TAG|$(TAG)|g" .k8s/deployment.yaml | kubectl apply -f -
	sleep 5
	kubectl port-forward deployment/api003 8000:8000

start: build scan-image load deploy

clear:
	kubectl delete -f .k8s/deployment.yaml || true
	docker stop api003 || true
	docker rm api003 || true
	docker images --format "{{.Repository}}:{{.Tag}}" | grep -i $(IMAGE_NAME) | xargs docker rmi || true
	minikube image ls | grep -i $(IMAGE_NAME) | xargs minikube image rm
