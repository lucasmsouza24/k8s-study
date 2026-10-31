# K1 — Troubleshooting

Um colega subiu uma aplicação simples (`hashicorp/http-echo`, que responde um texto fixo via HTTP) e diz que "nada funciona". A aplicação deveria responder o texto que está no ConfigMap `echo-config` quando alguém de dentro do cluster acessa `http://echo-svc.aval-k1`.

Os manifests têm **vários problemas** (mais de três). Encontre e corrija todos.

## Preparação

```bash
make setup    # aplica os manifests com problemas no namespace aval-k1
```

## Regras

- Corrija editando os arquivos em `.k8s/` e reaplicando (`kubectl apply -f .k8s/`). Pode usar `kubectl edit` para testar, mas o estado final tem que estar nos arquivos.
- **Não** altere o texto do ConfigMap nem coloque o texto direto no Deployment: a mensagem tem que vir do ConfigMap.
- Não renomeie os recursos (`echo`, `echo-svc`, `echo-config`).
- O Deployment deve terminar com **2 réplicas prontas**.
- Antes de corrigir cada problema, **observe o sintoma** e anote abaixo. Esse registro vale tanto quanto a correção.

## Verificação

```bash
make check
```

## Diagnóstico (preencha)

Para cada problema encontrado:

| # | Sintoma observado (status/evento/erro) | Comando que revelou | Causa | Correção |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |

**Qual comando você usaria para confirmar que o Service está apontando para os pods certos?**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
