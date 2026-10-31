guard:
	@test "$$(kubectl config current-context)" = "$${AVAL_CONTEXT:-minikube}" || (echo "contexto atual não é minikube, abortando" && exit 1)

build:
	minikube image build -t aval-k2-web:1.0 .

apply: guard
	kubectl apply -f .k8s/

check:
	bash check.sh

clean: guard
	kubectl delete namespace aval-k2 --ignore-not-found
	minikube image rm aval-k2-web:1.0 || true
