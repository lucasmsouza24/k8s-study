# Trilha — Redes

Não foi avaliada diretamente, mas apareceu como causa raiz em quase todas as lacunas: `EXPOSE`/`-p` (NAT), DNS dos Services, Ingress (proxy L7), Load Balancer no AKS, CNI e consumo de IPs, e a tarefa de DNS + certificado. 

| # | Módulo | Fase | Status |
|---|---|---|---|
| 01 | [IP, TCP/UDP, portas e NAT](01-ip-tcp-portas-nat/) | 1 | pendente |
| 02 | DNS: resolução, registros (A, CNAME, TXT), TTL, `resolv.conf` | 1 | pendente |
| 03 | HTTP e TLS: status codes (502 × 503 × 504), handshake TLS, certificados, CA, cadeia, SNI | 1 | pendente |
| 04 | Load balancers e proxies: L4 × L7, reverse proxy, health checks | 1 | pendente |

## Referências

| Fonte | Tipo | Para quê |
|---|---|---|
| [Julia Evans — zines](https://wizardzines.com) ("Networking! ACK!", "How DNS Works", "HTTP: Learn your browser's language") | zines curtos, pagos | Principal. Visual e direto ao ponto; ótimo para quem aprende fazendo |
| [Mess With DNS](https://messwithdns.net) | playground | Criar registros DNS de verdade e ver o que acontece (módulo 02) |
| [Cloudflare Learning Center](https://www.cloudflare.com/learning/) | artigos gratuitos | Explicações curtas de DNS, TLS, load balancing, CDN |
| [High Performance Browser Networking](https://hpbn.co) — Ilya Grigorik | livro gratuito online | Capítulos de TCP, TLS e HTTP, com mais profundidade |
| *Computer Networking: A Top-Down Approach* — Kurose & Ross | livro | Referência acadêmica, para consulta pontual (não ler inteiro) |

Ferramentas que você vai usar: `ip`, `ss`, `curl -v`, `dig`, `nc`, `tcpdump`, `openssl s_client`, `ipcalc`.
