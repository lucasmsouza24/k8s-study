#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_minikube_context

NS=aval-k3
k() { kubectl -n "$NS" "$@"; }

if ! dep="$(k get deployment web -o json 2>/dev/null)"; then
  echo "Deployment web não encontrado em ${NS}. Rode 'make setup'."; exit 2
fi
q() { echo "$dep" | jq -r "$1"; }

section "1. Estratégia"
expect "maxSurge" "$(q '.spec.strategy.rollingUpdate.maxSurge // "" | tostring')" "1"
expect "maxUnavailable" "$(q '.spec.strategy.rollingUpdate.maxUnavailable // "" | tostring')" "0"

section "2-4. Rollout e rollback"
history="$(k rollout history deployment/web 2>/dev/null)"
if echo "$history" | grep -q "atualiza para 1.27"; then ok "histórico registra 'atualiza para 1.27'"; else fail "histórico registra 'atualiza para 1.27'"; fi
if echo "$history" | grep -q "versao quebrada"; then ok "histórico registra 'versao quebrada'"; else fail "histórico registra 'versao quebrada'"; fi

broken_rs="$(k get rs -l app=web -o json | jq -r '[.items[] | select(.spec.template.spec.containers[0].image == "nginx:9.9.9-alpine")] | length')"
if [ "${broken_rs:-0}" -ge 1 ]; then ok "ReplicaSet da versão quebrada existe (passo 3 executado)"; else fail "ReplicaSet da versão quebrada existe (passo 3 executado)"; fi
broken_replicas="$(k get rs -l app=web -o json | jq -r '[.items[] | select(.spec.template.spec.containers[0].image == "nginx:9.9.9-alpine") | .spec.replicas] | add // 0')"
expect "ReplicaSet quebrado com 0 réplicas" "$broken_replicas" "0"

expect "imagem atual" "$(q '.spec.template.spec.containers[0].image')" "nginx:1.27-alpine"
k rollout status deployment/web --timeout=60s >/dev/null 2>&1
dep="$(k get deployment web -o json)"
desired="$(q '.spec.replicas')"
ready="$(q '.status.readyReplicas // 0')"
if [ "$ready" = "$desired" ] && [ "$ready" -ge 2 ]; then
  ok "todas as réplicas prontas (${ready}/${desired})"
else
  fail "todas as réplicas prontas" "${ready}/${desired}"
fi

section "5. HPA"
if hpa="$(k get hpa web -o json 2>/dev/null)"; then
  ok "HPA web existe"
  h() { echo "$hpa" | jq -r "$1"; }
  expect "alvo do HPA" "$(h '.spec.scaleTargetRef.kind + "/" + .spec.scaleTargetRef.name')" "Deployment/web"
  expect "minReplicas" "$(h '.spec.minReplicas')" "2"
  expect "maxReplicas" "$(h '.spec.maxReplicas')" "6"
  expect "alvo de CPU" "$(h '[.spec.metrics[]? | select(.resource.name == "cpu") | .resource.target.averageUtilization] | first // "" | tostring')" "60"

  cpu_req="$(q '.spec.template.spec.containers[0].resources.requests.cpu // ""')"
  if [ -n "$cpu_req" ]; then ok "Deployment define requests de CPU (${cpu_req})"; else fail "Deployment define requests de CPU"; fi

  active=""
  for _ in $(seq 1 18); do
    active="$(k get hpa web -o json | jq -r '.status.conditions[]? | select(.type == "ScalingActive") | .status')"
    [ "$active" = "True" ] && break
    sleep 5
  done
  if [ "$active" = "True" ]; then
    ok "HPA consegue ler métricas (ScalingActive=True)"
  else
    reason="$(k get hpa web -o json | jq -r '.status.conditions[]? | select(.type == "ScalingActive") | .message')"
    fail "HPA consegue ler métricas (ScalingActive=True)" "${reason:-sem condição ScalingActive ainda}"
  fi
else
  fail "HPA web existe"
fi

section "6. RBAC"
SA="system:serviceaccount:${NS}:auditor"
assert "ServiceAccount auditor existe" k get serviceaccount auditor
can() { kubectl auth can-i "$@" --as="$SA" 2>/dev/null; }
expect "auditor pode listar pods"          "$(can list pods -n "$NS")" "yes"
expect "auditor pode watch pods"           "$(can watch pods -n "$NS")" "yes"
expect "auditor pode ver deployments"      "$(can get deployments.apps -n "$NS")" "yes"
expect "auditor pode ler logs"             "$(can get pods --subresource=log -n "$NS")" "yes"
expect "auditor NÃO pode apagar pods"      "$(can delete pods -n "$NS")" "no"
expect "auditor NÃO pode alterar deployments" "$(can patch deployments.apps -n "$NS")" "no"
expect "auditor NÃO pode ler secrets"      "$(can get secrets -n "$NS")" "no"
expect "auditor NÃO pode listar pods em default" "$(can list pods -n default)" "no"

section "7. NetworkPolicy"
netpols="$(k get networkpolicy -o json)"
match="$(echo "$netpols" | jq '[.items[] | select(.spec.podSelector.matchLabels.app == "web")
  | select([.spec.ingress[]?.from[]?.podSelector.matchLabels.role] | index("frontend") != null)
  | select([.spec.ingress[]?.ports[]?.port | tostring] | index("80") != null)] | length')"
if [ "${match:-0}" -ge 1 ]; then
  ok "NetworkPolicy para app=web liberando role=frontend na porta 80"
else
  fail "NetworkPolicy para app=web liberando role=frontend na porta 80"
fi

from_frontend="$(incluster_curl "$NS" "http://web.${NS}" "role=frontend")"
from_other="$(incluster_curl "$NS" "http://web.${NS}" "role=outro")"
if echo "$from_frontend" | grep -qi "nginx"; then ok "pod com role=frontend acessa web"; else fail "pod com role=frontend acessa web"; fi
if echo "$from_other" | grep -qi "nginx"; then
  if [ "${match:-0}" -ge 1 ]; then
    info "pod sem role=frontend também acessou: a CNI do minikube provavelmente não aplica NetworkPolicy (use minikube start --cni=calico)"
  else
    fail "pod sem role=frontend é bloqueado"
  fi
else
  ok "pod sem role=frontend é bloqueado"
fi

summary
