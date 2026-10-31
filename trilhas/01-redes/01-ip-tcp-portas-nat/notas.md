# Notas — IP, TCP/UDP, portas e NAT

Escreva como se estivesse explicando para um colega júnior. Se travar ao explicar algo, volte para a fonte: é ali que está a lacuna.

## Endereço IP, sub-rede e CIDR

Um endereço IP é uma identificação atribuída à uma interface de rede (que pode ser simplificada como dispositivo para entendimento inicial) seguindo o formato especificado pelo protocolo IP. Hoje as versões mais famosas de endereços de ip são IPv4 e IPv6.  

o IPv4 é constituido por 4 conjuntos de valores que variam de 0 -> 255, podendo variar de 0.0.0.0 -> 255.255.255.255 = 2³² endereços possíveis (alguns desses endereços são reservados e não podem ser utilizados).  

o IPv6 é constituido por 8 conjuntos de valores que variam de 0 -> FFFF (hexadecimal) podendo variar de 0:0:0:0:0:0:0:0 até ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff = 16³² (2^128) endereços possíveis  

os zeros podem ser simplificados, dessa forma o endereço  

- 0:0:0:0:0:0:0:1 pode ser reescrito como ::1
- 0db8 -> db8

## IP privado × público e NAT

## TCP × UDP e o three-way handshake

## Portas e sockets

## 127.0.0.1 × 0.0.0.0

## Connection refused × timeout × reset

## SNAT × DNAT, e o que o `docker run -p` faz

## O que me surpreendeu / o que eu achava que era diferente

-

## Ligação com o meu trabalho

-
