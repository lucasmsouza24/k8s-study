#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 2
source ../../_shared/check.sh
require_docker
require_compose
require curl jq

PROJECT=aval-d3
dc() { docker compose -p "$PROJECT" "$@"; }

cleanup() { dc down -v >/dev/null 2>&1; }
trap cleanup EXIT

wait_api() {
  for _ in $(seq 1 30); do
    curl -sf http://localhost:8080/health >/dev/null && return 0
    sleep 1
  done
  return 1
}

section "Configuração"
if ! cfg="$(dc config --format json 2>&1)"; then
  fail "compose.yaml válido" "$(echo "$cfg" | tail -3)"
  summary; exit 1
fi
ok "compose.yaml válido"

for svc in api redis; do
  if echo "$cfg" | jq -e ".services.${svc}" >/dev/null; then ok "serviço '${svc}' definido"; else fail "serviço '${svc}' definido"; fi
done

redis_ports="$(echo "$cfg" | jq -r '.services.redis.ports // [] | length')"
expect "redis sem portas publicadas no host" "$redis_ports" "0"

cond="$(echo "$cfg" | jq -r '.services.api.depends_on.redis.condition // "nenhuma"')"
expect "api depende do redis saudável" "$cond" "service_healthy"

if echo "$cfg" | jq -e '.services.redis.healthcheck.test' >/dev/null; then ok "redis tem healthcheck"; else fail "redis tem healthcheck"; fi

restart="$(echo "$cfg" | jq -r '.services.api.restart // "no"')"
case "$restart" in
  always | unless-stopped | on-failure*) ok "api com restart policy '${restart}'" ;;
  *) fail "api com restart policy que reinicia o processo" "restart: '${restart}'" ;;
esac

section "Execução"
docker compose down >/dev/null 2>&1
dc down -v >/dev/null 2>&1
if ! dc up -d --build --wait >/dev/null 2>&1; then
  fail "projeto sobe (docker compose up --wait)" "rode 'docker compose up' e veja os logs"
  summary; exit 1
fi
ok "projeto sobe"

if wait_api; then ok "api responde em localhost:8080"; else fail "api responde em localhost:8080"; summary; exit 1; fi

curl -s http://localhost:8080/hit >/dev/null
curl -s http://localhost:8080/hit >/dev/null
before="$(curl -s http://localhost:8080/hits | jq -r .hits)"
expect "contador incrementa" "$before" "2"

section "Persistência"
dc down >/dev/null 2>&1
dc up -d --wait >/dev/null 2>&1
wait_api
after="$(curl -s http://localhost:8080/hits | jq -r .hits 2>/dev/null)"
expect "contador sobrevive a down/up" "$after" "$before"

section "Resiliência"
curl -s -m 2 http://localhost:8080/crash >/dev/null 2>&1
sleep 3
if wait_api; then ok "api volta sozinha após o processo morrer"; else fail "api volta sozinha após o processo morrer"; fi

section "Bônus"
redis_cid="$(dc ps -q redis)"
mem_limit="$(docker inspect -f '{{.HostConfig.Memory}}' "$redis_cid" 2>/dev/null)"
if [ "${mem_limit:-0}" -gt 0 ] && [ "$mem_limit" -le $((128 * 1024 * 1024)) ]; then
  bonus "redis limitado a $((mem_limit / 1024 / 1024)) MB"
else
  info "redis sem limite de memória de até 128 MB"
fi

summary
