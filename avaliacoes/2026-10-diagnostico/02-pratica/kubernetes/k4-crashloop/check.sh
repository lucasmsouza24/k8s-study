#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_minikube_context

NS=aval-k4
k() { kubectl -n "$NS" "$@"; }

if ! dep="$(k get deployment api -o json 2>/dev/null)"; then
  echo "Deployment api não encontrado em ${NS}. Rode 'make setup'."; exit 2
fi
c='.spec.template.spec.containers[0]'
q() { echo "$dep" | jq -r "$1"; }

section "Regras"
expect "ALLOC_MB inalterado" "$(q "[${c}.env[]? | select(.name==\"ALLOC_MB\") | .value] | first // \"\"")" "100"
expect "STARTUP_SECONDS inalterado" "$(q "[${c}.env[]? | select(.name==\"STARTUP_SECONDS\") | .value] | first // \"\"")" "20"
expect "liveness probe continua em /healthz" "$(q "${c}.livenessProbe.httpGet.path // \"\"")" "/healthz"
mem_limit="$(q "${c}.resources.limits.memory // \"\"")"
if [ -n "$mem_limit" ]; then ok "limit de memória definido (${mem_limit})"; else fail "limit de memória definido"; fi

section "Estabilidade"
echo "  aguardando rollout..."
if k rollout status deployment/api --timeout=120s >/dev/null 2>&1; then
  ok "rollout concluído"
else
  fail "rollout concluído" "veja: kubectl -n ${NS} get pods; kubectl -n ${NS} describe pod <pod>"
  summary; exit 1
fi
expect "réplicas prontas" "$(k get deployment api -o jsonpath='{.status.readyReplicas}')" "2"

echo "  observando os pods por 45s..."
sleep 45
pods_json="$(k get pods -l app=api -o json)"
restarts="$(echo "$pods_json" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | .status.containerStatuses[0].restartCount] | add // 0')"
expect "nenhum reinício nos pods atuais" "$restarts" "0"
not_ready="$(echo "$pods_json" | jq '[.items[] | select(.metadata.deletionTimestamp == null) | select(.status.containerStatuses[0].ready != true)] | length')"
expect "todos os pods continuam prontos" "$not_ready" "0"

summary
