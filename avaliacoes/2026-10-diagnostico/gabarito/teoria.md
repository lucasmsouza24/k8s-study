# Gabarito — Teoria

Para cada pergunta: os **pontos esperados** e o critério de nota. Nota 2 exige o mecanismo; nota 1 é a ideia certa sem o porquê.

---

## Docker

### D-01 · Container vs VM
- VM virtualiza **hardware** via hypervisor; cada VM tem **kernel próprio**.
- Container é um **processo** do host isolado; **compartilha o kernel** do host.
- Isolado: filesystem raiz, árvore de processos (PID), rede, hostname, IPC, usuários; recursos limitados por cgroups.
- Consequências: sobe em ms, ocupa pouco; isolamento mais fraco que VM; não dá para rodar um kernel diferente (container Linux no Windows/Mac roda dentro de uma VM, como no WSL2/Docker Desktop).

**2**: kernel compartilhado + pelo menos dois itens isolados. **1**: só "container é mais leve".

### D-02 · Imagem vs container
- Imagem: template **imutável**, um conjunto ordenado de camadas + configuração (env, cmd, user, portas).
- Container: instância em execução de uma imagem + uma **camada de escrita** própria (copy-on-write).
- Layer: diff de filesystem gerado por instruções que alteram arquivos (`RUN`, `COPY`, `ADD`). São endereçadas por hash, **compartilhadas** entre imagens e reaproveitadas no cache de build e no push/pull (só sobe/desce a camada que mudou). Um union filesystem (overlayfs) as sobrepõe.

### D-03 · CMD vs ENTRYPOINT
- `ENTRYPOINT`: o executável. `CMD`: argumentos padrão (ou o comando inteiro, se não houver ENTRYPOINT).
- `docker run img x y` substitui o `CMD`; `--entrypoint` substitui o ENTRYPOINT. Padrão comum: `ENTRYPOINT ["python", "app.py"]` + `CMD ["--port", "8000"]`.
- Forma exec: o processo roda direto e é o **PID 1**, recebe sinais.
- Forma shell: vira `/bin/sh -c "..."`; o **shell** é o PID 1 e normalmente **não repassa sinais** ao filho (ver D-15). Vantagem: expansão de variáveis.

**2**: inclui a questão dos sinais/PID 1 na forma shell.

### D-04 · EXPOSE
- **Não** publica nada. É documentação/metadata (usada por `docker run -P` e algumas ferramentas).
- `-p 8080:8000` cria o mapeamento NAT host:8080 → container:8000. Funciona com ou sem `EXPOSE`.
- Bônus: a aplicação precisa ouvir em `0.0.0.0`, não em `127.0.0.1`.

### D-05 · Persistência
- Arquivos ficam na camada de escrita: sobrevivem a `stop`/`start`, **somem no `docker rm`**.
- Volume: gerenciado pelo Docker (`/var/lib/docker/volumes/...`), independente da estrutura do host. Bom para dados (bancos).
- Bind mount: um diretório específico do host. Bom para desenvolvimento (hot reload) e para injetar config. Depende do host, tem problemas de permissão/UID.
- (tmpfs: em memória.)

### D-06 · COPY vs ADD
- `ADD` também baixa URLs e **extrai tar locais automaticamente**. `COPY` só copia.
- Recomendado: `COPY`, por ser explícito e previsível. Use `ADD` só quando quiser a extração do tar.

### D-07 · Cache de build
- a) Reexecuta `COPY app.py` em diante (EXPOSE/CMD só alteram metadata). O `pip install` vem do cache.
- b) Reexecuta `COPY requirements.txt` e tudo abaixo, incluindo o `pip install`.
- c) Qualquer alteração em qualquer arquivo invalida o `COPY . .` e **todo build reinstala as dependências**.
- Princípio: ordenar do que muda menos para o que muda mais. Uma camada invalidada invalida todas as seguintes.

**2**: acerta os três itens e entende a invalidação em cascata.

### D-08 · Multi-stage
- Vários `FROM` no mesmo Dockerfile. Os estágios de build têm toolchain (compilador, SDK, devDependencies) e o estágio final copia só o artefato (`COPY --from=build`).
- Exemplos: Go/Rust (binário em `scratch`/distroless), Java (JDK → JRE), **frontend Node → nginx servindo o `dist/`** (o caso do `blue-green/app1`), Python compilando wheels.
- Ganhos: imagem muito menor, menos superfície de ataque e menos CVEs (sem compilador, sem gerenciador de pacotes), segredos/arquivos de build ficam fora da imagem final.

### D-09 · Usuário root
- Sem user namespaces, o root do container é o **UID 0 do host**. Se houver um escape (vulnerabilidade no kernel/runtime, `--privileged`, capabilities extras, `docker.sock` ou diretório sensível montado), o atacante vira root no host.
- Mesmo sem escape: pode alterar binários da imagem, escrever em volumes como root e instalar ferramentas.
- O container é uma camada de defesa, não a única (defesa em profundidade).
- Evitar: criar usuário (`useradd -u 10001 app`), `USER 10001`, `COPY --chown`. No Kubernetes: `runAsNonRoot`.

### D-10 · .dockerignore
- Exclui arquivos do **contexto de build** enviado ao builder.
- Sem ele:
  - Contexto enorme (`node_modules`, `.git`, datasets) → build lento.
  - `COPY . .` leva o `node_modules` do host para a imagem, com binários nativos de outro SO/arquitetura.
  - **Vazamento** de `.env`, chaves e `.git` para dentro da imagem.
  - Cache invalidado por arquivos irrelevantes (logs, `.git`).

