up: down
	minikube image build -t api001 .
	kubectl apply -f .k8s/service.yaml
	kubectl apply -f .k8s/secret.yaml
	kubectl apply -f .k8s/configmap.yaml
	kubectl apply -f .k8s/deployment.yaml
	sleep 3
	kubectl port-forward service/api001-service 8000:8000

down:
	kubectl delete deployment/api001-deployment || true
	kubectl delete service/api001-service || true
	kubectl delete configmap/api001-configmap || true
	kubectl delete secret/api001-secret || true
