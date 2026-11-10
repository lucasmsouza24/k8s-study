# Labs — IP, TCP/UDP, portas e NAT

Quatro labs curtos, em ordem. Anote as respostas e saídas relevantes direto neste arquivo.

---

## Lab 1 — A sua rede

```bash
ip -br addr        # interfaces e seus IPs
ip route           # tabela de rotas
curl -4 -s https://ifconfig.me; echo    # seu IP público IPv4 (o do roteador, por causa do PAT)
curl -6 -s https://ifconfig.me; echo    # seu IP público IPv6 (sem NAT)
ipcalc 192.168.49.0/24
```

Responda:

1. Quais interfaces você tem? Para que serve cada uma (`lo`, Wi-Fi/ethernet, `docker0`, a bridge do minikube)?

```bash
lucas@cachyos:~$ ip -br addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp3s0           UP             192.168.15.7/24 2804:7f0:75c0:3399:7a6e:62c7:c278:a351/64 fe80::b15:202c:e6a2:d5fe/64 
docker0          DOWN           172.17.0.1/16 
br-83bdbb5ac474  DOWN           192.168.49.1/24
```

> lo: 127.0.0.1/8 -> é o localhost, usado para testes como uma interface interna do dispositivo  
> enp3s0 tem um endereço privado: 192.168.15.7/24 e dois endereços IPv6:  
>
> - 192.168.15.7/24 2804:7f0:75c0:3399:7a6e:62c7:c278:a351/64  
> - fe80::b15:202c:e6a2:d5fe/64
>
> enp3s0 é a interface da minha máquina  
> docker0 é a interface interna criada pelo docker  
> br-83bdbb5ac474 é  a interface criada pelo minikube

2. Qual o seu IP na rede local e qual o IP público, em IPv4 e em IPv6? Por que, no IPv4, eles são diferentes, e quem faz a tradução? Por que, no IPv6, o IP público aparece na sua própria interface?

```bash
lucas@cachyos:~/dev/k8s-study/$ curl -4 -s https://ifconfig.me; echo
179.98.191.244
lucas@cachyos:~/dev/k8s-study/$ curl -6 -s https://ifconfig.me; echo
2804:7f0:75c0:3399:7a6e:62c7:c278:a351
```

> no comando ip -br addr meu ip é 192.168.15.7/24 (interno)  
> no comando curl -4 -s https://ifconfig.me; echo, meu ip é 179.98.191.244
>
> isso por conta do NAT, que traduz a origem de 192.168.15.7 (privado) -> 179.98.191.244 (público)
>
> No IPv6, essa tradução não acontece. meu dispositivo já tem um endereço universalmente único. Meu provedor entregou junto com o roteador, um endereço de rede IPv6 único, e meu PC pegou um endereço disponível dentro da rede entregue (possivelmente 64 bits de host, por conta do /64 no endereçamento que aparece)

3. Qual é o *default gateway* (`ip route`)? O que acontece com um pacote para um IP que não está em nenhuma rota específica?

```bash
lucas@cachyos:~$ ip route
default via 192.168.15.1 dev enp3s0 proto dhcp src 192.168.15.7 metric 100 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
192.168.15.0/24 dev enp3s0 proto kernel scope link src 192.168.15.7 metric 100 
192.168.49.0/24 dev br-83bdbb5ac474 proto kernel scope link src 192.168.49.1 linkdown 
```

> default gateway: 192.168.15.1, ou seja, dentro da rede interna, esse é o IP do roteador. Se um pacote possui um destino sem tabela, ele passa pelo processo do NAT, que traduz o endereço de origem para o endereço público da rede, e o pacote passa a trafegar fora da rede interna, sai pra internet.

4. Quantos hosts cabem em `192.168.49.0/24`? E em `10.240.0.0/16`? (`ipcalc`)

> `192.168.49.0/24 -> 254 hosts`
>
> `10.240.0.0/16   -> 65534 hosts`

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

