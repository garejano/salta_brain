# Implementação: Nome Social dos Alunos

## Contexto

Alunos que possuem nome social cadastrado no sistema de origem (TOTVS/barramento) não têm esse dado exibido na listagem de frequência. O campo `NomeSocial` está completamente ausente de toda a cadeia do sistema — do sync até a exibição no card do aluno.

---

## Raiz do Problema

O fluxo de dados passa por cinco camadas, e nenhuma delas trata o nome social:

```
Barramento (TOTVS)
    └── BarramentoUsuarioResponse   ← sem NomeSocial
         └── SyncUsuarioService     ← não sincroniza NomeSocial
              └── Usuario (entity)  ← coluna ausente no banco
                   └── InformacoesCardAlunoGetService ← não conhece "nomesocial"
                        └── LancamentoGetService      ← exibe o que vier acima
```

---

## Arquivos a Modificar

| # | Arquivo | Tipo de Mudança |
|---|---------|-----------------|
| 1 | `Frequencia.Domain/DTO/Barramento/BarramentoUsuarioResponse.cs` | Adicionar propriedade |
| 2 | `Frequencia.Domain/Entities/Usuario.cs` | Adicionar propriedade |
| 3 | `Frequencia.Infra/Mapping/UsuarioMap.cs` | Mapear nova coluna |
| 4 | `Frequencia.Infra/Migrations/` | Criar nova migration |
| 5 | `Frequencia.Domain/Entities/InformacoesCardAluno.cs` | Adicionar constante |
| 6 | `Frequencia.Domain.Services/Sync/Entidades/SyncUsuarioService.cs` | Sincronizar o campo |
| 7 | `Frequencia.Domain.Services/InformacoesCardAluno/InformacoesCardAlunoGetService.cs` | Adicionar lógica de exibição |

---

## Passo a Passo

### Passo 1 — DTO do Barramento

**Arquivo:** `backend/Frequencia.Domain/DTO/Barramento/BarramentoUsuarioResponse.cs`

Adicionar a propriedade `NomeSocial`. O campo deve ser nullable pois a maioria dos alunos não o possui.

```csharp
// ANTES
public class BarramentoUsuarioResponse
{
    public Guid Hash { get; set; }
    public string Nome { get; set; }
    public bool Ativo { get; set; }
    public int? CodPessoaTOTVS { get; set; }
}

// DEPOIS
public class BarramentoUsuarioResponse
{
    public Guid Hash { get; set; }
    public string Nome { get; set; }
    public string? NomeSocial { get; set; }   // ← adicionar
    public bool Ativo { get; set; }
    public int? CodPessoaTOTVS { get; set; }
}
```

> Verificar junto ao time responsável pelo barramento se o campo já é enviado no payload e qual é o nome exato da propriedade JSON (pode ser `nomeSocial`, `nome_social`, etc.). Ajustar a serialização com `[JsonPropertyName]` se necessário.

---

### Passo 2 — Entidade de Domínio

**Arquivo:** `backend/Frequencia.Domain/Entities/Usuario.cs`

```csharp
// ANTES
public class Usuario : ExternalEntity
{
    public virtual string Nome { get; set; }
    public virtual string ElevaIdUserToken { get; set; }
    // ...
}

// DEPOIS
public class Usuario : ExternalEntity
{
    public virtual string Nome { get; set; }
    public virtual string? NomeSocial { get; set; }   // ← adicionar
    public virtual string ElevaIdUserToken { get; set; }
    // ...
}
```

---

### Passo 3 — Mapeamento EF Core

**Arquivo:** `backend/Frequencia.Infra/Mapping/UsuarioMap.cs`

Adicionar o mapeamento da nova coluna após o mapeamento de `Nome`:

```csharp
// ANTES
builder.Property(x => x.Nome)
       .IsRequired()
       .HasMaxLength(255);

// DEPOIS
builder.Property(x => x.Nome)
       .IsRequired()
       .HasMaxLength(255);

builder.Property(x => x.NomeSocial)   // ← adicionar
       .IsRequired(false)
       .HasMaxLength(255);
```

---

### Passo 4 — Migration

Gerar via CLI:

```bash
dotnet ef migrations add Alter_Usuario_Add_NomeSocial \
  --project backend/Frequencia.Infra \
  --startup-project backend/Frequencia.Api
```

