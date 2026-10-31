# Roadmap

Plano de estudos montado a partir da [avaliação diagnóstica de out/2026](avaliacoes/2026-10-diagnostico/03-resultado.md). Cada módulo lista as perguntas da avaliação que ele cobre: o módulo só está **concluído** quando você responde essas perguntas com nota 2, sem consulta (ver [COMO-ESTUDAR.md](COMO-ESTUDAR.md)).

Status: `pendente` · `em andamento` · `concluído` · `revisão` (concluído, com revisões espaçadas em dia)

As estimativas consideram **~5–6 h por semana**. São referências, não prazos.

---

## Fase 1 — Fundamentos

**Objetivo**: nível 1 (Usuário) nas três áreas. Entender o que você já opera hoje.
**Estimativa**: 10–12 semanas.

| # | Módulo | Cobre | Lab | Status |
|---|---|---|---|---|
| 1 | [Redes 01 — IP, TCP/UDP, portas e NAT](trilhas/01-redes/01-ip-tcp-portas-nat/) | D-04 | no módulo | pendente |
| 2 | Redes 02 — DNS | K-12 | no módulo | pendente |
| 3 | Linux 01 — Processos, sinais e permissões | D-09, D-15 | no módulo | pendente |
| 4 | Docker 01 — Imagens, camadas e cache | D-01, D-02, D-07, D-11, D-17, D-18 | no módulo | pendente |
| 5 | Docker 02 — Dockerfile | D-03, D-04, D-06, D-10 | no módulo | pendente |
| 6 | Docker 03 — Dados e redes | D-05, D-12 | D3 | pendente |
| 7 | Docker 04 — Imagens seguras e enxutas | D-08, D-09, D-13, D-19 | D1, D2 | pendente |
| 8 | Redes 03 — HTTP, TLS e certificados | — | no módulo | pendente |
| 9 | Kubernetes 01 — Arquitetura e o caminho do `apply` | K-01, K-06, K-19, K-20 | no módulo | pendente |
| 10 | Kubernetes 02 — Workloads | K-02, K-15, K-17 | no módulo | pendente |
| 11 | Redes 04 — Load balancers e proxies | K-13 | no módulo | pendente |
| 12 | Kubernetes 03 — Services, DNS e Ingress | K-03, K-05, K-12, K-13 | K1 | pendente |
| 13 | Kubernetes 04 — ConfigMaps e Secrets | K-04, K-14 | no módulo | pendente |
| 14 | Kubernetes 05 — Recursos, QoS e probes | K-07, K-08, K-09, K-10 | K4 | pendente |
| 15 | Kubernetes 06 — Rollout, rollback e estratégias | K-11 | K3 (passos 1–4) | pendente |
| — | **Reavaliação 1** | toda a teoria N1/N2 de Docker e K8s | — | pendente |
| — | Marco opcional: **KCNA** | | | |

## Fase 2 — Operação

**Objetivo**: nível 2 (Operador). Autonomia para operar aplicações no AKS, incluindo a tarefa de DNS + certificado.
**Estimativa**: 10–12 semanas.

| # | Módulo | Cobre | Lab | Status |
|---|---|---|---|---|
| 16 | AKS 01 — O modelo do AKS | A-01, A-02, A-08 | cluster de estudo | pendente |
| 17 | AKS 02 — Rede no AKS | A-03, A-05, A-11 | no módulo | pendente |
| 18 | AKS 03 — Identidades, ACR e Key Vault | A-04, A-06, A-07 | no módulo | pendente |
| 19 | **Projeto — [DNS + TLS de ponta a ponta](projetos/dns-tls-ponta-a-ponta/)** | | | pendente |
| 20 | Kubernetes 07 — Storage | K-16 | no módulo | pendente |
| 21 | Kubernetes 08 — Autoscaling (HPA) | K-18 | K3 (passo 5) | pendente |
| 22 | Kubernetes 09 — RBAC e ServiceAccounts | K-24 | K3 (passo 6) + `legacy/006-security` | pendente |
| 23 | Kubernetes 10 — NetworkPolicy | K-23 | K3 (passo 7) | pendente |
| 24 | Kubernetes 11 — Segurança de pods | K-27 | no módulo | pendente |
| 25 | Kubernetes 12 — Helm, Kustomize e GitOps | K-28 | no módulo | pendente |
| 26 | AKS 04 — Observabilidade | A-12 | no módulo | pendente |
| — | Lab integrador K2 | | K2 | pendente |
| — | **Reavaliação 2** (inclui a Parte B de AKS, no cluster de estudo) | | | pendente |
| — | Marco opcional: **CKAD** | | | |

## Fase 3 — Avançado

**Objetivo**: nível 3. Entender os mecanismos internos, resolver o que não é óbvio e desenhar ambientes.
**Estimativa**: 12+ semanas.

| # | Módulo | Cobre | Lab | Status |
|---|---|---|---|---|
| 27 | Linux 02 — Containers por dentro | D-14, D-16, D-17 | no módulo | pendente |
| 28 | Kubernetes 13 — Scheduling | K-22 | no módulo | pendente |
| 29 | Kubernetes 14 — Graceful shutdown e disrupções | K-25, K-26 | no módulo | pendente |
| 30 | Kubernetes 15 — Internals (controllers, kube-proxy, CNI) | K-19, K-20, K-21 | Kubernetes the Hard Way | pendente |
| 31 | AKS 05 — Escala e upgrades | A-09, A-10 | no módulo | pendente |
| 32 | **Projeto — Plataforma mínima** (cenário C-05 implementado) | C-05 | | pendente |
| — | Lab de troubleshooting K4 cronometrado + cenários C-01 a C-04 | | | pendente |
| — | **Reavaliação 3** | avaliação completa | | pendente |
| — | Marco opcional: **CKA** | | | |

---

## Fora do plano (por enquanto)

Temas que vão aparecer, mas não merecem módulo próprio agora: service mesh (Istio), CKS/segurança avançada, Terraform/Bicep para AKS, multi-cluster. Anote aqui o que surgir e reavalie ao final de cada fase.

-
