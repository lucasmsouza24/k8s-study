# Projeto — DNS + TLS de ponta a ponta

| | |
|---|---|
| **Status** | pendente |
| **Fase** | 2 |
| **Pré-requisitos** | Redes 02 (DNS), Redes 03 (HTTP e TLS), Redes 04 (load balancers), Kubernetes 03 (Services e Ingress), AKS 02 (rede), AKS 03 (identidades e Key Vault) |

## Por que este projeto

Na autoavaliação, "solicitar DNS e instalar o certificado em um cluster novo" apareceu nas três perguntas abertas: é a tarefa que você evita, a que não conseguiu resolver, e a que depende de outros times sem que você entenda o processo inteiro. Este projeto existe para você fazer esse processo do zero, sozinho, quantas vezes precisar.

## Entregáveis

1. Uma aplicação acessível em `https://<seu-dominio>` com certificado válido, nas três etapas abaixo.
2. **Um runbook**, em [`runbook.md`](runbook.md) (a criar), explicando o processo para alguém que nunca fez:
   - o que pedir para cada time, e em que ordem (ex.: "registro A de `app.exemplo.com` apontando para o IP X", "certificado para o host Y, no formato Z, guardado no Key Vault W")
   - como verificar cada etapa sozinho (`dig`, `curl -v`, `openssl s_client`)
   - os erros mais comuns e o que cada um significa

## Etapas

### Etapa 1 — Local, certificado autoassinado (minikube)
- Ingress Controller no minikube (`minikube addons enable ingress`)
- Nome local via `/etc/hosts` apontando para o IP do minikube
- Certificado autoassinado gerado com `openssl`, guardado num Secret `kubernetes.io/tls`, usado no Ingress
- Entender por que o navegador e o `curl` reclamam, e o que muda com `curl --cacert`

### Etapa 2 — Local, automatizado (cert-manager)
- cert-manager com uma CA própria (`ClusterIssuer` do tipo CA)
- Certificado emitido e renovado automaticamente a partir de uma annotation no Ingress
- Ver o ciclo: `Certificate` → `CertificateRequest` → Secret

### Etapa 3 — AKS, domínio e certificado reais
- Domínio real (um domínio barato ou subdomínio numa zona do Azure DNS)
- Ingress no cluster de estudo (application routing add-on ou ingress-nginx)
- Registro DNS apontando para o IP do Load Balancer
- Certificado público: Let's Encrypt via cert-manager **ou** certificado no Key Vault integrado ao ingress
- Destruir tudo no fim (custo)

## Registro

| Etapa | Data | Tempo | Dificuldades |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
