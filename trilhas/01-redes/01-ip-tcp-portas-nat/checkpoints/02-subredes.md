# Checkpoint 02 — Sub-redes e CIDR

Duas partes:

- **Parte A — Conceitos**: dá para fazer só com o artigo da Cloudflare sobre sub-rede e o que você já sabe de IP.
- **Parte B — Máscara em binário e CIDR**: faça **depois** do complemento listado no roteiro do módulo (item 1b). O artigo da Cloudflare não cobre esses cálculos.

Regras: sem consulta (exceto onde indicado), `não sei` vale, critério 0/1/2. Ao terminar cada parte, peça: "corrija o checkpoint `trilhas/01-redes/01-ip-tcp-portas-nat/checkpoints/02-subredes.md`, parte A" (ou B).

| Parte | Data | Pontos | Itens para reler |
|---|---|---|---|
| A | 2026-11-01 | 10 / 12 | A3 e A4: quem usa a máscara e como o host decide entre entrega direta e gateway |
| B | 2026-11-01 | 13 / 18 | conversão de octetos "quebrados" (B1); divisão em sub-redes (B5); faixas privadas (B6, B7) |
| Extras | 2026-11-02 | 6 / 8 | limites exatos de `172.16.0.0/12`; sempre escrever o CIDR junto com a máscara |