### D-11 · Tags
- `latest` é só um nome padrão, **não** significa "a mais recente". É mutável: não é reprodutível, não dá para saber o que está rodando, o rollback fica ambíguo e nós diferentes podem ter versões diferentes em cache. No Kubernetes, `latest` implica `imagePullPolicy: Always`.
- Tag = ponteiro **mutável**. Digest = hash do conteúdo, **imutável**: garante exatamente a mesma imagem.
- Boa prática: tag com versão/commit SHA, tags imutáveis no ACR, ou pin por digest.

### D-12 · Redes
- `docker network create app-net`, depois os dois containers com `--network app-net`. A API usa `REDIS_HOST=redis` (o nome do container).
- `localhost` não funciona: cada container tem o próprio namespace de rede.
- Bridge padrão: **sem DNS** por nome (só IP, ou o `--link` legado). User-defined: DNS embutido (nome/alias) e isolamento entre redes.

### D-13 · Secrets no build
- `ENV` fica gravado na config da imagem (`docker inspect`). `ARG` aparece no `docker history` das camadas que o usam. Quem faz pull da imagem lê.
- Um `RUN rm` depois não adianta: a camada anterior continua na imagem.
- Correto: BuildKit secrets, `RUN --mount=type=secret,id=token ...` com `docker build --secret id=token,env=TOKEN` (ou `--mount=type=ssh`). O segredo só existe durante aquele `RUN`.

**2**: explica por que vaza (history/inspect/camadas) **e** cita secret mount.

### D-14 · Primitivas do kernel
- **Namespaces**: isolam o que o processo *vê* (pid, net, mnt, uts, ipc, user, cgroup).
- **cgroups**: limitam e contabilizam o que o processo *usa* (CPU, memória, I/O, número de processos).
- **Union filesystem / overlayfs**: camadas + copy-on-write.
- **Capabilities**: dividem os poderes do root. **seccomp**: filtra syscalls. **AppArmor/SELinux**: controle de acesso mandatório.

**2**: namespaces e cgroups explicados corretamente (vê vs usa) + pelo menos mais um.

### D-15 · PID 1 e sinais
- `docker stop` manda SIGTERM ao PID 1, espera 10s (padrão) e manda SIGKILL. **137 = 128 + 9 (SIGKILL)**. O processo não está encerrando com o SIGTERM.
- Causas: forma shell ou script wrapper sem `exec` (o shell é o PID 1 e não repassa o sinal), ou a aplicação não trata SIGTERM.
- PID 1 é especial: o kernel **não aplica a ação padrão** dos sinais ao PID 1 do namespace, a menos que ele tenha instalado um handler. Um SIGTERM que mataria qualquer outro processo é ignorado. O PID 1 também precisa recolher processos zumbis.
- Correção: forma exec, `exec` no script, tratar SIGTERM na app, ou um init (`docker run --init`, tini, dumb-init).
- No Kubernetes é igual, com `terminationGracePeriodSeconds` (30s) no lugar dos 10s.

**2**: explica a regra especial do PID 1 e o 137 = SIGKILL. **1**: só "usar forma exec".

### D-16 · Limite de memória
- O cgroup de memória atinge o limite e o **OOM killer do kernel** mata o processo (não é o Docker que mata). Exit code 137.
- Identificar: `docker inspect -f '{{.State.OOMKilled}}'` = `true`, `docker events` (evento `oom`), `dmesg`/journal ("Memory cgroup out of memory").
- Bônus: runtimes com GC precisam de heap configurado relativo ao limit (JVM `MaxRAMPercentage`, Node `--max-old-space-size`).

### D-17 · Ecossistema de runtimes
- **OCI**: padrões de imagem, runtime e distribuição.
- **runc**: runtime de baixo nível que cria o processo isolado (namespaces/cgroups).
- **containerd**: runtime de alto nível que gerencia imagens, snapshots e ciclo de vida, e chama o runc.
- **Docker**: UX/plataforma (CLI, build, compose, redes) em cima do containerd.
- O Kubernetes fala com runtimes via **CRI**. O Docker Engine não implementava CRI, então existia um adaptador (dockershim), removido na 1.24. O AKS usa containerd.
- As imagens são padrão OCI/Docker v2, e qualquer runtime compatível as roda. O que quebrou foi só quem dependia do `docker.sock` nos nós.

### D-18 · Arquitetura de CPU
- A imagem foi construída para **arm64** e os nós são **amd64**: o binário não executa nessa CPU.
- Resolver: `docker build --platform linux/amd64`, ou buildx multi-arch (`--platform linux/amd64,linux/arm64`, gera um manifest list), ou buildar no CI.
- Verificar: `docker image inspect -f '{{.Architecture}}'`, `docker manifest inspect`.

### D-19 · Imagens base
- `python:3.12` (~1 GB): Debian completo com compiladores; compila qualquer dependência, mas é enorme e tem muitos CVEs.
- `slim` (~130 MB): Debian mínimo com **glibc**; compatível com as wheels `manylinux`. Padrão sensato.
- `alpine` (~50 MB): **musl**. Wheels `manylinux` não servem (precisa `musllinux` ou compilar), builds mais lentos, diferenças sutis (DNS, performance).
- Distroless: só o runtime, **sem shell nem gerenciador de pacotes**. Menor superfície e menos CVEs, mas o debug exige `kubectl debug`/ephemeral containers. Requer multi-stage.

**2**: cita a questão glibc vs musl e o trade-off debug vs segurança do distroless.

---

## Kubernetes

