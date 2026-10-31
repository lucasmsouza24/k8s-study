# Trilha — AKS

Diagnóstico de out/2026: **13%**, nível 0. Pontos cegos: integração com ACR. Você conhece o que usa (MI/WIF para o Key Vault, akv2k8s, separação de node pools); falta a infraestrutura em volta do cluster.

Começa na Fase 2, depois dos fundamentos de Kubernetes: quase tudo em AKS é "Kubernetes + como o Azure implementa isso".

| # | Módulo | Cobre | Fase | Status |
|---|---|---|---|---|
| 01 | O modelo do AKS: control plane gerenciado, tiers, node pools system/user, node resource group (`MC_`), acesso ao cluster (Entra ID, kubelogin, `--admin`) | A-01, A-02, A-08 | 2 | pendente |
| 02 | Rede no AKS: kubenet × Azure CNI × Overlay × Cilium, IPs da VNet, Service LoadBalancer, LB interno, opções de ingress | A-03, A-05, A-11 | 2 | pendente |
| 03 | Identidades, ACR e Key Vault: cluster × kubelet × workload identity, `--attach-acr`, Secrets Store CSI × akv2k8s | A-04, A-06, A-07 | 2 | pendente |
| 04 | Observabilidade: Container Insights, Managed Prometheus/Grafana, diagnostic settings, KQL | A-12 | 2 | pendente |
| 05 | Escala e upgrades: Cluster Autoscaler, KEDA, quotas, upgrades, node image, auto-upgrade channels | A-09, A-10 | 3 | pendente |

## Cluster de estudo

Você não tem acesso de leitura ao cluster do trabalho, então os labs de AKS usam um cluster próprio: `legacy/004-aks/scripts/create-aks.sh` cria um no tier Free com 1 nó.

**Custo**: o control plane Free não é cobrado, mas a VM do nó, o Load Balancer e os IPs são. Crie no começo da sessão e **destrua no fim** (`delete-rg.sh`). Se tiver acesso a uma subscription de estudo ou aos créditos do Visual Studio/Azure for Students, use-os.

## Referências

| Fonte | Tipo | Para quê |
|---|---|---|
| [Documentação do AKS](https://learn.microsoft.com/azure/aks/) — seção *Core concepts* | docs | Principal. Cada módulo corresponde a uma página de conceitos (cluster, rede, identidade, storage, escala) |
| [AKS baseline architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks) (Azure Architecture Center) | arquitetura de referência | Como a Microsoft recomenda montar um cluster de produção; base do projeto da Fase 3 |
| [mspnp/aks-baseline](https://github.com/mspnp/aks-baseline) | implementação de referência | A arquitetura acima em código, passo a passo |
| [Microsoft Learn — trilhas de AKS](https://learn.microsoft.com/training/) | cursos gratuitos com sandbox | Alguns módulos têm sandbox Azure gratuito, o que economiza o cluster de estudo |
| [AKS Engineering Blog](https://blog.aks.azure.com) e [Azure/AKS releases](https://github.com/Azure/AKS/releases) | blog e release notes | Novidades e mudanças (ex.: aposentadoria do kubenet) |