Depois de ler as correções, faça os [exercícios extras](#exercícios-extras) no fim do arquivo.

---

## Parte A — Conceitos

### A1 · Para que servem

O que é uma sub-rede? Por que dividir uma rede grande em sub-redes? Cite pelo menos dois benefícios.

> Subredes são segmentações lógicas dentro de redes. Um dos benefícios é organização, é mais fácil aplicar regras à subredes que estão separadas por departamento do que adicionar regras à cada endereço de host em uma grande rede. Além disso, o uso de subredes pode reduzir a taxa de transmissão em casos como descoberta de DHCP, que envia solicitação para todos os hosts da subrede, eviando degração da rede como um todo.

**Correção — 2/2.** Dois benefícios certos, e o segundo é dos mais importantes. O nome técnico é **domínio de broadcast**: mensagens enviadas "para todos" (como a descoberta do DHCP) ficam restritas à sub-rede. Só um ajuste de termo: o que diminui é o **tráfego de broadcast** que cada host recebe, não a "taxa de transmissão". Outro benefício que você vai ver muito no Azure: isolamento e segurança. NSGs e regras de firewall são aplicados por subnet.

### A2 · As duas partes do endereço

Um endereço IP tem duas partes. Quais são e o que cada uma identifica? Use como exemplo o seu IP, `192.168.15.6`, com a máscara `255.255.255.0`.

> A máscara 255.255.255.0 (11111111.11111111.11111111.00000000) é utilizada para declarar quais bits do meu endereço representam rede e quais repretentam a faixa de hosts (em binário). Nesse caso os 24 primeiros bits representam rede, e os últimos 8 representam a faixa de hosts.
>
> 192.168.15.0 -> endereço da subrede  
> 192.168.15.1 - 192.168.15.254 -> faixa de valores possíveis  
> 192.168.15.255 -> broadcast

**Correção — 2/2.** Muito bom, você já foi além da pergunta, com rede, faixa e broadcast. Para fechar o que foi perguntado: no `192.168.15.6`, a **parte de rede** é `192.168.15` (identifica a sub-rede) e a **parte de host** é `6` (identifica a interface dentro dela).

### A3 · A máscara

Para que serve a máscara de sub-rede? Ela viaja dentro do pacote? Quem a usa, e para decidir o quê?

> A máscara de subrede serve para que o endereço IP seja lido da forma correta, com a separação correta entre endereço de rede e de host. Não sei exatamente se a máscara de rede viaja junto com o pacote nem quem a usa.

**Correção — 1/2.** A função está certa. As duas partes que faltaram:

- A máscara **não viaja no pacote**. O cabeçalho IP só leva os endereços de origem e destino. A máscara é **configuração de cada interface**: o seu notebook recebeu a dele do DHCP, junto com o IP (é o `/24` do `192.168.15.6/24` na sua Q10).
- **Quem usa**: todo equipamento, cada um com a própria configuração.
  - O **seu notebook** usa a máscara para decidir se o destino está na mesma sub-rede (entrega direto) ou não (manda para o gateway). Esse é o uso mais frequente, e é a A4.
  - Os **roteadores** guardam prefixos na tabela de rotas (ex.: `10.0.0.0/8 → saída X`) e escolhem a rota **mais específica** que contém o destino, o que se chama *longest prefix match*.

### A4 · Mesma rede ou não

O seu notebook (`192.168.15.6`, máscara `255.255.255.0`) vai enviar um pacote para `192.168.15.20` e outro para `192.168.16.20`. O que ele faz de diferente em cada caso? (pense na Q8 do checkpoint 01)

> O destino do primeiro pacote está na mesma subrede da origem do pacote, então acredito que o caminho seja de certa forma mais curto. Já o segundo destino está em uma subrede diferente (pode ser até um endereço de fora da rede), então o pacote fara um caminho mais longo. Será entregue para o roteador, e o mesmo verificará sua tabela de rotas, ao onão encontrar vai mandar para o próximo salto, até que chegue em seu destino.

**Correção — 1/2.** O segundo caso está certo: o pacote vai para o gateway e segue salto a salto (evoluiu bem desde a Q8 do checkpoint 01). Faltou o mecanismo da decisão e o que acontece no primeiro caso:

- **Como o notebook decide**: ele aplica a máscara ao próprio IP e ao IP de destino, e compara as partes de rede. `192.168.15.6` e `192.168.15.20` → `192.168.15` = `192.168.15`: mesma rede. `192.168.16.20` → `192.168.16` ≠ `192.168.15`: outra rede.
- **Mesma rede**: o pacote é entregue **diretamente** ao destino, sem passar por roteamento. O notebook descobre o endereço físico (MAC) do destino com o protocolo **ARP** e envia. "Caminho mais curto" é a ideia certa, mas o ponto é que **nenhum roteador decide nada**.
- **Outra rede**: vai para o **default gateway**. Um detalhe: o roteador não manda para o próximo salto "ao não encontrar". Ele **sempre** encontra uma rota, mesmo que seja a rota padrão, e é ela que diz qual é o próximo salto.

### A5 · 255 e 0

Por que a máscara `255.255.255.0` usa justamente 255 e 0? O que esses dois números significam quando você pensa em bits? (pense na Q2 do checkpoint 01)

> Na representação em binário da máscara, cada bit de valor 1 representa o endereço de rede, e cada bit de valor 0 representa endereços de host.  
> 255.255.255.0 -> 11111111.11111111.11111111.00000000  
> como nesse caso são 8 zeros, é possível representar 2⁸ valores em binário, ou seja 256 (0 -> 255)  
> Obs: 2 desses endereços são sempre reservados, o primeiro para representar a rede e o último para representar o broadcast (comunicação com todos os hosts)

**Correção — 2/2.** Exato: 255 é um octeto com os 8 bits em 1 (parte de rede) e 0 é um octeto com os 8 bits em 0 (parte de host). A regra completa é que uma máscara é sempre uma sequência **contínua** de 1s seguida de 0s, e por isso só existem 9 valores possíveis para um octeto de máscara: 0, 128, 192, 224, 240, 248, 252, 254 e 255. Decorar essa lista ajuda muito no B1.

### A6 · Raciocínio

Na sua máquina, o `docker0` tem `172.17.0.1/16` e a rede do minikube tem `192.168.49.1/24`. O artigo diz que `192.0.2.0/24` é a rede identificada por "192.0.2". Sem calcular nada: o que você acha que o `/24` e o `/16` significam? Qual das duas redes comporta mais endereços?

> /24 ou /16 são somente outras formas de representar as máscaras. /24 indica que 24 bits são utilizados para representar a rede, enquanto o restante para hosts (32-24=8 -> 255.255.255.0).  
> A mesma coisa para /16: 16 bits para rede, 16 bits para hosts (32-16=16 -> 255.255.0.0)

**Correção — 2/2.** Deduziu certo, sem ter estudado CIDR. Só faltou dizer explicitamente qual comporta mais: o `docker0` (`/16`, 2¹⁶ = 65.536 endereços) contra o minikube (`/24`, 2⁸ = 256). Fixe a intuição: **quanto menor o número depois da barra, maior a rede**.

---

## Parte B — Máscara em binário e CIDR

Faça depois do complemento do roteiro (item 1b).

### B1 · Máscara em binário

Escreva `255.255.255.0` e `255.255.240.0` em binário. Quantos bits de rede cada uma tem? Qual a notação CIDR equivalente de cada uma?

> 255.255.255.0 -> 11111111.11111111.11111111.00000000 -> /24
>
> 255.255.240.0 -> 11111111.11111111.11100000 -> /19

**Correção — 1/2.** A primeira está certa. Na segunda, dois erros:

- **240 = 11110000**, não 11100000. O valor de cada bit, da esquerda para a direita, é `128 64 32 16 8 4 2 1`. Então 128 + 64 + 32 + 16 = 240 são **quatro** bits em 1. O `11100000` vale 224.
- Faltou o quarto octeto (`.00000000`). Escrever os 32 bits sempre ajuda a não errar a contagem.

Resposta: `11111111.11111111.11110000.00000000` = 8 + 8 + 4 = **/20**.

### B2 · Tamanhos

Quantos endereços existem em um `/24`, `/16`, `/26` e `/30`? Quantos deles podem ser usados por hosts, e por que se descontam dois?

> Se desconta dois, porque o primeiro e último valor são usados pra representar, respectivamente, endereço da rede e broadcast.  
> /24 -> 2⁸-2 = 254 valores possíveis  
> /16 -> 2¹⁶-2 = 65534 valores possíveis  
> /26 -> 2⁶-2 = 62 valores possíveis  
> /30 -> 2²-2 = 2 valores possíveis

**Correção — 2/2.** Correto, e o motivo também. Para completar, os totais são 256, 65.536, 64 e 4. Na nuvem a conta muda: o Azure reserva **5** endereços por subnet, não 2 (é a B8).

### B3 · Rede e broadcast

Para `192.168.15.6/24`, quais são o endereço de rede, o endereço de broadcast, o primeiro e o último endereço utilizável?

> rede: 192.168.15.0  
> broadcast: 192.168.15.255  
> faixa de valores utilizáveis: 192.168.15.1 -> 192.168.15.254

**Correção — 2/2.** Correto.

### B4 · Pertence ou não

O IP `10.240.5.10` pertence a `10.240.0.0/16`? E a `10.240.0.0/24`? E a `10.240.4.0/22`? Mostre como chegou na resposta.

> `10.240.5.10` pertence à `10.240.0.0/16`  
> `10.240.5.10 não pertence à 10.240.0.0/24 (é outra rede)`  
> `10.240.5.10 pertence à 10.240.4.0/22`  
> Cheguei na resposta avaliando se o endereço em questão está entre a faixa de valores válidos dado o barramento + endereço de rede. para os 2 primeiros foi fácil, mas exigiu um pouco mais de mim para o último, por conta do valor misto no terceiro octal.  
> /22 -> 11111111.11111111.11111100.00000000 -> 22 bits rede, 10 bits hosts  
> o terceiro octal do endereço já possui o valor 4 em decimal e 000001[00] em binário, sendo os bits em colchete reservados para host (ou seja, pode chegar até 000001[11] (7 em decimal). o que significa que os endereços ficam definidos da seguinte forma:  
> rede: 10.240.4.0  
> broadcast: 10.240.7.255  
> faixa válida: 10.240.4.1 -> 10.240.7.254  
> e como o endereço está dentro da faixa válida, eu entendo que o valor faz parte da rede sim.

**Correção — 2/2.** As três respostas estão certas, e o raciocínio do `/22` em binário é exatamente o método certo: foi a melhor resposta do checkpoint. Três ajustes:

- Faixa válida do `/22`: vai até `10.240.7.**254**`. O `.255` é o broadcast, como você mesmo escreveu na linha de cima.
- **Octeto**, não "octal". Octal é a base 8; cada grupo de 8 bits do IP é um *octeto*.
- "Barramento" não é um termo de redes: você quis dizer **máscara** (ou prefixo).

### B5 · Dividindo uma rede

Divida `192.168.10.0/24` em 4 sub-redes do mesmo tamanho. Qual o prefixo de cada uma e quais são as faixas (rede até broadcast)?

> sendo sincero eu ainda não li sobre o aspecto múltiplas subredes, não entendo bem como funciona e não sei representar as configurações, então pensei bastante pra separar as subnets mas não tenho certeza de nada:  
>
> subnet 1:  
> 192.168.10.0/25  
> rede 192.168.10.0  
> broadcast 192.168.10.63  
> faixa 192.168.10.1 -> 192.168.10.62  
>
> subnet 2:  
> 192.168.10.64/25  
> rede 192.168.10.64  
> broadcast 192.168.10.128  
> faixa 192.168.10.65 - 192.168.10.127  
>
> subnet 3:  
> 192.168.10.129/25  
> rede 192.168.10.129  
> broadcast 192.168.10.192  
> faixa 192.168.10.130 -> 192.168.10.191  
>
> subnet 4:  
> 192.168.10.193/25  
> rede 192.168.10.193  
> broadcast 192.168.10.255  
> faixa 192.168.10.194 -> 192.168.10.254

**Correção — 1/2.** A intuição principal está certa: você dividiu 256 por 4 e chegou a blocos de **64** endereços, sem ter estudado o assunto. Os erros:

- **O prefixo é** `/26`, não `/25`. Para dividir em 4, você "empresta" 2 bits da parte de host para a parte de rede (2² = 4 sub-redes): 24 + 2 = **26**. Um `/25` divide o `/24` em só **2** pedaços de 128, o que não bate com os blocos de 64 que você mesmo calculou. Confira: `/26` → 32 − 26 = 6 bits de host → 2⁶ = 64.
- **Os limites desalinharam a partir da sub-rede 2.** A regra é: o endereço de rede é sempre um **múltiplo do tamanho do bloco** (0, 64, 128, 192), e o broadcast é **o endereço de rede da próxima sub-rede menos 1**.

| Sub-rede | Rede | Hosts utilizáveis | Broadcast |
|---|---|---|---|
| `192.168.10.0/26` | .0 | .1 – .62 | .63 |
| `192.168.10.64/26` | .64 | .65 – .126 | .127 |
| `192.168.10.128/26` | .128 | .129 – .190 | .191 |
| `192.168.10.192/26` | .192 | .193 – .254 | .255 |

Atalho para achar o tamanho do bloco: **256 − o valor do octeto "quebrado" da máscara**. Num `/26`, a máscara é `255.255.255.192`, e 256 − 192 = 64.

### B6 · Classes × CIDR

As classes A, B e C do artigo da Cloudflare ainda são usadas? O que o CIDR mudou, e por quê? Por que a faixa privada `172.16.0.0/12` não se encaixa em nenhuma classe?

> Até onde eu entendi todas as classes são obsoletas, a notação CIDR substituiu todas por ter uma forma bastante personalizada de definir os tamanhos das subnets e com o modelo de classes muitas vezes diversos valores de host ficavam subutilizados. não sei a resposta para a segunda pergunta

**Correção — 1/2.** A primeira parte está certa: obsoletas, e o CIDR resolveu o desperdício. As classes só permitiam três tamanhos (`/8`, `/16`, `/24`): uma empresa que precisava de 500 endereços ganhava um classe B inteiro, com 65 mil. O que faltou:

- O CIDR também resolveu o **crescimento das tabelas de rotas**: blocos contíguos podem ser anunciados como um só prefixo maior. Por exemplo, quatro `/24` vizinhos viram um `/22`, que é exatamente o que você calculou na B4. Isso se chama agregação.
- `172.16.0.0/12` vai de `172.16.0.0` a `172.31.255.255`: são 16 "classes B" vizinhas (`172.16` a `172.31`) juntas num bloco só. Um `/12` não é nenhum dos três tamanhos permitidos pelas classes, então ele só pode ser expresso com CIDR.

### B7 · Faixas privadas

Escreva as três faixas de IP privado em notação CIDR e diga, aproximadamente, quantos endereços cada uma tem.

> A única que me lembro é a 192.168.1.0/24. É realmente importante "decorar" isso? me parece só uma decoreba

**Correção — 0/2.** `192.168.1.0/24` é uma sub-rede comum em casa, mas a **faixa privada** inteira é `192.168.0.0/16`. As três:

| Faixa | Vai de … até | Tamanho |
|---|---|---|
| `10.0.0.0/8` | 10.0.0.0 – 10.255.255.255 | ~16,7 milhões |
| `172.16.0.0/12` | 172.16.0.0 – 172.31.255.255 | ~1 milhão |
| `192.168.0.0/16` | 192.168.0.0 – 192.168.255.255 | ~65 mil |

**Vale decorar?** Sim. São só três itens, e você vai usar o tempo todo:

- **Troubleshooting**: ao ver um IP num log, num `kubectl get pods -o wide` ou num erro de conexão, saber na hora se é interno ou externo muda toda a investigação.
- **Desenho de redes**: VNets, subnets do AKS, CIDR de pods e de Services **não podem se sobrepor** à rede da empresa ou da VPN. Sobreposição é um problema clássico e difícil de corrigir depois, porque exige recriar o cluster. Na sua própria máquina já convivem duas faixas: `192.168.15.6` (casa e minikube) e `172.17.0.1` (Docker).

Para lembrar: as três ficam em ordem de tamanho decrescente, `/8` → `/12` → `/16`.

### B8 · AKS (pode usar calculadora)

No Azure, cada subnet tem **5 endereços reservados** pela plataforma. No Azure CNI tradicional, cada nó do AKS ocupa 1 IP para si e reserva antecipadamente 30 IPs para os seus pods. Numa subnet `10.240.0.0/24`, quantos nós cabem? Que problema isso causa num upgrade do cluster, quando o AKS cria nós extras temporários?

> /24 -> 254 dispositivos  
> 5 -> Reservados pra Azure  
> 31 -> por Node (1 para o Node, 30 reservados para pods)  
> (254 - 5) / 31 = 8  
> É possível provisionar 8 Nodes (e vai restar um IP), suportando até 30 Pods por Node. seria possível ter no máximo 241 Pods (caso se dividissem perfeitamente entre os Nodes). Não seria possível escalar a quantidade de Nodes, pois haveria apenas 1 IP disponível

**Correção — 2/2.** O resultado (8 nós) e o problema do upgrade estão certos: sem IPs livres, o AKS não consegue criar o nó extra (*surge*), e o upgrade falha. O mesmo vale para escalar o cluster. Dois ajustes na conta:

- Os 5 reservados do Azure **já incluem** o endereço de rede e o broadcast (os reservados são `.0`, `.1` gateway, `.2` e `.3` DNS do Azure, e `.255`). A conta é 256 − 5 = **251**, e 251 / 31 = 8 nós, sobrando **3** IPs, não 1. Descontar 2 e depois mais 5 conta os mesmos endereços duas vezes.
- 8 nós × 30 = **240** pods, não 241.

É por isso que o Azure CNI tradicional exige subnets grandes, e por isso o Azure CNI Overlay existe: com ele, os pods saem de outra faixa e não consomem IPs da subnet (a A-03 da avaliação).

### B9 · Na sua máquina (pode usar o terminal)

Rode `ipcalc 192.168.15.6/24` e `ipcalc 172.17.0.1/16`. Explique cada linha da saída com as suas palavras.

```bash
lucas@cachyos:~$ ipcalc 192.168.15.6/24
Address:   192.168.15.6         11000000.10101000.00001111. 00000110
Netmask:   255.255.255.0 = 24   11111111.11111111.11111111. 00000000
Wildcard:  0.0.0.255            00000000.00000000.00000000. 11111111
=>
Network:   192.168.15.0/24      11000000.10101000.00001111. 00000000
HostMin:   192.168.15.1         11000000.10101000.00001111. 00000001
HostMax:   192.168.15.254       11000000.10101000.00001111. 11111110
Broadcast: 192.168.15.255       11000000.10101000.00001111. 11111111
Hosts/Net: 254                   Class C, Private Internet
```

> Address: demonstra qual é o endereço do meu dispositivo (ou no caso a interface de rede do meu pc)  
> Netmask: Exibe a configuração de máscara de rede e seu equivalente em /24 e binário  
> Wildcard: Aparentemente indica quais bits do endereço são relativos aos hosts  
> Network: Exibe o endereço da minha rede (basicamente o Address mas com 0 ao invés de 6, por conta do /24  
> HostMin: Identifica o começo da faixa válida de valores para host (descontando address e broadcast)  
> HostMax: Identifica qual é o último valor da faixa de endereços válidos para hosts  
> Broadcast: Identifica o endereço do broadcast  
> Hosts/Net: Informa quantos endereços válidos a rede possui no total para dispositivos (exclui network e broadcast)  exibe a classe da rede + info se é public ou private  
> todos os campos também apresentam o endereço em binário

**Correção — 2/2.** Todas as linhas estão certas. Ajustes de precisão:
- **Wildcard**: exato, é a máscara invertida (bits de host em 1). Aparece em ACLs de roteadores e em algumas regras de firewall.
- **Network**: no `/24` é mesmo "trocar o último número por 0". A regra geral é: **zerar todos os bits de host** (fazer um AND do endereço com a máscara). Num `/22`, por exemplo, isso mexe também no terceiro octeto, como você viu na B4.
- **HostMin**: desconta o endereço de **rede** (*network*), não o *address*. O *address* é o seu IP, que é um host comum.
- O "Class C" que o `ipcalc` mostra é herança histórica, só informativa.
- Faltou rodar o segundo comando (`172.17.0.1/16`). Vale rodar para ver a diferença: o `Hosts/Net` vira 65.534.

---

## Exercícios extras

Sem consulta. Confira depois com `ipcalc`, e só peça correção se a sua resposta e a do `ipcalc` não baterem e você não entender por quê.

### E1 · Conversão

Escreva em binário (os 32 bits) e em CIDR: `255.255.255.224`, `255.255.252.0`, `255.255.255.128`.

> `255.255.255.224 = 11111111.11111111.11111111.11100000`  
> `255.255.252.0 = 11111111.11111111.11111100.00000000`  
> `255.255.255.128 = 11111111.11111111.11111111.10000000`

**Correção — 1/2.** As três conversões para binário estão **certas**, incluindo os octetos "quebrados" que tinham dado errado na B1. Faltou só escrever o CIDR, contando os bits em 1: **/27**, **/22** e **/25**.

### E2 · Divisão

Divida `10.0.0.0/24` em **8** sub-redes iguais. Qual o prefixo? Liste rede e broadcast das três primeiras e da última.

> 10.0.0.0/24 = 2⁸ = 256.  
> 256 / 8 = 32  
> Cada subrede vai comportar 32 endereços (30 hosts)
>
> 32 = 2⁵ -> 5 bits serão necessários para representar os 32 hosts  
> 11111111.11111111.11111111.11100000 = /27
>
> subnet 1:  
> address 10.0.0.0/27  
> network: 10.0.0.0  
> broadcast 10.0.0.31
>
> subnet 2:  
> address: 10.0.0.32/27  
> network: 10.0.0.32  
> broadcast: 10.0.0.63
>
> subnet 3:  
> address: 10.0.0.64/27  
> network: 10.0.0.64  
> broadcast: 10.0.0.95
>
> subnet 8:  
> address: 10.0.0.224/27  
> network: 10.0.0.224  
> broadcast: 10.0.0.255  
>
> para chegar na sunet 8 eu parti do broadcast da subnet 3 e somei 128 (31 * 4, das 4 subnets restantes), isso resultou em 223 (broadcast da subnet 7), então assumi que a subnet 8 começava com 224 (e conferi ao somar 223 + 32, como deu exatamente 255 me senti confiante com essa lógica)

**Correção — 2/2.** Tudo certo: o prefixo `/27` e as quatro faixas. Compare com a B5: lá o prefixo e os limites tinham saído errados, e agora estão certos. Dois detalhes no raciocínio:
- Você escreveu "somei 128 (31 × 4)", mas 31 × 4 = 124. O que você somou foi **32 × 4 = 128**. O passo entre sub-redes é sempre o **tamanho do bloco (32)**, não o número de hosts.
- Atalho para a última sub-rede: o endereço de rede dela é sempre **256 − tamanho do bloco** = 256 − 32 = 224.
- Precisão: os 5 bits representam **32 endereços** (30 hosts utilizáveis), não "32 hosts".



### E3 · Divisão em octeto diferente

Divida `172.20.0.0/16` em **4** sub-redes iguais. Qual o prefixo e quais são as faixas?

> 172.20.0.0/16 -> suporta 65,536 endereços (2¹⁶)  
> cada subnet suportaria 16,384 endereços (2¹⁶ / 4)  
> 11111111.11111111.11000000.00000000 -> /18  
>
> subnet 1:  
> address: 172.20.0.0/18  
> network: 172.20.0.0  
> broadcast: 172.20.63.255  
> faixa: 172.20.0.1 -> 172.20.63.254  
>
> subnet 2:  
> address: 172.20.64.0/18  
> network: 172.20.64.0  
> broadcast: 172.20.127.255  
> faixa: 172.20.64.1 -> 172.20.127.254  
>
> subnet 3:  
> address: 172.20.128.0/18  
> network: 172.20.128.0  
> broadcast: 172.20.191.255  
> faixa 172.20.128.1 -> 172.20.191.254  
>
> subnet 4:  
> address: 172.20.192.0/18  
> network: 172.20.192.0  
> broadcast: 172.20.255.255  
> faixa 172.20.192.1 -> 172.20.255.254  
>
> confesso que no começo, fiquei confuso pra calcular o broadcast + faixa da primeira subnet (por conta do terceiro octeto), usei o ipcalc pra entender o padao, e a partir da subnet 2 consegui calcular os valores normalmente. independente de eu ter usado o ipcalc, acredito que entendi a lógica por tras.

**Correção — 2/2.** Tudo certo: o `/18` e as quatro faixas. Usar o `ipcalc` para entender o padrão está ótimo num exercício extra, e foi bom você ter registrado isso. Na prova do módulo vai ser sem ferramenta. O padrão que você descobriu é o mesmo das divisões em um único octeto, só que um octeto antes:
- O octeto "quebrado" da máscara agora é o **terceiro** (`255.255.192.0`). O bloco é 256 − 192 = **64**, e conta no terceiro octeto: 0, 64, 128, 192.
- O quarto octeto fica **inteiro** para hosts: vai de 0 a 255 dentro de cada valor do terceiro. Por isso o broadcast da primeira sub-rede é `172.20.63.255`: é o último valor do terceiro octeto (64 − 1 = 63) com o quarto todo em 1.

### E4 · Privado ou não

Para cada IP, diga se é privado e de qual faixa: `10.244.3.7`, `172.32.0.1`, `172.31.200.5`, `192.169.1.1`, `192.168.49.2`.

> `10.244.3.7 privado, faixa 10.0.0.1 -> 10.255.255.254 (10.0.0.0/8)`  
> `172.32.0.1 não é privado`  
> `172.31.200.5 privado, faixa 172.16.0.1 -> 172.16.255.254 (172.16.0.0/12)`  
> `192.169.1.1 não é privado`  
> `192.168.49.2 privado, faixa 192.168.0.1 -> 192.168.255.254`

**Correção — 1/2.** Os cinco veredictos estão **certos**, inclusive as duas pegadinhas (`172.32.0.1` e `192.169.1.1` são públicos). O erro está na faixa que você escreveu para o `172.16.0.0/12`:
- Você escreveu `172.16.0.1 → 172.16.255.254`, que seria só um `/16`. O correto é **`172.16.0.0 → 172.31.255.255`**. O seu próprio veredicto sobre o `172.31.200.5` contradiz a faixa que você anotou: ele não caberia nela. Cuidado para não fixar a versão errada nas notas.
- Ao descrever uma faixa privada, use o bloco inteiro (de `.0.0` até `.255.255`), e não a faixa de hosts (`.1` a `.254`). "Privado" é uma propriedade de **todos** os endereços do bloco; rede e broadcast só existem dentro de cada sub-rede que você criar nele.
