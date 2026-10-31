guard:
	@test "$$(kubectl config current-context)" = "$${AVAL_CONTEXT:-minikube}" || (echo "contexto atual não é minikube, abortando" && exit 1)

setup: guard
	minikube image build -t aval-k4-api:1.0 .
	kubectl apply -f .k8s/namespace.yaml
	kubectl apply -f .k8s/

apply: guard
	kubectl apply -f .k8s/

check:
	bash check.sh

clean: guard
	kubectl delete namespace aval-k4 --ignore-not-found
	minikube image rm aval-k4-api:1.0 || true
