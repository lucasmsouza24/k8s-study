# Trilha — Kubernetes

Diagnóstico de out/2026: **20%**, nível 0 (N1 em 42%, a área mais perto do nível 1). Pontos cegos: Pods/Deployments/ReplicaSets, troubleshooting e Ingress. O que você sabe vem da operação: falta o modelo de como as peças se encaixam.

| # | Módulo | Cobre | Lab | Fase | Status |
|---|---|---|---|---|---|
| 01 | Arquitetura e o caminho do `apply`: componentes, reconciliation loop, declarativo × imperativo | K-01, K-06, K-19, K-20 | no módulo | 1 | pendente |
| 02 | Workloads: Pod, ReplicaSet, Deployment, Job, CronJob, DaemonSet, StatefulSet; labels × annotations | K-02, K-15, K-17 | no módulo | 1 | pendente |
| 03 | Services, DNS e Ingress: tipos de Service, EndpointSlices, DNS interno, Ingress Controller, Gateway API | K-03, K-05, K-12, K-13 | [K1](../../avaliacoes/2026-10-diagnostico/02-pratica/kubernetes/k1-troubleshooting/) | 1 | pendente |
| 04 | ConfigMaps e Secrets: env × volume, atualização, base64 × criptografia | K-04, K-14 | no módulo + `legacy/001` | 1 | pendente |
| 05 | Recursos, QoS e probes: requests/limits, throttling × OOM, QoS, liveness/readiness/startup, diagnóstico de status | K-07, K-08, K-09, K-10 | [K4](../../avaliacoes/2026-10-diagnostico/02-pratica/kubernetes/k4-crashloop/) + `legacy/002` | 1 | pendente |
| 06 | Rollout, rollback e estratégias: rolling update, maxSurge/maxUnavailable, histórico, blue-green, canary | K-11 | [K3](../../avaliacoes/2026-10-diagnostico/02-pratica/kubernetes/k3-operacao/) (1–4) + `legacy/deployment-patterns` | 1 | pendente |
| 07 | Storage: PV, PVC, StorageClass, access modes | K-16 | no módulo | 2 | pendente |
| 08 | Autoscaling: HPA, metrics-server | K-18 | K3 (5) | 2 | pendente |
| 09 | RBAC e ServiceAccounts | K-24 | K3 (6) + `legacy/006-security` | 2 | pendente |
| 10 | NetworkPolicy | K-23 | K3 (7) | 2 | pendente |
| 11 | Segurança de pods: securityContext, Pod Security Standards | K-27 | no módulo + `legacy/003` | 2 | pendente |
| 12 | Helm, Kustomize e GitOps | K-28 | no módulo | 2 | pendente |
| 13 | Scheduling: affinity, taints/tolerations, topology spread | K-22 | no módulo | 3 | pendente |
| 14 | Graceful shutdown e disrupções: SIGTERM × endpoints, preStop, PDB, drain | K-25, K-26 | no módulo | 3 | pendente |
| 15 | Internals: controllers, kube-proxy, CNI | K-19, K-20, K-21 | Kubernetes the Hard Way | 3 | pendente |

Lab integrador da Fase 2: [K2](../../avaliacoes/2026-10-diagnostico/02-pratica/kubernetes/k2-do-zero/).

## Referências

| Fonte | Tipo | Para quê |
|---|---|---|
| [Documentação oficial](https://kubernetes.io/docs/) — seções *Concepts* e *Tasks* | docs | Principal. É a única fonte permitida nas provas CKAD/CKA, então vale se acostumar |
| *Kubernetes: Up and Running* — Burns, Beda, Hightower, Villalba | livro | Complementar para a Fase 1; claro e prático |
| *Kubernetes in Action* — Marko Lukša | livro | Complementar mais profundo, ótimo para "como funciona por dentro" |
| [learnk8s.io](https://learnk8s.io) | artigos | Guia visual de troubleshooting de Deployments (módulo 05) e graceful shutdown (módulo 14) |
| [Killercoda](https://killercoda.com) | cenários interativos gratuitos | Prática no navegador, incluindo cenários de CKAD/CKA |
| [CNCF curriculum](https://github.com/cncf/curriculum) | currículo oficial | Conteúdo cobrado em KCNA, CKAD e CKA |
| [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) — Kelsey Hightower | tutorial | Módulo 15: montar um cluster na mão, componente por componente |
| *Kubernetes Patterns* — Ibryam & Huß | livro | Fase 3, padrões de design |
| [roadmap.sh/kubernetes](https://roadmap.sh/kubernetes) | mapa | Checklist de cobertura ao fim de cada fase |
