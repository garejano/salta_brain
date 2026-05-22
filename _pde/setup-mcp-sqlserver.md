# Setup MCP SQL Server — Claude Code

## O que é

O `@bilims/mcp-sqlserver` é um MCP (Model Context Protocol) que permite ao Claude Code consultar diretamente um banco SQL Server. Com ele ativo, o Claude consegue listar tabelas, descrever estruturas e executar queries durante uma conversa.


---

## 1. Instalar o pacote

```powershell
npm install -g @bilims/mcp-sqlserver
```

Verifique a instalação:

```powershell
mcp-sqlserver --version
```

---

## 2. Configurar a conexão

Edite o arquivo:

```
C:\Users\<seu-usuario>\AppData\Roaming\Claude\claude_desktop_config.json
```

Se o arquivo não existir, crie-o. Adicione o bloco abaixo (preserve qualquer conteúdo que já exista no arquivo):

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

---

## 3. Liberar permissões no Claude Code

Para o Claude não pedir confirmação a cada chamada ao banco, adicione as permissões no arquivo:

```
C:\Users\<seu-usuario>\.claude\settings.json
```

```json
{
  "permissions": {
    "allow": [
      "mcp__sqlserver__test_connection",
      "mcp__sqlserver__list_databases",
      "mcp__sqlserver__list_tables",
      "mcp__sqlserver__execute_query",
      "mcp__sqlserver__describe_table"
    ]
  }
}
```

> Se o arquivo já tiver um array `allow`, apenas acrescente as linhas acima ao array existente.

---

## 4. Verificar conexão

Reinicie o Claude Desktop e rode no terminal:

```powershell
claude mcp list
```

Resultado esperado:

```
sqlserver: mcp-sqlserver  - ✓ Connected
```

Ou peça diretamente ao Claude numa sessão:

```
teste a conexão com o sql server
```

---

## Ferramentas disponíveis após configuração

| Ferramenta | O que faz |
|---|---|
| `mcp__sqlserver__test_connection` | Testa se a conexão está ativa |
| `mcp__sqlserver__get_server_info` | Versão e edição do SQL Server |
| `mcp__sqlserver__list_databases` | Lista os bancos disponíveis |
| `mcp__sqlserver__list_tables` | Lista tabelas do banco configurado |
| `mcp__sqlserver__list_views` | Lista views |
| `mcp__sqlserver__describe_table` | Estrutura de uma tabela (colunas, tipos) |
| `mcp__sqlserver__get_foreign_keys` | Chaves estrangeiras de uma tabela |
| `mcp__sqlserver__get_table_stats` | Estatísticas (linhas, tamanho) |
| `mcp__sqlserver__execute_query` | Executa uma query SQL |
