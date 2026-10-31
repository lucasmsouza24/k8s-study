# Teoria — Docker

Responda abaixo de cada pergunta, no bloco `>`. Livro fechado. `não sei` é uma resposta válida.

---

## Nível 1 — Fundamentos

### D-01 · Container vs VM

Qual a diferença entre um container e uma máquina virtual? O que um container compartilha com o host e o que ele tem isolado?

> containers e VMs são muito semelhantes, ambos tem como proposta isolar ambientes. A principal diferença que eu enxergo entre os dois é qual parte do ambiente é isolado. Enquanto a VM utiliza parte do hardware do host e "emula" (ou isola) todo um sistema operacional novo e tudo que está acima disso o container isola o processo. Não tem SO completo, ele acaba chamando as instruções do SO do host (o que economiza bastante o uso de memória). Confesso que não sei o nível de detalhamento que eu deveria, não lembro por exemplo do papel do hypervisor. Também não lembro como containers baseados em linux conseguem rodar no windows, sendo que são SOs diferentes e teoricamente instruções diferentes também.

### D-02 · Imagem vs container

Qual a diferença entre imagem e container? O que é uma *layer* (camada) de imagem e por que imagens são construídas em camadas?

> não sei o que é layer de imagem e nem por que é construído assim. não sei explicar tão bem a diferença de imagem e container, mas entendo que uma boa analogia é que a imagem é como se fosse uma classe, ou um script e o container é como se fosse um objeto, ou a aplicação rodando de fato, de forma isolada e podendo rodar várias instancias identicas

### D-03 · CMD vs ENTRYPOINT

Qual a diferença entre `CMD` e `ENTRYPOINT`? E qual a diferença entre a forma *exec* (`CMD ["python", "app.py"]`) e a forma *shell* (`CMD python app.py`)?

> essa é difícil. até onde me lembro, CMD e ENTRYPOINT são comandos de execução que serão o comando principal do container, aquele que é feito por último após o building da imagem (após a instalação das libs, etc), a grande diferença é que ENTRYPOINT é substituível, se eu iniciar o container manualmente passando um comando diferente via parametro, esse comando é substituido pelo comando declarado no ENTRYPOINT do dockerfile na execução do container, enquanto o CMD é menos flexível, uma vez descrito no dockerfile, ele ira executar de qualquer forma. não sei a diferença das formas exec e shell :/

### D-04 · EXPOSE

A instrução `EXPOSE 8000` no Dockerfile torna a porta acessível a partir do host? Qual a relação entre `EXPOSE` e `docker run -p 8080:8000`?

> não. a instrução EXPOSE 8000 deixa a porta do container acessível e não o do host. já o parametro/valor -p 8080:8000 faz com que a porta 8000 do container direcione toda a comunicação para a porta 8080 do HOST e acredito que esse comando não funciona se a porta em questão do container não estiver "exposta" atravez do EXPOSE.

### D-05 · Persistência

Um container grava arquivos em `/app/uploads`. O que acontece com esses arquivos quando o container é removido (`docker rm`)? Quais as diferenças entre *volume* e *bind mount*, e quando usar cada um?

> containers, em geral são feitos para serem descartáveis. qualquer dado gravado neles são deletados em caso de restart ou deleção. para persistir dados, volume mounts são utilizados. até onde sei são volumes lógicos usados pra persistir informações que precisam sobreviver ao ciclo de vida dos containers

### D-06 · COPY vs ADD

Qual a diferença entre `COPY` e `ADD`? Qual é a recomendada e por quê?

> não conheço o comando ADD. sei que o comando COPY é utilizado para copiar arquivos da máquina host para "dentro da imagem" comum antes ou depois da instalação de dependencias durante o biulding da imagem docker.

---

## Nível 2 — Uso no dia a dia

### D-07 · Cache de build

Veja o Dockerfile de `legacy/002-resource-management/Dockerfile` deste repo:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

a) Se você alterar só o `app.py` e rebuildar, quais instruções são reexecutadas?
b) E se alterar o `requirements.txt`?
c) O que aconteceria com o cache se a ordem fosse `COPY . .` seguido de `RUN pip install`?

> não sei

### D-08 · Multi-stage build

O que é um multi-stage build? Dê um exemplo de situação em que ele faz muita diferença no tamanho/segurança da imagem final.

> não sei

### D-09 · Usuário root

Por que rodar o processo do container como `root` é um problema, se o container já é "isolado"? Como evitar no Dockerfile?

