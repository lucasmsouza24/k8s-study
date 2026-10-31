# Correção — Teoria Docker

Corrigido em 29/10/2026.

Os temas marcados com **(prática)** são cobrados nos exercícios D1–D3.

> Atualização (30/10): a prática deixou de ser avaliação e virou lab de fim de módulo do mapa de estudos (ver `03-resultado.md`). O `gabarito/teoria.md` pode ser lido agora, como material de estudo. O `gabarito/pratica.md` continua fechado até você fazer cada lab.

## Notas

| Pergunta | Nota | Comentário |
|---|---|---|
| D-01 · Container vs VM | 1 | O essencial está certo: o container isola um processo e usa o kernel do host, e a VM traz um SO completo. Faltou dizer **o que** fica isolado (processos, rede, filesystem, hostname, usuários). Sobre o Windows: um container Linux só roda lá dentro de uma VM Linux (WSL2/Hyper-V), justamente porque precisa de um kernel Linux para compartilhar. |
| D-02 · Imagem vs container | 1 | A analogia classe/objeto é boa e correta. Faltou o conceito de **camadas**, que é a base do cache de build e do tamanho da imagem. **Ponto cego**: você se deu nota 3 nesse tema. |
| D-03 · CMD vs ENTRYPOINT | 0 | Está **invertido**: o `CMD` é que é substituído quando você passa um comando no `docker run`. O `ENTRYPOINT` só muda com `--entrypoint`. A diferença entre as formas exec e shell é **(prática)**. |
| D-04 · EXPOSE | 1 | O "não" está certo, mas o `EXPOSE` não abre porta nenhuma, nem no container: é só documentação. O `-p` funciona sem `EXPOSE`. O sentido do mapeamento também ficou ao contrário: o que chega na 8080 do **host** vai para a 8000 do **container**. |
| D-05 · Persistência | 1 | Certo que o `docker rm` apaga e o volume persiste. Erro: **restart** (`stop`/`start`) não apaga os dados, só o `rm`. Faltou a diferença entre volume e bind mount. |
| D-06 · COPY vs ADD | 0 | O `COPY` está descrito corretamente, mas o `ADD` você não conhecia. É um item rápido de aprender. |
| D-07 · Cache de build | 0 | **(prática)** |
| D-08 · Multi-stage | 0 | **(prática)** |
| D-09 · Usuário root | 1 | Nota no limite. A intuição está certa (uma brecha permitiria elevar privilégio no host), mas o `EXPOSE` não tem relação com isso. Faltou o mecanismo e como evitar no Dockerfile, que são **(prática)**. |
| D-10 · .dockerignore | 2 | Boa resposta: cita contexto de build, reprodutibilidade do `node_modules`, arquivos pesados e cache. Ainda falta um problema importante, que é **(prática)**. Sobre a sua dúvida: o que está no `.dockerignore` nem chega ao builder, então um `COPY node_modules/ .` explícito **falha** com "not found". |
| D-11 · Tags | 1 | O problema de reprodutibilidade está certo. Mas `latest` não "busca a mais recente": é só o nome de tag usado quando nenhuma é informada, e pode apontar para qualquer versão. Faltou a parte do digest. |
| D-12 · Redes | 0 | **(prática)** |
| D-13 · Secrets no build | 0 | O `ENV` é inseguro, sim, mas não só para quem entra no container: **quem tem a imagem lê o valor sem nem rodá-la**. Respondendo à sua pergunta: sim, está errado, o `ARG` também fica gravado. A forma correta é **(prática)**. |
| D-14 · Primitivas do kernel | 0 | |
| D-15 · PID 1 e sinais | 0 | **(prática)** |
| D-16 · Limite de memória | 0 | |
| D-17 · Runtimes | 0 | |
| D-18 · Arquitetura de CPU | 0 | |
| D-19 · Imagens base | 1 | A ideia está certa: imagem mais enxuta significa menos superfície de ataque, e o Alpine é outra distro, com outro gerenciador de pacotes (`apk`). Faltou o que mais causa problema na prática (a **biblioteca C** é diferente no Alpine), além das imagens distroless e do trade-off com a facilidade de debug. |

## Totais

| Bloco | Pontos | % |
|---|---|---|
| Docker N1 (D-01 a D-06) | 4 / 12 | 33% |
| Docker N2 (D-07 a D-13) | 4 / 14 | 29% |
| Docker N3 (D-14 a D-19) | 1 / 12 | 8% |
| **Total** | **9 / 38** | **24%** |

## Leitura do resultado

- **Onde você sabe, raciocina bem.** As respostas de D-10 e D-19 mostram que você entende o *porquê* (reprodutibilidade, superfície de ataque), não só decorou.
- **Os "não sei" honestos ajudaram.** Não houve chute disfarçado, então o diagnóstico é confiável.
- **Os erros mais importantes são conceitos invertidos ou mal fixados**, não ausência total de conhecimento: CMD/ENTRYPOINT, `EXPOSE`, `ARG` seguro, `latest` como "a mais recente". Corrigir esses vale mais do que aprender coisa nova, porque hoje eles levam a decisões erradas com convicção.
- **Padrão provável**: você entrou em infra operando clusters que já estavam prontos, então aprendeu Kubernetes/AKS "de cima para baixo" e o Docker ficou para trás. Isso é comum e esperado. Vamos ver se a teoria de Kubernetes confirma.
