# Desafio RD

Essa branch `beta` foi criado para tentar demonstrar os conhecimentos em Ruby.

Foi decidido criar uma stack em Sinatra e ir evoluindo a stack conforme a necessidade.
Ela conta com uma API que cria `customers`: `POST /v1/customers`

## Proposta

A ideia dessa branch era plugar o service `CustomerSuccessManagerBalancing`
dentro de uma stack web para tentar demonstrar os conhecimentos em ruby.

## Estrutura

A estrutura baseia-se em uma [arquitetura hexagonal](https://herbertograca.com/2017/11/16/explicit-architecture-01-ddd-hexagonal-onion-clean-cqrs-how-i-put-it-all-together/)
onde teremos o core domain, `lib/cs_managers`, sendo consumido pelos adapters das camadas externas.

```
  +-----------------+
  |                 |
  |     api/v1      |
  |                 |
  +-----------------+
                                                                 +-------+
  +-----------------+                                            |       |
  |                 |                                            |       |
  |    backoffice   |           +----------------------+         |       |
  |                 |           |                      |         |       |
  +-----------------+  +----->  |   DOMAIN             |  +-->   | DB    |
                                |   lib/cs_managers/** |         |       |
  +-----------------+  <-----+  |                      |  <--+   |       |
  |                 |           +----------------------+         |       |
  |   schedulers    |                                            |       |
  |                 |                                            |       |
  +-----------------+                                            +-------+

  +-----------------+
  |                 |
  |   workers       |
  |                 |
  +-----------------+

```

A camada mais externa, `api, backoffice, console, workers, schedulers`, seriam processos separados
e escaláveis compartilhando do mesmo core domain.

Essa arquitetura de deixar os processos escaláveis é bastante utilizado
pelo guia [12 factor app](https://12factor.net/pt_br/concurrency) bem como
a utilizacão de env vars para configuracão das dependencias como servico
(DB, redis, elasticsearch).

## Service Objects VS Operations

Foi adicionado no core domain, um diretório de operations. Uma operation
nada mais é que um BoundedContext do DDD aliado ao CommandPattern (só faz uma acão)

O modelo foi altamente inspirado no [Hanami Interactors](https://guides.hanamirb.org/architecture/interactors/)
e acabai deixando o código mais clean e organizado visualmente.

Tenho dado muita preferência a esse modelo por trazer uma simplicidade arquitetural
e clareza aos devs. O service model costuma virar um [Ball Of Mud](https://en.wikipedia.org/wiki/Big_ball_of_mud).

É nessa camada de operacões que os componentes individuais são ligados em seu contexto.

## Sobre a API

A API criada nesta aplicacão apenas responde a rota conforme o curl abaixo:

```
curl  \
    -XPOST \
    -H'Content-Type: application/json' \
    -H'Accept: application/json' \
    -d'{"name": "John Doe", "score": 10}' \
    http://localhost:3000/api/v1/customers
```

A resposta da API é normalizada na seguinte estrutura, independente do que aconteca
o client nunca receberá uma estrutura diferente de:

```
{
    "result": "success",
    "request_id": "762654cc-943a-4313-8148-c916f354bdce",
    "messages": [], # filled when there is error
    "data": {
        "id": "d8c4e33d-7a0e-4826-aead-05666c9ad2ea",
        "name": "John Doe",
        "score": 10
    }
}

```

## NGINX nas imagens docker

Dentro das imagens o server `puma` é protegido pelo `nginx` de conexões lentas
e da wild web. NGINX é um webserver muito parrudo, resiliente e maduro para lidar com esse cenário.

Antes do advento do docker, costumávamos colocar o `nginx` na frente do server `unicorn`
para proteger nosso ruby server. A comunicacão entre eles ocorre via proxy reverso.

Isso traz grande maleabilidade e protecão para nosso server ruby, pois conseguimos
delegar para o nginx a entrega de arquivos estáticos e de receber um stream de dados
para upload com muito mais qualidade que um puma da vida.

Por esse motivo, nas imagens docker, costumo subir um processo `nginx` fazendo proxy
para o server ruby que está segurando o container no ar.

Quando subimos nesse formato, é legal ter uma rota de `health/check` que passa
pelo `nginx` e chega no `puma` para checar que ambos os processos estão rodando
e válidos.

No k8s, temos esses checks usando os probes `readinessCheck` (para checar quando
o POD está pronto para receber requests) e `livenessCheck` (para checar se o POD, após subir,
continua na ativa).

## Dependências para desenvolvimento

- docker
- docker-compose

## Rodando a aplicacão

```
docker-compose up
```

Acessar: [http://localhost:3000](http://localhost:3000)

## Fluxo para desenvolvimento

Abra um terminal separado e suba o postgres e o redis

```
docker-compose up postgres redis
```

Em outro terminal suba a aplicacao ruby:

```
bundle exec ruby boot.rb
```
Acessar: [http://localhost:4567](http://localhost:4567)

## Rodando os testes

Para rodar a suite de testes:
```
bundle exec rake test
```
