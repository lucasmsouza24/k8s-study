# Trilha — Linux

Container é um processo Linux. Sinais, PID 1, usuários e limites de recursos explicam boa parte dos comportamentos "estranhos" de Docker e Kubernetes (D-09, D-14 a D-16).

| # | Módulo | Fase | Status |
|---|---|---|---|
| 01 | Processos, sinais e permissões: PID, `ps`, SIGTERM × SIGKILL, exit codes (128+n), UID/GID, permissões de arquivo | 1 | pendente |
| 02 | Containers por dentro: namespaces, cgroups v2, overlayfs, capabilities (`unshare`, `nsenter`, `/sys/fs/cgroup`) | 3 | pendente |

## Referências

| Fonte | Tipo | Para quê |
|---|---|---|
| [The Linux Command Line](https://linuxcommand.org/tlcl.php) — William Shotts | livro gratuito | Principal do módulo 01 (capítulos de permissões e processos) |
| [Julia Evans — "How Containers Work"](https://wizardzines.com) | zine | Ponte entre Linux e containers (módulo 02) |
| [iximiuz Labs](https://labs.iximiuz.com) — Ivan Velichko | playgrounds e tutoriais | Principal do módulo 02. Excelente em internals de containers |
| "Containers From Scratch" — Liz Rice (palestra) | vídeo | Container em ~50 linhas de Go: desmistifica namespaces e cgroups |
| *Container Security* — Liz Rice | livro | Aprofundamento do módulo 02 |
