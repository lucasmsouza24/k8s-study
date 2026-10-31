#!/usr/bin/env bash
# Funções comuns aos check.sh dos exercícios práticos.
# Uso: source "$(dirname "$0")/../../_shared/check.sh"

PASS=0
FAIL=0
BONUS=0

if [ -t 1 ]; then
  GREEN=$'\e[32m'; RED=$'\e[31m'; YELLOW=$'\e[33m'; BLUE=$'\e[34m'; RESET=$'\e[0m'
else
  GREEN=""; RED=""; YELLOW=""; BLUE=""; RESET=""
fi

section() { echo; echo "${BLUE}== $1${RESET}"; }
ok()      { PASS=$((PASS + 1)); echo "  ${GREEN}✔${RESET} $1"; }
fail()    { FAIL=$((FAIL + 1)); echo "  ${RED}✘${RESET} $1"; if [ -n "${2:-}" ]; then echo "      ${YELLOW}↳ $2${RESET}"; fi; }
info()    { echo "  ${YELLOW}ℹ${RESET} $1"; }
bonus()   { BONUS=$((BONUS + 1)); echo "  ${GREEN}★${RESET} bônus: $1"; }

# expect "descrição" "valor obtido" "valor esperado"
expect() {
  if [ "$2" = "$3" ]; then ok "$1"; else fail "$1" "obtido: '${2}' | esperado: '${3}'"; fi
}

# assert "descrição" comando [args...]  -> passa se o comando retornar 0
assert() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then ok "$desc"; else fail "$desc"; fi
}

require() {
  local missing=0
  for bin in "$@"; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      echo "${RED}Dependência ausente: ${bin}${RESET}"; missing=1
    fi
  done
  [ "$missing" -eq 0 ] || exit 2
}

require_docker() {
  require docker
  docker info >/dev/null 2>&1 || { echo "${RED}Docker daemon não está rodando.${RESET}"; exit 2; }
  docker buildx version >/dev/null 2>&1 || { echo "${RED}Plugin buildx ausente (pacman -S docker-buildx).${RESET}"; exit 2; }
}

require_compose() {
  docker compose version >/dev/null 2>&1 || { echo "${RED}Plugin compose ausente (pacman -S docker-compose).${RESET}"; exit 2; }
}

# Os exercícios de Kubernetes NUNCA devem rodar contra um cluster de trabalho.
AVAL_CONTEXT="${AVAL_CONTEXT:-minikube}"
require_minikube_context() {
  require kubectl jq
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null)"
  if [ "$ctx" != "$AVAL_CONTEXT" ]; then
    echo "${RED}Contexto atual é '${ctx}', esperado '${AVAL_CONTEXT}'.${RESET}"
    echo "Troque com: kubectl config use-context ${AVAL_CONTEXT}"
    exit 2
  fi
  kubectl get --raw /readyz >/dev/null 2>&1 || { echo "${RED}Cluster não responde. Rode: minikube start${RESET}"; exit 2; }
}

# incluster_curl <namespace> <url> [labels]  -> imprime o corpo da resposta
incluster_curl() {
  local ns="$1" url="$2" labels="${3:-}"
  local name="aval-curl-$RANDOM"
  local args=(-n "$ns" run "$name" --rm -i --quiet --restart=Never --image=curlimages/curl:8.10.1)
  [ -n "$labels" ] && args+=(--labels="$labels")
  timeout 90 kubectl "${args[@]}" --command -- curl -s -m 5 "$url" 2>/dev/null
}

summary() {
  local total=$((PASS + FAIL))
  echo
  if [ "$FAIL" -eq 0 ]; then
    echo "${GREEN}Resultado: ${PASS}/${total} verificações passaram${RESET}"
  else
    echo "${RED}Resultado: ${PASS}/${total} verificações passaram${RESET}"
  fi
  [ "$BONUS" -gt 0 ] && echo "Bônus: ${BONUS}"
  [ "$FAIL" -eq 0 ]
}
