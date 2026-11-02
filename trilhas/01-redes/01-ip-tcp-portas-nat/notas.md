# Notas — IP, TCP/UDP, portas e NAT

Escreva como se estivesse explicando para um colega júnior. Se travar ao explicar algo, volte para a fonte: é ali que está a lacuna.

## Endereço IP, sub-rede e CIDR

### IP

Um endereço IP é uma identificação atribuída à uma interface de rede (que pode ser simplificada como dispositivo para entendimento inicial) seguindo o formato especificado pelo protocolo IP. Hoje as versões mais famosas de endereços de ip são IPv4 e IPv6.  

o IPv4 é constituido por 4 conjuntos de valores que variam de 0 -> 255, podendo variar de 0.0.0.0 -> 255.255.255.255 = 2³² endereços possíveis (alguns desses endereços são reservados e não podem ser utilizados).  

o IPv6 é constituido por 8 conjuntos de valores que variam de 0 -> FFFF (hexadecimal) podendo variar de 0:0:0:0:0:0:0:0 até ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff = 16³² (2^128) endereços possíveis  

os zeros podem ser simplificados, dessa forma o endereço  

- 0:0:0:0:0:0:0:1 pode ser reescrito como ::1
- 0db8 -> db8

### Subnet

Subnets (ou subredes) são segmentações lógicas dentro de redes (como subconjuntos de redes). Uma subnet é útil porque permite a atribuição de regras específicas para cada subnet, como uma segmentação entre diferentes departamentos de uma empresa, configuração de firewall personalizado, etc.

### CIDR

CIDR é uma notação enxuta que representa a máscara de rede de uma net/subnet.  
Exemplo:  
máscara: 255.255.255.0 -> 11111111.11111111.11111111.00000000 -> /24  
máscara: 255.255.0.0 -> 11111111.11111111.00000000.00000000 -> /16  
CIDR = /X -> X = quantidade de bits na máscara para representar endereço de rede.  

A quantidade de endereços disponíveis dentro da rede pode ser definido com a seguinte regra:  
(2³²⁻²⁴) - 2 -> para /24  
(2³²⁻¹⁶) - 2 -> para /16  
assim por diante, lembrando que o primeiro e último endereço são reservados para rede e broadcast.  

Algumas faixas de valores não são roteáveis (de forma pública), são reservadas para uso de subredes internas (privadas) os seguintes endereços: 

| bloco CIDR     | faixa                          | Endereços disponíveis |
| -------------- | ------------------------------ | --------------------- |
| 10.0.0.0/8     | 10.0.0.0 -> 10.255.255.255     | 16.777.216 |
| 172.16.0.0/12  | 172.16.0.0 -> 172.31.255.255   | 1.048.576 |
| 192.168.0.0/16 | 192.168.0.0 -> 192.168.255.255 | 65.536 |

Como a máscara é utilizada? Internamente, o dispositivo aplica a máscara nos IPs de origem/destino, se a rede for a mesma, o pacote pode ser entregue diretamente (pois fazem parte da mesma rede) senão o pacote é entregue para o roteador, onde os próximos saltos serão realizados para fora.

## IP privado × público e NAT

### IP Privado 

Um endereço de IP privado faz parte de uma rede privada, que não está aberta para a internet pública (pelo menos não diretamente)

### IP Público

Um endereço de IP público faz parte e está acessível pela internet, geralmente associado à dispositivos de rede como roteadores.

### NAT: Network Address Translation

Como explicado acima, IPs privados não tem acesso direto à internet, o acesso se dá por um dispositivo intermediário, normalmente o roteador. Quando uma requisição sai de um dispositivo com IP privado e seu destino está fora da rede, a requisição é entregue para o roteador e ele aplica um processo de tradução (NAT) onde a origem da requisição é alterada do IP privado do dispositivo para o IP público da rede (roteador) antes de seguir seu destino na internet. existem diferentes tipos de NAT para diferentes situações.

#### NAT Estático

Um NAT estático estabelece um mapeamento 1:1 do IP público da rede com um IP privado de dispositivo dentro da rede (quase como se o IP privado fosse traduzido para o IP público antes de saír da internet, e vice versa para entrar na rede privada). Funciona bem bem para aplicações que precisam estar acessíveis 24/7 como aplicações web, apis, etc.

#### NAT Dinâmico

De certa perspectiva, um NAT dinâmico também cria um mapeamento de 1:1 (com a parte da reescrita de origem/destino exatamente igual) com o IP privada para o IP público da rede, com a diferença de que esse mapeamento só é estabelecida quando o dispositivo da rede faz abre uma request pra fora, o mapeamento é desfeita após o tempo sem tráfego. Ou seja, solicitações de fora da rede nunca conseguem alcançar um dispositivo da rede privada, pois não há garantia de que o mapeamento estará aberta. 

É interessante declarar que muitas explicações sobre NAT Dinâmico usam como exemplo redes com múltiplos IPs públicos, onde a saída de rede pode acontecer abrindo conexões 1:1 para algum IP disponível no momento da solicitação. Esse modelo não é comumente utilizado, pois é limitado em vários sentidos, principalmente pq se só houver 1 IP de saída, somente um dispositivo consegue estabelecer um mapeamento por vez, tornando uma rede com múltiplos dispositivos privados praticamente inviável.

### PAT

O PAT resolve o problema mencionado anteriormente. Durante a reescrita de origem/destino, além do IP ele também reescreve a *porta* (a porta sempre existiu, no cabeçalho TCP/UDP de toda conexão; o NAT básico só não mexe nela), tornando possível que múltiplos dispositivos estabeleçam conexões com a internet ao mesmo tempo, usando o mesmo IP público.

Quando um browser faz solicitações, a solicitação é feita por uma porta do dispositivo, como 51000 por exemplo, ao entender que o endereço destino está fora da rede interna, a request é encaminhada para o roteador que por sua vez reescreve o IP de origem e, se necessário, também a porta de origem. Se a porta que o dispositivo de origem utilizou estiver disponível no IP público **para aquele destino** (mesmo IP e porta de destino; para destinos diferentes, a mesma porta pública pode ser reutilizada ao mesmo tempo), essa mesma porta será gravada durante a reescrição, senão uma porta disponível aleatória será utilizada em seu lugar (como existe uma tabela de conversão, a reversão acontece sem problemas no momento do response).

Dessa forma, diversos dispositivos conseguem abrir conexões ao mesmo tempo usando o mesmo IP público.

Importante: o PAT só funciona para conexões que os dispositivos de dentro da rede **iniciam**. Cada entrada da tabela é criada quando um dispositivo abre uma conexão para fora, só aceita as respostas dessa conexão e expira quando ela termina ou fica um tempo sem tráfego. Um pacote que chega de fora sem uma entrada correspondente na tabela é descartado. Ou seja, o PAT não torna nenhum dispositivo acessível a partir da internet.

## TCP × UDP e o three-way handshake

## Portas e sockets

## 127.0.0.1 × 0.0.0.0

## Connection refused × timeout × reset

## SNAT × DNAT, e o que o `docker run -p` faz

## O que me surpreendeu / o que eu achava que era diferente

-

## Ligação com o meu trabalho

-