```bash
# Terminal 1:
lucas@cachyos:~/dev/k8s-study/$ python3 -m http.server 8000 --bind 127.0.0.1
Serving HTTP on 127.0.0.1 port 8000 (http://127.0.0.1:8000/) ...
127.0.0.1 - - [09/Nov/2026 21:21:29] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Nov/2026 21:21:29] code 404, message File not found
127.0.0.1 - - [09/Nov/2026 21:21:29] "GET /json/version HTTP/1.1" 404 -
127.0.0.1 - - [09/Nov/2026 21:21:29] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Nov/2026 21:22:18] "GET / HTTP/1.1" 200 -

# Terminal 2:
lucas@cachyos:~/dev/k8s-study/$ ss -tlnp | grep 8000
LISTEN 0      5          127.0.0.1:8000       0.0.0.0:*    users:(("python3",pid=23961,fd=3))
lucas@cachyos:~/dev/k8s-study/$ curl -v http://127.0.0.1:8000/ -o /dev/null
*   Trying 127.0.0.1:8000...
* Established connection to 127.0.0.1 (127.0.0.1 port 8000) from 127.0.0.1 port 45476 
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0* using HTTP/1.x
> GET / HTTP/1.1
> Host: 127.0.0.1:8000
> User-Agent: curl/8.23.0
> Accept: */*
> 
* Request completely sent off
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Server: SimpleHTTP/0.6 Python/3.14.9
< Date: Tue, 10 Nov 2026 00:22:18 GMT
< Content-type: text/html; charset=utf-8
< Content-Length: 835
< 
{ [835 bytes data]
100    835 100    835   0      0  1.13M      0                     100    835 100    835   0      0  1.08M      0                     100    835 100    835   0      0  1.04M      0                              0
* shutting down connection #0
lucas@cachyos:~/dev/k8s-study/$ curl -v http://179.98.191.244:8000/ -o /dev/
null
*   Trying 179.98.191.244:8000...
* connect to 179.98.191.244 port 8000 from 192.168.15.7 port 59966 failed: Conexão recusada
* Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect toserver
* closing connection #0
curl: (7) Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect to server
lucas@cachyos:~/dev/k8s-study/$ curl -v http://192.168.15.7:8000/ -o /dev/nu
ll
*   Trying 192.168.15.7:8000...
* connect to 192.168.15.7 port 8000 from 192.168.15.7 port 45274 failed: Conexão recusada
* Failed to connect to 192.168.15.7:8000 after 0 ms: Could not connect to server
* closing connection #0
curl: (7) Failed to connect to 192.168.15.7:8000 after 0 ms: Could not connect to server
lucas@cachyos:~/dev/k8s-study/$ 
```

```bash
# Terminal 1:
lucas@cachyos:~/dev/k8s-study/$ python3 -m http.server 8000 --bind 0.0.0.0
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
127.0.0.1 - - [09/Nov/2026 21:25:55] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Nov/2026 21:25:55] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Nov/2026 21:25:55] code 404, message File not found
127.0.0.1 - - [09/Nov/2026 21:25:55] "GET /json/version HTTP/1.1" 404 -
127.0.0.1 - - [09/Nov/2026 21:25:55] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [09/Nov/2026 21:27:51] "GET / HTTP/1.1" 200 -
192.168.15.7 - - [09/Nov/2026 21:28:44] "GET / HTTP/1.1" 200 -
192.168.15.7 - - [09/Nov/2026 21:32:23] "GET / HTTP/1.1" 200 -

# Terminal 2:
lucas@cachyos:~/dev/k8s-study/$ ss -tlnp | grep 8000
LISTEN 0      5            0.0.0.0:8000       0.0.0.0:*    users:(("python3",pid=24482,fd=3))

lucas@cachyos:~/dev/k8s-study/$ curl -v http://127.0.0.1:8000/ -o /dev/null
*   Trying 127.0.0.1:8000...
* Established connection to 127.0.0.1 (127.0.0.1 port 8000) from 127.0.0.1 port 55204
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      00* using HTTP/1.x
> GET / HTTP/1.1
> Host: 127.0.0.1:8000
> User-Agent: curl/8.23.0
> Accept: */*
> 
* Request completely sent off
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Server: SimpleHTTP/0.6 Python/3.14.9
< Date: Tue, 10 Nov 2026 00:27:51 GMT
< Content-type: text/html; charset=utf-8
< Content-Length: 835
< 
{ [835 bytes data]
100    835 100    835   0      0  1.14M      0100    835 100    835   0      0  1.09M      0100    835 100    835   0      0  1.05M      00
* shutting down connection #0
lucas@cachyos:~/dev/k8s-study/$ 
lucas@cachyos:~/dev/k8s-study/$ 
lucas@cachyos:~/dev/k8s-study/$ curl -v http://192.168.15.7:8000/ -o /dev/nu
ll
*   Trying 192.168.15.7:8000...
* Established connection to 192.168.15.7 (192.168.15.7 port 8000) from 192.168.15.7 port 32850
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      00* using HTTP/1.x
> GET / HTTP/1.1
> Host: 192.168.15.7:8000
> User-Agent: curl/8.23.0
> Accept: */*
> 
* Request completely sent off
* HTTP 1.0, assume close after body
< HTTP/1.0 200 OK
< Server: SimpleHTTP/0.6 Python/3.14.9
< Date: Tue, 10 Nov 2026 00:28:44 GMT
< Content-type: text/html; charset=utf-8
< Content-Length: 835
< 
{ [835 bytes data]
100    835 100    835   0      0  1.13M      0100    835 100    835   0      0  1.08M      0100    835 100    835   0      0  1.04M      00
* shutting down connection #0
lucas@cachyos:~/dev/k8s-study/$ 
lucas@cachyos:~/dev/k8s-study/$ 
lucas@cachyos:~/dev/k8s-study/$ curl -v http://2804:7f0:75c0:3399:7a6e:62c7:c278:a351:8000/ -o /dev/null
* URL rejected: Port number was not a decimal number between 0 and 65535
curl: (3) URL rejected: Port number was not a decimal number between 0 and 65535
lucas@cachyos:~/dev/k8s-study/$ 
lucas@cachyos:~/dev/k8s-study/$ curl -v http://179.98.191.244:8000/ -o /dev/
null
*   Trying 179.98.191.244:8000...
* connect to 179.98.191.244 port 8000 from 192.168.15.7 port 44134 failed: Conexão recusada
* Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect toserver
* closing connection #0
curl: (7) Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect to server
lucas@cachyos:~/dev/k8s-study/$ 
```

