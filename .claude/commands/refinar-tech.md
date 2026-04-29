# Criar Plano Técnico

Quando o usuário invocar este comando com uma chave de card Jira (ex.: `EFC-1234`), siga este processo.

A pesquisa de contexto é delegada a um subagente para não poluir a conversa principal.

---

## Uso

```
/refinar-tech EFC-1234
```

---

## Processo

### 1. Verificar pré-requisitos

Verificar se existem os seguintes arquivos em `cards/EFC-{NUMERO}/`:

- `EFC-{NUMERO}.md` — card principal (obrigatório)
- `EFC-{NUMERO}.refinamento.md` — refinamento aprovado (obrigatório)

Se qualquer um dos dois não existir:
- Se faltar o card principal: sugerir `/jira_sync EFC-{NUMERO}`.
- Se faltar o refinamento: sugerir `/refinar-feature EFC-{NUMERO}`.
- Encerrar sem prosseguir.

Se ambos existirem, lê-los integralmente. Ler também `EFC-{NUMERO}.bug-report.md` se existir.

---

### 2. Invocar o subagente de pesquisa técnica

Dispare um subagente com o prompt abaixo, substituindo os valores reais de `{TICKET}`, `{CONTEUDO_CARD}` e `{CONTEUDO_REFINAMENTO}`.

---

**Prompt do subagente:**

> Você é um agente de pesquisa técnica. Sua tarefa é explorar o código do repositório afetado e retornar contexto estruturado para que o agente principal possa redigir um plano técnico de implementação em fases — sem redigir o plano você mesmo.
>
> **Ticket:** `{TICKET}`
>
> **Card principal:**
> ```
> {CONTEUDO_CARD}
> ```
>
> **Refinamento:**
> ```
> {CONTEUDO_REFINAMENTO}
> ```
>
> ---
>
> **Passo 1 — Identificar o repositório**
>
> Leia `c:/projects/salta_brain/repository_map.md`.
> Confirme o repositório indicado no refinamento ou pelo label do card.
>
> ---
>
> **Passo 2 — Ler convenções do repositório**
>
> No repositório identificado:
> - Leia `CLAUDE.md` (raiz e subpastas relevantes como `backend/`, `frontend/`).
> - Leia `README.md` para entender a estrutura geral de camadas.
> - Registre padrões importantes: nomenclatura, camadas, como criar/alterar entidades, como funciona o schema de banco, como rodar testes, restrições conhecidas.
>
> ---
>
> **Passo 3 — Ler documentações das camadas**
>
> Antes de analisar o código, leia as pastas `Docs/` nas camadas do repositório quando existirem:
> - `backend/EstruturaPedagogica.Domain/Docs/`
> - `backend/EstruturaPedagogica.Test/Docs/`
> - Outras pastas `Docs/` em Infra e API quando existirem
>
> Essas pastas contêm guias de padrões que devem ser seguidos na implementação.
>
> ---
>
> **Passo 4 — Localizar código afetado**
>
> Use `backend/EstruturaPedagogica.Domain/Entities/Base/Funcionalidade.cs` como ponto de partida para localizar controllers, serviços, repositórios e testes relacionados ao tema da atividade.
>
> Com base nos Critérios de Aceite e na User Story do refinamento:
> - Localize os arquivos que precisam ser criados ou alterados (entidades, repositórios, serviços, controllers, DTOs, mappings, frontend, scripts SQL).
> - Para cada arquivo relevante: leia o trecho afetado e entenda o comportamento atual.
> - Identifique dependências entre os arquivos (ex.: entidade precisa existir antes do mapping; script SQL precisa rodar antes do serviço).
> - Registre qualquer restrição ou convenção do CLAUDE.md que impacte a implementação.
>
> ---
>
> **Passo 5 — Identificar commands de padrão relevantes**
>
> Se a implementação envolver criação ou alteração dos seguintes padrões, leia o command correspondente no repositório como fonte de verdade — não replique de memória:
> - **Nova entidade** → leia `.claude/commands/criar-entidade.md`
> - **Novo filtro** → leia `.claude/commands/criar-filtro.md`
> - **Nova exportação** → leia `.claude/commands/criar-exportacao.md`
> - **Novo service (que não seja filtro nem exportação)** → leia `.claude/commands/criar-service.md`
> - **Novos testes de integração** → leia `.claude/commands/criar-testes.md`
>
> Para cada command lido, registre quais fases do plano devem seguir aquele padrão.
>
> ---
>
> **Retorno esperado:**
>
> ```
> STATUS: contexto_pronto
>
> TICKET: {TICKET}
> REPOSITORIO: <nome>
> REPOSITORIO_PATH: c:/projects/<nome>
>
> CONVENCOES_RELEVANTES:
> <lista numerada de convenções do CLAUDE.md que impactam esta implementação>
>
> ARQUIVOS_AFETADOS:
> <lista agrupada por camada com path relativo, ação (criar/modificar/remover) e descrição do que muda>
>
> COMMANDS_DE_PADRAO_RELEVANTES:
> <lista de commands lidos e quais fases do plano devem seguir cada um — ou "nenhum">
>
> SUGESTAO_DE_FASES:
> <sequência sugerida de fases, considerando:
>  - arquitetura em camadas: Domain → Domain.Services → Infra → API → Frontend
>  - agrupamento de alterações relacionadas na mesma fase
>  - testes de integração sempre na última fase quando houver backend
>  - cada fase com nome, CAs que endereça (ou "infraestrutura"), e descrição do que fazer>
>
> RESTRICOES_E_RISCOS:
> <breaking changes, dados em produção, dependências externas, pontos de atenção>
> ```

