# PostgreSQL — Erro 42501 ao rodar migrations com ALTER TABLE

## Problema

Ao rodar a aplicação (EF Core migrations), o seguinte erro ocorre:

```
Npgsql.PostgresException: '42501: must be owner of table <NomeDaTabela>'
```

O EF tenta executar `ALTER COLUMN` durante a migration, mas o usuário de conexão da aplicação não é dono da tabela no PostgreSQL.

## Causa

No PostgreSQL, `ALTER TABLE` (incluindo `ALTER COLUMN TYPE`) exige que o executor seja o **owner** da tabela ou um **superuser**. O usuário da aplicação normalmente tem apenas permissões de leitura/escrita (DML), não DDL.

## Solução

### 1. Rodar o ALTER TABLE manualmente com o owner/DBA

```sql
-- Executar com o owner da tabela ou superuser
ALTER TABLE "NomeDaTabela"
    ALTER COLUMN "NomeColuna" TYPE character varying(300);
```

> Script salvo em `_scripts/apply_escola_externa_nome_300.sql` para o caso EscolaExterna.Nome (200 → 300).

### 2. Marcar a migration como aplicada no EF (sem re-executar)

Via CLI:
```powershell
dotnet ef migrations mark-applied <NomeDaMigration>
```

Ou diretamente no banco:
```sql
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('<NomeDaMigration>', '6.0.0');
-- Ajustar a versão consultando os valores existentes na tabela
```

### 3. Subir a aplicação normalmente

O EF verifica `__EFMigrationsHistory` antes de executar — com o registro inserido, não tentará rodar o `ALTER` de novo.

## Caso concreto

- **Repositório:** `documentacao-pedagogica`
- **Tabela:** `EscolaExterna`
- **Coluna:** `Nome` — ampliada de `varchar(200)` para `varchar(300)`
- **Arquivo de migration:** `20260522120000_Alter_EscolaExterna_NomeMaxLength300.cs`
- **Script SQL:** `_scripts/apply_escola_externa_nome_300.sql`
- **Validação:** `_scripts/check_escola_externa_nome_length.sql`
