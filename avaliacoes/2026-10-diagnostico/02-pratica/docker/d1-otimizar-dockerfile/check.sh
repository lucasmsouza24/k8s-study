#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_docker
require curl tar

IMAGE=aval-d1:check
CONTAINER=aval-d1-check
PORT=18001
TMP="$(mktemp -d)"

cleanup() {
  docker rm -f "$CONTAINER" >/dev/null 2>&1
  docker rmi -f "${IMAGE}-cache" >/dev/null 2>&1
  rm -rf "$TMP"
}
trap cleanup EXIT

if [ ! -f dataset/dump.bin ] || [ ! -f .env ]; then
  echo "Rode 'make setup' antes."; exit 2
fi

section "Build"
if ! docker build -t "$IMAGE" . >"$TMP/build.log" 2>&1; then
  fail "imagem builda" "últimas linhas do log:"
  tail -20 "$TMP/build.log"
  summary; exit 1
fi
ok "imagem builda"

section "Tamanho"
size_mb=$(( $(docker image inspect -f '{{.Size}}' "$IMAGE") / 1024 / 1024 ))
if [ "$size_mb" -lt 200 ]; then
  ok "imagem com ${size_mb} MB (< 200 MB)"
else
  fail "imagem com menos de 200 MB" "tamanho atual: ${size_mb} MB"
fi

section "Usuário"
user="$(docker image inspect -f '{{.Config.User}}' "$IMAGE")"
case "${user%%:*}" in
  "" | root | 0) fail "não roda como root" "USER da imagem: '${user:-<vazio>}'" ;;
  *) ok "roda como '${user}'" ;;
esac

section "Segredos e arquivos indesejados"
if docker image inspect "$IMAGE" | grep -q supersecret123; then
  fail "token ausente da configuração da imagem (ENV, labels...)"
else
  ok "token ausente da configuração da imagem"
fi
if docker history --no-trunc "$IMAGE" | grep -q supersecret123; then
  fail "token ausente do histórico de build (docker history)"
else
  ok "token ausente do histórico de build"
fi

docker create --name "$CONTAINER" "$IMAGE" >/dev/null
docker export "$CONTAINER" >"$TMP/fs.tar"
docker rm -f "$CONTAINER" >/dev/null
tar -tf "$TMP/fs.tar" >"$TMP/files.txt"

if grep -qE '(^|/)dataset/dump\.bin$' "$TMP/files.txt"; then
  fail "dataset/ fora da imagem" "encontrado: $(grep -E 'dump\.bin$' "$TMP/files.txt" | head -1)"
else
  ok "dataset/ fora da imagem"
fi
if grep -qE '(^|/)\.env$' "$TMP/files.txt"; then
  fail ".env fora da imagem" "encontrado: $(grep -E '(^|/)\.env$' "$TMP/files.txt" | head -1)"
else
  ok ".env fora da imagem"
fi
if grep -aq supersecret123 "$TMP/fs.tar"; then
  fail "token ausente de todos os arquivos da imagem"
else
  ok "token ausente de todos os arquivos da imagem"
fi
rm -f "$TMP/fs.tar"

section "Execução"
docker run -d --name "$CONTAINER" -p "${PORT}:8000" -e API_TOKEN=runtime-token "$IMAGE" >/dev/null
for _ in $(seq 1 30); do
  curl -sf "http://localhost:${PORT}/health" >/dev/null && break
  sleep 1
done
assert "GET /health retorna 200" curl -sf "http://localhost:${PORT}/health"
body="$(curl -s "http://localhost:${PORT}/")"
if echo "$body" | grep -q '"token_configured":true'; then
  ok "GET / mostra token_configured: true"
else
  fail "GET / mostra token_configured: true" "resposta: ${body:-<vazia>}"
fi

section "Encerramento"
start=$(date +%s%N)
docker stop "$CONTAINER" >/dev/null
elapsed_ms=$(( ($(date +%s%N) - start) / 1000000 ))
code="$(docker inspect -f '{{.State.ExitCode}}' "$CONTAINER")"
if [ "$elapsed_ms" -lt 3000 ]; then
  ok "docker stop em ${elapsed_ms} ms (< 3 s)"
else
  fail "docker stop em menos de 3 s" "levou ${elapsed_ms} ms"
fi
case "$code" in
  0 | 143) ok "exit code ${code} após docker stop (encerrou pelo SIGTERM)" ;;
  *) fail "exit code 0 ou 143 após docker stop" "exit code: ${code}" ;;
esac
docker rm -f "$CONTAINER" >/dev/null

section "Cache de build"
cp -a . "$TMP/ctx"
docker build -t "${IMAGE}-cache" "$TMP/ctx" >/dev/null 2>&1
echo "# cache-test $(date +%s%N)" >>"$TMP/ctx/app.py"
docker build --progress=plain -t "${IMAGE}-cache" "$TMP/ctx" >"$TMP/cache.log" 2>&1
step="$(grep -E '^#[0-9]+ \[[^]]+\] RUN .*(pip|uv|poetry) ' "$TMP/cache.log" | head -1 | awk '{print $1}')"
if [ -z "$step" ]; then
  fail "dependências usam cache quando só app.py muda" "não encontrei um passo RUN com pip/uv/poetry no build"
elif grep -qE "^${step} CACHED" "$TMP/cache.log"; then
  ok "dependências usam cache quando só app.py muda"
else
  fail "dependências usam cache quando só app.py muda" "o passo de instalação foi reexecutado"
fi

summary
