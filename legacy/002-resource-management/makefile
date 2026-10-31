up: down
	minikube image build -t api002 .
	kubectl apply -f .k8s/service.yaml
	kubectl apply -f .k8s/deployment.yaml

down:
	kubectl delete -f .k8s/service.yaml || true
	kubectl delete -f .k8s/deployment.yaml || true

clear: down
	minikube image rm api002