---

### 3. Redigir o plano técnico

Com base no retorno do subagente, gere a proposta de plano técnico e **apresente ao usuário para aprovação** antes de gravar qualquer arquivo.

**Estrutura do plano técnico:**

```markdown
# Plano Técnico — {TICKET}

> Gerado em: <data>

## Contexto

<Parágrafo curto ligando o refinamento ao que precisa ser feito tecnicamente.>

## Convenções aplicáveis

<Lista das convenções do CLAUDE.md que guiam esta implementação.>

## Critérios de Aceite

<Lista dos CAs do refinamento, numerados.>

## Fases

### Fase 1 — <nome> _(<CAs que endereça, ex: CA-01, CA-02 — ou "infraestrutura">)_

**Status:** pendente

<Descrição detalhada: arquivos a criar/alterar, lógica principal, padrão a seguir.
Se esta fase seguir um command específico (criar-entidade, criar-service, etc.), indicar explicitamente.>

---

### Fase 2 — <nome> _(<CAs>)_

**Status:** pendente

<Descrição>

---

_(repetir para todas as fases — testes de integração sempre na última fase)_

## Restrições e riscos

- <risco ou ponto de atenção>

## Repositório identificado

**Repo:** `<nome>`
```

> Linguagem técnica é bem-vinda aqui — este documento é para desenvolvedores.

---

### 4. Aguardar aprovação e gravar

Aguarde aprovação explícita do usuário. Se houver ajustes, revise e apresente novamente.

**Após aprovação**, gravar em:

```
cards/{TICKET}/{TICKET}.tech.md
```

Confirmar ao usuário o caminho do arquivo gerado e que pode iniciar a execução com `/executar-plano {TICKET}` quando estiver pronto (se o repositório possuir este command).

---

## O que **não** fazer

- Não gravar o arquivo antes da aprovação explícita do usuário.
- Não prosseguir se o arquivo de refinamento não existir.
- Não escrever de volta para o Jira.
- Não inventar convenções — basear-se exclusivamente nos `CLAUDE.md` e `Docs/` lidos.
- Não omitir arquivos de camadas menos visíveis (migrations, scripts SQL, mappings EF).
- Não criar fases sem identificar o CA correspondente — ou marcar explicitamente como _(infraestrutura)_ quando não houver CA associado.
- Não colocar testes de integração em fases intermediárias — sempre na última fase.
