# Labs — IP, TCP/UDP, portas e NAT

Quatro labs curtos, em ordem. Anote as respostas e saídas relevantes direto neste arquivo.

---

## Lab 1 — A sua rede

```bash
ip -br addr        # interfaces e seus IPs
ip route           # tabela de rotas
curl -s https://ifconfig.me; echo    # seu IP público
ipcalc 192.168.49.0/24
```

Responda:

1. Quais interfaces você tem? Para que serve cada uma (`lo`, Wi-Fi/ethernet, `docker0`, a bridge do minikube)?
>
2. Qual o seu IP na rede local e qual o IP público? Por que são diferentes, e quem faz a tradução?
>
3. Qual é o *default gateway* (`ip route`)? O que acontece com um pacote para um IP que não está em nenhuma rota específica?
>
4. Quantos hosts cabem em `192.168.49.0/24`? E em `10.240.0.0/16`? (`ipcalc`)
>

---

## Lab 2 — Portas, sockets e "onde a app está escutando"

Terminal 1:

```bash
python3 -m http.server 8000 --bind 127.0.0.1
```

Terminal 2:

```bash
ss -tlnp | grep 8000                    # o que está escutando, em qual endereço
curl -v http://127.0.0.1:8000/ -o /dev/null
curl -v http://<SEU_IP_LOCAL>:8000/ -o /dev/null   # o IP do Lab 1
```

Agora pare o servidor e suba com `--bind 0.0.0.0`. Repita os três comandos.

Depois, teste os três tipos de falha:

```bash
curl -v http://127.0.0.1:8001/          # porta sem ninguém escutando
curl -v -m 5 http://10.255.255.1/       # IP para onde ninguém responde
nc -zv 127.0.0.1 8000                   # teste de porta sem HTTP
```

Responda:

1. O que mudou na coluna *Local Address* do `ss` entre `127.0.0.1` e `0.0.0.0`? O que isso significa?
>
2. Por que o `curl` no seu IP local falhou com `--bind 127.0.0.1`? Qual foi a mensagem?
>
3. Qual a diferença entre as mensagens da porta 8001 e do IP 10.255.255.1? O que cada uma diz sobre **onde** está o problema?
>

---

## Lab 3 — Vendo o handshake TCP

Com o servidor do Lab 2 rodando (`--bind 0.0.0.0`):

Terminal 2:

```bash
sudo tcpdump -i lo -n 'tcp port 8000 or tcp port 8001'
```

Terminal 3:

```bash
curl -s http://127.0.0.1:8000/ -o /dev/null
curl -s http://127.0.0.1:8001/ -o /dev/null
```

Responda:

1. Identifique na saída as flags `[S]`, `[S.]`, `[.]`, `[P.]` e `[F.]`. O que cada uma é?
>
2. O que aparece na conexão para a porta 8001? Por que é isso que gera o "Connection refused"?
>
3. Qual foi a **porta de origem** do `curl`? De onde ela vem?
>

---

## Lab 4 — NAT no Docker

```bash
docker run -d --name web -p 8080:80 nginx:alpine
sudo ss -tlnp | grep 8080
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' web
curl -sI http://localhost:8080/ | head -1
curl -sI http://<IP_DO_CONTAINER>/ | head -1

# a regra de NAT (use a que funcionar no seu sistema)
sudo iptables -t nat -L DOCKER -n
sudo nft list ruleset | grep -B2 -A2 8080
```

Responda:

1. Qual a regra que o Docker criou? É SNAT ou DNAT? Do quê para o quê?
>
2. Por que você consegue acessar o IP do container direto do host, mas um colega na mesma rede Wi-Fi não conseguiria?
>
3. O `EXPOSE 80` da imagem do nginx teve algum papel aqui? Teste com uma imagem que **não** tem `EXPOSE`: `docker run -d --rm --name q0 -p 8003:8000 python:3.12-slim python -m http.server 8000` e depois `curl -sI http://localhost:8003/`.
>

### Quebre de propósito

Para cada quebra abaixo, preveja o sintoma **antes** de rodar, depois rode e registre na tabela.

```bash
# 1. app escutando só no loopback DENTRO do container
docker run -d --rm --name q1 -p 8001:8000 python:3.12-slim python -m http.server 8000 --bind 127.0.0.1
curl -v http://localhost:8001/

# 2. porta do container errada no -p
docker run -d --rm --name q2 -p 8002:8080 nginx:alpine
curl -v http://localhost:8002/

# 3. porta do host já ocupada
docker run -d --rm --name q3 -p 8080:80 nginx:alpine
```

| O que quebrei | Previ | Sintoma observado | Como diagnostiquei (comando) | Causa |
|---|---|---|---|---|
| App em 127.0.0.1 no container | | | | |
| Porta do container errada | | | | |
| Porta do host ocupada | | | | |

A quebra 1 é uma das causas clássicas de "funciona no meu Docker, não funciona no cluster" (cenário C-03 da avaliação).

Limpeza:

```bash
docker rm -f web q0 q1 q2 q3 2>/dev/null
```

---

## Registro

- Tempo gasto:
- Consultas à documentação:
- O que mais me surpreendeu:
