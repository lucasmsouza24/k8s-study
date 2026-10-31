#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_minikube_context

NS=aval-k1
k() { kubectl -n "$NS" "$@"; }

section "Recursos"
for r in deployment/echo service/echo-svc configmap/echo-config; do
  assert "${r} existe" k get "$r"
done

msg="$(k get configmap echo-config -o jsonpath='{.data.message}')"
expect "texto do ConfigMap inalterado" "$msg" "avaliacao-k1-ok"

cm_ref="$(k get deployment echo -o json | jq -r '[.spec.template.spec.containers[0].env[]? | select(.valueFrom.configMapKeyRef.name == "echo-config")] | length')"
if [ "${cm_ref:-0}" -ge 1 ]; then ok "mensagem vem do ConfigMap"; else fail "mensagem vem do ConfigMap" "nenhuma env referencia o ConfigMap echo-config"; fi

section "Deployment"
k rollout status deployment/echo --timeout=60s >/dev/null 2>&1
ready="$(k get deployment echo -o jsonpath='{.status.readyReplicas}')"
expect "réplicas prontas" "${ready:-0}" "2"

mem="$(k get deployment echo -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}')"
case "$mem" in
  *Gi | *G | *Ti | *T) fail "memory request razoável para um echo server" "requests.memory: ${mem}" ;;
  *) ok "memory request razoável (${mem:-não definido})" ;;
esac

section "Service"
endpoints="$(k get endpointslices -l kubernetes.io/service-name=echo-svc -o json | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length')"
expect "Service com 2 endpoints prontos" "${endpoints:-0}" "2"

body="$(incluster_curl "$NS" "http://echo-svc.${NS}")"
if echo "$body" | grep -q "avaliacao-k1-ok"; then
  ok "http://echo-svc.${NS} responde a mensagem do ConfigMap"
else
  fail "http://echo-svc.${NS} responde a mensagem do ConfigMap" "resposta: '${body:-<vazia/timeout>}'"
fi

summary
