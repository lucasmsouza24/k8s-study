# RBAC em Kubernetes (AKS)

Este documento contém uma visão teórica, exemplos práticos (manifests e comandos) e exercícios para estudar RBAC em AKS.

## Plano

- Entender conceitos essenciais de RBAC.
- Ver exemplos YAML e comandos `kubectl` para aplicar e testar.
- Fazer exercícios práticos com comandos de verificação.

## Conceitos Essenciais

- **Role / ClusterRole**: definem regras (`rules`) com `verbs` (get, list, create, delete, watch, patch, update), `resources` (pods, secrets, deployments) e `apiGroups`. `Role` é scoped a namespace; `ClusterRole` é cluster-scoped.
- **RoleBinding / ClusterRoleBinding**: vinculam `subjects` (User, Group, ServiceAccount) a uma Role/ClusterRole. `RoleBinding` é por namespace; `ClusterRoleBinding` é global.
- **Subjects**: `User`, `Group`, `ServiceAccount` (para SAs inclua `namespace`).
- **roleRef**: referência ao `Role` ou `ClusterRole` (tipo e nome).
- **resourceNames**: limita a recursos com nomes específicos (ex.: um Secret específico).
- **apiGroups**: agrupa recursos por API (`""` indica a core API).
- **Princípio do menor privilégio**: conceda apenas os `verbs` e `resources` estritamente necessários.
- **Testes e auditoria**: use `kubectl auth can-i`, examine bindings e roles com `kubectl get`.
- **Uso em AKS**: normalmente vincule `ServiceAccount` a workloads, evite `cluster-admin` salvo necessidade crítica.

## Exemplos Práticos

### Role + RoleBinding (leitura de pods em `dev`)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods-binding
  namespace: dev
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### ClusterRole + ClusterRoleBinding (visualização de nós)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-viewer
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-viewer-binding
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: node-viewer
  apiGroup: rbac.authorization.k8s.io
```

### ServiceAccount e RoleBinding

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: prod
---
# Exemplo: Role/RoleBinding referenciando subject kind: ServiceAccount name: app-sa namespace: prod
```

### Role limitado por `resourceNames` (apenas um Secret específico)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader-limited
  namespace: prod
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["my-app-secret"]
  verbs: ["get"]
```

## Comandos úteis

- Ver se um sujeito pode executar uma ação:

```bash
kubectl auth can-i get pods --namespace=dev --as=alice
kubectl auth can-i create secrets --as=system:serviceaccount:prod:app-sa -n prod
```

- Listar bindings:

```bash
kubectl get rolebinding --all-namespaces
kubectl get clusterrolebinding
```

- Mostrar Role/ClusterRole em YAML:

```bash
kubectl get role pod-reader -n dev -o yaml
kubectl get clusterrole node-viewer -o yaml
```

- Testar uma ServiceAccount dentro de um Pod: criar um Pod com `serviceAccountName: app-sa` e usar `kubectl exec -it` para testar ações.

## Exercícios Práticos (progressão)

1) Exercício 1 — básico

- Tarefa: Criar namespace `dev`, criar `ServiceAccount` `dev-sa`, criar `Role` que permite `create` e `list` em `configmaps` no namespace `dev`, e bindar a `dev-sa`.
- Verificação: `kubectl auth can-i create configmaps --as=system:serviceaccount:dev:dev-sa -n dev`
- Dica: use `apiGroups: [""]` e `resources: ["configmaps"]`.

2) Exercício 2 — controle fino

- Tarefa: Criar uma Role que permita `get` apenas do Secret chamado `db-creds` em `staging` (use `resourceNames`).
- Verificação: `kubectl auth can-i get secret/db-creds --as=... -n staging` (deve passar) e `kubectl auth can-i get secrets --as=... -n staging` (deve falhar).

3) Exercício 3 — namespace vs cluster

- Tarefa: Criar um `ClusterRole` que permita `list` e `watch` de `nodes` e um `ClusterRoleBinding` para o grupo `infra`.
- Verificação: `kubectl auth can-i list nodes --as=<user-in-group>`

4) Exercício 4 — padrão CI/CD

- Tarefa: Criar uma SA `ci-sa` em `ci` que possa `create` pods e `get` secrets somente no namespace `ci`.
- Verificação: 

```bash
kubectl auth can-i create pods --as=system:serviceaccount:ci:ci-sa -n ci
kubectl auth can-i get secrets --as=system:serviceaccount:ci:ci-sa -n ci
```

5) Exercício 5 — auditoria

- Tarefa: Procurar por bindings que concedam `cluster-admin` a qualquer sujeito.
- Dica: `kubectl get clusterrolebinding -o json | jq '.items[] | select(.roleRef.name=="cluster-admin") | {name: .metadata.name, subjects: .subjects}'`

6) Exercício 6 — avançado (separação de privilégios)

- Tarefa: Um app precisa listar `pods` em `app-ns` e assistir `endpoints` em todos os namespaces. Projete Roles/ClusterRole e bindings apropriados para a SA do app.
- Verificação: usar `kubectl auth can-i` com `--as` da SA para ambas as ações.

---

Se quiser, gero os manifests completos para qualquer exercício e os comandos prontos para aplicar e testar.