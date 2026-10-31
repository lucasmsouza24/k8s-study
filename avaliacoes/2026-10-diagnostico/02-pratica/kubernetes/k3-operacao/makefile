guard:
	@test "$$(kubectl config current-context)" = "$${AVAL_CONTEXT:-minikube}" || (echo "contexto atual não é minikube, abortando" && exit 1)

setup: guard
	kubectl apply -f .k8s/namespace.yaml
	kubectl apply -f .k8s/
	kubectl -n aval-k3 rollout status deployment/web

check:
	bash check.sh

clean: guard
	kubectl delete namespace aval-k3 --ignore-not-found
