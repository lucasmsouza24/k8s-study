# Prática

## Pré-requisitos

```bash
sudo pacman -S --needed docker docker-buildx docker-compose minikube kubectl jq
sudo systemctl start docker
minikube start --cni=calico        # calico é necessário para o NetworkPolicy do K3 ter efeito
```

> Se o seu minikube já existe com outra CNI, dá pra recriar com `minikube delete && minikube start --cni=calico`, ou seguir sem: o K3 só vai avisar que a NetworkPolicy não está sendo aplicada.

Depois rode o preflight:

```bash
bash avaliacoes/2026-10-diagnostico/02-pratica/_shared/preflight.sh
```

**Segurança**: todos os `check.sh` de Kubernetes se recusam a rodar se o contexto atual do `kubectl` não for `minikube`, para não aplicar nada no cluster do trabalho por engano. Mesmo assim, confira o contexto (`kubectl config current-context`) antes de rodar comandos manualmente.

## Exercícios

| ID | Exercício | O que mede | Tempo de referência* |
|---|---|---|---|
| D1 | [Otimizar Dockerfile](docker/d1-otimizar-dockerfile/) | cache, tamanho, non-root, sinais, secrets | 30 min |
| D2 | [Multi-stage do zero](docker/d2-multi-stage/) | multi-stage, imagens mínimas | 20 min |
| D3 | [Docker Compose](docker/d3-compose/) | redes, volumes, healthcheck, dependências | 30 min |
| K1 | [Troubleshooting](kubernetes/k1-troubleshooting/) | diagnóstico de pods e services | 30 min |
| K2 | [Aplicação do zero](kubernetes/k2-do-zero/) | escrever manifests completos sem template | 45 min |
| K3 | [Operação](kubernetes/k3-operacao/) | rollout, rollback, HPA, RBAC, NetworkPolicy | 45 min |
| K4 | [CrashLoop](kubernetes/k4-crashloop/) | diagnóstico de reinícios e OOM | 30 min |

\* Tempo que alguém com nível "Operador" (ver `03-resultado.md`) levaria. Não é limite: se passar, continue e anote o tempo real.

## Como funciona cada exercício

Cada diretório tem:

- `README.md` — o enunciado. Leia inteiro antes de começar.
- `makefile` — atalhos (`make setup`, `make check`, `make clean`).
- `check.sh` — valida o resultado. Mostra **o que** falhou, não **como** corrigir.

Anote no próprio README do exercício (seção "Registro") o tempo gasto, as consultas à doc e as dificuldades.
