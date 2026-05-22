# Configurando o MCP SQL Server no Claude Code

## O que é o MCP SQL Server

O **mcp-sqlserver** é um servidor MCP (Model Context Protocol) que permite ao Claude consultar bancos de dados SQL Server diretamente durante uma conversa. Com ele configurado, o Claude pode listar bancos, descrever tabelas, executar queries e explorar dados sem que você precise copiar e colar resultados manualmente.

---

## Pré-requisitos

### 1. Instalar o pacote mcp-sqlserver

```bash
npm install -g mcp-sqlserver
```

Verifique se a instalação funcionou:

```bash
mcp-sqlserver --version
```

### 2. Ter acesso a uma instância SQL Server

Você precisará de:
- **Host** da instância
- **Usuário** e **senha** com as permissões necessárias
- **Nome do banco de dados** padrão (pode ser alterado em tempo de execução)

> **Boa prática:** crie um usuário de leitura dedicado (ex: `mcp.readonly`) com permissão apenas de `SELECT`. Assim o Claude nunca consegue modificar dados por acidente.

---

## Configuração Principal — `claude_desktop_config.json`

Este arquivo fica em:

```
C:\Users\<seu-usuario>\AppData\Roaming\Claude\claude_desktop_config.json
```

Adicione (ou crie) a seção `mcpServers` com as configurações do SQL Server:

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

### Variáveis de ambiente explicadas

| Variável | Descrição |
|---|---|
| `SQLSERVER_HOST` | Hostname ou IP da instância SQL Server |
| `SQLSERVER_USER` | Usuário de autenticação SQL |
| `SQLSERVER_PASSWORD` | Senha do usuário |
| `SQLSERVER_DATABASE` | Banco de dados padrão ao conectar |
| `SQLSERVER_ENCRYPT` | `"true"` para forçar conexão criptografada (TLS) |
| `SQLSERVER_TRUST_CERT` | `"true"` para aceitar certificados autoassinados (comum em redes internas) |

> **Nota sobre `SQLSERVER_TRUST_CERT`:** use `"true"` apenas em redes internas confiáveis. Em produção com certificado válido, deixe como `"false"`.

---

## Permissões — `settings.json`

O Claude Code exige aprovação explícita para usar ferramentas MCP. Para evitar prompts a cada uso, adicione as permissões no arquivo de configurações do usuário:

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
      "mcp__sqlserver__list_views",
      "mcp__sqlserver__describe_table",
      "mcp__sqlserver__execute_query",
      "mcp__sqlserver__get_foreign_keys",
      "mcp__sqlserver__get_table_stats",
      "mcp__sqlserver__get_server_info"
    ]
  }
}
```

> Você pode adicionar apenas as ferramentas que quiser liberar. As que não estiverem na lista pedirão confirmação manual a cada uso.

---

## Ferramentas disponíveis

| Ferramenta | O que faz |
|---|---|
| `test_connection` | Testa se a conexão com o banco está funcionando |
| `get_server_info` | Retorna versão e informações da instância SQL Server |
| `list_databases` | Lista todos os bancos de dados disponíveis |
| `list_tables` | Lista as tabelas de um banco/schema |
| `list_views` | Lista as views de um banco/schema |
| `describe_table` | Retorna colunas, tipos e constraints de uma tabela |
| `get_foreign_keys` | Retorna as chaves estrangeiras de uma tabela |
| `get_table_stats` | Retorna estatísticas da tabela (linhas, tamanho, etc.) |
| `execute_query` | Executa uma query SQL e retorna os resultados |

---

## Como usar na prática

Depois que a configuração estiver no lugar, basta pedir ao Claude naturalmente:

```
Liste as tabelas do banco ElevaPortalHomolog.
```

```
Descreva a tabela dbo.Alunos e mostre seus relacionamentos.
```

```
Quantos registros existem na tabela de matrículas criadas em 2025?
```

```
Mostre os últimos 10 lançamentos de notas do aluno com matrícula 12345.
```

O Claude vai usar as ferramentas MCP automaticamente para buscar as informações e responder.

---

## Reiniciando após configurar

Após editar o `claude_desktop_config.json`, **feche e abra o Claude Code** (ou o Claude Desktop) para que o servidor MCP seja carregado.

Para verificar se o MCP está ativo, peça ao Claude:

```
Teste a conexão com o SQL Server.
```

---

## Configuração atual deste ambiente

A configuração atual (já funcionando) aponta para:

- **Host:** `belerofonte.eleva.local`
- **Usuário:** `mcp.readonly`
- **Banco padrão:** `ElevaPortalHomolog`
- **Criptografia:** habilitada (`ENCRYPT=true`, `TRUST_CERT=true`)

Os arquivos de configuração estão em:

- **MCP config:** `C:\Users\gustavo.arejano\AppData\Roaming\Claude\claude_desktop_config.json`
- **Permissões:** `C:\Users\gustavo.arejano\.claude\settings.json`
