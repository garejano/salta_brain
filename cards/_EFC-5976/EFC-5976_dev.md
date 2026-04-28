# Compartilhando uso de IA — EFC-5976

---

## Mensagem de compartilhamento

> Pessoal, compartilhando um uso de IA que achei bastante útil.
>
> No EFC-5976 usei o Claude Code com MCP do SQL Server integrado para planejar, implementar e gerar massa de testes — tudo com dados reais do banco de homolog. O ponto valioso foi o `EFC-5976_QA.md`: um guia que DEV ou QA consegue executar sem precisar conhecer o processo (meu caso...), com queries prontas para validar cada cenário. 
> Detalhei no documento abaixo: motivação, como fiz, em que cenários faz sentido usar e o que ainda precisa de supervisão humana.

---

## Contexto

Card **EFC-5976 — Autonomia de Avaliação e Cálculo para Itinerários**. O objetivo era adicionar suporte a escopos de **Componente Formativo (CF)** no Configurador de Avaliações — uma tela complexa que mistura NHibernate, Knockout.js, enums com mapeamento não-sequencial no banco e regras de negócio do Novo Ensino Médio que eu não dominava completamente.

O desafio não era só implementar. Era entender o processo com segurança suficiente para não quebrar o que já existia, e gerar evidências de que o que foi feito estava correto.

---

## Como usei o Claude Code

### 1. Geração do plano técnico (`EFC-5976.md`)

Parti da transcrição da planning, dos textos do Jira e do código relacionado. Pedi para o Claude explorar o código e refinar o plano com dados reais — especialmente os IDs da tabela `ItinerarioFormativoCiclo`, que **não são sequenciais** (o Id=3 foi excluído do banco em algum momento). Sem isso, o mapeamento `EscopoEnum → IdCiclo` teria ficado errado na implementação.

O Claude conectou via **MCP do SQL Server** e validou os dados diretamente no banco de homolog antes de qualquer linha de código ser escrita.

### 2. Implementação

Com o plano validado, pedi a implementação seguindo as fases documentadas:
- Criação das entidades C# (`ItinerarioFormativoCiclo`, mapeamento NHibernate)
- Extensão do `EscopoEnum` com os 4 novos valores
- Branches CF nos managers (`FiltroManager`, `BuscaManager`, `EdicaoEstruturaManager`)
- Frontend dinâmico — dropdown de escopos reconstruído por agrupamento

Durante a implementação o Claude identificou dois bugs que não estavam no plano:
1. `FiltroManager.GetAgrupamentos` chamava um repositório inexistente — corrigido antes de qualquer teste.
2. `EdicaoEstruturaManager.SetEstrutura` não gravava `ItinerarioFormativoCiclo` nos registros criados — bug só descoberto quando tentei testar via tela. O Claude diagnosticou pelo payload e pelo banco, localizou os 3 pontos a corrigir (DTO, JS, Manager) e aplicou em sequência.

### 3. Casos de teste (`ECF-5976-CT.md`)

Pedi para gerar os cenários de teste a partir do entendimento acumulado — tanto do código quanto do banco. Saíram 12 cenários cobrindo desde regressão dos escopos regulares até isolamento entre ciclos CF.

### 4. Guia de QA com dados reais (`EFC-5976_QA.md`)

Esse foi o ponto mais útil. Pedi para o Claude analisar o plano, os cenários de teste **e o banco de homolog** simultaneamente, e gerar um documento que um QA sem contexto do processo conseguisse executar.

O resultado incluiu:
- Dados reais de homolog para cada cenário (Rede, Agrupamento, Ano Letivo exatos)
- Queries de pré-condição e pós-validação para cada CT
- Um mapa de quais cenários eram testáveis imediatamente e quais precisavam de setup
- A nota crítica de que nenhuma `EstruturaAvaliacao` tinha `ItinerarioFormativoCiclo` preenchido ainda — o que explicava por que o grid ficaria vazio mesmo com tudo implementado

Esse documento acabou sendo usado pelo tech lead como **exemplo de massa de testes** numa outra discussão.

---

## O que funcionou bem

**MCP do SQL Server integrado** foi o diferencial. Não é "Cole o schema aqui" — é o Claude consultando o banco em tempo real enquanto analisa o código, cruzando os dois. Quando perguntei "qual filtro preciso para ver as novas opções de escopo?", a resposta veio com dados reais do banco de homolog, não com um exemplo genérico.

**Continuidade de contexto** também ajudou bastante. O trabalho durou várias sessões. O Claude manteve memória do que havia sido decidido — IDs não-sequenciais, mapeamentos, decisões de arquitetura — sem precisar repetir o contexto a cada interação.

---

## Quando esse fluxo faz sentido

- Card com **regras de negócio que você não domina** completamente, mas o código e o banco têm as respostas.
- Necessidade de **gerar evidências** (massa de testes, queries de validação) além do código em si.
- Implementações que cruzam **backend + frontend + banco** — onde manter consistência entre as camadas manualmente é custoso.

---

## O que não substituiu

Revisar o código gerado. Em alguns pontos o Claude propôs soluções que precisaram de ajuste (ex.: a abordagem inicial para `EhDisciplinaMae` em LINQ, que não era segura para tradução SQL). O fluxo funcionou bem como **acelerador com supervisão**, não como delegação completa.

---

*Card: EFC-5976 | Branch: feature/EFC-5976 | Ferramentas: Claude Code + MCP SQL Server*