> adianto que não sei. mas acredito que usar root do container pode permitir a exploração de brechas de seguranças, por meio da elevação de privilégios, caso o processo do container consiga acessar algo da máquina host via EXPOSE ou até criar processos novos dentro da máquina HOST

### D-10 · .dockerignore

Para que serve o `.dockerignore`? Cite dois problemas concretos que acontecem sem ele (pense, por exemplo, no `legacy/deployment-patterns/blue-green/app1`, que tem `node_modules/`).

> o .dockerignore funciona como o .gitignore, faz com que os processos de building do container ignore uma lista de arquivos/diretórios para o building. não sei como se comportaria se eu passasse explicitamente COPY node_modules/ . com o node_modules estando no dockerignore, mas se tentar usar um COPY * . acredito que o fato do node_modules estar presente no dockerignore faria com que ele não fosse passado para a imagem. ao não usar o dockerignore pode ser que aconteçam problemas semelhantes à problemas de cache durante o building de imagem. durante um deploy é interessante montar o node_modules do zero e não reaproveitar o que vem do host, isso pode fazer com que o comportamento em diferentes seja diferente, pois dependeria de qual host tem ou não node_modules (acaba com a reprodutividade do processo). além disso pode fazer com que arquivos desnecessários e pesados possam ser passados para a imagem sem querer

### D-11 · Tags

Quais os problemas de usar a tag `latest` em produção? Qual a diferença entre referenciar uma imagem por *tag* e por *digest* (`@sha256:...`)?

> latest sempre busca a versão mais recente da imagem, se eu uso latest de uma imagem base para minha aplicação após uma implementação na app, em casos de aplicação quebrada eu não tenho como garantir que minha aplicação quebrou por conta da imlementação ou por conta de uma nova versão vindo da imagem base

### D-12 · Redes

Dois containers precisam se comunicar (uma API e um Redis). Como você faz isso com `docker run`? Qual a diferença entre a rede `bridge` padrão e uma rede *user-defined* criada com `docker network create`?

> não me lembro de como se faz isso, só usei bridge network

### D-13 · Secrets no build

Uma imagem precisa de um token para baixar dependências privadas durante o build. Por que `ARG TOKEN` ou `ENV TOKEN=...` não são seguros? Qual a forma correta?

> os valores de ENV ficam acessíveis dentro da imagem, pode ser um problema se alguém conoseguir acessar o container e usar um comando parecido com "printenv | grep -i TOKEN", mas até onde eu sei o ARG não fica gravado na imagem, eu acredito que seja seguro, estou errado?

---

## Nível 3 — Por baixo do capô

### D-14 · Primitivas do kernel

Quais recursos do kernel Linux tornam containers possíveis? Explique o papel de cada um (pelo menos três).

> não sei

### D-15 · PID 1 e sinais

Um container leva exatamente 10 segundos para parar em todo `docker stop` e termina com exit code `137`. O que provavelmente está acontecendo? Por que o processo com PID 1 dentro do container é "especial"? Como corrigir?

> não sei

### D-16 · Limite de memória

Um container rodando com `--memory=256m` tenta alocar 400 MB. O que acontece, quem toma a ação e como você identifica isso depois do fato?

> não sei

### D-17 · Ecossistema de runtimes

Explique a relação entre Docker, containerd, runc e OCI. O Kubernetes "removeu o suporte ao Docker" na versão 1.24 — por que as imagens construídas com `docker build` continuam funcionando no AKS?

> não sei

### D-18 · Arquitetura de CPU

Você builda uma imagem num Mac M-series, faz push e o pod no AKS falha com `exec format error`. O que aconteceu e como resolver?

> não sei

### D-19 · Imagens base

Compare `python:3.12`, `python:3.12-slim`, `python:3.12-alpine` e imagens *distroless*. Quais os trade-offs (tamanho, compatibilidade, segurança, facilidade de debug)?

> até onde eu sei, python:3.12 é uma imagem completa e "pesada", com um "SO" maior pra simular o ambiente onde o processo do python roda. O slim possui uma versão um pouco mais enxuta do python:3.12 e o alpine tras uma versão ainda mais enxuta, a ponto de que pode ser que algumas dependencias tenham que ser instaladas manualmente para o funcionamento da aplicação. quanto mais "enxuta" é a distro, teoricamente mais segura ela é, pois tem menos dependencias para terem vulnerabilidades. porém, são baseados em distros diferentes, e não são compatíveis entre sí. alpine não só pode exigir a instalação de dependencias específicas, como também pode exigir um formato diferente de instalação dessas dependencias, vou usar um exemplo impreciso: seria como a diferença entre apt-get install e pacman 
