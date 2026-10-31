# Resultado

> **Status (30/10/2026): diagnóstico fechado com base na teoria.** Feitos: autoavaliação e teoria de Docker, Kubernetes e AKS (Parte A). Não feitos: cenários, AKS Parte B (sem acesso ao cluster) e a prática, que foi convertida em labs do mapa de estudos (ver "Próximos passos").
>
> Correções detalhadas: `correcao/01-docker-teoria.md`, `correcao/02-kubernetes-teoria.md`, `correcao/03-aks-teoria.md`.

## Critério de pontuação da teoria

Cada pergunta vale de 0 a 2:

| Nota | Critério |
|---|---|
| 0 | Não sabe, ou resposta errada no essencial |
| 1 | Parcial: acerta a ideia geral mas falta mecanismo, ou tem erro relevante |
| 2 | Completa: explica o **porquê** (mecanismo), não só o **o quê** |

## Teoria

| Bloco | Perguntas | Máx | Pontos | % |
|---|---|---|---|---|
| Docker N1 | D-01 a D-06 | 12 | 4 | 33% |
| Docker N2 | D-07 a D-13 | 14 | 4 | 29% |
| Docker N3 | D-14 a D-19 | 12 | 1 | 8% |
| Kubernetes N1 | K-01 a K-06 | 12 | 5 | 42% |
| Kubernetes N2 | K-07 a K-18 | 24 | 4 | 17% |
| Kubernetes N3 | K-19 a K-28 | 20 | 2 | 10% |
| AKS conceitos | A-01 a A-12 | 24 | 3 | 13% |
| AKS cluster real | B-01 a B-08 | 16 | — | sem acesso |
| Cenários | C-01 a C-05 | 10 | — | não feito |

## Níveis

| Nível | Nome | Docker | Kubernetes | AKS |
|---|---|---|---|---|
| 0 | Iniciante | Docker N1 < 70% | Kubernetes N1 < 70% | AKS conceitos < 40% |
| 1 | Usuário | N1 ≥ 70% | N1 ≥ 70% e K1 concluído (mesmo fora do tempo) | conceitos ≥ 40% |
| 2 | Operador | N2 ≥ 70%, D1–D3 concluídos | N2 ≥ 70%, K1–K3 concluídos | conceitos ≥ 70%, cluster real ≥ 60% |
| 3 | Avançado | N3 ≥ 60%, D1–D3 fluentes | N3 ≥ 60%, K1–K4 fluentes, cenários ≥ 60% | conceitos ≥ 85%, cluster real ≥ 85%, C-04 e C-05 ≥ 1 |

- **Iniciante**: usa por receita, copia de exemplos, não sabe por que algo funciona.
- **Usuário**: entende os objetos básicos, consegue fazer deploy e resolver problemas óbvios com ajuda.
- **Operador**: opera aplicações em produção com autonomia. É o nível da CKAD.
- **Avançado**: entende os mecanismos internos, resolve problemas não óbvios, desenha ambientes. É o nível da CKA.

## Meu resultado

| Área | Nível | Observações |
|---|---|---|
| Docker | 0 — Iniciante | N1 em 33%. Conceitos básicos invertidos (CMD/ENTRYPOINT, `EXPOSE`, `ARG`). |
| Kubernetes | 0 — Iniciante | N1 em 42%, é a área mais perto do nível 1. O que você sabe vem da operação: troubleshooting por sintoma, labels, requests. |
| AKS | 0 — Iniciante | 13%. Você conhece o que usa (MI/WIF, akv2k8s), mas não a infraestrutura em volta do cluster (rede, identidades, LB, ingress). |

### Diagnóstico

Pela teoria, você é **iniciante nas três áreas, com conhecimento operacional real "por sintoma"**: sabe que um Pending é falta de recurso, que um OOM é memória, que uma secret expirada no KV derruba a autenticação. Sabe também como resolver isso **no seu ambiente**. O que falta é o modelo de como as peças funcionam por baixo, que é o que permite resolver problemas que você ainda não viu e fazer tarefas novas (como DNS + certificado) sem medo.

Isso não é o mesmo que "não saber nada". Quem aprendeu em produção costuma estar exatamente aqui, e o caminho é mais rápido do que para quem parte do zero, porque cada conceito novo se encaixa em algo que você já viu acontecer.

## Autoavaliação vs. realidade

