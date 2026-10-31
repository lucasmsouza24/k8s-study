# Teoria — Cenários

Perguntas abertas, sem resposta única. O que se avalia aqui é o **raciocínio**: quais hipóteses você levanta, em que ordem investiga, quais comandos usaria e como confirmaria a causa. Escreva como se estivesse explicando para um colega durante um incidente.

Livro fechado.

---

### C-01 · Deploy que não sobe

Você fez o deploy de uma nova versão da API no AKS. O pipeline passou, mas 10 minutos depois o `kubectl get pods` mostra os pods novos em `CrashLoopBackOff` e os antigos ainda rodando. Os usuários não reclamaram.

a) Por que os usuários não foram afetados?
b) Descreva sua investigação passo a passo.
c) Como você reverte enquanto investiga?

> a) por que os pods antigos não foram substituidos  
> não sei como eu faria as demais partes

### C-02 · Lentidão intermitente

Uma API em Python fica lenta (p99 de 200ms para 3s) em alguns momentos do dia, sem erros. O uso de CPU no Grafana mostra o pod em torno de 50% do limit. A equipe diz "não é CPU, está em 50%". Quais hipóteses você levantaria e como investigaria cada uma?

>

### C-03 · "Funciona no meu Docker, não funciona no cluster"

Um dev diz: "a imagem roda perfeitamente com `docker run` na minha máquina, mas no cluster o pod não fica pronto". Liste pelo menos cinco causas possíveis (diferenças entre os dois ambientes) e como verificar cada uma.

>

### C-04 · Pod Pending após escala

Na Black Friday, o HPA escalou o Deployment de 5 para 20 réplicas. 8 réplicas ficaram em `Pending` por 15 minutos. O Cluster Autoscaler está habilitado. O que pode estar acontecendo? Liste as hipóteses e onde verificar cada uma.

>

### C-05 · Desenho de um ambiente

Você vai colocar em produção no AKS um sistema com: uma API pública (HTTP), um worker que consome uma fila do Service Bus, e um banco PostgreSQL. Descreva como estruturaria isso no Kubernetes/Azure: quais objetos/serviços, onde fica o banco, como os segredos chegam até os pods, como expor a API, como escalar o worker e o que monitorar. Não precisa de YAML, só a arquitetura e as justificativas.

>
