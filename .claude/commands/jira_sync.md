# Skill: jira_sync

## Descrição

Mantém os arquivos locais em `cards/` atualizados a partir do Jira. O fluxo é **sempre unidirecional: Jira → local**. O Jira é a fonte de verdade; esta skill nunca escreve nem altera dados no Jira. Alterações feitas localmente nos arquivos de cards não são propagadas de volta.

---

## Uso

```
/jira_sync              → sincroniza todos os cards abertos do usuário
/jira_sync <KEY>        → sincroniza (ou cria) um card específico (ex: /jira_sync EFC-6196)
/jira_sync --list       → lista cards abertos sem criar arquivos
/jira_sync backlog      → grava snapshot do backlog em cards/BACKLOG/backlog.md
```

---

## Parâmetros

| Parâmetro  | Descrição | Obrigatório |
|------------|-----------|-------------|
| `<KEY>`    | Chave do card Jira (ex: `EFC-6196`) | Não |
| `--list`   | Apenas lista, sem gravar arquivos | Não |
| `backlog`  | Grava snapshot do backlog do projeto em `cards/BACKLOG/backlog.md` | Não |

---

## Execução Passo a Passo

### 1. Descobrir instância e usuário

- Usar `getAccessibleAtlassianResources` para obter o `cloudId`.
- Usar `lookupJiraAccountId` com o e-mail do usuário para obter o `accountId` — **necessário apenas nos modos completo, `--list` e `backlog`; pular esta chamada no modo card único (`<KEY>`).**

### 2. Buscar cards

**Modo completo (sem parâmetros):**
```jql
assignee = "<accountId>" AND statusCategory != Done ORDER BY updated DESC
```
Campos: `summary`, `status`, `issuetype`, `priority`, `project`, `description`, `updated`, `subtasks`, `parent`

**Modo card único (`/jira_sync <KEY>`):**
```jql
key = "<KEY>"
```
Sem filtro de assignee — sincroniza o card independentemente de estar atribuído ao usuário ou de qual for seu status.

**Modo lista (`--list`):**  
Executar a mesma query do modo completo, mas imprimir tabela no terminal e encerrar sem gravar.

**Modo backlog (`backlog`):**
```jql
project = EFC AND statusCategory = "To Do" ORDER BY priority ASC, updated DESC
```
Gravar o resultado em `cards/BACKLOG/backlog.md` usando o template da **Seção "Template de Backlog"**. Criar o diretório se não existir. Sempre sobrescrever sem pedir confirmação (snapshot de ponto no tempo).

### 3. Para cada card — criar/atualizar arquivo local

#### 3a. Verificar se o diretório já existe

- Caminho: `cards/<KEY>/`
- Se existir `cards/<KEY>/<KEY>.md`, perguntar ao usuário se deseja sobrescrever antes de continuar.

#### 3b. Buscar detalhes completos do card

Usar `getJiraIssue` (ou `searchJiraIssuesUsingJql` com `maxResults=1`) para obter:
- `description` completa
- `subtasks` e seus statuses
- `parent` (Epic/Feature)
- `priority`, `labels`, `fixVersions`
- `comments` recentes (últimos 3)

#### 3c. Gravar `cards/<KEY>/<KEY>.md`

Usar o template da **Seção "Template de Saída"** abaixo, preenchendo com os dados reais do card.

### 4. Exibir resumo

Ao final, exibir tabela com os cards processados:

```
✔ EFC-6196  →  cards/EFC-6196/EFC-6196.md  (criado)
✔ EFC-5976  →  cards/EFC-5976/EFC-5976.md  (atualizado)
✗ EFC-3301  →  ignorado (usuário negou sobrescrita)
```

---

## Template de Saída — `cards/<KEY>/<KEY>.md`

