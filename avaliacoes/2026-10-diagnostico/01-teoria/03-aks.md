# Teoria — AKS

Responda abaixo de cada pergunta, no bloco `>`. Livro fechado. `não sei` é uma resposta válida.

A Parte B é diferente: é uma investigação **somente leitura** no cluster que você usa no trabalho. Ela mede se você entende o ambiente real com que lida no dia a dia.

---

## Parte A — Conceitos

### A-01 · Modelo de responsabilidade

No AKS, o que a Microsoft gerencia e o que é responsabilidade sua? Qual a diferença entre os tiers *Free*, *Standard* e *Premium* do control plane?

> azure -> segurança física, recursos contratados disponíveis, interfaces de rede
>
> eu -> código das aplicações, segurança das aplicações (dados), ambiente de onde vem a imagem, configurações de rede, configurações de infra (k8s), acesso à azure

### A-02 · Node pools

Qual a diferença entre *system* e *user* node pools? Por que é recomendado separar? O que é o *node resource group* (`MC_...`) e o que tem dentro dele?

> o próprio k8s precisa de um cluster com diversos componentes para funcionamento interno, por isso é recomendado ter um nodepool isolado para as aplicações. não sei o que é node resource group

### A-03 · Networking

Compare os modelos de rede do AKS: kubenet, Azure CNI (tradicional), Azure CNI Overlay e Azure CNI powered by Cilium. Qual o impacto de cada um no consumo de IPs da VNet?

> não faço a MENOR ideia

### A-04 · AKS + ACR

Em `legacy/004-aks/` você criou um cluster e depois fez o attach de um ACR. O que o `az aks update --attach-acr` faz por baixo dos panos? Qual identidade é usada para puxar a imagem?

> acredito que em algum nível permite comunicação entre o AKS e o ACR especificado, mas não conheço detalhes

### A-05 · Service LoadBalancer no AKS

Quando você cria um Service `type: LoadBalancer` no AKS, o que é criado no Azure e em qual resource group? Como você faria esse Service ser acessível apenas dentro da VNet?

> acredito que um load balancer com IP é criado no mesmo RG do AKS, mas de fato não tenho nenhuma certeza

### A-06 · Identidades

Explique a diferença entre: (a) a managed identity do cluster (control plane), (b) a kubelet identity, e (c) Microsoft Entra Workload Identity. Qual delas uma aplicação deve usar para ler um segredo do Key Vault, e por que não usar uma connection string num Secret do Kubernetes?

> a) com MI devidamente configurado, é possível usar a autenticação da SP somente com o valor do CLIENT_ID (uma vez que a aplicação esteja rodando no contexto certo, onde se tem a MI configurada)  
> b) não sei  
> c) WIF é um modelo onde não é necessário se preocupar com a expiração de secrets  
> eu usaria MI, por não ter risco de expor nada sem querer, secrets do kubernetes por mais que sejam seguras podem ser acessadas por pessoas com acesso.

### A-07 · Secrets com Key Vault

Como funciona o *Secrets Store CSI Driver* com o provider do Azure Key Vault? O segredo vira um Secret do Kubernetes?

> se vc estiver falando do akv2k8s, as secrets do AKS ficam sincronizadas com valores que vem diretamente do kv. 

### A-08 · Autenticação no cluster

Qual a diferença entre `az aks get-credentials` e `az aks get-credentials --admin`? O que é a integração com Microsoft Entra ID e o que é "Azure RBAC for Kubernetes Authorization"? Para que serve o `kubelogin`?

> não sei

### A-09 · Autoscaling

Qual a diferença entre o HPA, o Cluster Autoscaler e o KEDA? Num pico de tráfego, em que ordem eles atuam e o que pode dar errado (pense em quota de vCPU da subscription)?

> não sei

### A-10 · Upgrades

Como funciona o upgrade de um cluster AKS (control plane vs node pools)? O que é `max-surge`? Qual a diferença entre upgrade de versão do Kubernetes e upgrade de *node image*? O que são os *auto-upgrade channels*?

> não sei

### A-11 · Ingress no AKS

Quais as opções de ingress mais comuns no AKS (ex.: NGINX/application routing add-on, AGIC, Application Gateway for Containers)? Qual a diferença essencial entre um ingress controller rodando dentro do cluster e um fora dele?

> não sei

### A-12 · Observabilidade

Quais as opções de monitoramento no AKS (Container Insights, Managed Prometheus, Managed Grafana, diagnostic settings)? Onde você olharia os logs do control plane (ex.: `kube-apiserver`, `kube-audit`)?

> as opçoes que conheço são prometheus, grafana e elastic. mas não sei configurar e utilizar nenhum desses

---

## Parte B — Investigação do cluster do trabalho (somente leitura)

**Atenção**: use apenas comandos de leitura (`get`, `describe`, `az aks show`, `az ... list`). Nada de `apply`, `delete`, `edit`, `scale`. Se não tiver permissão para algo, anote "sem acesso" — isso também é informação útil.

Para cada item, escreva **a resposta e o comando que usou para descobrir**.

### B-01

Qual a versão do Kubernetes do cluster e dos node pools? Quantos node pools existem, de qual tipo (system/user) e qual o tamanho de VM?

> Não tenho permissão pra fazer isso no trabalho vou pular essa seção, só tenho acesso ao minikube na minha máquina mas pelo nível que eu estou, acredito que eu não saiba quase nada aqui



### B-02

Qual o network plugin (e plugin mode, se houver) e qual a network policy engine configurada?

>

### B-03

Como as imagens chegam ao cluster? (qual registry, como o cluster se autentica nele)

>

### B-04

Como o tráfego externo chega até as aplicações? (Ingress controller? LoadBalancer direto? App Gateway? Front Door?)

>

### B-05

Como as aplicações recebem configurações e segredos? (ConfigMap, Secret, Key Vault via CSI, variáveis no pipeline...)

>

### B-06

Como é feito o deploy? (pipeline que roda `kubectl apply`, Helm, ArgoCD/Flux...) Onde estão os manifests?

>

### B-07

O cluster tem autoscaler ligado? Algum Deployment tem HPA? Os Deployments da sua equipe definem requests/limits e probes?

>

### B-08

Onde ficam os logs e métricas das aplicações? Você consegue achar os logs de um pod que morreu ontem?

>
