#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_docker
require curl jq

IMAGE=aval-d2:check
CONTAINER=aval-d2-check
PORT=18002
TMP="$(mktemp -d)"

cleanup() { docker rm -f "$CONTAINER" >/dev/null 2>&1; rm -rf "$TMP"; }
trap cleanup EXIT

section "Dockerfile"
if [ ! -f Dockerfile ]; then
  fail "Dockerfile existe"; summary; exit 1
fi
ok "Dockerfile existe"
stages=$(grep -ciE '^\s*FROM\s' Dockerfile)
if [ "$stages" -ge 2 ]; then ok "multi-stage (${stages} estágios)"; else fail "multi-stage" "encontrei ${stages} instrução(ões) FROM"; fi

section "Build"
if ! docker build -t "$IMAGE" . >"$TMP/build.log" 2>&1; then
  fail "imagem builda" "últimas linhas do log:"
  tail -20 "$TMP/build.log"
  summary; exit 1
fi
ok "imagem builda"

size_mb=$(( $(docker image inspect -f '{{.Size}}' "$IMAGE") / 1024 / 1024 ))
if [ "$size_mb" -lt 25 ]; then ok "imagem com ${size_mb} MB (< 25 MB)"; else fail "imagem com menos de 25 MB" "tamanho atual: ${size_mb} MB"; fi

section "Execução"
docker run -d --name "$CONTAINER" -p "${PORT}:8080" "$IMAGE" >/dev/null
for _ in $(seq 1 15); do
  curl -sf "http://localhost:${PORT}/health" >/dev/null && break
  sleep 1
done
if curl -sf "http://localhost:${PORT}/health" >/dev/null; then
  ok "GET /health retorna 200"
else
  fail "GET /health retorna 200" "logs do container: $(docker logs "$CONTAINER" 2>&1 | tail -3 | tr '\n' ' ')"
fi

uid="$(curl -s "http://localhost:${PORT}/" | jq -r '.uid' 2>/dev/null)"
if [ -n "$uid" ] && [ "$uid" != "null" ] && [ "$uid" != "0" ]; then
  ok "processo roda com uid ${uid} (não-root)"
else
  fail "processo roda como não-root" "uid reportado: '${uid:-<sem resposta>}'"
fi

section "Bônus"
if docker run --rm --entrypoint /bin/sh "$IMAGE" -c true >/dev/null 2>&1; then
  info "imagem final ainda tem /bin/sh"
else
  bonus "imagem final sem shell"
fi

summary
