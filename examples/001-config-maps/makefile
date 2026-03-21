up: down
	minikube image build -t api001 .
	kubectl apply -f .k8s/service.yaml
	kubectl apply -f .k8s/configmap.yaml
	kubectl apply -f .k8s/deployment.yaml

down:
	kubectl delete deployment/api001-deployment
	kubectl delete service/api001-service
	kubectl delete configmap/api001-configmap
