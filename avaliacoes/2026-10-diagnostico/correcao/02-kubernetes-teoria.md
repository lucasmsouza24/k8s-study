# Correção — Teoria Kubernetes

Corrigido em 30/10/2026. As respostas completas estão em `gabarito/teoria.md`, que agora pode ser lido como material de estudo (ver "Próximos passos" em `03-resultado.md`).

## Notas

| Pergunta | Nota | Comentário |
|---|---|---|
| K-01 · Arquitetura | 0 | |
| K-02 · Pod/RS/Deployment | 1 | Certo: o pod é a menor unidade e o Deployment mantém o estado desejado. Erro: o ReplicaSet **não é um tipo de pod**. A cadeia é Deployment → ReplicaSet → Pods: o RS mantém N pods, e o Deployment cria um RS por versão (é isso que permite rollout e rollback). |
| K-03 · Services | 1 | Labels/selector está certo. Os tipos de Service você não lembrava. |
| K-04 · ConfigMap vs Secret | 1 | Diferença de propósito certa. A parte central ficou sem resposta: o Secret **não é criptografado**, é base64 (qualquer um com `get secrets` lê). |
| K-05 · Namespaces | 1 | Certo que nós e node pools não são isolados. Faltou o mais importante: **a rede não é isolada**. Por padrão, pods de namespaces diferentes se falam livremente. |
| K-06 · Declarativo vs imperativo | 1 | Nota no limite. Você descreveu o que cada comando faz, mas não a diferença que importa: mudanças com `edit`/`scale` não ficam no git e o próximo `apply` as desfaz (drift). |
| K-07 · Requests e limits | 1 | Boa parte certa: request é reservado mesmo sem uso, o scheduler usa o request, e falta de espaço deixa o pod Pending. Faltou o que acontece ao passar do limit, que é diferente para cada recurso: CPU sofre **throttling** (fica lento, não morre) e memória leva a **OOMKilled**. |
| K-08 · QoS | 0 | |
| K-09 · Probes | 0 | Ponto importante: isso explica o seu item (e) da K-10. |
| K-10 · Diagnóstico de status | 1 | Causas certas em a, b, c e f. A d é mais específica do que "config errada": é uma **referência a ConfigMap/Secret ou chave inexistente**. Na e, "READY 0/1" significa que a **readiness probe** está falhando e o pod não recebe tráfego. Nenhum comando foi citado (`describe pod`, `logs --previous`, eventos), e é ele que separa "sei o que significa" de "sei investigar". |
| K-11 · Rolling update | 0 | |
| K-12 · DNS interno | 1 | `api-estoque.estoque` está certo e funciona. O sufixo é `.svc`, não `.service`: FQDN `api-estoque.estoque.svc.cluster.local`. Faltou explicar por que o nome curto falha. |
| K-13 · Ingress | 0 | |
| K-14 · Atualização de ConfigMap | 0 | |
| K-15 · Tipos de workload | 1 | Job, CronJob (cria Jobs) e Deployment estão certos. Faltaram StatefulSet e DaemonSet. Azure Functions/Lambda não usam Jobs do Kubernetes por baixo; a analogia de "execução com começo, meio e fim" está certa, mas o exemplo não. |
| K-16 · Storage | 0 | |
| K-17 · Labels e selectors | 0 | Labels selecionam; annotations **não** são usadas para relacionar componentes. Remover o label faz o ReplicaSet criar outro pod, e o antigo fica órfão e vivo. |
| K-18 · HPA | 0 | |
| K-19 · Do apply ao container | 0 | |
| K-20 · Controllers e operators | 0 | |
| K-21 · Como Services funcionam | 0 | |
| K-22 · Scheduling | 0 | |
| K-23 · NetworkPolicy | 0 | |
| K-24 · ServiceAccount e RBAC | 1 | Certo: SA é uma identidade, recebe permissões via RBAC, e você usa uma na prática no pipeline. Faltou como o pod a usa (token montado no pod) e o par **Role + RoleBinding**. |
| K-25 · Graceful shutdown | 0 | |
| K-26 · Disrupções | 0 | |
| K-27 · Segurança do pod | 1 | A ideia geral (limitar privilégios, evitar escalada) está certa, mas sem o que cada campo faz. |
| K-28 · Helm/Kustomize/GitOps | 0 | A analogia "Helm é como pip" é boa, mas é só uma parte de três. |

## Totais

| Bloco | Pontos | % |
|---|---|---|
| Kubernetes N1 (K-01 a K-06) | 5 / 12 | 42% |
| Kubernetes N2 (K-07 a K-18) | 4 / 24 | 17% |
| Kubernetes N3 (K-19 a K-28) | 2 / 20 | 10% |
| **Total** | **11 / 56** | **20%** |

## Leitura

- O que você sabe vem **da operação**: troubleshooting por sintoma, labels, request → Pending, OOM, SA no pipeline. É conhecimento real, mas sem o modelo de como as peças funcionam por baixo.
- A lacuna mais impactante para o seu dia a dia é **probes + rollout + Services/Ingress**. É o caminho exato que o tráfego e um deploy percorrem, e é onde estão os problemas que você resolve hoje.
