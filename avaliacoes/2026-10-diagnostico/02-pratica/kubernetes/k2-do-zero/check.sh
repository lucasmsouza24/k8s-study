#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_minikube_context

NS=aval-k2
k() { kubectl -n "$NS" "$@"; }

section "Namespace e configuração"
if ! kubectl get namespace "$NS" >/dev/null 2>&1; then
  fail "namespace ${NS} existe"; summary; exit 1
fi
ok "namespace ${NS} existe"
expect "ConfigMap web-config com color=blue" "$(k get configmap web-config -o jsonpath='{.data.color}' 2>/dev/null)" "blue"
if [ -n "$(k get secret web-secret -o jsonpath='{.data.token}' 2>/dev/null)" ]; then
  ok "Secret web-secret com chave token"
else
  fail "Secret web-secret com chave token"
fi

section "Deployment"
if ! dep="$(k get deployment web -o json 2>/dev/null)"; then
  fail "Deployment web existe"; summary; exit 1
fi
ok "Deployment web existe"
k rollout status deployment/web --timeout=90s >/dev/null 2>&1

c='.spec.template.spec.containers[0]'
pod_sc='.spec.template.spec.securityContext'
q() { echo "$dep" | jq -r "$1"; }

expect "imagem" "$(q "${c}.image")" "aval-k2-web:1.0"
expect "label app=web no template" "$(q '.spec.template.metadata.labels.app')" "web"
expect "réplicas desejadas" "$(q '.spec.replicas')" "3"
expect "réplicas prontas" "$(q '.status.readyReplicas // 0')" "3"

expect "APP_COLOR vem do ConfigMap web-config/color" \
  "$(q "[${c}.env[]? | select(.name==\"APP_COLOR\") | .valueFrom.configMapKeyRef | \"\(.name)/\(.key)\"] | first // \"\"")" \
  "web-config/color"

expect "liveness probe em /healthz" "$(q "${c}.livenessProbe.httpGet.path // \"\"")" "/healthz"
expect "readiness probe em /ready" "$(q "${c}.readinessProbe.httpGet.path // \"\"")" "/ready"

expect "maxUnavailable" "$(q '.spec.strategy.rollingUpdate.maxUnavailable // "" | tostring')" "0"
expect "maxSurge" "$(q '.spec.strategy.rollingUpdate.maxSurge // "" | tostring')" "1"

qos="$(k get pods -l app=web -o jsonpath='{.items[*].status.qosClass}' | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)"
expect "QoS dos pods" "$qos" "Guaranteed"

section "Segurança"
non_root="$(q "(${c}.securityContext.runAsNonRoot // ${pod_sc}.runAsNonRoot // false) | tostring")"
expect "runAsNonRoot" "$non_root" "true"
expect "readOnlyRootFilesystem" "$(q "${c}.securityContext.readOnlyRootFilesystem // false | tostring")" "true"
expect "allowPrivilegeEscalation" "$(q "${c}.securityContext.allowPrivilegeEscalation | tostring")" "false"
expect "capabilities.drop contém ALL" "$(q "${c}.securityContext.capabilities.drop // [] | any(.[]; . == \"ALL\") | tostring")" "true"

section "Service e comportamento"
expect "Service web do tipo ClusterIP" "$(k get service web -o jsonpath='{.spec.type}' 2>/dev/null)" "ClusterIP"
expect "Service web na porta 80" "$(k get service web -o jsonpath='{.spec.ports[0].port}' 2>/dev/null)" "80"

body="$(incluster_curl "$NS" "http://web.${NS}.svc.cluster.local/")"
if [ -z "$body" ] || ! echo "$body" | jq -e . >/dev/null 2>&1; then
  fail "http://web.${NS}.svc.cluster.local/ responde" "resposta: '${body:-<vazia/timeout>}'"
else
  ok "http://web.${NS}.svc.cluster.local/ responde"
  expect "app recebe color=blue" "$(echo "$body" | jq -r .color)" "blue"
  expect "app lê o token em /etc/web/token" "$(echo "$body" | jq -r .token_loaded)" "true"
  uid="$(echo "$body" | jq -r .uid)"
  if [ "$uid" != "0" ]; then ok "processo roda com uid ${uid}"; else fail "processo não roda como root" "uid: 0"; fi
fi

section "PodDisruptionBudget"
if pdb="$(k get pdb web-pdb -o json 2>/dev/null)"; then
  ok "PDB web-pdb existe"
  expect "minAvailable" "$(echo "$pdb" | jq -r '.spec.minAvailable // "" | tostring')" "2"
  expect "PDB seleciona app=web" "$(echo "$pdb" | jq -r '.spec.selector.matchLabels.app // ""')" "web"
else
  fail "PDB web-pdb existe"
fi

section "Bônus"
spread="$(q '((.spec.template.spec.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution // []) | length) + ([.spec.template.spec.topologySpreadConstraints[]? | select(.whenUnsatisfiable == "ScheduleAnyway")] | length)')"
if [ "${spread:-0}" -gt 0 ]; then bonus "preferência por nós diferentes"; else info "sem preferência de espalhamento entre nós"; fi

summary