### K-01 · Arquitetura
- Control plane:
  - **kube-apiserver**: porta de entrada; autentica, autoriza, faz admission; é o único que fala com o etcd.
  - **etcd**: banco chave-valor com todo o estado do cluster.
  - **kube-scheduler**: escolhe o nó de cada pod pendente.
  - **kube-controller-manager**: roda os controllers (Deployment, ReplicaSet, Node, EndpointSlice...).
  - **cloud-controller-manager**: integra com o cloud (LB, rotas, discos).
- Nós:
  - **kubelet**: garante que os containers dos pods do nó rodem; executa as probes; reporta o status.
  - **kube-proxy**: regras de rede dos Services.
  - **Container runtime** (containerd) e plugin **CNI**.
- Add-on essencial: **CoreDNS**.

**2**: todos os principais, com papel correto. **1**: faltando 2 ou mais, ou papéis trocados.

### K-02 · Pod, ReplicaSet, Deployment
- O Deployment gerencia ReplicaSets (**um por versão do template**). O ReplicaSet garante N pods com aqueles labels.
- O Deployment adiciona rolling update, rollback e histórico.
- Um pod criado direto: se morrer ou o nó cair, **ninguém recria**; não escala nem atualiza.

### K-03 · Services
- **ClusterIP** (padrão): IP virtual interno, para comunicação entre serviços.
- **NodePort**: porta 30000–32767 em todos os nós → ClusterIP.
- **LoadBalancer**: provisiona um LB do cloud → NodePort → pods.
- (ExternalName; headless com `clusterIP: None`.)
- O **selector** de labels define os pods. O controller mantém **EndpointSlices** com os IPs dos pods **prontos** (readiness), e o kube-proxy programa as regras.

### K-04 · ConfigMap vs Secret
- Ambos guardam chave/valor e são injetados como env ou arquivo. Secret é para dado sensível.
- Secret é **base64** (encoding, não criptografia). No etcd, criptografia em repouso é configuração do cluster (o AKS criptografa o disco do etcd e oferece KMS com Key Vault).
- Diferenças práticas: RBAC separado, montado em tmpfs, não aparece no `describe`.
- Quem tem `get secrets` no namespace lê todos. Daí Key Vault + CSI, External Secrets, Sealed Secrets.

**2**: base64 ≠ criptografia, e o risco está no RBAC/etcd.

### K-05 · Namespaces
- Isola: **nomes**, escopo de RBAC, ResourceQuota/LimitRange; serve de escopo para NetworkPolicy.
- **Não** isola:
  - **Rede**: por padrão, pods de namespaces diferentes se falam livremente.
  - **Nós/kernel**: pods de namespaces diferentes dividem o mesmo nó.
  - **Recursos cluster-scoped**: Nodes, PVs, StorageClass, ClusterRoles, CRDs.
- Não é uma fronteira de segurança forte sozinho.

### K-06 · Declarativo vs imperativo
- `create`: imperativo, falha se o objeto já existe. `apply`: declarativo, cria ou atualiza com merge (last-applied-configuration / server-side apply).
- `edit`/`scale` mudam o estado vivo **sem registro** → drift. O próximo `apply` do git desfaz a mudança (ex.: `replicas`).
- Git + apply/GitOps: auditável, revisável em PR, reprodutível.

### K-07 · Requests e limits
- **Requests**: o mínimo reservado. É o que o **scheduler** usa (soma dos requests ≤ allocatable do nó) e o que define o peso de CPU.
- **Limits**: teto imposto via cgroups.
- Acima do limit de **CPU** → **throttling** (CFS quota): o processo fica lento, mas não morre.
- Acima do limit de **memória** → **OOMKilled** (137).
- O scheduler **não** olha o uso real nem os limits.

**2**: throttling vs OOM, e o scheduler usa requests.

### K-08 · QoS
- **Guaranteed**: todos os containers com requests = limits de CPU e memória.
- **Burstable**: algum request/limit definido, mas sem ser Guaranteed.
- **BestEffort**: nada definido.
- O Deployment `002` (50m/64Mi → 100m/128Mi) é **Burstable**.
- Na falta de memória no nó (eviction), o kubelet despeja primeiro BestEffort, depois Burstable acima dos requests, e por último Guaranteed (também afeta o `oom_score_adj`).

### K-09 · Probes
- **liveness** falhou → o kubelet **reinicia** o container.
- **readiness** falhou → o pod **sai dos endpoints** do Service, sem reinício.
- **startup**: enquanto não passa, liveness e readiness ficam desligadas; se estourar, reinicia. Serve para boot lento.
- Liveness checando o banco: se o banco cair, **todos os pods reiniciam em cascata**, o que não resolve nada (o problema é externo) e ainda gera uma tempestade de reconexões. A liveness deve checar só a saúde do próprio processo; dependências, se for o caso, vão na readiness (com cuidado).

**2**: os três comportamentos + o efeito cascata.

### K-10 · Diagnóstico de status
- a) **Pending**: nenhum nó atende (requests, nodeSelector/affinity, taints, PVC não bound). `describe pod` (evento FailedScheduling), `describe node` (Allocated resources), `get pvc`.
- b) **ImagePullBackOff**: imagem/tag inexistente, registry privado sem credencial, rede, rate limit. `describe pod` (eventos: "not found" vs "unauthorized").
- c) **CrashLoopBackOff**: o container sobe e morre repetidamente (erro da app, config faltando, comando errado, OOM, liveness). `logs --previous`, `describe` (Last State, Exit Code, Reason).
- d) **CreateContainerConfigError**: referência a ConfigMap/Secret ou chave inexistente. `describe pod`.
- e) **Running 0/1**: readiness falhando (porta/path errados, app ainda não pronta). `describe` (Readiness probe failed), `logs`, `port-forward`.
- f) **OOMKilled**: estourou o limit de memória. `describe` (Reason OOMKilled, 137), `kubectl top pod`, métricas.

