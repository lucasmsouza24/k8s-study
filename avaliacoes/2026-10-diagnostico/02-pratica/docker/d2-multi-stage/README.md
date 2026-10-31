# D2 — Multi-stage do zero

Aqui tem uma API em Go (`main.go`) e **nenhum Dockerfile**. Você não precisa saber Go nem ter Go instalado: a compilação acontece dentro do build.

Para compilar: `go build -o <saida> .` (dentro de um diretório com `main.go` e `go.mod`).

## Requisitos

Escreva um `Dockerfile` cuja imagem final:

1. Seja gerada por um **multi-stage build** (compila num estágio, roda em outro).
2. Tenha **menos de 25 MB**.
3. Rode com usuário **não-root** (a API responde o próprio `uid` em `GET /`).
4. Responda `GET /health` na porta 8080.
5. **Bônus**: não tenha shell (`/bin/sh`) na imagem final.

Dica de armadilha: um binário Go compilado normalmente pode depender da libc do sistema onde foi compilado. Pense no que acontece se você rodar esse binário numa imagem que não tem libc.

## Verificação

```bash
make check
```

## Perguntas (responda aqui)

**Qual imagem base você escolheu para o estágio final e por quê? Quais as desvantagens dela?**

>

**Sem shell na imagem, como você debugaria esse container em produção (no Docker e no Kubernetes)?**

>

## Registro

- Tempo gasto:
- Consultas à documentação (quantas / o quê):
- Dificuldades:
