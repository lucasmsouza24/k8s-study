# Teoria — Kubernetes

Responda abaixo de cada pergunta, no bloco `>`. Livro fechado. `não sei` é uma resposta válida.

---

## Nível 1 — Fundamentos

### K-01 · Arquitetura

Liste os componentes do *control plane* e dos *worker nodes* e explique em uma frase o papel de cada um.

> não sei

### K-02 · Pod, ReplicaSet, Deployment

Qual a relação entre Pod, ReplicaSet e Deployment? Por que quase nunca se cria um Pod diretamente?

> um pod é o menor componente no k8s, ele contem o container ou conjunto de containers que especificamos. existem alguns tipos de pods, acredito que o mais comum seja o replicaSet (mas não sei a diferença de replicaset para outros tipos de pod), o deployment é um componente onde nós definimos o estado desejado (quantos pods quero pra minha aplicação por exemplo) e o deployment vai "ficar de olho" e provisionar pods para garantir que o estado atual está de acordo com a especificação. tenho ciencia de que meu conhecimento é limitado sobre esses componentes, eu só sei o suficiente para navegar, consultar e analisar problemas simples e acabei aprendendo em ambiente produtivo

### K-03 · Services

Quais os tipos de Service (`ClusterIP`, `NodePort`, `LoadBalancer`) e quando usar cada um? Como o Service sabe para quais Pods encaminhar o tráfego?

> não sei a diferença entre os tipos de service, lembro de já ter estudado em algum momento mas relamente não lembro. para as services encaminhar tráfego para os pods, o ideal é trabalhar com labels. são como tags que são especificadas tanto na definição das services quanto na definição dos pods (ou deployments que vão provisionar esses pods), os labels precisam ter o mesmo nome e valor, pra dar match.

### K-04 · ConfigMap vs Secret

Qual a diferença entre ConfigMap e Secret? Um Secret do Kubernetes é criptografado? Explique.

> config map é um componente que guarda valores de configuração, que podem ser lidos por outros componentes. secrets seguem uma lógica parecida, mas são específicos para valores secretos e que não podem ser expostos.

### K-05 · Namespaces

O que um namespace isola e o que ele **não** isola?

> um namespace é um isolamento lógico, componentes isolados por elas são services, deployments, pods, configmaps, secrets. algo que a namespace não isola é o node e nodepool.

### K-06 · Declarativo vs imperativo

Qual a diferença entre `kubectl create -f` e `kubectl apply -f`? E entre usar `kubectl edit` / `kubectl scale` e manter os YAMLs versionados no git?

> kubectl apply -f faz com que seja aplicado um arquivo yaml que esteja na máquina host como uma especificação de estado desejado, não sei qual a relação disso com o create. kubectl edit <componente> faz com que abra um notepad (ou outro editor de texto) com o yaml do componente em questão. pelo editor, é possível editar o yaml e salvar o novo estado desejado. já usei kubectl scale uma vez, por meio dele é possível também especificar um estado novo (um parametro específico como replicas: 1 ao inves de 3)

---

## Nível 2 — Uso no dia a dia

### K-07 · Requests e limits

Explique `requests` e `limits` de CPU e memória. O que acontece quando um container ultrapassa o limit de **CPU**? E o de **memória**? Qual dos dois o scheduler usa para decidir em qual nó colocar o Pod?

> request -> é o recurso mínimo necessário para a aplicação. independente do uso real, a aplicação vai alocar oo valor especificado em requests  
> limit -> é o recurso máximo que a applicação pode utilizar do node, necessariamente tem que ser maior ou igual à limits. o fator principal para decidir em qual nó alocar o pod é o request, pois ele especifica o mínimo para a aplicação funcionar. caso não tenha cpu/mem disponível em nenhum dos nodes, o pod vai ficar em estado pending

### K-08 · QoS

