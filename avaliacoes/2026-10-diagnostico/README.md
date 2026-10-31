# Avaliação de nível — Docker, Kubernetes e AKS

Objetivo: descobrir **de onde partir** no mapa de estudos. Não é uma prova para "passar" — é um diagnóstico. Uma resposta "não sei" honesta vale mais do que um chute certo, porque o chute esconde exatamente o buraco que o mapa precisa cobrir.

## Estrutura

```
avaliacoes/2026-10-diagnostico/
├── 00-autoavaliacao.md        # responda ANTES de tudo (5 min)
├── 01-teoria/
│   ├── 01-docker.md
│   ├── 02-kubernetes.md
│   ├── 03-aks.md
│   └── 04-cenarios.md         # troubleshooting e design, respostas abertas
├── 02-pratica/
│   ├── README.md              # pré-requisitos e como rodar
│   ├── _shared/               # funções usadas pelos check.sh
│   ├── docker/
│   │   ├── d1-otimizar-dockerfile/
│   │   ├── d2-multi-stage/
│   │   └── d3-compose/
│   └── kubernetes/
│       ├── k1-troubleshooting/
│       ├── k2-do-zero/
│       ├── k3-operacao/
│       └── k4-crashloop/
├── 03-resultado.md            # planilha de pontuação e definição de nível
├── correcao/                  # correções comentadas de cada parte já feita
└── gabarito/                  # NÃO abra antes de terminar
```

## Ordem sugerida

| Etapa | O que fazer | Tempo estimado |
|---|---|---|
| 1 | `00-autoavaliacao.md` | 5 min |
| 2 | Teoria Docker | 40 min |
| 3 | Prática Docker (D1 → D3) | 1h30 |
| 4 | Teoria Kubernetes | 1h |
| 5 | Prática Kubernetes (K1 → K4) | 2h30 |
| 6 | Teoria AKS + cenários | 1h |
| 7 | Correção e `03-resultado.md` | 30 min |

Não precisa fazer tudo de uma vez — dá pra dividir em 3 ou 4 sessões. O que importa é **não estudar entre as sessões** os tópicos que ainda vão cair, senão o diagnóstico perde valor.

## Regras

**Teoria — "livro fechado"**
- Sem consultar docs, Google ou IA. Responda com o que você sabe hoje.
- Se não souber, escreva `não sei`. Se souber parcialmente, escreva o que sabe e marque `(parcial)`.
- Pode e deve usar exemplos do seu dia a dia no trabalho — isso conta muito.

**Prática — "como na certificação"**
- Pode consultar **somente** a documentação oficial: [docs.docker.com](https://docs.docker.com), [kubernetes.io/docs](https://kubernetes.io/docs) e `kubectl explain` / `--help`. É o mesmo critério da CKA/CKAD.
- Sem IA, sem Stack Overflow, sem copiar de outros labs deste repo.
- Anote o tempo gasto em cada exercício e quantas vezes precisou consultar a doc — isso entra no resultado (fluência é diferente de saber).
- Cada exercício tem um `check.sh` que valida o resultado. Rode quantas vezes quiser.

## Correção

Duas opções (pode usar as duas):

1. **Auto-correção**: compare com `gabarito/teoria.md` e `gabarito/pratica.md` usando o critério 0 / 1 / 2 descrito em `03-resultado.md`.
2. **Correção pelo agente**: depois de responder, peça "corrija minha avaliação em `avaliacoes/2026-10-diagnostico/`". O agente lê suas respostas inline e preenche o resultado. Geralmente é mais preciso em respostas parciais.

Com o resultado em mãos, o próximo passo é montar o mapa de estudos partindo do nível identificado.
