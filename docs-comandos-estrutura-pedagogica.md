# Comandos Claude Code — estrutura-pedagogica

> Guia de uso dos slash commands disponíveis no repositório `estrutura-pedagogica`.
> Comandos com `_` no nome são internos (chamados por outros comandos) e não devem ser invocados diretamente.

---

## Fluxo de desenvolvimento e onde cada comando se encaixa

```
     PO          Refinamento → Planejamento → Implementação → Revisão → Merge
      │               │              │               │             │        │
/refinar-feature  /refinar-    /planejar-      /executar-    /analisar-pr  /merge-branch
/documentar-e2e   feature      implementacao   plano         
                  /documentar-                 /criar-entidade
                  e2e                          /criar-filtro
                  /identificar-                /criar-exportacao
                  bug                          /criar-service
                                               /criar-testes
```

> **PO e Dev compartilham** `/refinar-feature` e `/documentar-e2e` — o PO usa para preparar e validar requisitos antes do desenvolvimento; o Dev usa para alinhar o spec com o Jira.

---

## Comandos por fase

---

### PO (PRODUCT OWNER)

O PO atua antes e durante a fase de Refinamento. Seu foco é garantir que o card chegue ao dev com requisitos claros e critérios de aceite verificáveis.

| Momento | O que o PO faz |
|---|---|
| Card novo no backlog | Roda `/refinar-feature` para estruturar a User Story — ou acompanha o dev e atua como **aprovador** da proposta gerada |
| Card pronto para sprint | Valida se os critérios de aceite refletem corretamente as regras de negócio esperadas |
| Antes do desenvolvimento | Roda `/documentar-e2e` para gerar o caderno de testes em linguagem de negócio, usado como referência para UAT |
| Card de bug | Valida o bug report gerado pelo dev com `/identificar-bug` antes de a correção começar |

#### `/refinar-feature <EFC-XXXX>`

**Como o PO usa:** O Claude transforma a descrição atual do Jira em uma User Story estruturada e **apresenta para aprovação antes de gravar qualquer coisa**. Esse é o momento central do PO: revisar, pedir ajustes e confirmar. Só após aprovação explícita a descrição é atualizada no Jira.

**Quando usar:** Ao preparar um card para entrar em sprint — antes do planejamento técnico.

#### `/documentar-e2e <EFC-XXXX>`

**Como o PO usa:** Gera um caderno de testes em Gherkin (Given/When/Then) em **linguagem de negócio pura**, sem código ou jargão técnico. O resultado é apresentado para aprovação do PO e depois anexado ao card Jira. Serve como contrato de entrega e base para testes de aceitação (UAT).

**Quando usar:** Após a User Story aprovada, antes ou logo após o início do desenvolvimento.

> O PO não precisa usar os comandos de implementação (`/criar-filtro`, `/executar-plano`, etc.) nem de revisão técnica (`/analisar-pr`, `/merge-branch`). Sua atuação se concentra na definição e validação dos requisitos.

---

### REFINAMENTO

#### `/refinar-feature <EFC-XXXX>`

**O que faz:** Lê a descrição do card Jira, explora o repositório para entender o contexto, e redige uma **User Story estruturada** (contexto, "Como… quero… para que…", critérios de aceite numerados e regras de negócio). Apresenta a proposta para aprovação e, após confirmação, atualiza a descrição diretamente no Jira em formato ADF. Salva o arquivo `Docs/user-story-EFC-XXXX.md` localmente.

**Quando usar:** Antes de qualquer planejamento técnico. É o primeiro passo quando um card chega ao time — transforma a descrição informal em um spec revisável e alinhado.

**Pré-requisitos:** Variáveis de ambiente `JIRA_BASE_URL`, `JIRA_USER` e `JIRA_API_TOKEN` exportadas no terminal.

---

#### `/documentar-e2e <EFC-XXXX>`

**O que faz:** Gera um **caderno de testes E2E em Gherkin** (Given/When/Then) descrevendo os cenários em linguagem de negócio — sem referências a botões, modais ou endpoints. Cobre caminho feliz, casos de borda e controle de acesso quando relevante. Apresenta para aprovação, salva em `Docs/`, anexa o arquivo ao Jira e remove-o localmente.

**Quando usar:** Durante o refinamento ou logo antes do início do desenvolvimento. O caderno é insumo para QA validar a entrega sem precisar ler código.

**Pré-requisitos:** Card com User Story já definida (ou descrição suficiente no Jira). Variáveis Jira exportadas.

---

#### `/identificar-bug <EFC-XXXX>`

**O que faz:** Lê o card de bug no Jira (incluindo anexos), explora o código para entender o fluxo afetado e gera dois documentos: um **bug report em linguagem de negócio** (passos para reprodução, impacto, comportamento esperado) e um **caderno de testes E2E** com cenário de regressão. Ambos são aprovados pelo usuário antes de serem anexados ao Jira. Garante que o repositório está no branch `master` atualizado antes de começar.

**Quando usar:** Ao receber um card de bug — antes de abrir uma branch de correção. Substitui a análise manual e já entrega os testes E2E de regressão para QA.

