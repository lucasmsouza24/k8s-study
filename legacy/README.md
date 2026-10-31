# Legacy — labs anteriores ao diagnóstico

Labs feitos entre março e setembro de 2026, antes da [avaliação diagnóstica](../avaliacoes/2026-10-diagnostico/03-resultado.md) e da reorganização do repo. Ficam aqui como registro do ponto de partida: foram feitos seguindo exemplos, sem o método atual (notas, prova, revisão).

Não são mantidos. Os caminhos e comandos funcionavam na época, mas os pipelines dependem de recursos Azure (ACR `acrstudy`, AKS `aks-study`, service connections) que podem não existir mais.

| Lab | O que fazia | Reaproveitar em |
|---|---|---|
| `001-config-maps-and-secrets` | API FastAPI lendo config de ConfigMap e Secret via env | Kubernetes 04 (config e secrets) |
| `002-resource-management` | Endpoints que consomem CPU (`/cpu-bound`) e vazam memória (`/memory`) para observar requests/limits | Kubernetes 05 (recursos e probes): ótimo para ver throttling e OOMKilled na prática |
| `003-security-scan` | Pipeline local com Trivy (fs, config, imagem, cluster) e securityContext restrito | Docker 04 (imagens seguras) e Kubernetes 11 (segurança de pods) |
| `004-aks` | Scripts para criar e destruir um AKS de estudo (tier Free, 1 nó) e comandos de node pool | AKS 01: cluster de estudo, ligado só durante as sessões |
| `005-aks-app-information` | API com variável de ambiente por stage, publicada no ACR e implantada no AKS via Azure Pipelines | AKS 03 (ACR e identidades) e CI/CD |
| `006-security/RBAC` | Teoria e 6 exercícios de RBAC | Kubernetes 09 (RBAC): os exercícios podem ser feitos como lab |
| `deployment-patterns/blue-green` | App React servida em dois Deployments (blue/green), alternando o selector do Service NodePort | Kubernetes 06 (rollout e estratégias de deploy) |
| `.k8s/namespaces.yaml` | Namespaces `hom` e `prd` | — |
| `azure-pipelines.yml`, `.azure/pipelines/` | Build/push para o ACR, criação do AKS e deploy via Azure DevOps | AKS 03 / CI/CD, se for recriar os pipelines |
| `topics/` | Rascunho de notas (vazio) | — |