1. O que mudou na coluna *Local Address* do `ss` entre `127.0.0.1` e `0.0.0.0`? O que isso significa?

127.0.0.1:8000 -> aponta para o localhost, é uma interface de teste, só acessível de dentro do próprio dispositivo  
0.0.0.0:8000 -> permite conexão de fora do dispositivo  
na primeira situação, o único curl que bate no servidor é o que aponta para o [localhost](http://localhost), ou seja, quando a request sai do próprio dispositivo  
Na segunda situação, onde foi configurado 0.0.0.0, requisições apontando para o [localhost](http://localhost) também foram atendidas normalmente. Mas dessa vez também era possível requisitar o endereço interno da minha interface na rede privada (192.168.15.7) e a conexão foi aberta normalmente  
Também é importante falar que a tentativa de estabelecer conexão passando o IP público da rede não deu certo (192.168.15.7), provavelmente tem que fazer uma configuração manual para mapear 1:1 192.168.15.7:8000 -> 192.168.15.7:8000.

2. Por que o `curl` no seu IP local falhou com `--bind 127.0.0.1`? Qual foi a mensagem?

Possivelmente causado por uma mensagem RST, o processo estava configurado apenas para usar a interface do localhost, que só aceita acesso interno.

```bash
*   Trying 179.98.191.244:8000...
* connect to 179.98.191.244 port 8000 from 192.168.15.7 port 59966 failed: Conexão recusada
* Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect toserver
* closing connection #0
curl: (7) Failed to connect to 179.98.191.244:8000 after 0 ms: Could not connect to server
```

3. Qual a diferença entre as mensagens da porta 8001 e do IP 10.255.255.1? O que cada uma diz sobre **onde** está o problema?

```bash
lucas@cachyos:~/dev/k8s-study/$ curl -v http://127.0.0.1:8001/  
*   Trying 127.0.0.1:8001...
* connect to 127.0.0.1 port 8001 from 127.0.0.1 port 39068 failed: Conexão recusada
* Failed to connect to 127.0.0.1:8001 after 0 ms: Could not connect to server
* closing connection #0
curl: (7) Failed to connect to 127.0.0.1:8001 after 0 ms: Could not connectto server
# Conexão recusada, pois nenhum processo estava "escutando" na porta informada
# RST

lucas@cachyos:~/dev/k8s-study/$ curl -v -m 5 http://10.255.255.1/
*   Trying 10.255.255.1:80...
* Connection timed out after 5004 milliseconds
* closing connection #0
curl: (28) Connection timed out after 5004 milliseconds
# Timeout, endereço não encontrado dentro do tempo de timeout configurado

lucas@cachyos:~/dev/k8s-study/$ nc -zv 127.0.0.1 8000 
Connection to 127.0.0.1 8000 port [tcp/irdmi] succeeded!
lucas@cachyos:~/dev/k8s-study/$ 
# Parece que algum tipo de conexão foi estabelecida, só não entendi como sem o http
```

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
2. O que aparece na conexão para a porta 8001? Por que é isso que gera o "Connection refused"?
3. Qual foi a **porta de origem** do `curl`? De onde ela vem?

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
2. Por que você consegue acessar o IP do container direto do host, mas um colega na mesma rede Wi-Fi não conseguiria?
3. O `EXPOSE 80` da imagem do nginx teve algum papel aqui? Teste com uma imagem que **não** tem `EXPOSE`: `docker run -d --rm --name q0 -p 8003:8000 python:3.12-slim python -m http.server 8000` e depois `curl -sI http://localhost:8003/`.

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
