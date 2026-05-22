# MCPs Ativos no Claude Code — Guia para a Equipe

> Documento para onboarding de colegas que queiram usar os mesmos MCPs (Model Context Protocol) no Claude Code.
> **Data:** 2026-05-20

---

## O que é MCP?

MCP (Model Context Protocol) são extensões que conectam o Claude Code a sistemas externos. Em vez de copiar e colar dados, o Claude consulta o sistema diretamente durante a conversa.

---

## MCPs ativos

### 1. SQL Server (`mcp-sqlserver`)

Permite ao Claude consultar o banco de dados SQL Server diretamente. Útil para explorar schema, entender dados, escrever e validar queries.

#### Instalação

```bash
npm install -g mcp-sqlserver
```

> Requer Node.js instalado. Verifique com `node -v`.

#### Configuração

Edite (ou crie) o arquivo `%APPDATA%\Claude\claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "sqlserver": {
      "command": "mcp-sqlserver",
      "env": {
        "SQLSERVER_HOST": "<host do banco>",
        "SQLSERVER_USER": "<usuário>",
        "SQLSERVER_PASSWORD": "<senha>",
        "SQLSERVER_DATABASE": "<nome do banco>",
        "SQLSERVER_ENCRYPT": "true",
        "SQLSERVER_TRUST_CERT": "true"
      }
    }
  }
}
```

> Peça ao Gustavo ou ao time de infra as credenciais de leitura (`mcp.readonly`).  
> Nunca use credenciais de escrita aqui — o usuário `mcp.readonly` é só leitura por design.

#### Ferramentas disponíveis

| Ferramenta | O que faz |
|---|---|
| `list_databases` | Lista os bancos disponíveis no servidor |
| `list_tables` | Lista todas as tabelas do banco configurado |
| `list_views` | Lista as views |
| `describe_table` | Mostra colunas, tipos e constraints de uma tabela |
| `get_foreign_keys` | Mostra as foreign keys de uma tabela |
| `get_table_stats` | Estatísticas da tabela (contagem de linhas, etc.) |
| `execute_query` | Executa uma query SQL (somente leitura) |
| `get_server_info` | Informações do servidor SQL |
| `test_connection` | Testa se a conexão está funcionando |

#### Exemplos de uso no chat

```
Liste todas as tabelas do banco que têm "Aluno" no nome.

Descreva a tabela Matriculas — quais são as colunas e tipos?

Quais são as foreign keys da tabela Turmas?

Escreva uma query para contar alunos ativos por escola.
```

---

### 2. Atlassian — Jira & Confluence (integração nativa Claude Code)

Integração built-in do Claude Code com a plataforma Atlassian. Não precisa de instalação extra — é configurada via autenticação OAuth diretamente no Claude Code.

#### Como autenticar

No Claude Code, basta pedir algo relacionado ao Jira. O Claude vai solicitar autenticação na primeira vez:

```
Abra o card EFC-XXXX no Jira para mim.
```

O Claude vai te guiar pelo fluxo OAuth com a Atlassian.

#### Ferramentas disponíveis — Jira

| Ferramenta | O que faz |
|---|---|
| `getJiraIssue` | Busca os detalhes completos de um card pelo key (ex: EFC-1234) |
| `searchJiraIssuesUsingJql` | Pesquisa cards usando JQL |
| `getVisibleJiraProjects` | Lista os projetos Jira disponíveis |
| `getAccessibleAtlassianResources` | Lista os recursos Atlassian autorizados |
| `lookupJiraAccountId` | Busca o ID de um usuário pelo email |
| `createJiraIssue` | Cria um novo card |
| `editJiraIssue` | Edita campos de um card existente |
| `addCommentToJiraIssue` | Adiciona comentário a um card |
| `addWorklogToJiraIssue` | Lança horas em um card |
| `transitionJiraIssue` | Muda o status de um card (ex: "Em andamento" → "Done") |
| `getTransitionsForJiraIssue` | Lista as transições disponíveis para um card |
| `getIssueLinkTypes` | Lista tipos de link entre cards |
| `createIssueLink` | Cria um link entre dois cards |
| `getJiraProjectIssueTypesMetadata` | Metadata dos tipos de issue de um projeto |
| `getJiraIssueTypeMetaWithFields` | Campos disponíveis para um tipo de issue |

#### Ferramentas disponíveis — Confluence

| Ferramenta | O que faz |
|---|---|
| `getConfluenceSpaces` | Lista os espaços Confluence |
| `getPagesInConfluenceSpace` | Lista páginas de um espaço |
| `getConfluencePage` | Lê o conteúdo de uma página |
| `createConfluencePage` | Cria uma nova página |
| `updateConfluencePage` | Atualiza uma página existente |
| `searchConfluenceUsingCql` | Pesquisa usando CQL |
| `getConfluencePageDescendants` | Lista subpáginas |
| `getConfluencePageFooterComments` | Lê comentários de rodapé |
| `createConfluenceFooterComment` | Adiciona comentário de rodapé |
| `createConfluenceInlineComment` | Adiciona comentário inline |

#### Ferramenta genérica

| Ferramenta | O que faz |
|---|---|
| `fetch` | Faz uma request HTTP genérica para APIs Atlassian |
| `search` | Pesquisa unificada Jira + Confluence |
| `atlassianUserInfo` | Retorna info do usuário autenticado |

#### Exemplos de uso no chat

```
Abra o card EFC-6322 e me mostre a descrição completa.

Liste os cards em andamento do projeto EFC atribuídos a mim.

Pesquise cards com JQL: project = EFC AND status = "In Progress" AND assignee = currentUser()

Crie um comentário no card EFC-1234: "Ajuste feito conforme solicitado."

Mude o status do card EFC-1234 para "Done".
```

---

## Dicas gerais

- **Permissões automáticas:** na primeira vez que o Claude usa uma ferramenta MCP, ele pede aprovação. Você pode marcar "Sempre permitir" para não ser perguntado de novo.
- **SQL é somente leitura:** o usuário configurado (`mcp.readonly`) não tem permissão de escrita. O Claude não vai conseguir fazer INSERT/UPDATE/DELETE mesmo que você peça.
- **Jira: Claude não grava automaticamente** — ele sempre pede confirmação antes de criar/editar cards ou adicionar comentários.
- **Arquivo de config:** `%APPDATA%\Claude\claude_desktop_config.json` (Windows). Reinicie o Claude Code após alterar.

---

## Troubleshooting

| Problema | Solução |
|---|---|
| `mcp-sqlserver: command not found` | Rode `npm install -g mcp-sqlserver` e reinicie o Claude |
| Erro de conexão no SQL | Verifique se está na VPN. O host `belerofonte.eleva.local` é interno. |
| Atlassian pede autenticação toda vez | Verifique se o token OAuth não expirou — faça login novamente |
| Claude não usa o MCP | Verifique se o `claude_desktop_config.json` está bem formado (JSON válido) |