**Pré-requisitos:** Variáveis Jira exportadas. Repositório sem alterações não commitadas.

---

### PLANEJAMENTO TÉCNICO

#### `/planejar-implementacao <EFC-XXXX>`

**O que faz:** Lê o spec (arquivo `Docs/user-story-EFC-XXXX.md` ou, se não existir, o Jira), explora o repositório, e monta um **plano técnico faseado** respeitando a arquitetura em camadas (Domain → Domain.Services → Infra → API → Frontend). Cada fase é vinculada a um critério de aceite e indica explicitamente quando seguirá padrões de scaffolding (`criar-entidade`, `criar-filtro`, etc.). Apresenta para aprovação e salva em `Docs/plano-tecnico-EFC-XXXX.md`.

**Quando usar:** Após refinamento aprovado, antes de abrir a branch de desenvolvimento. O plano é o guia de execução que o `/executar-plano` vai seguir.

**Pré-requisitos:** User Story aprovada (preferencialmente com `Docs/user-story-EFC-XXXX.md` gerado pelo `/refinar-feature`).

---

### IMPLEMENTAÇÃO

#### `/executar-plano <EFC-XXXX>`

**O que faz:** Lê o `Docs/plano-tecnico-EFC-XXXX.md` e executa as fases pendentes **uma por vez**, aguardando confirmação do usuário entre elas. Verifica que o branch atual não é protegido (`master`, `develop`, `homolog`). Ao concluir todas as fases, executa build e testes (`dotnet test` no backend, `npm run build` + `lint` no frontend), e cria o commit seguindo o padrão do repositório.

**Quando usar:** Após plano aprovado e branch de feature criado. É o comando central da fase de desenvolvimento.

**Pré-requisitos:** `Docs/plano-tecnico-EFC-XXXX.md` existente. Branch de feature ativo (`feature/EFC-XXXX-descricao`).

---

#### `/criar-entidade <NomeDaEntidade>`

**O que faz:** Scaffolding completo de uma **nova entidade de domínio**: classe C# (herdando `BaseEntity` ou `StatefulEntity`), interface e implementação do repositório, mapping EF Core, e fixture de testes com Bogus. Também atualiza as entidades relacionadas (navegações reversas e mappings). Lê a documentação interna de criação de entidades antes de qualquer arquivo.

**Quando usar:** Dentro do `/executar-plano` quando uma fase exige nova entidade, ou diretamente quando o usuário quer adicionar uma entidade pontual. Deve vir antes de qualquer service ou filtro que dependa dela.

**Inputs necessários:** Nome da entidade, tipo (`Base` ou `Stateful`) e lista de campos com tipos e relações.

---

#### `/criar-filtro <Funcionalidade>`

**O que faz:** Scaffolding completo de um **filtro em cascata** (ex.: Rede → Escola → Turma): enum de passos, DTO de request, repositório de filtro, `FilterService`, `ValidacaoService`, controller com endpoints por passo, configuração Angular do filtro, service Angular e página de listagem com filtro (corpo da listagem vazio). Termina com testes de integração do `FilterService`.

**Quando usar:** Quando a feature inclui uma tela de listagem com filtro hierárquico. Cria toda a estrutura de uma vez — frontend e backend.

**Inputs necessários:** Nome da funcionalidade (PascalCase), passos do filtro em ordem, entidade-base do repositório e regras adicionais opcionais.

---

#### `/criar-exportacao <Funcionalidade>`

**O que faz:** Adiciona a funcionalidade de **exportação Excel** em uma feature que já possui filtro: cria o DTO de exportação, adiciona o método `GetParaExport` no repositório existente, cria o `ExportarService`, adiciona o endpoint `/export` no controller existente, e integra o botão de exportação no componente de listagem Angular. Termina com testes de integração do `ExportarService`.

**Quando usar:** Após o `/criar-filtro` de uma funcionalidade — é um complemento, não pode ser executado sem o filtro existente.

**Inputs necessários:** Nome da funcionalidade, colunas do Excel, nome do arquivo `.xlsx`, nome da aba, repositório de origem e campos obrigatórios para exportar.

---

#### `/criar-service <Funcionalidade> <NomeService>`

**O que faz:** Cria a **interface** (`I{Nome}Service`) e a **implementação** (`{Nome}Service`) de um service de domínio no backend, seguindo os padrões do projeto: primary constructor C# 12, `ServiceResult<T>`, validação procedural, sem `Include()`, sem queries dentro de loops. Pode ser chamado diretamente pelo usuário ou como subagente por `/criar-filtro` e `/criar-exportacao`.

**Quando usar:** Quando a feature requer um service específico que não se enquadra nos padrões de filtro ou exportação. Também é chamado internamente pelos outros comandos de scaffolding.

**Inputs necessários:** Funcionalidade (namespace), nome do service, tipo de retorno, dependências, métodos públicos, regras de validação e lógica de negócio.

---

#### `/criar-testes <NomeService | Feature>`

**O que faz:** Cria ou complementa testes para **frontend (Jest)** ou **backend (.NET integração)**. No frontend: testes de serviço (mock de `ApiClient`) e testes de componente (lógica pura extraída, sem `TestBed`). No backend: classe de integração herdando `BaseTest`, com seed via `SeedDatabase`, cobrindo caminho feliz, ramificações condicionais e variações de permissão. Apresenta os cenários planejados para aprovação antes de criar arquivos.

**Quando usar:** Durante a implementação (para coverage de novos services) ou em revisão quando lacunas forem identificadas. O `/executar-plano` já inclui esta etapa na última fase do plano.

**Inputs necessários:** Nome do service (backend) ou nome da feature/arquivo (frontend).

---

### REVISÃO DE CÓDIGO

#### `/analisar-pr [<branch-origem> | <numero-do-PR>] [<EFC-XXXX> | --criterios]`

**O que faz:** Analisa o diff entre dois branches e gera um relatório de revisão em `Docs/revisao-pr.md` com três seções: **Conformidade com o Spec** (CA por CA), **Backend** (N+1, projeções, autenticação, UnitOfWork, etc.) e **Frontend** (tipagem, erros HTTP, standalone, modais, guards). Pode receber o número de um PR do GitHub ou o nome de um branch como argumento.

**Quando usar:** Antes de aprovar um PR — tanto pelo autor (auto-revisão) quanto pelo revisor. Substitui a leitura manual do diff para identificar desvios de padrão.

**Modos de uso:**
- `/analisar-pr 212` — analisa o PR #212 do GitHub
- `/analisar-pr master EFC-1234` — compara branch atual com `master`, valida CAs do card
- `/analisar-pr master --criterios` — pede os CAs manualmente antes de analisar

---

### MERGE

#### `/merge-branch <branch-origem>`

**O que faz:** Traz as mudanças do branch informado para o branch atual, com triagem e resolução de conflitos, build de verificação e commit do merge. Classifica cada conflito entre **resolvível automaticamente** (imports, formatação, adições independentes) e **requer decisão humana** (lógica alterada nos dois lados), apresentando a triagem antes de resolver qualquer arquivo.

**Quando usar:** Para atualizar uma branch de feature com as mudanças de `develop` ou `master`, ou para integrar um branch em outro. Não substitui o merge via PR — é para merges locais durante o desenvolvimento.

**Restrições:**
- `homolog` nunca pode ser origem
- Merges para `production` só são permitidos a partir de `master`

---

## Comandos internos (não invocar diretamente)

Estes comandos são incluídos como subrotinas pelos comandos acima. Estão documentados aqui apenas para referência.

| Comando | Função |
|---|---|
| `_jira.md` | Verifica variáveis de ambiente e busca um ticket no Jira via `curl.exe` |
| `_jira-handoff.md` | Baixa o zip de handoff de design anexado ao Jira e extrai em `Docs/handoff-{TICKET}/` |
| `_jira-documentar.md` | Anexa um arquivo ao Jira como attachment e remove o arquivo local |
| `_explorar-repositorio.md` | Orienta o agente a usar a documentação interna e o enum `Funcionalidade.cs` como ponto de partida para explorar o repositório |
| `_git-verificar-sem-alteracoes.md` | Verifica `git status` e interrompe o fluxo se houver alterações não commitadas |
| `_pr-criterios-analise.md` | Define os critérios de backend e frontend aplicados pelo `/analisar-pr` |
| `_pr-resolver-branches.md` | Resolve `BRANCH_ORIGEM` e `BRANCH_DESTINO` a partir dos argumentos do `/analisar-pr` |
| `_pr-resolver-criterios.md` | Obtém os critérios de aceite do arquivo local, do Jira ou do usuário para o `/analisar-pr` |

---

## Variáveis de ambiente necessárias

Alguns comandos requerem acesso ao Jira. Exporte antes de usá-los (ou configure no perfil do shell):

```bash
export JIRA_BASE_URL="https://sua-empresa.atlassian.net"
export JIRA_USER="seu.email@empresa.com"
export JIRA_API_TOKEN="seu-token-aqui"
```

No Claude Code, use `! export NOME=valor` para exportar sem sair da sessão.

---

## Resumo rápido por perfil

**Dev iniciando uma feature:**
```
/refinar-feature EFC-XXXX  →  /planejar-implementacao EFC-XXXX  →  /executar-plano EFC-XXXX
```

**Dev antes de abrir PR:**
```
/analisar-pr master EFC-XXXX
```

**Dev atualizando branch com develop:**
```
/merge-branch develop
```

**PO preparando um card:**
```
/refinar-feature EFC-XXXX  →  (aprovar User Story)  →  /documentar-e2e EFC-XXXX
```

**QA recebendo a entrega:**
> Solicitar ao dev que rode `/documentar-e2e EFC-XXXX` — o caderno de testes E2E estará anexado ao card Jira.

**Dev recebendo card de bug:**
```
/identificar-bug EFC-XXXX  →  (corrigir)  →  /analisar-pr master EFC-XXXX
```