| Tema | Achei (0-4) | Mostrei (0-4) | Tipo |
|---|---|---|---|
| Imagem vs container, camadas, cache de build | 3 | 1 | **ponto cego** |
| Pods, Deployments, ReplicaSets | 3 | 1 | **ponto cego** |
| Troubleshooting de pods | 3 | 1 | **ponto cego** (a confirmar com K1) |
| Ingress / Gateway API | 2 | 0 | **ponto cego** |
| Integração AKS + ACR | 2 | 0 | **ponto cego** |

Os demais temas ficaram calibrados (diferença menor que 2). Não houve nenhum caso de insegurança (saber mais do que achava).

**O padrão é claro: todos os pontos cegos são temas que você usa no dia a dia.** Operar algo repetidamente dá a sensação de domínio, mas o que você domina é o *procedimento* no seu ambiente, não o *mecanismo*. Nos temas que você não usa, sua autoavaliação foi precisa. Isso é um bom sinal (você sabe medir o que não sabe) e mostra onde focar: **o que você já faz é por onde começar**, porque é onde a falta de base mais te expõe hoje.

## Lacunas prioritárias

1. **Fundamentos de rede** (não avaliados diretamente, mas aparecem como causa raiz em Docker, Services, Ingress, AKS e no problema de DNS/certificado): IP, portas, NAT, DNS, HTTP, TLS e load balancer.
2. **Docker N1/N2**: camadas e cache, instruções do Dockerfile (CMD/ENTRYPOINT, exec × shell, `EXPOSE`), ciclo de vida e volumes, redes, segredos e non-root.
3. **Kubernetes, o caminho do deploy e do tráfego**: arquitetura, Deployment → ReplicaSet → Pod, **probes**, **rolling update/rollback**, tipos de Service, DNS interno, Ingress.
4. **Kubernetes, configuração e recursos**: ConfigMap/Secret (base64, atualização), requests/limits/QoS, HPA, labels × annotations.
5. **AKS, a infra em volta do cluster**: responsabilidade do control plane, node pools e `MC_`, identidades (cluster × kubelet × workload identity), ACR, LoadBalancer, opções de ingress.
6. **DNS + certificado TLS de ponta a ponta**: o seu problema real, e o projeto que fecha os itens 1, 3 e 5.

Depois disso, N3: arquitetura interna, scheduling, NetworkPolicy, RBAC a fundo, graceful shutdown, upgrades, observabilidade, Helm/GitOps.

## Observações para o mapa

- **DNS + certificados TLS em cluster novo** entra como projeto de conclusão da trilha de AKS:
  - como um domínio chega até o ingress (registro DNS → IP do LB/App Gateway)
  - o que é um certificado e quem o emite (CA, CSR, cadeia)
  - onde ele fica (Key Vault / Secret TLS)
  - como o ingress o usa
  - automação (cert-manager / integração com Key Vault)
- Sem acesso de leitura ao cluster do trabalho, os labs são no minikube. Para AKS, vale considerar um cluster próprio de estudo (o `legacy/004-aks/` já cria um, no tier Free, com 1 nó) ligado só durante as sessões.
- Itens da Parte B que dá para responder pelo repo/pipeline da sua aplicação: B-03, B-05, B-06 e B-08. São opcionais, mas ancoram o estudo no seu ambiente.

## Próximos passos

- **A prática deixa de ser avaliação e vira lab de fim de módulo.** Com N1 abaixo de 70%, ela não mudaria nenhum nível, e fazê-la agora seria frustrante e pouco informativo. Os exercícios funcionam muito bem como checkpoint depois de estudar cada tema:

  | Lab | Depois do módulo de |
  |---|---|
  | D1, D2 | Dockerfile, camadas, segurança da imagem |
  | D3 | redes e volumes |
  | K1 | probes, Services, troubleshooting |
  | K2 | workloads, config, recursos |
  | K3 | rollout, HPA, RBAC, NetworkPolicy |
  | K4 | probes avançadas e OOM |

- **Exceção opcional: K1 (30 min) agora.** É o único ponto cego que a teoria pode estar subestimando: você faz troubleshooting todo dia, talvez saiba *fazer* mais do que conseguiu *explicar*. Se passar no K1 sozinho, o item "troubleshooting" sai da lista de pontos cegos.
- `gabarito/teoria.md` pode ser lido agora, como material de estudo. `gabarito/pratica.md` continua fechado até você fazer cada lab.
- **Cenários (`04-cenarios.md`)**: guarde para o fim do mapa. Junto com uma nova rodada desta avaliação (daqui a uns 2–3 meses), eles servem para medir a evolução.