O EF Core gerará automaticamente a migration. O resultado esperado é:

```csharp
// Migration gerada: YYYYMMDDHHMMSS_Alter_Usuario_Add_NomeSocial.cs
public partial class Alter_Usuario_Add_NomeSocial : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "NomeSocial",
            table: "Usuario",
            type: "varchar(255)",
            maxLength: 255,
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(
            name: "NomeSocial",
            table: "Usuario");
    }
}
```

---

### Passo 5 — Constante na Entidade de Configuração

**Arquivo:** `backend/Frequencia.Domain/Entities/InformacoesCardAluno.cs`

```csharp
// ANTES
public const string PrimeiroNome = "primeironome";
public const string Sobrenome = "sobrenome";
public const string NomeCompleto = "nomecompleto";
public const string RA = "ra";

// DEPOIS
public const string PrimeiroNome = "primeironome";
public const string Sobrenome = "sobrenome";
public const string NomeCompleto = "nomecompleto";
public const string RA = "ra";
public const string NomeSocial = "nomesocial";   // ← adicionar
```

---

### Passo 6 — Serviço de Sync

**Arquivo:** `backend/Frequencia.Domain.Services/Sync/Entidades/SyncUsuarioService.cs`

Três pontos de alteração: `InsertEntities`, `UpdateEntities` e `ShouldUpdate`.

```csharp
// InsertEntities — ANTES
new UsuarioEntity
{
    Nome = x.Nome,
    HashOrigem = x.Hash,
    CodPessoaTOTVS = x.CodPessoaTOTVS,
}

// InsertEntities — DEPOIS
new UsuarioEntity
{
    Nome = x.Nome,
    NomeSocial = x.NomeSocial,             // ← adicionar
    HashOrigem = x.Hash,
    CodPessoaTOTVS = x.CodPessoaTOTVS,
}
```

```csharp
// UpdateEntities — ANTES
local.Nome = barramento.Nome;
local.CodPessoaTOTVS = barramento.CodPessoaTOTVS;

// UpdateEntities — DEPOIS
local.Nome = barramento.Nome;
local.NomeSocial = barramento.NomeSocial;  // ← adicionar
local.CodPessoaTOTVS = barramento.CodPessoaTOTVS;
```

```csharp
// ShouldUpdate — ANTES
private static bool ShouldUpdate(UsuarioEntity local, BarramentoUsuarioResponse barramento)
{
    return !local.Ativo
        || local.Nome != barramento.Nome
        || local.CodPessoaTOTVS != barramento.CodPessoaTOTVS;
}

// ShouldUpdate — DEPOIS
private static bool ShouldUpdate(UsuarioEntity local, BarramentoUsuarioResponse barramento)
{
    return !local.Ativo
        || local.Nome != barramento.Nome
        || local.NomeSocial != barramento.NomeSocial   // ← adicionar
        || local.CodPessoaTOTVS != barramento.CodPessoaTOTVS;
}
```

---

### Passo 7 — Serviço de Exibição do Card

**Arquivo:** `backend/Frequencia.Domain.Services/InformacoesCardAluno/InformacoesCardAlunoGetService.cs`

Esta é a mudança mais importante para a exibição. A regra de negócio é: **usar `NomeSocial` quando preenchido; caso contrário, recair no `Nome`**.

O método `GetInformacao(AlunoEntity, string)` precisa tratar a nova constante. A lógica se aplica somente aos casos `NomeSocial`, `PrimeiroNome` e `Sobrenome` — que usam o nome para derivar partes. O `NomeCompleto` também deve respeitar o nome social quando disponível.

