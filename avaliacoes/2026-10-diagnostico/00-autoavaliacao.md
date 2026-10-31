# Autoavaliação (responda ANTES de começar)

Dê uma nota de 0 a 4 para quanto você **acha** que domina cada tema. Não pense muito, é a primeira impressão que importa. No final, comparamos com o resultado real: a diferença entre o que você acha e o que mostra é tão útil quanto a nota em si (revela pontos cegos e também insegurança injustificada).

| Nota | Significado |
|---|---|
| 0 | Nunca ouvi falar / não sei o que é |
| 1 | Já ouvi falar, sei o que é por alto |
| 2 | Já usei seguindo exemplo/tutorial ou copiando de algo existente |
| 3 | Uso sozinho e consigo explicar como funciona |
| 4 | Consigo debugar problemas difíceis e ensinar para outra pessoa |

## Docker

| Tema                                                     | Nota (0-4) |
| -------------------------------------------------------- | ---------- |
| Imagem vs container, camadas, cache de build             | 3          |
| Escrever Dockerfile do zero                              | 2          |
| Multi-stage build e otimização de imagem                 | 0          |
| Redes e volumes no Docker                                | 1          |
| Docker Compose                                           | 2          |
| Segurança de imagens (non-root, secrets, scan)           | 1          |
| Como containers funcionam no Linux (namespaces, cgroups) | 0          |

## Kubernetes

| Tema                                                    | Nota (0-4) |
| ------------------------------------------------------- | ---------- |
| Arquitetura (control plane, nodes, componentes)         | 0          |
| Pods, Deployments, ReplicaSets                          | 3          |
| Services e DNS interno                                  | 2          |
| ConfigMaps e Secrets                                    | 2          |
| Requests/limits, QoS, OOMKill                           | 2          |
| Probes (liveness, readiness, startup)                   | 0          |
| Rolling update e rollback                               | 0          |
| Troubleshooting de pods (CrashLoop, Pending, ImagePull) | 3          |
| Ingress / Gateway API                                   | 2          |
| Storage (PV, PVC, StorageClass)                         | 1          |
| Scheduling (affinity, taints, tolerations)              | 0          |
| RBAC e ServiceAccounts                                  | 2          |
| NetworkPolicy                                           | 0          |
| HPA / autoscaling                                       | 0          |
| Helm / Kustomize                                        | 0          |

## AKS / Azure

| Tema                                              | Nota (0-4) |
| ------------------------------------------------- | ---------- |
| Criar e configurar um cluster AKS                 | 1          |
| Node pools (system/user), upgrades                | 1          |
| Networking no AKS (CNI, Load Balancer, IPs)       | 0          |
| Integração AKS + ACR                              | 2          |
| Identidades (managed identity, workload identity) | 1          |
| Integração com Key Vault                          | 1          |
| Monitoramento (Container Insights, Prometheus)    | 0          |
| CI/CD para AKS (Azure Pipelines, GitOps)          | 2          |

## Perguntas abertas

**No seu trabalho, quais tarefas com AKS você faz hoje sem precisar de ajuda?**

> consultar logs de aplicações quebradas, entender e resolver os problemas (geralmente associado à autenticação com KV usando MI, CLIENT_SECRET expirada vindo do KV, ACR, ingress, CPU/mem insuficiente, etc

**Quais tarefas você evita, ou faz com medo de quebrar alguma coisa?**

> instalação de certificado de DNS, sempre que um ambiente novo (cluster) chega, eu nunca fiz a tarefa de solicitar DNS e instalar o certificado, não entendo bem o processo como um todo, e boa parte do processo depende de outros times, é dificil se comunicar com outros times pra fazer parte do trabalho quando não se sabe o processo como um todo ao menos que de forma geral

**Qual foi o último problema de infra que você não conseguiu resolver (ou que alguém resolveu por você)?**

> a instalação de certificados DNS como mencionado na pergunta anterior
