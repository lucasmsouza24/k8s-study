# D3 — Docker Compose

Uma API (`app.py`, já com `Dockerfile` pronto) conta acessos num Redis:

- `GET /hit` incrementa e retorna o contador
- `GET /hits` só retorna o contador
- `GET /health` retorna 200 se conseguir falar com o Redis
- `GET /crash` derruba o processo com exit code 1 (para testar o restart)

A API lê o host do Redis da variável `REDIS_HOST` (porta 6379).

## Requisitos

Escreva um `compose.yaml` com dois serviços, `api` e `redis` (imagem `redis:7-alpine`), tal que:

1. A API fique acessível em `http://localhost:8080`.
2. O Redis **não** seja acessível a partir do host (só a API fala com ele).
3. A API encontre o Redis pelo nome do serviço.
4. O contador **sobreviva** a um `docker compose down` seguido de `docker compose up` (sem `-v`).
5. A API só inicie depois que o Redis estiver **saudável** (não basta "iniciado").
6. A API seja reiniciada automaticamente se o processo morrer.
7. **Bônus**: limite o Redis a 128 MB de memória (no container).

## Verificação

```bash
make check
```

O `check.sh` derruba o que você tiver subido manualmente (`docker compose down`, sem apagar volumes, para liberar a porta 8080), sobe o projeto com o nome `aval-d3` e limpa tudo no final.

## Perguntas (responda aqui)

**Por que `depends_on` sem condição não garante que a API vai conseguir conectar no Redis?**

>

**Onde ficam fisicamente os dados do volume no host? O que acontece com eles num `docker compose down -v`?**

>

**Como esse setup se traduziria para Kubernetes? (quais objetos substituem cada parte do compose)**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