```csharp
// ANTES
public string GetInformacao(AlunoEntity aluno, string informacao)
{
    if (informacao == InformacoesCardAlunoEntity.RA) { return "RA " + aluno.Matricula; }
    else if (informacao == InformacoesCardAlunoEntity.NomeCompleto) { return aluno.Usuario.Nome; }
    else
    {
        string primeiroNome = GetPrimeiroNome(aluno.Usuario.Nome);
        string sobrenome = GetSobrenome(aluno.Usuario.Nome, primeiroNome);

        return informacao switch
        {
            InformacoesCardAlunoEntity.PrimeiroNome => primeiroNome,
            InformacoesCardAlunoEntity.Sobrenome => string.IsNullOrWhiteSpace(sobrenome) ? primeiroNome : sobrenome,
            _ => throw new Exception("Tipo de informação desconhecida para exibição no card dos alunos.")
        };
    }
}

// DEPOIS
public string GetInformacao(AlunoEntity aluno, string informacao)
{
    if (informacao == InformacoesCardAlunoEntity.RA)
        return "RA " + aluno.Matricula;

    // Nome efetivo: social tem precedência sobre o nome cadastral
    string nomeEfetivo = !string.IsNullOrWhiteSpace(aluno.Usuario.NomeSocial)
        ? aluno.Usuario.NomeSocial
        : aluno.Usuario.Nome;

    if (informacao == InformacoesCardAlunoEntity.NomeSocial)
        return nomeEfetivo;

    if (informacao == InformacoesCardAlunoEntity.NomeCompleto)
        return nomeEfetivo;

    string primeiroNome = GetPrimeiroNome(nomeEfetivo);
    string sobrenome = GetSobrenome(nomeEfetivo, primeiroNome);

    return informacao switch
    {
        InformacoesCardAlunoEntity.PrimeiroNome => primeiroNome,
        InformacoesCardAlunoEntity.Sobrenome => string.IsNullOrWhiteSpace(sobrenome) ? primeiroNome : sobrenome,
        _ => throw new Exception("Tipo de informação desconhecida para exibição no card dos alunos.")
    };
}
```

> **Decisão de negócio a confirmar:** a opção `NomeSocial` no card serve apenas para redes que querem explicitamente configurar o card para mostrar o nome social. A alternativa é sempre aplicar a substituição silenciosa (nome social sobrescreve o nome em qualquer configuração), o que já é alcançado com `nomeEfetivo` no código acima. Alinhar com o produto qual comportamento é o desejado.

---

## Ordem de Execução Recomendada

```
1. Confirmar com o time do barramento o nome do campo no payload JSON
2. Passo 1 — BarramentoUsuarioResponse
3. Passo 2 — Usuario (entity)
4. Passo 3 — UsuarioMap
5. Passo 4 — Gerar e revisar migration
6. Passo 5 — InformacoesCardAluno (constante)
7. Passo 6 — SyncUsuarioService
8. Passo 7 — InformacoesCardAlunoGetService
9. Testes unitários (ver seção abaixo)
10. Aplicar migration em homologação
11. Forçar re-sync dos usuários afetados (ou aguardar ciclo natural)
```

---

## Testes a Adicionar/Atualizar

### Unitários — `InformacoesCardAlunoGetService`

Cenários a cobrir:

| Configuração do card | NomeSocial preenchido? | Resultado esperado |
|---|---|---|
| `nomecompleto` | Sim | Retorna `NomeSocial` |
| `nomecompleto` | Não | Retorna `Nome` |
| `nomesocial` | Sim | Retorna `NomeSocial` |
| `nomesocial` | Não | Retorna `Nome` (fallback) |
| `primeironome` | Sim | Retorna primeiro token do `NomeSocial` |
| `primeironome` | Não | Retorna primeiro token do `Nome` |
| `sobrenome` | Sim | Retorna sobrenome do `NomeSocial` |
| `ra` | Sim | Retorna `"RA " + Matricula` (não afetado) |

### Integração — `SyncUsuarioService`

- Insert: verificar que `NomeSocial` é gravado quando vem preenchido no barramento
- Insert: verificar que `NomeSocial` fica `null` quando não vem no barramento
- Update: verificar que `NomeSocial` é atualizado quando muda no barramento
- Update: verificar que `ShouldUpdate` retorna `true` quando apenas o `NomeSocial` muda

---

## Observações

- **Retroatividade:** alunos já sincronizados não terão `NomeSocial` preenchido até o próximo ciclo de sync. Se necessário, criar script de re-sync ou acionar o processo de sincronização manual para os registros afetados.
- **Banco de dados:** a coluna deve ser `nullable` para não quebrar alunos que não possuem nome social.
- **Frontend:** nenhuma alteração necessária. O campo `informacaoPrincipal` / `informacaoSecundaria` já é renderizado dinamicamente no componente `lancamento.component.html`.
- **Configuração por rede:** se o produto decidir que o nome social deve ser configurável por rede (como as demais opções de card), será necessário também incluir `"nomesocial"` como opção nas migrations de `InformacoesCardAluno` e expor a opção no painel de configuração.
