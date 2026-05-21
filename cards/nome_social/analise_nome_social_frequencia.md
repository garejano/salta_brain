# Análise: Nome Social no Módulo Frequência

**Data:** 2026-05-19  
**RA analisado:** 23313977

---

## Conclusão

**O `NomeSocial` não trafega em nenhum ponto da cadeia que alimenta o módulo Frequência.** A implementação exige mudanças em dois repositórios: `barramento-pedagogico` e `frequencia`.

---

## Fluxo completo de dados

```
dbo.Pessoa.NomeSocial (SQL Server — fonte de verdade)
    │
    ▼
VIEW ModuloFrequencia.UsuarioAluno (SQL Server)
    │  ← NomeSocial AUSENTE na view
    ▼
barramento-pedagogico
  ├── Entity:  FrequenciaUsuarioAluno  { Nome, CodPessoaTOTVS }
  ├── DTO:     FrequenciaUsuarioResponse { Hash, Nome, CodPessoaTOTVS, Ativo }
  └── Endpoint: GET api/frequencia/usuariosalunos
    │  ← NomeSocial AUSENTE no DTO retornado
    ▼
frequencia (sync)
  ├── BarramentoSyncRepository.GetUsuarioAluno()
  ├── BarramentoUsuarioResponse { Hash, Nome, Ativo, CodPessoaTOTVS }
  ├── SyncUsuarioService.InsertEntities / UpdateEntities
  └── Entidade local Usuario { Nome, CodPessoaTOTVS }
    │  ← NomeSocial AUSENTE em toda a cadeia de sync
    ▼
Banco PostgreSQL do Frequência
  └── Tabela Usuario — sem coluna NomeSocial
```

---

## Raiz do problema

O barramento-pedagogico expõe o `NomeSocial` **em outro endpoint** (alunos matriculados via `AlunoEscolaRepository`), mas o endpoint específico de sync de usuários para o Frequência (`api/frequencia/usuariosalunos`) lê de uma **view** (`ModuloFrequencia.UsuarioAluno`) que não inclui o campo.

---

## Evidências no barramento-pedagogico

### `FrequenciaUsuarioAluno.cs` — entity
```csharp
public class FrequenciaUsuarioAluno : BaseEntity
{
    public virtual string Nome { get; set; }
    public virtual int? CodPessoaTOTVS { get; set; }
    // NomeSocial ausente
}
```

### `FrequenciaUsuarioAlunoMap.cs` — mapeamento
```csharp
builder.ToView("UsuarioAluno", schema: "ModuloFrequencia");
// Mapeia apenas Nome e CodPessoaTOTVS
```

### `FrequenciaUsuarioResponse.cs` — DTO retornado ao Frequência
```csharp
public class FrequenciaUsuarioResponse
{
    public Guid Hash { get; set; }
    public string Nome { get; set; }
    public int? CodPessoaTOTVS { get; set; }
    public bool Ativo { get; set; }
    // NomeSocial ausente
}
```

### `FrequenciaUsuarioAlunoRepository.cs` — query
```csharp
.Select(x => new FrequenciaUsuarioResponse
{
    Hash = x.Hash,
    Nome = x.Nome,
    CodPessoaTOTVS = x.CodPessoaTOTVS,
    Ativo = x.Ativo
    // NomeSocial não é selecionado
})
```

**Nota:** o barramento-pedagogico JÁ tem `NomeSocial` na entidade `Pessoa.cs` e já usa ele em `AlunoEscolaRepository` (lógica `NomeSocial ?? Nome`). O campo existe no modelo de dados — só não foi incluído no fluxo de sync do Frequência.

---

## Evidências no frequencia

### `BarramentoUsuarioResponse.cs` — DTO de entrada do sync
```csharp
public class BarramentoUsuarioResponse
{
    public Guid Hash { get; set; }
    public string Nome { get; set; }
    public bool Ativo { get; set; }
    public int? CodPessoaTOTVS { get; set; }
    // NomeSocial ausente
}
```

### `SyncUsuarioService.cs` — InsertEntities / UpdateEntities
Mapeia apenas `Nome` e `CodPessoaTOTVS`. Sem `NomeSocial`.

---

## Aluno RA 23313977

Dados encontrados no SQL Server (`ElevaPortalHomolog.dbo.Pessoa`):

```
Nome:       HAMLOREM IPSUM DOLOR SIT AMES
NomeSocial: NULL
```

O `NomeSocial` está nulo no portal legado. Pode ser que o dado exista no TOTVS mas nunca tenha sido sincronizado para `dbo.Pessoa`. Vale confirmar diretamente no TOTVS / barramento se esse aluno possui `NomeSocial` cadastrado.

---

## O que precisa ser implementado

### No barramento-pedagogico (pré-requisito)

1. Atualizar a **view `ModuloFrequencia.UsuarioAluno`** no SQL Server para incluir `NomeSocial` (JOIN com `dbo.Pessoa` ou origem equivalente)
2. Adicionar `NomeSocial` à entity `FrequenciaUsuarioAluno`
3. Adicionar `NomeSocial` ao DTO `FrequenciaUsuarioResponse`
4. Selecionar `NomeSocial` no `FrequenciaUsuarioAlunoRepository`
5. Idem para as variantes professor (`FrequenciaUsuarioProfessor`) e responsável, se necessário

### No frequencia (passos de IMPLEMENTACAO_NOME_SOCIAL.md)

1. Adicionar `NomeSocial` em `BarramentoUsuarioResponse`
2. Adicionar `NomeSocial` na entity `Usuario`
3. Mapear a coluna em `UsuarioMap`
4. Criar migration `Alter_Usuario_Add_NomeSocial`
5. Adicionar constante `NomeSocial` em `InformacoesCardAluno`
6. Sincronizar o campo em `SyncUsuarioService`
7. Adicionar lógica de exibição em `InformacoesCardAlunoGetService`

### Ponto de atenção — aluno RA 23313977

O `NomeSocial` deste aluno está nulo em `dbo.Pessoa`. Confirmar com o time se o dado existe no TOTVS antes de testar a exibição. Após a implementação será necessário forçar re-sync deste aluno.
