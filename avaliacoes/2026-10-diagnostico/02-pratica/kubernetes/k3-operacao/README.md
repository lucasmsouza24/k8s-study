# K3 — Operação

Tarefas do dia a dia de quem opera um cluster. A ordem importa: faça na sequência e leia cada passo inteiro antes de executar.

## Preparação

```bash
make setup                          # namespace aval-k3, Deployment e Service "web" (nginx:1.26-alpine)
minikube addons enable metrics-server
```

## Tarefas

### 1. Estratégia de rollout
Altere o Deployment para que o rolling update suba **no máximo 1 pod extra** por vez e **nunca** fique com menos pods prontos do que o número de réplicas.

### 2. Atualização
Atualize a imagem para `nginx:1.27-alpine` **usando comandos imperativos** (sem editar o arquivo) e registre o motivo da mudança como `atualiza para 1.27`, de forma que ele apareça em `kubectl rollout history`. Espere o rollout terminar.

### 3. Atualização com problema
Atualize a imagem para `nginx:9.9.9-alpine` (essa tag não existe), registrando o motivo `versao quebrada`. **Não corrija ainda**: observe e responda as perguntas da seção "Perguntas" sobre esse passo.

### 4. Rollback
Volte para a revisão com `nginx:1.27-alpine` usando o mecanismo de rollback do Kubernetes (não use `set image` de novo).

### 5. Autoscaling
Crie um HPA `web` que mantenha entre **2 e 6** réplicas, mirando **60%** de uso de CPU. Ele precisa estar **funcionando** de fato (métrica atual aparecendo em `kubectl get hpa`, não `<unknown>`).

> Atenção: se você precisar mudar algo no Deployment para isso, lembre do que fez nos passos 2–4.

### 6. RBAC
Crie uma ServiceAccount `auditor` no namespace `aval-k3` que possa **apenas**:
- ver (get, list, watch) pods e deployments do namespace `aval-k3`
- ler logs de pods do namespace `aval-k3`

Ela **não** pode apagar nada, ler Secrets, nem ver nada fora do namespace.

### 7. NetworkPolicy
Crie uma NetworkPolicy que permita acesso aos pods `app: web` na porta 80 **somente** a partir de pods com o label `role: frontend` (do mesmo namespace). Qualquer outro pod não deve conseguir acessar.

## Verificação

```bash
make check
```

## Perguntas (responda aqui)

**Passo 2: qual comando você usou para registrar o motivo da mudança?**

>

**Passo 3: quantos pods ficaram prontos durante o rollout quebrado? Por que o rollout não derrubou a aplicação? O que teria acontecido com a estratégia padrão (25%/25%)?**

>

**Passo 3: quais comandos mostram que o rollout está travado e por quê?**

>

**Passo 4: depois do rollback, qual é o número da revisão atual em `rollout history`? Por que ela não é a "2"?**

>

**Passo 5: o HPA funcionou de primeira? Se não, o que faltava?**

>

**Agora o arquivo `.k8s/deployment.yaml` e o que está no cluster são diferentes. Qual o risco disso? Como times costumam evitar esse problema?**

>

**Passo 7: como você testou que a NetworkPolicy funciona?**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
