# D1 — Otimizar um Dockerfile

Você herdou esta API (FastAPI) com um `Dockerfile` que "funciona", mas tem vários problemas. Sua tarefa é reescrever o `Dockerfile` (e criar o que mais for necessário) até o `check.sh` passar.

## Preparação

```bash
make setup     # gera arquivos locais que simulam um diretório de projeto real
make run-bad   # opcional: builda e roda a versão original para você observar
```

Experimente com a versão original antes de mudar: veja o tamanho da imagem (`docker images`), rode `docker stop` e cronometre, olhe `docker history`...

## Requisitos

A imagem final deve:

1. Ter **menos de 200 MB**.
2. **Não** rodar como root.
3. Parar com `docker stop` em **menos de 3 segundos**, encerrando pelo SIGTERM (exit code `0` ou `143`, nunca `137`).
4. **Não** conter o token `supersecret123` em lugar nenhum (variáveis de ambiente, histórico, arquivos). O token deve ser passado em runtime: `docker run -e API_TOKEN=...`.
5. Ao alterar apenas o `app.py`, o rebuild **não** deve reinstalar as dependências.
6. **Não** conter os arquivos `dataset/` e `.env` do diretório.
7. Continuar funcionando: `GET /health` retorna 200 e `GET /` mostra `"token_configured": true` quando o token é passado.

Você pode alterar `Dockerfile`, `start.sh` e criar arquivos novos. **Não altere** `app.py` nem `requirements.txt`.

## Verificação

```bash
make check
```

## Perguntas (responda aqui)

**Quais problemas você encontrou no Dockerfile original? Para cada um, qual o impacto?**

>

**Por que o `docker stop` da versão original demorava? (explique o mecanismo, não só a correção)**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
