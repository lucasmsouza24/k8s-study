# K2 — Aplicação do zero

Aqui não tem template. Você vai escrever todos os manifests em `.k8s/` a partir da especificação abaixo. Pode usar `kubectl create ... --dry-run=client -o yaml` para gerar esqueletos e `kubectl explain` para consultar campos (é assim que se faz na CKA/CKAD).

## A aplicação

`app.py` é uma API HTTP na porta **8000** com:

- `GET /healthz` — liveness
- `GET /ready` — readiness
- `GET /` — retorna `color` (variável `APP_COLOR`), `token_loaded` (se o arquivo `/etc/web/token` existe e não está vazio), `uid` e o nome do pod

O `Dockerfile` está pronto. Builde a imagem direto no minikube:

```bash
make build    # minikube image build -t aval-k2-web:1.0 .
```

## Especificação

Tudo no namespace **`aval-k2`**.

1. **ConfigMap** `web-config` com a chave `color` = `blue`.
2. **Secret** `web-secret` com a chave `token` (valor à sua escolha).
3. **Deployment** `web`:
   - imagem `aval-k2-web:1.0`, label `app: web`, **3 réplicas**
   - variável `APP_COLOR` vinda da chave `color` do ConfigMap
   - o Secret montado como **arquivo** em `/etc/web/token`
   - liveness probe em `/healthz` e readiness probe em `/ready`
   - requests e limits definidos de forma que os pods tenham **QoS `Guaranteed`**
   - rolling update que **nunca** reduza a capacidade abaixo de 3 pods prontos, subindo **um pod novo por vez**
   - `securityContext`: não pode rodar como root, sistema de arquivos raiz somente leitura, sem escalada de privilégio, sem nenhuma capability Linux
4. **Service** `web`, do tipo ClusterIP, na porta **80**, encaminhando para a porta 8000 dos pods.
5. **PodDisruptionBudget** `web-pdb` garantindo no mínimo **2** pods disponíveis.
6. **Bônus**: configure os pods para *preferirem* ficar em nós diferentes (no minikube só tem um nó, então tem que ser uma preferência, não uma obrigação).

## Verificação

```bash
make apply    # kubectl apply -f .k8s/
make check
```

## Perguntas (responda aqui)

**Com esse PDB e 3 réplicas, o que acontece se você tentar fazer `kubectl drain` no único nó do minikube?**

>

**Por que a imagem usa `USER 10001` (numérico) e não `USER app`? O que aconteceria com `runAsNonRoot: true` se fosse um nome?**

>

**Se você mudar o valor de `color` no ConfigMap, o que acontece com os pods? Como você aplicaria a mudança?**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
