# Redes 01 — IP, TCP/UDP, portas e NAT

| | |
|---|---|
| **Status** | pendente |
| **Início** | |
| **Conclusão** | |
| **Tempo total** | (estimativa: 5–6 h) |
| **Cobre (avaliação)** | D-04 |

## Por que este módulo

Quase todo problema de "não conecta" passa por aqui: uma porta que não está escutando, uma app ouvindo no endereço errado, um NAT que você não sabia que existia. É a base para entender o `docker run -p` (Docker 02), os Services do Kubernetes (Kubernetes 03) e a rede do AKS (AKS 02), onde o tamanho da subnet decide quantos pods cabem no cluster.

## Objetivos

Ao final, sem consulta, eu consigo:

- [ ] Explicar o que é um endereço IP, uma sub-rede e a notação CIDR, e calcular quantos endereços cabem num `/24` ou num `/16`
- [ ] Diferenciar IP privado de público e explicar por que meu notebook (e um pod) usa IP privado
- [ ] Explicar a diferença entre TCP e UDP e descrever o *three-way handshake*
- [ ] Explicar o que é uma porta e um socket, e ver o que está escutando na máquina (`ss`)
- [ ] Explicar a diferença entre escutar em `127.0.0.1` e em `0.0.0.0`
- [ ] Diferenciar *connection refused*, *timeout* e *connection reset*, e saber o que cada um indica sobre onde está o problema
- [ ] Explicar NAT, SNAT e DNAT, e mostrar a regra de NAT que o `docker run -p` cria

## Pré-teste

Responda antes de estudar, sem consulta. Não apague depois: é o registro do ponto de partida.

**D-04 · A instrução `EXPOSE 8000` no Dockerfile torna a porta acessível a partir do host? Qual a relação entre `EXPOSE` e `docker run -p 8080:8000`?**

> (sua resposta original no diagnóstico teve nota 1; responda de novo sem olhar)

**Quando um `curl` falha, qual a diferença entre receber "Connection refused" e ficar esperando até dar timeout?**

>

**O que significa um servidor "escutar em 0.0.0.0"?**

>

## Roteiro de estudo

Fonte principal: [Cloudflare Learning Center](https://www.cloudflare.com/learning/) (artigos curtos sobre IP, sub-redes, portas e TCP/IP). Complementar: [High Performance Browser Networking](https://hpbn.co), capítulo *Building Blocks of TCP*.

| # | Conteúdo | Fonte | Feito |
|---|---|---|---|
| 1 | Endereço IP, sub-rede, CIDR, IP privado × público (faixas 10/8, 172.16/12, 192.168/16) | Cloudflare Learning (artigos sobre *Internet Protocol* e *subnet*) | [ ] |
| 2 | NAT: como vários dispositivos saem para a internet com um único IP público | Cloudflare Learning ou Kurose & Ross, capítulo da camada de rede (seção de NAT) | [ ] |
| 3 | TCP × UDP, portas, three-way handshake, encerramento (FIN/RST) | Cloudflare Learning (artigos sobre *TCP/IP* e *computer port*) + HPBN, *Building Blocks of TCP* (até "Flow Control") | [ ] |
| 4 | Sockets, `127.0.0.1` × `0.0.0.0`, refused × timeout × reset | [Labs 2 e 3](labs/) (aprender fazendo) + `man ss` | [ ] |
| 5 | DNAT e SNAT no Docker | [Lab 4](labs/) + docs do Docker: *Networking → Port publishing* | [ ] |

## Labs

Ver [`labs/`](labs/). Pré-requisitos: `iproute2` (`ip`, `ss`), `curl`, `tcpdump`, `ipcalc`, `nc` (openbsd-netcat) e Docker rodando.

```bash
sudo pacman -S --needed iproute2 curl tcpdump ipcalc openbsd-netcat
```

## Definição de pronto

- [ ] `notas.md` explica todos os objetivos com minhas palavras
- [ ] Labs feitos, incluindo as tabelas de quebra-de-propósito
- [ ] `prova.md` com nota 2 em todas as perguntas
- [ ] Revisão D+1 feita

## Dúvidas para depois

-