**2**: 5 ou 6 corretos, com comandos. **1**: 3 ou 4.

### K-11 · Rolling update
- Cria um ReplicaSet novo e escala gradualmente, subindo o novo e descendo o antigo conforme a readiness.
- **maxSurge**: quantos pods **acima** de `replicas` podem existir. **maxUnavailable**: quantos podem ficar indisponíveis **abaixo** de `replicas`. Padrão 25%/25%.
- `kubectl rollout status | history | undo [--to-revision=N] | pause | restart`.
- `progressDeadlineSeconds` só marca o rollout como falho; **não faz rollback automático**.

### K-12 · DNS interno
- `http://api-estoque.estoque` (porta 80 é o padrão do HTTP). FQDN: `api-estoque.estoque.svc.cluster.local`.
- O nome curto usa os search domains do `/etc/resolv.conf` do pod, que começam pelo **namespace do próprio pod** (`pedidos.svc.cluster.local`). Ele procura `api-estoque.pedidos.svc.cluster.local`, que não existe.

### K-13 · Ingress
- Service LoadBalancer: LB **L4** (TCP/UDP), um IP por Service, não entende HTTP.
- Ingress: regras **L7** (host, path, TLS) que levam vários Services a um único ponto de entrada.
- O **Ingress Controller** (NGINX, AGIC, Traefik...) é quem lê os objetos e implementa as regras. Sem controller, o objeto Ingress não faz nada. O controller normalmente é exposto por um Service LoadBalancer.
- **Gateway API**: sucessora do Ingress. Mais expressiva, separa papéis (GatewayClass/Gateway/HTTPRoute). O projeto ingress-nginx da comunidade foi aposentado, o que acelera a migração.

### K-14 · Atualização de ConfigMap
- **Env**: lida na criação do container; mudanças no ConfigMap **não afetam pods rodando**.
- **Volume**: o kubelet atualiza os arquivos depois de um tempo (até ~1 min), mas a app precisa reler o arquivo. Com `subPath`, **nunca** atualiza.
- Forçar: `kubectl rollout restart`, ou um hash do ConfigMap numa annotation do template (checksum no Helm, `configMapGenerator` no Kustomize) para que a mudança gere um rollout.

### K-15 · Tipos de workload
- **Deployment**: stateless (APIs).
- **StatefulSet**: identidade estável (nome ordinal + DNS via headless Service), PVC por réplica, ordem de start/stop. Ex.: bancos, Kafka, Elasticsearch.
- **DaemonSet**: um pod por nó. Ex.: coletor de logs, node-exporter, CNI, drivers CSI.
- **Job**: roda até completar. Ex.: migração de banco.
- **CronJob**: Job agendado. Ex.: backup noturno.

### K-16 · Storage
- **PV**: o storage real (ex.: um Azure Disk), cluster-scoped.
- **PVC**: o pedido do usuário (tamanho, access mode, classe), namespaced; o pod referencia o PVC.
- **StorageClass**: o "tipo" de storage + provisioner (`disk.csi.azure.com`), `reclaimPolicy`, `volumeBindingMode` (WaitForFirstConsumer).
- **Dynamic provisioning**: criar o PVC faz o provisioner criar o disco e o PV automaticamente.
- **RWO**: leitura/escrita por **um nó** (Azure Disk). **RWX**: vários nós ao mesmo tempo (Azure Files, NFS).

### K-17 · Labels e selectors
- Labels: identificam e **selecionam** (Services, ReplicaSets, NetworkPolicy, `-l`). Annotations: metadata livre, não selecionável (change-cause, config de ingress, checksums).
- Remover o label: o ReplicaSet deixa de contar esse pod e **cria um novo** para repor. O pod antigo continua rodando, **órfão** e fora do Service. É uma técnica útil para isolar um pod problemático e investigar.

**2**: acerta que o pod continua vivo e um novo é criado.

### K-18 · HPA
- A cada ~15s, o HPA consulta a metrics API e calcula `desejado = ceil(atual × métrica atual / alvo)`.
- Utilização % = uso / **requests** → precisa de **requests** definidos e do **metrics-server** (CPU/memória) ou de um adapter para métricas custom.
- `<unknown>`: metrics-server ausente/não pronto, pods sem requests do recurso, pods recém-criados, selector errado.
- Bônus: stabilization window no scale down (5 min); `replicas` no manifest briga com o HPA a cada `apply`.

### K-19 · Do apply ao container
1. kubectl lê o kubeconfig e autentica no apiserver.
2. apiserver: authn → authz (RBAC) → admission (mutating/validating, PSA, webhooks) → validação → persiste no **etcd**.
3. O **deployment controller** (via watch) cria o ReplicaSet. O **replicaset controller** cria os Pods (ainda sem nó).
4. O **scheduler** filtra e pontua os nós e faz o binding (`nodeName`).
5. O **kubelet** do nó vê o pod e chama o runtime via **CRI**: pull da imagem, sandbox (pause), **CNI** atribui o IP, monta volumes (CSI), roda os init containers e depois os containers.
6. O kubelet roda as probes e reporta o status. Quando fica Ready, o controller de **EndpointSlice** adiciona o IP do pod.
7. O **kube-proxy** de cada nó atualiza as regras. O **CoreDNS** resolve o nome do Service e o tráfego chega ao pod.

**2**: apiserver/etcd, cadeia de controllers, scheduler, kubelet/CRI/CNI, endpoints/kube-proxy. **1**: faltando 2 ou mais elos.

### K-20 · Controllers e operators
- Reconciliation loop: comparar continuamente o desejado (`spec`) com o atual (`status`) e agir para convergir (level-triggered, via watch).
- **CRD**: estende a API com novos tipos. **Operator**: CRD + controller que codifica conhecimento operacional (provisionar, fazer backup, fazer upgrade).
- Exemplos: cert-manager, Prometheus Operator (ServiceMonitor), ArgoCD (Application), KEDA (ScaledObject), Secrets Store CSI (SecretProviderClass), CloudNativePG, Strimzi.

### K-21 · Como Services funcionam
- O kube-proxy em cada nó observa Services e EndpointSlices e programa o **netfilter**: no modo iptables, um DNAT para um dos IPs de pod (escolha probabilística); no modo IPVS ou nftables, uma tabela de balanceamento no kernel. O pacote para ClusterIP:porta é reescrito para PodIP:targetPort **no próprio nó de origem**; o conntrack mantém a conexão.
- O CNI garante o roteamento pod a pod entre nós.
- eBPF (Cilium): substitui o kube-proxy, balanceando com programas eBPF no kernel. Mais eficiente em escala, com NetworkPolicy L3–L7 e observabilidade (Hubble). No AKS: Azure CNI powered by Cilium.

**2**: DNAT feito localmente pelas regras do kube-proxy. **1**: "o kube-proxy faz o balanceamento" sem mecanismo (ou achando que é um proxy no caminho).

### K-22 · Scheduling
- **nodeSelector**: labels exatos do nó. **Node affinity**: versão expressiva (required/preferred, operadores).
- **Pod (anti-)affinity**: posiciona em relação a outros pods, por `topologyKey` (hostname, zona).
- **Taints** repelem; **tolerations** permitem, mas **não atraem**. Para um pool dedicado: taint + toleration + affinity.
- **topologySpreadConstraints**: distribui uniformemente entre domínios (`maxSkew`, `topologyKey`, `whenUnsatisfiable`).
- 3 zonas: node pool com `--zones 1 2 3` + `topologySpreadConstraints` com `topologyKey: topology.kubernetes.io/zone`, `maxSkew: 1`, `DoNotSchedule` (ou anti-affinity required por zona). Cuidado: Azure Disk LRS é zonal e amarra o pod à zona do disco.

### K-23 · NetworkPolicy
- Padrão: **tudo liberado**, inclusive entre namespaces.
- Default deny de ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: minha-app
spec:
  podSelector: {}
  policyTypes: ["Ingress"]
