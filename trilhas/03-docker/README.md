# Trilha — Docker

Diagnóstico de out/2026: **24%**, nível 0. Ponto cego: camadas e cache (achava 3, mostrou 1). Conceitos invertidos: CMD/ENTRYPOINT, `EXPOSE`, `ARG` "seguro", `latest`.

| # | Módulo | Cobre | Lab | Fase | Status |
|---|---|---|---|---|---|
| 01 | Imagens, camadas e cache: imagem × container, layers, cache e invalidação, tags × digest, OCI e runtimes, multi-arquitetura | D-01, D-02, D-07, D-11, D-17, D-18 | no módulo | 1 | pendente |
| 02 | Dockerfile: CMD × ENTRYPOINT, exec × shell, `EXPOSE`, `COPY` × `ADD`, `.dockerignore`, contexto de build | D-03, D-04, D-06, D-10 | no módulo | 1 | pendente |
| 03 | Dados e redes: ciclo de vida, volume × bind mount, redes user-defined, Compose | D-05, D-12 | [D3](../../avaliacoes/2026-10-diagnostico/02-pratica/docker/d3-compose/) | 1 | pendente |
| 04 | Imagens seguras e enxutas: multi-stage, non-root, secrets no build, imagens base, scan (Trivy) | D-08, D-09, D-13, D-19 | [D1](../../avaliacoes/2026-10-diagnostico/02-pratica/docker/d1-otimizar-dockerfile/), [D2](../../avaliacoes/2026-10-diagnostico/02-pratica/docker/d2-multi-stage/) | 1 | pendente |

O D1 cobre também sinais/PID 1, então faça-o depois de Linux 01.

## Referências

| Fonte | Tipo | Para quê |
|---|---|---|
| [Documentação oficial](https://docs.docker.com) — "Get started", "Dockerfile reference", "Build cache", "Multi-stage builds", "Build secrets", "Networking", "Volumes" | docs | Principal. A doc do Docker é boa e é o que vale na prática |
| *Docker Deep Dive* — Nigel Poulton | livro | Complementar, para o modelo mental de imagens, camadas e runtimes |
| [container.training](https://container.training) — Jérôme Petazzoni | slides de workshop gratuitos | Material de treinamento completo, de Docker a Kubernetes |
| [iximiuz.com](https://iximiuz.com) / [iximiuz Labs](https://labs.iximiuz.com) | artigos e labs | Aprofundamento de imagens, camadas e runtimes |
| [roadmap.sh/docker](https://roadmap.sh/docker) | mapa | Checklist de cobertura no fim da trilha |
| `legacy/003-security-scan` | lab antigo | Trivy, no módulo 04 |
