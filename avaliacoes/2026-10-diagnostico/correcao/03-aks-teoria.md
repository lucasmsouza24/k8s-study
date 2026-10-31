# Correção — Teoria AKS

Corrigido em 30/10/2026.

## Parte A — Notas

| Pergunta | Nota | Comentário |
|---|---|---|
| A-01 · Responsabilidade | 0 | Faltou o ponto central: a Microsoft gerencia o **control plane** (apiserver, etcd, scheduler), e as VMs dos nós ficam na **sua** subscription, sob sua responsabilidade (versão, upgrades). Os tiers não foram respondidos. |
| A-02 · Node pools | 1 | A ideia de separar o sistema das aplicações está certa. O node resource group (`MC_...`) é onde o AKS cria as VMs dos nós, discos, load balancer e IPs. |
| A-03 · Networking | 0 | |
| A-04 · AKS + ACR | 0 | O `--attach-acr` dá o papel **AcrPull** à **kubelet identity** (a identidade dos nós), que é quem puxa as imagens. |
| A-05 · Service LoadBalancer | 1 | Certo que é criado um Load Balancer com IP. Errado o lugar: ele fica no **node resource group (`MC_...`)**, não no RG do AKS. A parte do LB interno ficou sem resposta. |
| A-06 · Identidades | 1 | A conclusão está certa (identidade em vez de segredo, porque o Secret pode ser lido por quem tem acesso) e você conhece MI e WIF na prática. Faltou diferenciar as três: a (a) descrita é a MI de uma aplicação, não a do cluster; a (b) ficou sem resposta. Para pods, a resposta esperada é a **Workload Identity**, que é justamente a forma de um pod usar uma MI de modo seguro. |
| A-07 · Secrets Store CSI | 0 | O akv2k8s é **outra ferramenta**, que faz um trabalho parecido. Vale saber se o seu trabalho usa o akv2k8s ou o CSI driver: é uma ótima pergunta para levar ao time. |
| A-08 · Autenticação | 0 | |
| A-09 · Autoscaling | 0 | |
| A-10 · Upgrades | 0 | |
| A-11 · Ingress no AKS | 0 | |
| A-12 · Observabilidade | 0 | Prometheus, Grafana e Elastic são ferramentas genéricas. Faltaram as opções do AKS (Container Insights, Managed Prometheus) e os logs do control plane (diagnostic settings). |

**Total Parte A: 3 / 24 (13%)**

## Parte B — Não feita

Você não tem acesso de leitura ao cluster (`az aks show`, recursos de cluster). Mesmo assim, alguns itens dá para responder **sem** esse acesso, olhando o repositório e o pipeline da sua aplicação:

- **B-03**: de onde vem a imagem (o registry no YAML do pipeline/manifest)
- **B-05**: como os segredos chegam (akv2k8s? CSI? variáveis do pipeline?)
- **B-06**: como é feito o deploy (Azure Pipelines com quê: `kubectl apply`, Helm?)
- **B-08**: onde você olha os logs hoje

Não é obrigatório, mas essas respostas ajudam a ancorar o estudo no seu ambiente real.

## Leitura

- O que você sabe de AKS é exatamente o que você **usa**: MI/WIF para chegar ao Key Vault, akv2k8s, a separação de node pools.
- A lacuna maior é a **infraestrutura em volta do cluster**: rede (CNI, LB, IPs), identidades e como o tráfego entra. Esse é o mesmo território da tarefa de DNS + certificado que você evita, ou seja, ela é sintoma dessa lacuna, não um tópico isolado.
