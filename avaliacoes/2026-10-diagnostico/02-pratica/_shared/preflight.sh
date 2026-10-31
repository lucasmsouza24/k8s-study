#!/usr/bin/env bash
# Verifica se o ambiente está pronto para os exercícios práticos.
source "$(dirname "$0")/check.sh"

section "Ferramentas"
for bin in docker kubectl minikube jq curl; do
  assert "$bin instalado" command -v "$bin"
done

section "Docker"
assert "daemon rodando (systemctl start docker)" docker info
assert "plugin buildx (pacman -S docker-buildx)" docker buildx version
assert "plugin compose (pacman -S docker-compose)" docker compose version

section "Kubernetes"
assert "minikube rodando (minikube start)" minikube status
ctx="$(kubectl config current-context 2>/dev/null)"
expect "contexto atual do kubectl" "$ctx" "${AVAL_CONTEXT}"
assert "API server responde" kubectl get --raw /readyz

summary