```

- Quem aplica a política é a **CNI/policy engine** (Calico, Cilium, Azure NPM). Sem suporte, o objeto é aceito e **ignorado** em silêncio.
- Bônus: as políticas são aditivas (allow-list); negar egress exige liberar o DNS.

### K-24 · ServiceAccount e RBAC
- Todo pod roda com uma ServiceAccount (`default` se não for especificada). O kubelet monta um **token projetado** (JWT com audiência, expiração e rotação, vinculado ao pod) + `ca.crt` + `namespace`.
- O client usa o token como Bearer → identidade `system:serviceaccount:<ns>:<sa>` → RBAC.
- Para listar ConfigMaps: SA + **Role** (`apiGroups: [""]`, `resources: [configmaps]`, `verbs: [get, list, watch]`) + **RoleBinding**, e `serviceAccountName` no pod.
- Bônus: `automountServiceAccountToken: false` quando o pod não precisa; esse mesmo token é a base do Workload Identity.

### K-25 · Graceful shutdown
- Ao deletar o pod, ele entra em Terminating e **duas coisas acontecem em paralelo**:
  - O kubelet roda o `preStop` e depois envia **SIGTERM**.
  - O pod é removido dos EndpointSlices, e kube-proxy/ingress de cada nó atualizam suas regras **com atraso**.
- Se a app para de aceitar conexões antes de todos pararem de mandar tráfego, surgem 502/503. Uma app que não trata SIGTERM é morta com SIGKILL depois do `terminationGracePeriodSeconds` (30s), com requisições em andamento.
- A readiness não ajuda aqui: a remoção dos endpoints já acontece pelo Terminating.
- Solução:
  - `preStop` com sleep de 5–15s (ou `lifecycle.preStop.sleep` nativo) para dar tempo à propagação.
  - Graceful shutdown na app: parar de aceitar, terminar as requisições em andamento, fechar keep-alives.
  - `terminationGracePeriodSeconds` maior que preStop + drain.
  - `maxUnavailable: 0`.

**2**: explica a **corrida** entre SIGTERM e remoção de endpoints e propõe o preStop. Pergunta típica de nível avançado.

### K-26 · Disrupções
- O PDB limita disrupções **voluntárias** (drain, upgrade, Eviction API), via `minAvailable` ou `maxUnavailable`. Não protege contra queda de nó ou OOM.
- 1 réplica sem PDB: o drain despeja o pod → **downtime** até ele ficar pronto em outro nó.
- 2 réplicas com `minAvailable: 2`: disruptions allowed = 0 → o drain fica **travado** e o upgrade do node pool falha ou fica preso. Use `minAvailable: 1` ou `maxUnavailable: 1`.

### K-27 · Segurança do Pod
- `runAsNonRoot`: o kubelet recusa iniciar o container se o UID for 0. Requer UID **numérico** na imagem ou `runAsUser`.
- `readOnlyRootFilesystem`: rootfs só leitura (use `emptyDir` para `/tmp`).
- `allowPrivilegeEscalation: false`: `no_new_privs`, impede ganhar privilégio via setuid.
- `capabilities.drop: ["ALL"]`: remove as capabilities Linux; adicione só as necessárias.
- **PSS**: privileged (sem restrição) / baseline (bloqueia escalações conhecidas: privileged, hostNetwork, hostPath...) / restricted (non-root, drop ALL, seccomp RuntimeDefault...). Aplicados pelo **Pod Security Admission** via labels no namespace (enforce/audit/warn). No AKS, também Azure Policy.

### K-28 · Empacotamento e entrega
- **Helm**:
  - chart = templates + `values.yaml`
  - release = instância instalada, com histórico, upgrade e rollback
  - values = parametrização por ambiente
- **Kustomize**: sem templates; YAML puro numa base + overlays com patches. Embutido no kubectl (`apply -k`).
- **GitOps**: o git é a fonte da verdade. Um agente **dentro** do cluster (ArgoCD/Flux) **puxa** e reconcilia continuamente, detectando e corrigindo drift. O pipeline não precisa de credencial do cluster e o rollback vira `git revert`.
- Pipeline com `kubectl apply`: **push**, aplica uma vez e não detecta drift.

---

## AKS — Parte A

### A-01 · Modelo de responsabilidade
- A Microsoft gerencia o **control plane**: apiserver, etcd, scheduler, controllers (disponibilidade, patches, backup do etcd). Você não vê essas VMs.
- Você cuida de:
  - nós (VMs na **sua** subscription, que você paga)
  - disparar ou configurar os upgrades
  - patching do SO dos nós (configurável)
  - workloads, rede, segurança, add-ons e capacidade
- Tiers:
  - **Free**: sem SLA financeiro, para dev/test.
  - **Standard**: SLA do apiserver (99,95% com AZ) e escala para clusters grandes.
  - **Premium**: Standard + **LTS** (suporte estendido de versão).

### A-02 · Node pools
- **System**: pods críticos (CoreDNS, metrics-server, konnectivity, CSI). Todo cluster precisa de pelo menos um. **User**: aplicações.
- Separar evita que uma app sem limits afogue os componentes do sistema e permite VM sizes e escalas diferentes. Use o taint `CriticalAddonsOnly=true:NoSchedule` no pool de sistema.
- **Node resource group** (`MC_<rg>_<cluster>_<região>`): gerenciado pelo AKS. Contém VMSS, discos (inclusive dos PVs), NICs, Load Balancer, IPs públicos, NSG, route table e a kubelet identity. Não mexa manualmente.

### A-03 · Networking
- **kubenet**:
  - nós com IP da VNet; pods com CIDR privado + NAT/route table
  - economiza IPs, mas tem limitações
  - **em processo de aposentadoria**
- **Azure CNI tradicional**:
  - **cada pod recebe IP da subnet**: diretamente roteável
  - consome muitos IPs (max-pods × nós) e o planejamento de subnet é difícil
  - existe a variante com pod subnet dinâmica
- **Azure CNI Overlay**:
  - pods num CIDR overlay fora da VNet; só os nós consomem IP da VNet
  - escala bem; é o recomendado hoje
- **Azure CNI powered by Cilium**:
  - dataplane eBPF sobre overlay ou pod subnet
  - substitui o kube-proxy, com NetworkPolicy e observabilidade integradas

**2**: entende que a diferença central é **de onde vem o IP do pod** e o impacto na VNet.

### A-04 · AKS + ACR
- Cria um role assignment **AcrPull** no ACR para a **kubelet identity** (a managed identity dos nós/VMSS).
- O containerd do nó usa essa identidade para obter o token do ACR. **Não precisa de imagePullSecrets**.
- Quem roda o comando precisa de permissão para criar role assignments (Owner/User Access Administrator).

### A-05 · Service LoadBalancer no AKS
- O cloud-controller-manager configura o **Azure Load Balancer Standard** do cluster, que fica no **node resource group (MC_)**: frontend IP (cria um Public IP), regras de balanceamento, health probes para os nós e regras de NSG.
- Interno: annotation `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` → IP privado da subnet.

### A-06 · Identidades
- (a) **Cluster identity**: o AKS usa para gerenciar recursos Azure (LB, IPs, discos, rotas).
- (b) **Kubelet identity**: atribuída aos nós; puxa do ACR. Em tese, qualquer pod do nó alcança o IMDS, por isso **não deve ser usada pela app**.
- (c) **Workload Identity**: por aplicação. A ServiceAccount é **federada** com uma managed identity/app registration no Entra, e o token projetado da SA (emitido pelo OIDC issuer do cluster) é trocado por um token do Entra.
- A app deve usar **Workload Identity** + papel no Key Vault (Key Vault Secrets User).
- Connection string em Secret: segredo de longa duração, legível por quem tem `get secrets`, rotação manual, risco de ir parar no git. Com identidade não há segredo para gerenciar.

**2**: diferencia as três e justifica a Workload Identity.

### A-07 · Secrets com Key Vault
- Add-on `azure-keyvault-secrets-provider` (DaemonSet).
- Você cria um **SecretProviderClass** (vault, objetos, identidade) e o pod monta um volume CSI que o referencia. Na inicialização do pod, os segredos são buscados e montados **como arquivos**.
- **Não** vira Secret do Kubernetes por padrão. Com `secretObjects`, sincroniza para um Secret (útil para env vars), que só existe enquanto algum pod monta o volume.
- Rotação: autorotation atualiza o arquivo; env vars não se atualizam.

### A-08 · Autenticação no cluster
- Com Entra ID integrado, `get-credentials` gera um kubeconfig que usa **kubelogin**: cada pessoa autentica com a própria identidade (auditoria, RBAC por grupo).
- `--admin`: certificado de **cluster-admin** estático que ignora o Entra (break-glass). Pode ser desabilitado (`--disable-local-accounts`).
- Entra integration: autenticação via Entra + autorização com RBAC do Kubernetes (bindings para object IDs de grupos).
- Azure RBAC for Kubernetes: autorização via **role assignments do Azure** (AKS RBAC Reader/Writer/Admin) no escopo do cluster ou namespace.
- kubelogin: plugin exec do client-go que obtém o token do Entra.

### A-09 · Autoscaling
- **HPA** escala pods. **Cluster Autoscaler** escala nós quando há pods **Pending** por falta de recursos (olha **requests**, não o uso real) e remove nós ociosos. **KEDA** escala por eventos (fila do Service Bus, lag do Kafka, cron), inclusive **para zero**, gerenciando um HPA por baixo.
- Ordem: a métrica sobe → o HPA aumenta as réplicas → pods Pending → o CA cria nós (minutos) → pods agendados.
- O que pode dar errado:
  - **quota de vCPU** da subscription/região
  - `maxCount` do pool atingido
  - IPs da subnet esgotados (CNI tradicional)
  - SKU sem capacidade na zona
  - requests mal definidos
- Bônus: Node Auto Provisioning (Karpenter).

### A-10 · Upgrades
- Primeiro o control plane, depois os node pools, **uma minor por vez**.
- Nos nós: cria nó(s) **surge** na versão nova, faz cordon + drain de um antigo (respeitando PDBs), remove e repete.
- `max-surge`: quantos nós extras por vez. Mais rápido, mas consome mais quota e IPs.
- **Node image upgrade**: atualiza o SO/containerd/kernel dos nós sem mudar a versão do Kubernetes.
- **Auto-upgrade channels**:
  - do cluster: none/patch/stable/rapid/node-image
  - do SO dos nós: None/Unmanaged/SecurityPatch/NodeImage
  - combinados com planned maintenance windows
- Suporte de versões N-2 (LTS no Premium).

### A-11 · Ingress no AKS
- **Application routing add-on** (NGINX gerenciado, integra com Azure DNS e Key Vault). NGINX/Traefik self-managed via Helm. **AGIC** (configura um Application Gateway externo). **Application Gateway for Containers** (sucessor do AGIC, com Gateway API). Ingress gateway do add-on de Istio.
- In-cluster: o tráfego entra por um Azure LB L4, e o proxy L7 **roda como pods** (consome recursos do cluster; você escala).
- Out-of-cluster: o proxy L7 é um **serviço gerenciado do Azure** (com WAF) e manda tráfego direto aos pods. O controller no cluster só traduz Ingress/Gateway em configuração do Azure.

### A-12 · Observabilidade
- **Container Insights**: agente → Log Analytics (logs de stdout/stderr em `ContainerLogV2`, inventário, eventos; consulta via KQL).
- **Managed Prometheus**: métricas no Azure Monitor workspace. **Managed Grafana**: dashboards.
- Logs do control plane (`kube-apiserver`, `kube-audit`, `kube-audit-admin`, controller-manager, scheduler, cluster-autoscaler) **não vêm habilitados**: é preciso criar uma **diagnostic setting** no recurso AKS para enviar ao Log Analytics (tabelas `AKSControlPlane`/`AKSAudit`, ou `AzureDiagnostics`).
- `kubectl get events` guarda só ~1h.

---

## AKS — Parte B

Critério: **2** = resposta correta **e** o comando/caminho para descobrir; **1** = sabe a resposta mas não como verificar (ou o contrário); **0** = não sabe.

Comandos de referência:

| Item | Onde olhar |
|---|---|
| B-01 | `az aks show -g RG -n NOME --query "{versao:kubernetesVersion,atual:currentKubernetesVersion,tier:sku.tier}"` · `az aks nodepool list -g RG --cluster-name NOME -o table` · `kubectl get nodes -L agentpool,kubernetes.azure.com/mode,node.kubernetes.io/instance-type` |
| B-02 | `az aks show -g RG -n NOME --query networkProfile` (`networkPlugin`, `networkPluginMode`, `networkPolicy`, `networkDataplane`, `outboundType`) · `kubectl get pods -n kube-system` (cilium? azure-npm? calico?) |
| B-03 | `kubectl get pods -A -o jsonpath='{..image}' \| tr ' ' '\n' \| sort -u` · `imagePullSecrets` nos pods · `az aks show --query identityProfile.kubeletidentity` · `az aks check-acr -g RG -n NOME --acr X.azurecr.io` |
| B-04 | `kubectl get ingress,ingressclass -A` · `kubectl get svc -A \| grep LoadBalancer` · `kubectl get gateway,httproute -A` · `az aks show --query "ingressProfile"` |
| B-05 | `envFrom`/`valueFrom`/`volumes` nos Deployments · `kubectl get secretproviderclass -A` · `az aks show --query addonProfiles` |
| B-06 | YAMLs do pipeline · `helm list -A` · `kubectl get ns` (argocd? flux-system?) · `kubectl get deploy -o yaml` (labels `app.kubernetes.io/managed-by`) |
| B-07 | `az aks nodepool list --query "[].{nome:name,auto:enableAutoScaling,min:minCount,max:maxCount}" -o table` · `kubectl get hpa -A` · `kubectl get deploy -n NS -o yaml` (resources, probes) |
| B-08 | Log Analytics/Container Insights (`ContainerLogV2 \| where PodName startswith "x"`) · `kubectl logs --previous` só cobre o último restart do mesmo pod; os logs de um pod deletado só existem se foram enviados para algum lugar |

---

## Cenários

### C-01 · Deploy que não sobe
- a) O rolling update só derruba pods antigos à medida que os novos ficam **Ready**. Os novos nunca ficaram, então os antigos continuaram servindo (com `maxUnavailable > 0`, um pouco menos de capacidade). O pipeline "passou" porque não espera `rollout status`: é uma melhoria a fazer.
- b) Investigação:
  - `get pods`, depois `describe pod` (Last State, Exit Code, Reason, eventos)
  - `logs --previous`
  - **diff entre as versões**: imagem, env, ConfigMap/Secret novos, probes, recursos
  - dependências: config faltando, migração, permissão de identidade/Key Vault, OOM
  - rodar a imagem localmente com a mesma config
- c) `kubectl rollout undo` resolve na hora, mas o ideal é reverter no git/pipeline para não gerar drift.

**2**: os três itens, com investigação ordenada (eventos → logs → diff).

### C-02 · Lentidão intermitente
- **CPU throttling**: a média de 50% esconde rajadas. O CFS aplica a quota em janelas de 100ms, e uma rajada estoura a quota e trava o processo até a próxima janela. Ver `container_cpu_cfs_throttled_periods_total`; gráficos com resolução de 1 min mascaram o problema.
- Outras hipóteses (e como verificar):
  - GC/memória perto do limit (métricas de memória e GC)
  - dependências lentas: banco, APIs (tracing com App Insights/OpenTelemetry)
  - **DNS** (`ndots: 5` gera várias consultas; CoreDNS sobrecarregado)
  - **SNAT port exhaustion** no outbound do Azure LB (métricas do LB / NAT Gateway)
  - poucos workers ou um event loop bloqueado (uvicorn com 1 worker)
  - pool de conexões esgotado
  - vizinho barulhento no nó (requests mal definidos)
  - I/O de disco do nó
  - HPA lento em picos
- Correlacionar os horários com tráfego, deploys e jobs.

**2**: throttling explicado + 3 outras hipóteses, cada uma com uma forma de verificar.

### C-03 · "Funciona no meu Docker"
Pelo menos cinco:
1. **Arquitetura** (arm64 × amd64).
2. **Config/env/secrets** ausentes ou diferentes.
3. **Probes** com porta/path errados ou rígidas demais para o tempo de boot.
4. **Limits** baixos (OOM/throttling no boot).
5. **securityContext/PSS**: non-root, rootfs só leitura, e a app tenta escrever em disco.
6. **Rede**: dependência acessível do notebook (VPN, localhost) mas não do cluster; NetworkPolicy; DNS.
7. **Imagem diferente**: a imagem local não é a do registry, `latest`/`IfNotPresent` com cache no nó.
8. `command`/`args` sobrescritos no manifest.
9. Volumes montados localmente.

Verificar com: `describe`, `logs`, `kubectl exec ... env`, `kubectl debug`, `port-forward`, e comparando o digest da imagem local com o `imageID` do pod.

**2**: 5 ou mais causas plausíveis, com forma de verificação.

### C-04 · Pending após escala
- Hipóteses:
  - **quota de vCPU** da região/família esgotada
  - `maxCount` do pool atingido
  - **IPs da subnet** esgotados
  - SKU sem capacidade na zona (allocation failure)
  - pods com nodeSelector/affinity/tolerations que nenhum pool atende (o CA não cria um nó que não resolveria)
  - request maior que o maior nó
  - PVC zonal
  - ResourceQuota (aí o pod nem é criado: aparece nos eventos do ReplicaSet)
- Onde verificar:
  - `describe pod` (FailedScheduling, **NotTriggerScaleUp** com o motivo)
  - `kubectl -n kube-system get configmap cluster-autoscaler-status -o yaml`
  - logs do cluster-autoscaler (diagnostic settings)
  - `az vm list-usage -l REGIAO -o table`
  - Activity Log da VMSS
  - `az aks nodepool show`

**2**: quota/maxCount/IPs + onde ver o motivo do CA.

### C-05 · Desenho de um ambiente
Pontos esperados:
- **API**:
  - Deployment com ≥ 2–3 réplicas espalhadas por zonas, Service ClusterIP
  - Ingress/Gateway (App Routing ou App Gateway for Containers com WAF), TLS
  - HPA, PDB, probes, requests/limits
- **Worker**:
  - Deployment escalado por **KEDA** pelo tamanho da fila
  - graceful shutdown (peek-lock, completar só depois de processar)
  - idempotência e dead-letter queue
- **PostgreSQL fora do cluster**: Azure Database for PostgreSQL Flexible Server (backup, HA e patch gerenciados), com private endpoint. StatefulSet de banco em produção só com motivo forte.
- **Segredos/identidade**: Workload Identity para Service Bus e Postgres (autenticação Entra, sem senha), Key Vault + CSI para o que for segredo de verdade, nada no git.
- **Cluster**:
  - pools system/user, zonas, autoscaler, tier Standard
  - Azure CNI Overlay (+Cilium), NetworkPolicy, NAT Gateway para egress
  - janelas de manutenção
- **Entrega**: ACR com attach, tags imutáveis, scan; CI build/push; CD via Helm/Kustomize ou GitOps.
- **Monitoramento**:
  - Container Insights, Managed Prometheus + Grafana, tracing (App Insights/OpenTelemetry)
  - alertas: 5xx, latência, profundidade da fila/DLQ, restarts, OOM, throttling, pressão nos nós
  - logs do control plane

**2**: banco gerenciado + identidade sem segredo + escala do worker por fila + exposição + monitoramento, com justificativas. **1**: funcional mas com lacunas (ex.: connection string em Secret, banco no cluster sem justificativa, worker escalado por CPU).
