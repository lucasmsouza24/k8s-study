# Gabarito — Prática

## D1 — Otimizar Dockerfile

### Problemas do original

| Problema | Impacto |
|---|---|
| `FROM python:3.12` (imagem completa) | ~1 GB, centenas de CVEs, pull lento |
| `ENV API_TOKEN=supersecret123` | segredo visível para qualquer um com a imagem (`docker inspect`) |
| `COPY . .` antes do `pip install` | qualquer mudança reinstala todas as dependências |
| Sem `.dockerignore` | `dataset/` (150 MB) e `.env` (segredos!) vão para a imagem; contexto lento |
| Roda como root | ver D-09 |
| `CMD ./start.sh` (forma shell) + script sem `exec` | SIGTERM não chega ao uvicorn → `docker stop` espera 10s → SIGKILL (137) |
| `pip install` sem `--no-cache-dir` | cache do pip (~MBs) dentro da imagem |
| `RUN chmod` numa camada separada | duplica o arquivo numa nova camada (pequeno aqui, grave com arquivos grandes) |

**Mecanismo do `docker stop`**: `CMD ./start.sh` vira `/bin/sh -c ./start.sh`. O shell que interpreta o script fica como PID 1 e roda o uvicorn como **filho**. O `docker stop` manda SIGTERM ao PID 1. O shell não repassa o sinal ao filho e, por ser PID 1 sem handler, o kernel ignora o sinal. Depois de 10s vem o SIGKILL, e o uvicorn nunca executa o shutdown.

### Solução de referência

`Dockerfile`:

```dockerfile
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

RUN useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app
USER 10001

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

`.dockerignore`:

```
dataset/
.env
.git
__pycache__/
Dockerfile*
makefile
check.sh
```

Alternativa mantendo o `start.sh`: trocar a linha por `exec uvicorn app:app --host 0.0.0.0 --port 8000` e usar `CMD ["./start.sh"]` (com `COPY --chmod=755 start.sh .`).

---

## D2 — Multi-stage

```dockerfile
FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/api .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/api /api
EXPOSE 8080
ENTRYPOINT ["/api"]
```

- `CGO_ENABLED=0` gera um binário **estático**. Sem isso, o binário pode depender da libc e falhar em `scratch`/distroless com um enganoso `no such file or directory`.
- `distroless/static:nonroot` já roda como UID 65532, tem certificados CA, tzdata e `/etc/passwd`, e não tem shell. Imagem final: ~5–10 MB.
- Alternativa `FROM scratch` + `USER 65534`: ainda menor, mas sem certificados CA (chamadas HTTPS falham) nem tzdata, a menos que você copie.
- Debug sem shell:
  - **Docker**: `docker run -it --pid=container:X --network=container:X busybox` (compartilha os namespaces), `docker cp`, `docker logs`.
  - **Kubernetes**: `kubectl debug -it POD --image=busybox --target=CONTAINER` (ephemeral container).

---

## D3 — Compose

```yaml
services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      REDIS_HOST: redis
    depends_on:
      redis:
        condition: service_healthy
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: ["redis-server", "--appendonly", "yes"]
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
    mem_limit: 128m
    restart: unless-stopped

volumes:
  redis-data:
```

- `depends_on` sem condição só espera o container **iniciar**, não o processo aceitar conexões. Mesmo com healthcheck, a app deveria ter retry, porque o Redis pode reiniciar depois.
- Os dados ficam em `/var/lib/docker/volumes/<projeto>_redis-data/_data`. `down -v` apaga os volumes nomeados declarados no compose.
- Kubernetes:
  - api → Deployment + Service (+ Ingress)
  - redis → StatefulSet + PVC + Service (ou um serviço gerenciado: Azure Cache for Redis)
  - `environment` → ConfigMap
  - `depends_on` → readiness probe + retry na app (ou init container)
  - `restart` → é o padrão do Kubernetes
  - `mem_limit` → `resources.limits`

---

## K1 — Troubleshooting

Os problemas, na ordem em que aparecem:

| # | Sintoma | Comando | Causa | Correção |
|---|---|---|---|---|
| 1 | Pods `Pending`, evento `FailedScheduling: Insufficient memory` | `kubectl describe pod` | `memory: 64Gi` em requests/limits | `64Mi` |
| 2 | `ErrImagePull` / `ImagePullBackOff`, "repository does not exist" | `kubectl describe pod` | typo: `http-eco` | `hashicorp/http-echo:0.2.3` |
| 3 | `CreateContainerConfigError`, "couldn't find key MESSAGE" | `kubectl describe pod` | a chave do ConfigMap é `message` (minúscula) | `key: message` |
| 4 | `Running` mas `0/1`, "Readiness probe failed: connection refused" | `kubectl describe pod` | probe na 8080, app ouve na 5678 | `port: 5678` |
| 5 | Service sem endpoints | `kubectl get endpointslices -l kubernetes.io/service-name=echo-svc` / `kubectl describe svc echo-svc` | selector `app: echo-api` × label `app: echo` | `app: echo` |
| 6 | `curl` → connection refused | `kubectl get endpointslices ...` mostra a porta 8080 | `targetPort: 8080` | `targetPort: 5678` |

Atalho válido: mudar a app para `-listen=:8080` (e o `containerPort`) resolve o 4 e o 6 de uma vez. Para contar, você precisa ter percebido os dois.

**Nota do diagnóstico**: 2 se identificou 6/6 com o sintoma certo; 1 se corrigiu tudo mas não soube dizer o sintoma/comando de algum.

---

## K2 — Aplicação do zero

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: aval-k2
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-config
  namespace: aval-k2
data:
  color: blue
---
apiVersion: v1
kind: Secret
metadata:
  name: web-secret
  namespace: aval-k2
type: Opaque
stringData:
  token: meu-token
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: aval-k2
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: web
    spec:
      securityContext:
        runAsNonRoot: true
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                topologyKey: kubernetes.io/hostname
                labelSelector:
                  matchLabels:
                    app: web
      containers:
        - name: web
          image: aval-k2-web:1.0
          ports:
            - name: http
              containerPort: 8000
          env:
            - name: APP_COLOR
              valueFrom:
                configMapKeyRef:
                  name: web-config
                  key: color
          volumeMounts:
            - name: token
              mountPath: /etc/web
              readOnly: true
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
          readinessProbe:
            httpGet:
              path: /ready
              port: http
          resources:
            requests:
              cpu: 100m
              memory: 64Mi
            limits:
              cpu: 100m
              memory: 64Mi
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop: ["ALL"]
      volumes:
        - name: token
          secret:
            secretName: web-secret
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: aval-k2
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: http
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: web-pdb
  namespace: aval-k2
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web
```

Respostas:
- **Drain no único nó**: o PDB permite 1 disrupção (3 − 2). O primeiro pod é despejado, mas o substituto fica `Pending` (o único nó está cordoned). As outras evictions são negadas pelo PDB e o drain fica **em loop** ("Cannot evict pod as it would violate the pod's disruption budget"). Num cluster com vários nós, o drain esperaria o substituto ficar pronto antes de continuar.
- **USER numérico**: o kubelet não lê o `/etc/passwd` da imagem, então não consegue saber se `app` é UID 0. Com `runAsNonRoot: true` e usuário não numérico, o container falha com `CreateContainerConfigError: image has non-numeric user (app), cannot verify user is non-root`. A correção é usar UID numérico na imagem ou `runAsUser` no pod.
- **Mudar o ConfigMap**: env não atualiza. É preciso `kubectl rollout restart deployment/web` (ou um hash do ConfigMap no template).

---

## K3 — Operação

```bash
NS=aval-k3

# 1. estratégia (editar o arquivo ANTES dos passos 2-4, ou via patch)
kubectl -n $NS patch deployment web -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'

# 2. atualização (annotate DEPOIS do set image, senão a revisão antiga também recebe o motivo)
kubectl -n $NS set image deployment/web nginx=nginx:1.27-alpine
kubectl -n $NS annotate deployment/web kubernetes.io/change-cause="atualiza para 1.27" --overwrite
kubectl -n $NS rollout status deployment/web

# 3. versão quebrada
kubectl -n $NS set image deployment/web nginx=nginx:9.9.9-alpine
kubectl -n $NS annotate deployment/web kubernetes.io/change-cause="versao quebrada" --overwrite
kubectl -n $NS rollout status deployment/web --timeout=30s   # não termina
kubectl -n $NS get rs,pods
kubectl -n $NS describe deployment web                        # Conditions / eventos

# 4. rollback
kubectl -n $NS rollout history deployment/web
kubectl -n $NS rollout undo deployment/web                    # ou --to-revision=2

# 5. HPA (requests de CPU são obrigatórios; NÃO reaplique o arquivo, ele ainda tem nginx:1.26)
minikube addons enable metrics-server
kubectl -n $NS set resources deployment/web --requests=cpu=50m,memory=32Mi
kubectl -n $NS autoscale deployment web --min=2 --max=6 --cpu=60%   # kubectl < 1.33: --cpu-percent=60
kubectl -n $NS get hpa -w

# 6. RBAC
kubectl -n $NS create serviceaccount auditor
kubectl -n $NS create role auditor --verb=get,list,watch --resource=pods,pods/log,deployments.apps
kubectl -n $NS create rolebinding auditor --role=auditor --serviceaccount=$NS:auditor
kubectl auth can-i delete pods -n $NS --as=system:serviceaccount:$NS:auditor   # no
```

