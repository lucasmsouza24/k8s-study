# Prova — IP, TCP/UDP, portas e NAT

Sem consulta. Critério: 0 (não sei / errado), 1 (parcial, sem o mecanismo), 2 (completo, explica o porquê). Só passa com 2 em todas.

Peça ao agente: "corrija a prova de `trilhas/01-redes/01-ip-tcp-portas-nat/prova.md`".

| Tentativa | Data | Resultado |
|---|---|---|
| 1 | | |

---

### P-01 · EXPOSE (D-04 da avaliação)
A instrução `EXPOSE 8000` no Dockerfile torna a porta acessível a partir do host? Qual a relação entre `EXPOSE` e `docker run -p 8080:8000`? Em que sentido o tráfego é encaminhado?

>

**Nota:**

### P-02 · IP privado
Seu notebook tem um IP `192.168.x.x` e um pod no AKS tem um IP `10.x.x.x`. Esses endereços "existem" na internet? Como eles conseguem acessar sites externos?

>

**Nota:**

### P-03 · CIDR
Quantos endereços existem em um `/24` e em um `/16`? O IP `10.240.5.10` pertence a `10.240.0.0/16`? E a `10.240.0.0/24`? Por que o tamanho de uma subnet importa ao criar um cluster AKS?

>

**Nota:**

### P-04 · TCP × UDP
Qual a diferença entre TCP e UDP? Descreva o three-way handshake. Cite um protocolo que normalmente usa UDP e por quê.

>

**Nota:**

### P-05 · Tipos de falha
Para cada mensagem, diga o que aconteceu no nível de rede e o que isso indica sobre **onde** está o problema:

a) `Connection refused`
b) timeout
c) `Connection reset by peer` / `Empty reply from server`

>

**Nota:**

### P-06 · Endereço de escuta
Qual a diferença entre um servidor escutar em `127.0.0.1` e em `0.0.0.0`? Por que uma aplicação que escuta em `127.0.0.1` dentro de um container não responde via `docker run -p`, mesmo com a porta certa?

>

**Nota:**

### P-07 · NAT
O que é NAT? Qual a diferença entre SNAT e DNAT? Qual deles o `docker run -p` usa, e qual o seu roteador de casa usa quando você acessa a internet?

>

**Nota:**

### P-08 · Portas de origem
Quando o seu `curl` se conecta a um servidor na porta 443, qual é a porta de origem da conexão e de onde ela vem? Se milhares de conexões saem por um único IP público ao mesmo tempo, que limite pode ser atingido?

>

**Nota:**
