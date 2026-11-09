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

- [x] Explicar o que é um endereço IP, uma sub-rede e a notação CIDR, e calcular quantos endereços cabem num `/24` ou num `/16`
- [ ] Diferenciar IP privado de público e explicar por que meu notebook (e um pod) usa IP privado
- [ ] Explicar a diferença entre TCP e UDP e descrever o *three-way handshake*
- [ ] Explicar o que é uma porta e um socket, e ver o que está escutando na máquina (`ss`)
- [ ] Explicar a diferença entre escutar em `127.0.0.1` e em `0.0.0.0`
- [ ] Diferenciar *connection refused*, *timeout* e *connection reset*, e saber o que cada um indica sobre onde está o problema
- [ ] Explicar NAT, SNAT e DNAT, e mostrar a regra de NAT que o `docker run -p` cria

## Pré-teste

Responda antes de estudar, sem consulta. Não apague depois: é o registro do ponto de partida.

**D-04 · A instrução** `EXPOSE 8000` **no Dockerfile torna a porta acessível a partir do host? Qual a relação entre** `EXPOSE` **e** `docker run -p 8080:8000`**?**

> 'EXPOSE 8000' no Dockerfile, faz com que a porta 8000 do container fique disponível para escuta. 'docker run -p 8080:8000' faz cria uma ligação entre a porta 8000 do container e a porta 8080 do HOST.

**Quando um** `curl` **falha, qual a diferença entre receber "Connection refused" e ficar esperando até dar timeout?**

> Ao receber 'Connection refused' temos a informação de que a conexão encontrou seu destino, e foi recusada por algum motivo. Já ao receber timeout, significa que o endereço destino não foi encontrado.

**O que significa um servidor "escutar em 0.0.0.0"?**

> 'escutar em 0.0.0.0' faz com que a comunicação fique aberta para fora do contexto. se uma aplicação rodar por exemplo em 127.0.0.1 ela só fica disponível de dentro da própria máquina, comunicação externa não consegue alcançar 127.0.0.1. Já tive um problema semelhante quando usei WSL com docker, foi necessário subir a aplicação apontando para 0.0.0.0, pois acredito que no caso do WSL existem 2 máquinas HOST, a HOST pai é a própria máquina e a HOST filho é o WSL (que é host do docker) então ao rodar em 127.0.0.1 só fica acessível de dentro do WSL.

## Roteiro de estudo

Fonte principal: [Cloudflare Learning Center](https://www.cloudflare.com/learning/) (artigos curtos sobre IP, sub-redes, portas e TCP/IP). Complementar: [High Performance Browser Networking](https://hpbn.co), capítulo *Building Blocks of TCP*.

| # | Conteúdo | Fonte | Feito |
|---|---|---|---|
| 1a | Endereço IP: IPv4 × IPv6, loopback, público × privado, roteamento | Cloudflare Learning (artigos sobre *Internet Protocol*) → [checkpoint 01](checkpoints/01-ip.md) | [x] |
| 1b | Sub-rede e máscara (conceito) | [Cloudflare — O que é uma sub-rede?](https://www.cloudflare.com/pt-br/learning/network-layer/what-is-a-subnet/) → [checkpoint 02, parte A](checkpoints/02-subredes.md). Atenção: o artigo apresenta as classes A/B/C como se fossem atuais; elas estão obsoletas desde 1993 | [x] |
| 1c | Máscara em binário, CIDR, rede/broadcast, hosts utilizáveis, divisão em sub-redes, faixas privadas (10/8, 172.16/12, 192.168/16) | [Wikipedia — Classless Inter-Domain Routing](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) (seções de notação e blocos) + praticar com `ipcalc` (mostra os bits) → [checkpoint 02, parte B](checkpoints/02-subredes.md) | [x] |
| 2 | NAT: como vários dispositivos saem para a internet com um único IP público; SNAT × DNAT; PAT; port forwarding | Visão geral: [Fortinet — O que é NAT](https://www.fortinet.com/br/resources/cyberglossary/network-address-translation). Principal: [slides de NAT da Univ. do Porto](https://www.dcc.fc.up.pt/~rprior/1920/AR/slides/06%20-%20NAT.pdf). Vídeo: [NIC.br — NAT para IPv4](https://moodle.saladeaula.nic.br/mod/page/view.php?id=1648) (trecho de PAT: 12:28–23:57). Ligação com o Azure (opcional): [Microsoft — SNAT para conexões de saída](https://learn.microsoft.com/pt-br/azure/load-balancer/load-balancer-outbound-connections) | [ ] |
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