```markdown
# <KEY> — <summary>

> **Fonte:** Jira (`gruposalta.atlassian.net`) — somente leitura. Não edite campos sincronizados diretamente aqui.  
> **Status:** <status> | **Tipo:** <issuetype> | **Prioridade:** <priority> | **Última sincronização:** <data e hora da execução da skill>

---

## 1. Contexto e Motivação

<description — reescrita em prosa clara se for ADF/JSON, preservando o conteúdo>

---

## 2. Critérios de Aceitação

<extrair da descrição ou listar "não especificado no card">

---

## 3. Subtarefas

| # | Key | Resumo | Status |
|---|-----|--------|--------|
<uma linha por subtarefa, ou "Nenhuma subtarefa" se vazio>

---

## 4. O Que Precisa Ser Feito

<síntese técnica do escopo de implementação com base na descrição>

---

## 5. Arquivos Prováveis a Modificar

<se possível inferir pelo contexto do card e do repositório, listar aqui>

---

## 6. Links

- Jira: https://gruposalta.atlassian.net/browse/<KEY>
<links extras encontrados na descrição>
```

---

## Template de Saída — `cards/BACKLOG/backlog.md`

```markdown
# Backlog — EFC

> Snapshot gerado em: <data e hora da execução>

---

| Key | Tipo | Prioridade | Resumo | Assignee |
|-----|------|------------|--------|----------|
<uma linha por card, ordenada por prioridade e depois por atualização>

---

_Total: <n> cards em backlog_
```

---

## Regras e Restrições

### Princípio fundamental

> **O Jira é a fonte de verdade. Esta skill é somente leitura em relação ao Jira.**  
> Nenhuma chamada de escrita (`createJiraIssue`, `editJiraIssue`, `addCommentToJiraIssue`, `transitionJiraIssue` etc.) deve ser feita em nenhuma circunstância.  
> Se o usuário pedir para atualizar algo no Jira, recusar e orientar a fazer diretamente pelo Jira.

### Regras de arquivo local

- **Não sobrescrever** `cards/<KEY>/<KEY>.md` sem confirmação explícita do usuário — o arquivo pode conter anotações manuais.
- **Não criar** arquivos para cards com status `Done` no modo completo, a menos que `--list` seja usado. No modo card único (`<KEY>`), criar/atualizar independentemente do status.
- Converter descrições em formato ADF (Atlassian Document Format) para Markdown legível antes de gravar.
- Preservar arquivos adicionais já existentes no diretório do card (ex: `*_QA.md`, `*_dev.md`).
- Usar o `cloudId` da instância `gruposalta.atlassian.net` sempre que disponível no contexto da sessão (evitar chamada redundante a `getAccessibleAtlassianResources`).

---

## Exemplos

### Exemplo 1 — Listar sem gravar

```
/jira_sync --list
```

Saída esperada:

```
Cards abertos atribuídos a você (5):

| Key       | Tipo       | Status        | Resumo                                              |
|-----------|------------|---------------|-----------------------------------------------------|
| EFC-6196  | Story      | Aguardando QA | Data de alocação do professor na tela de alocação   |
| EFC-5976  | Story      | Aguardando QA | Autonomia de Avaliação e Cálculo para Itinerários   |
| EFC-5855  | Bug        | Aberta        | Front - EstruturaPedagogica - Loop sem acesso       |
| EFC-3301  | Story      | Aberta        | Gerar Certificado de Conclusão em 1 arquivo         |
| EFC-5967  | Technology | Aberta        | Front:Filtro - campo sem cache no primeiro loading  |
```

### Exemplo 2 — Sincronizar card específico

```
/jira_sync EFC-6196
```

Cria `cards/EFC-6196/EFC-6196.md` com o contexto completo do card.

### Exemplo 3 — Sincronizar todos

```
/jira_sync
```

Cria/atualiza um arquivo por card aberto, confirmando antes de sobrescrever qualquer existente.

---

## Dependências

- MCP `Atlassian` configurado e autenticado (`mcp__claude_ai_Atlassian__*`)
- Permissão de escrita no diretório `cards/`

---

## Erros Esperados e Como Tratar

| Erro | Causa | Ação |
|------|-------|------|
| `cloudId` não encontrado | MCP Atlassian não autenticado | Orientar o usuário a autenticar via `/mcp` |
| Card não encontrado | KEY inválida ou sem permissão | Informar e encerrar sem criar arquivo |
| Descrição vazia | Card sem texto no Jira | Gravar arquivo com seção de contexto marcada como "Não preenchida no Jira" |
| Diretório `cards/` inexistente | Primeira execução | Criar o diretório automaticamente |