Quais são as classes de QoS de um Pod e como cada uma é definida? Qual a QoS do Deployment em `legacy/002-resource-management/.k8s/deployment.yaml`? Por que isso importa quando o nó fica sem memória?

> nao faço ideia do que seja isso

### K-09 · Probes

Explique `livenessProbe`, `readinessProbe` e `startupProbe`: o que o kubelet faz quando cada uma falha? Por que é uma má ideia a liveness probe checar se o banco de dados está acessível?

> não sei

### K-10 · Diagnóstico de status

Para cada status abaixo, diga a causa mais provável e os comandos que você usaria para investigar:

a) `Pending`
b) `ImagePullBackOff`
c) `CrashLoopBackOff`
d) `CreateContainerConfigError`
e) `Running`, mas `READY 0/1`
f) `OOMKilled`

> a) sem recurso disponível para criação do pod (cpu/mem)
>
> b) problemas na importação da imagem especificada no deployment/pod (dockerhub,acr,etc)
>
> c) aplicação quebrou e lançou alguma exeção de saída
>
> d) possivelmente alguma configuração errada no yaml do deployment/pod ou na imagem especificada
>
> e) aplicação rodando, não sei o que significa o ready
>
> f) OOM -> out of memory. a aplicação chegou a iniciar, mas durante a execução de algum processo acabou precisando de mais memória do que a especificada como mem limit.

### K-11 · Rolling update

Como funciona o rolling update de um Deployment? O que controlam `maxSurge` e `maxUnavailable`? Como você faz rollback e como vê o histórico de versões?

> sei que o rolling update é utilizado para subir novas versões da aplicação. é o processo ofinal do CI/CD de uma aplicação kubernetes. mas de fato não sei como funciona

### K-12 · DNS interno

Um Pod no namespace `pedidos` precisa chamar o Service `api-estoque` no namespace `estoque`, na porta 80. Qual URL ele usa? Qual o FQDN completo? Por que só `http://api-estoque` não funciona?

