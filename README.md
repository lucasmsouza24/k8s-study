# k8s-study

Meu histórico de aprendizado em **Docker, Kubernetes e AKS**, e nos assuntos que são base para eles (redes e Linux).

Trabalho com AKS no dia a dia: investigo aplicações quebradas, problemas de autenticação com Key Vault e managed identity, secrets expiradas, ACR, ingress e falta de recursos. Aprendi isso operando em produção, "por sintoma". Este repo é onde eu construo a base que falta: entender **como** as coisas funcionam, e não só como resolver os problemas que eu já vi.

## Onde estou

Ponto de partida, pela [avaliação diagnóstica de out/2026](avaliacoes/2026-10-diagnostico/03-resultado.md):

| Área | Diagnóstico (out/2026) | Agora | Meta da Fase 1 |
|---|---|---|---|
| Docker | 24% · nível 0 | — | nível 1 |
| Kubernetes | 20% · nível 0 | — | nível 1 |
| AKS | 13% · nível 0 | — | — (começa na Fase 2) |

**Estudando agora**: [Redes 01 — IP, TCP/UDP, portas e NAT](trilhas/01-redes/01-ip-tcp-portas-nat/)

## Progresso

| Trilha | Módulos concluídos |
|---|---|
| [Redes](trilhas/01-redes/) | 0 / 4 |
| [Linux](trilhas/02-linux/) | 0 / 2 |
| [Docker](trilhas/03-docker/) | 0 / 4 |
| [Kubernetes](trilhas/04-kubernetes/) | 0 / 15 |
| [AKS](trilhas/05-aks/) | 0 / 5 |
| [Projetos](projetos/) | 0 / 2 |

Plano completo, por fase: [ROADMAP.md](ROADMAP.md).

## Como este repo funciona

```
├── ROADMAP.md          # o plano: fases, módulos, status
├── COMO-ESTUDAR.md     # o método: ciclo de um módulo e definição de pronto
├── REFERENCIAS.md      # índice de materiais e certificações
├── trilhas/            # um diretório por trilha, um subdiretório por módulo
│   └── <trilha>/<NN-modulo>/
│       ├── README.md   #   objetivos, pré-teste, roteiro, status
│       ├── notas.md    #   o que aprendi, com minhas palavras
│       ├── labs/       #   prática, incluindo "quebre de propósito"
│       ├── prova.md    #   prova do módulo (só conclui com nota máxima)
│       └── revisao.md  #   revisão espaçada (D+1, D+7, D+30)
├── avaliacoes/         # diagnóstico inicial e reavaliações por fase
├── projetos/           # projetos integradores de ponta a ponta
├── casos-reais/        # problemas reais do trabalho, anonimizados
├── diario/             # registro de cada sessão de estudo
├── templates/          # modelos para módulo, sessão e caso real
└── legacy/             # labs anteriores à reorganização
```

Para começar um módulo novo: `cp -r templates/modulo trilhas/<trilha>/<NN-nome>`.
