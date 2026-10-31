# K4 — CrashLoop

O time reclama: "a API não para de reiniciar e, quando para, não recebe tráfego". Ninguém mexeu no código. Você precisa descobrir o porquê e deixar a API estável.

## Preparação

```bash
make setup    # builda a imagem no minikube e aplica o Deployment no namespace aval-k4
```

## Regras

- **Não** altere `app.py` nem as variáveis `ALLOC_MB` e `STARTUP_SECONDS`: elas representam o comportamento real da aplicação (ela realmente precisa de 100 MB de cache e de ~20s para aquecer).
- **Não** remova a liveness probe. Ela tem que continuar existindo e checando `/healthz`.
- Mantenha um **limit de memória** (remover o limit não é uma correção aceitável).
- O estado final tem que estar em `.k8s/deployment.yaml`.

## Verificação

```bash
make check    # demora ~1 minuto: observa os pods por um tempo para garantir que não reiniciam
```

## Diagnóstico (preencha)

Para cada problema encontrado (há mais de um):

### Problema 1
- **Sintoma** (o que você viu em `get pods`, eventos, etc.):
- **Evidência** (comando + trecho relevante da saída):
- **Causa raiz**:
- **Correção**:

### Problema 2
- **Sintoma**:
- **Evidência**:
- **Causa raiz**:
- **Correção**:

### Problema 3
- **Sintoma**:
- **Evidência**:
- **Causa raiz**:
- **Correção**:

**Nos dois tipos de reinício, o que aparece em `Last State` (Reason e Exit Code) no `kubectl describe pod`? Como você diferencia "morreu por OOM" de "kubelet reiniciou por liveness"? Em que situação um reinício por liveness também terminaria com exit code 137?**

>

**Que valor de limit de memória você escolheu e como chegou nele? Como faria isso para uma aplicação real em produção?**

>

**Qual a diferença entre resolver o problema de boot lento com `initialDelaySeconds` grande e com `startupProbe`?**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