> não lembro de cabeça, mas sei que as services tem DNSs internos, acredito que seja algo pareciso com [http://api-estoque.estoque.service](http://api-estoque.estoque.service) ou algo assim

### K-13 · Ingress

Qual a diferença entre um Service `LoadBalancer` e um Ingress? O que é um *Ingress Controller* e por que criar um objeto `Ingress` sozinho não faz nada? Já ouviu falar da Gateway API?

> não seim

### K-14 · Atualização de ConfigMap

Uma aplicação lê configuração de um ConfigMap. O que acontece quando você altera o ConfigMap se ele estiver montado (a) como variável de ambiente; (b) como volume? Como forçar os pods a pegarem a nova configuração?

> não sei

### K-15 · Tipos de workload

Quando usar `Deployment`, `StatefulSet`, `DaemonSet`, `Job` e `CronJob`? Dê um exemplo real para cada.

> um job é um componente que provisiona pods com execuções de começo meio e fim, como uma aplicação que só precisa rodar baseada em eventos por exemplo (acredito que o azure functions e aws lambda tenha isso por tras dos panos) já o cronjob é um componente semelhante ao deployment, porém o cronjob provisiona jobs e não pods. os cronjobs possuem parametros de recorrência do scheduling para programar "de quanto em quanto tempo" preciso provisionar um job específico. o deployment provisiona pods que precisam estar sempre rodando, como aplicações web ou apis.

### K-16 · Storage

Explique PersistentVolume, PersistentVolumeClaim e StorageClass. O que é *dynamic provisioning*? O que significam os access modes `ReadWriteOnce` e `ReadWriteMany`?

> não sei

### K-17 · Labels e selectors

Qual a diferença entre labels e annotations? O que acontece se você remover manualmente (`kubectl label pod ... app-`) o label `app` de um Pod gerenciado por um Deployment cujo selector é `app: api`?

> acredito que ambos sejam utilizados para relacionar diferentes componentes, como direcionar requests feitas de uma service para um pod/deployment. mas não sei as diferenças

### K-18 · HPA

Como funciona o HorizontalPodAutoscaler? O que ele precisa para funcionar (componentes e configuração no Deployment)? Por que um HPA às vezes mostra `<unknown>/50%`?

> não sei

---

## Nível 3 — Por baixo do capô e produção

### K-19 · Do apply ao container

Descreva, passo a passo e citando os componentes envolvidos, tudo o que acontece desde `kubectl apply -f deployment.yaml` até o container estar rodando e recebendo tráfego por um Service.

> não faço a menor ideia

### K-20 · Controllers e operators

O que é o *reconciliation loop*? O que é um CRD e o que é um Operator? Cite um que você já usou (mesmo sem saber que era um).

> não sei

### K-21 · Como Services funcionam

O IP de um Service `ClusterIP` não pertence a nenhuma interface de rede. Como então o tráfego chega ao Pod? Qual o papel do kube-proxy e o que muda com CNIs baseadas em eBPF (como Cilium)?

> não sei

### K-22 · Scheduling

Explique `nodeSelector`, node affinity, pod anti-affinity, taints/tolerations e `topologySpreadConstraints`. Como você garantiria que as 3 réplicas de uma API fiquem em zonas de disponibilidade diferentes?

> não sei

### K-23 · NetworkPolicy

Qual o comportamento de rede padrão entre pods em um cluster sem NetworkPolicy? Escreva (de cabeça, pode errar a sintaxe) uma política *default deny* de ingress para um namespace. Por que uma NetworkPolicy pode não ter efeito nenhum em alguns clusters?

> não sei

### K-24 · ServiceAccount e RBAC

Como um Pod se autentica na API do Kubernetes? O que é o token montado em `/var/run/secrets/kubernetes.io/serviceaccount/`? Como você concede a um Pod permissão para listar ConfigMaps só do próprio namespace?

> serviceAccount são como usuários que podem ser definidos. permissões podem ser concedidas à esses usuários atraves de roles RBAC (read/create/delete/update de componentes). acredito que esses usuários podem ser utilizados por componentes dentro do k8s, mas no caso onde conheço, utilizo um service account para permitir meu processo de CI/CD (azure pipelines atravez de SC kubernetes) à fazer deploy da aplicação

### K-25 · Graceful shutdown

Durante todo deploy sua API retorna alguns erros 502/503 por alguns segundos, mesmo com readiness probe configurada. Explique a sequência de eventos quando um Pod é terminado (SIGTERM, remoção de endpoints, `terminationGracePeriodSeconds`, `preStop`) e por que esses erros acontecem. Como resolver?

> não sei

### K-26 · Disrupções

O que é um PodDisruptionBudget? O que acontece num `kubectl drain` (ou num upgrade de node pool) se a sua aplicação tem 1 réplica sem PDB? E com 2 réplicas e um PDB `minAvailable: 2`?

> não sei

### K-27 · Segurança do Pod

Explique os campos de `securityContext`: `runAsNonRoot`, `readOnlyRootFilesystem`, `allowPrivilegeEscalation` e `capabilities.drop: ["ALL"]`. O que são os Pod Security Standards (privileged / baseline / restricted)?

> sei que esses campos existem para limitar o que os pods tem permissão para fazer, e principalmente evitar privilege scalation, que pode ser um problema grave de segurança. mas não conheço no detalhe cada valor possível e quais são as configurações ideais

### K-28 · Empacotamento e entrega

O que é Helm (chart, release, values)? Qual a diferença para Kustomize? O que é GitOps e como ferramentas como ArgoCD/Flux mudam a forma de fazer deploy em relação a um pipeline que roda `kubectl apply`?

> helm é como um gerenciador de pacotes, eu o vejo como um pip, mas não sei usar muito bem. não sei a diferença para os outros citados e não sei o que é gitops
