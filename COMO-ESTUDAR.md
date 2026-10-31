# Como estudar

O problema que este método resolve: com os roadmaps do [roadmap.sh](https://roadmap.sh), era fácil passar por muitos tópicos sem aprofundar em nenhum. Aqui a regra é **um módulo por vez, e ele só termina quando cumpre a definição de pronto**.

Os roadmaps continuam úteis, mas como **mapa de cobertura** (para conferir se nada importante ficou de fora), não como sequência de estudo.

## O ciclo de um módulo

Cada módulo vive em `trilhas/<trilha>/<NN-modulo>/`, criado a partir de [`templates/modulo/`](templates/modulo/).

1. **Pré-teste (10 min)**: responda de novo, sem consulta, as perguntas da avaliação que o módulo cobre (estão no README do módulo). Isso ativa o que você já sabe e mostra o que procurar.
2. **Estudo**: use **uma** referência principal e no máximo uma complementar (listadas no módulo). Ler 5 fontes sobre o mesmo assunto é uma forma de procrastinar.
3. **Notas em suas palavras** (`notas.md`): escreva como se estivesse explicando para um colega júnior. Se travar ao explicar algo, é ali que está a lacuna: volte para a fonte. Diagramas (Mermaid) valem muito.
4. **Lab** (`labs/`): primeiro faça funcionar. Depois **quebre de propósito** e registre a tabela *sintoma → causa → como diagnostiquei*. É isso que transforma o seu conhecimento "por sintoma" em conhecimento "por mecanismo".
5. **Prova do módulo** (`prova.md`): sem consulta, responda as perguntas da avaliação do módulo + as perguntas próprias da prova. Critério 0/1/2 (o mesmo da avaliação). Só passa com **2 em todas**. Se não passar, volte ao passo 2 só nos itens que faltaram.
6. **Revisão espaçada** (`revisao.md`): responda as perguntas de revisão em D+1, D+7 e D+30 depois de concluir. Registre a data e se lembrou. Errou? A pergunta volta para o D+1.
7. **Registre**: uma entrada no [diário](diario/) e atualize o status no [ROADMAP](ROADMAP.md) e no [README](README.md).

### Definição de pronto

- [ ] `notas.md` explica todos os objetivos do módulo com suas palavras
- [ ] Lab feito, com pelo menos uma tabela de quebra-de-propósito
- [ ] Prova com nota 2 em todas as perguntas
- [ ] Revisão D+1 feita

## Outras dinâmicas

| Dinâmica | Onde | Quando |
|---|---|---|
| **Checkpoint** | `<modulo>/checkpoints/` | No meio do módulo, quando um subtema terminar: rodada curta de questões antes de seguir para o próximo. Não substitui a prova |
| **Diário de sessão** | `diario/AAAA-MM.md` | Toda sessão, 5 min no final: o que fiz, o que aprendi, dúvidas, próximo passo |
| **Casos reais** | `casos-reais/` | Quando resolver (ou não conseguir resolver) um problema no trabalho. Liga o sintoma ao mecanismo e mostra a evolução no portfólio |
| **Projetos** | `projetos/` | No fim de cada fase. Junta vários módulos em algo real |
| **Reavaliação** | `avaliacoes/` | No fim de cada fase. A mesma avaliação diagnóstica, para medir a evolução |
| **Desafio cronometrado** | [Killercoda](https://killercoda.com) | A partir da Fase 2, para ganhar velocidade (CKAD/CKA são provas contra o relógio) |
| **Ensinar** | um post, uma apresentação para o time | Ao concluir uma trilha. Se consegue ensinar, aprendeu |

## Regras

- **Não pule a prova.** Ler e entender não é o mesmo que saber explicar sem consulta.
- **"Não sei" continua valendo.** A prova é para você, não para os outros.
- **Dúvida que surgir fora do módulo atual vai para "Dúvidas para depois"** no README do módulo, não vira estudo agora.
- **Repo público**: nada de nome de empresa, hosts, IPs, nomes de recursos ou segredos do trabalho, principalmente em `casos-reais/`.
