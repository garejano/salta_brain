# Setup Claude Code — Ambiente Salta

Documentação para configurar o Claude Code igual ao ambiente do Gustavo.

---

## 1. Pré-requisitos

- **Node.js** instalado (para o MCP de SQL Server)
- **Claude Code** instalado (CLI + desktop app)
- Acesso à rede interna Salta (VPN ou presencial) para conectar ao SQL Server

---

## 2. MCP SQL Server

O MCP usado é o `@bilims/mcp-sqlserver` (pacote npm).

### 2.1 Instalar o pacote globalmente

```powershell
npm install -g @bilims/mcp-sqlserver
```

Versão atual no ambiente de referência: `2.0.3`

### 2.2 Configurar no Claude Desktop

Edite o arquivo `claude_desktop_config.json` localizado em:

```
C:\Users\<seu-usuario>\AppData\Roaming\Claude\claude_desktop_config.json
```

Adicione o bloco `mcpServers` com a configuração abaixo:

```json
{
  "mcpServers": {
    "sqlserver": {
      "command": "mcp-sqlserver",
      "env": {
        "SQLSERVER_HOST": "belerofonte.eleva.local",
        "SQLSERVER_USER": "mcp.readonly",
        "SQLSERVER_PASSWORD": "PlpyWfEvTSQqss5w",
        "SQLSERVER_DATABASE": "ElevaPortalHomolog",
        "SQLSERVER_ENCRYPT": "true",
        "SQLSERVER_TRUST_CERT": "true"
      }
    }
  }
}
```

> O usuário `mcp.readonly` tem acesso somente leitura ao banco `ElevaPortalHomolog`.

### 2.3 Verificar conexão

Depois de reiniciar o Claude Desktop, abra uma sessão e peça ao Claude:

```
liste as tabelas do banco de dados
```

Ou use o comando direto: `mcp__sqlserver__list_tables`.

---

## 3. MCP Atlassian (Jira)

Não requer instalação local — é um MCP remoto via integração `claude.ai`.

### Como autenticar

1. Abra o Claude Code
2. Tente usar qualquer ferramenta Atlassian (ex: buscar um card Jira)
3. O Claude vai solicitar autenticação → clique no link e faça login com sua conta Atlassian da Salta

---

## 4. Plugin TypeScript LSP

Adicione o plugin de Language Server Protocol para TypeScript.

### Como instalar

No Claude Code, execute:

```
/install-plugin typescript-lsp
```

Ou pelo terminal:

```powershell
claude plugins install typescript-lsp
```

---

## 5. Configurações globais do Claude Code

Arquivo: `C:\Users\<seu-usuario>\.claude\settings.json`

```json
{
  "permissions": {
    "allow": [
      "mcp__sqlserver__test_connection",
      "mcp__sqlserver__list_databases",
      "mcp__sqlserver__execute_query",
      "mcp__sqlserver__describe_table"
    ]
  },
  "extraKnownMarketplaces": {
    "claude-plugins-official": {
      "source": {
        "source": "git",
        "url": "https://github.com/anthropics/claude-plugins-official.git"
      }
    }
  },
  "theme": "dark",
  "enabledPlugins": {
    "typescript-lsp@claude-plugins-official": true
  }
}
```

> As permissões em `allow` evitam que o Claude pergunte confirmação a cada chamada ao SQL Server.

---

## 6. Verificação final

Após tudo configurado, abra o Claude Code e rode:

```powershell
claude mcp list
```

Você deve ver algo assim:

```
sqlserver: mcp-sqlserver  - ✓ Connected
claude.ai Atlassian: https://mcp.atlassian.com/v1/mcp - ✓ Connected
```

---

## Resumo dos componentes

| Componente | Tipo | Como configurar |
|---|---|---|
| SQL Server | MCP local (npm) | `npm i -g @bilims/mcp-sqlserver` + `claude_desktop_config.json` |
| Atlassian/Jira | MCP remoto (claude.ai) | Login na primeira chamada |
| TypeScript LSP | Plugin Claude Code | `/install-plugin typescript-lsp` |