```yaml
# 7. NetworkPolicy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-allow-frontend
  namespace: aval-k3
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes: ["Ingress"]
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 80
```

```bash
# teste
kubectl -n aval-k3 run t1 --rm -it --restart=Never --image=curlimages/curl --labels=role=frontend -- curl -m 3 -s web
kubectl -n aval-k3 run t2 --rm -it --restart=Never --image=curlimages/curl -- curl -m 3 -s web   # timeout
```

Respostas:
- **Passo 3**: com `maxSurge: 1, maxUnavailable: 0`, cria **1** pod novo (ImagePullBackOff) e mantém os **4** antigos prontos; nenhum antigo cai, porque o novo nunca fica Ready. Com o padrão 25%/25% (4 réplicas → 1/1), **1** antigo seria derrubado (3/4 de capacidade) e 2 novos ficariam presos. Depois de `progressDeadlineSeconds` (600s), a condição vira `Progressing=False / ProgressDeadlineExceeded`, **sem rollback automático**.
- **Passo 4**: a revisão atual vira **4**, não 2. O rollback "promove" o ReplicaSet antigo para a próxima revisão; os números são monotônicos e a 2 some do histórico.
- **Passo 5**: o HPA mostra `<unknown>` sem requests de CPU (a utilização é calculada sobre o request) ou com o metrics-server ainda subindo.
- **Drift**: o arquivo ainda diz `nginx:1.26-alpine` e não tem requests. Um `kubectl apply -f .k8s/` (por um colega ou pelo pipeline) faria **downgrade** e quebraria o HPA. Mitigações: toda mudança pelo git + pipeline/GitOps (ArgoCD/Flux detectam e corrigem drift), sem `replicas` no manifest quando há HPA, e acesso de escrita restrito no cluster.

---

## K4 — CrashLoop

| # | Sintoma | Evidência | Causa | Correção |
|---|---|---|---|---|
| 1 | `OOMKilled`/CrashLoopBackOff logo ao subir | `describe pod`: `Last State: Terminated, Reason: OOMKilled, Exit Code: 137`; logs param em "carregando cache" | limit de 64Mi < 100 MB de cache + runtime | limit de memória ~192Mi (requests ~160Mi) |
| 2 | Reinicia a cada ~10s, nunca fica pronto | eventos: `Liveness probe failed: ... connection refused` → `Container api failed liveness probe, will be restarted`; logs param em "aquecendo" | liveness começa aos 5s com `failureThreshold: 1`, mas o boot leva 20s | `startupProbe` em `/healthz` com `periodSeconds: 5`, `failureThreshold: 12` (até 60s) e liveness com `failureThreshold: 3` |
| 3 | `Running` mas `0/1`, sem reinícios | eventos: `Readiness probe failed: HTTP probe failed with statuscode: 404` | path `/readyz` não existe | `path: /ready` |

```yaml
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 10
            failureThreshold: 3
          startupProbe:
            httpGet:
              path: /healthz
              port: 8000
            periodSeconds: 5
            failureThreshold: 12
          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
            periodSeconds: 5
          resources:
            requests:
              cpu: 50m
              memory: 160Mi
            limits:
              cpu: 200m
              memory: 192Mi
```

Respostas:
- **OOM × liveness**: OOM aparece como `Reason: OOMKilled`, exit 137, sem evento de probe. Por liveness, aparecem os eventos `Liveness probe failed` / `will be restarted`, e o Last State fica `Completed`/exit 0 (esta app trata SIGTERM). Um reinício por liveness termina com **137** quando a app **ignora o SIGTERM** e o kubelet manda SIGKILL depois do `terminationGracePeriodSeconds`.
- **Limit**: medir o uso real (`kubectl top pod`, métricas de pico), somar uma margem de 20–30% e validar com teste de carga. Em produção, o VPA em modo recomendação e o histórico do Prometheus ajudam.
- **initialDelaySeconds × startupProbe**: o `initialDelaySeconds` é fixo. Se o boot demorar mais (nó frio, dependência lenta), mata do mesmo jeito; se for alto, atrasa a detecção de um travamento real em todos os restarts. A `startupProbe` dá um orçamento máximo de boot e libera a liveness **assim que** a app sobe, mantendo a liveness rígida.
