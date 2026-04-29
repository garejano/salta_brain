# SPDD — REASONS Canvas | estrutura-pedagogica

> Artefato principal — mantenha versionado junto ao código da feature.
> Regra: quando código e canvas divergirem, corrija o canvas primeiro, depois o código.
> As seções **N (Norms)** e **S (Safeguards)** estão pré-preenchidas com as convenções do repositório.
> Preencha: R, E, A, S(tructure) e O.

---

## Cabeçalho

**Feature / Story:** <!-- título -->  
**Card Jira:** <!-- EFC-XXXX -->  
**Repositório:** estrutura-pedagogica  
**Versão:** v1.0  
**Data:** <!-- YYYY-MM-DD -->  
**Autor:** <!-- nome -->

---

## R — Requirements

### Problema

<!-- Descreva em 2–3 frases o problema pedagógico/operacional que esta implementação resolve. -->

### Definição de Pronto

- [ ] Endpoint(s) respondem conforme contrato definido em Operations
- [ ] Testes de integração cobrem os cenários definidos nas Operations
- [ ] Frontend (se aplicável) funciona no fluxo completo
- [ ] Script SQL (se aplicável) aplicado e revisado em `scripts-db-pedagogico`
- [ ] ...

### Fora de Escopo

- ...

---

## E — Entities

> Use `BaseEntity` para entidades sem rastreamento de usuário.
> Use `StatefulEntity` para entidades que precisam de auditoria (criação, alteração, inativação por usuário).

### Entidades

```
[NomeEntidade] : BaseEntity          // sem auditoria
  + Id: int                          // herdado
  + Hash: Guid                       // herdado
  + Ativo: bool                      // herdado
  - propriedade: tipo
  - PropriedadeNavegacao: OutraEntidade    // virtual

[OutraEntidade] : StatefulEntity     // com auditoria de usuário
  + Id, Hash, Ativo                  // herdados de BaseEntity
  + DataInclusao: DateTime           // herdado de StatefulEntity
  + UsuarioInclusaoId: int?          // herdado
  + DataUltimaAlteracao: DateTime?   // herdado
  + UsuarioUltimaAlteracaoId: int?   // herdado
  + DataInativacao: DateTime?        // herdado
  - propriedade: tipo
```

### Relacionamentos

```
[EntidadeA] --possui--> [EntidadeB]   // 1:N → List<EntidadeB> em EntidadeA
[EntidadeB] --pertence--> [EntidadeA] // N:1 → EntidadeA + EntidadeAId em EntidadeB
```

### Invariantes de Domínio

- ...

### DTOs

```
// Request
[Feature]Request
  - campo: tipo    // validação: ex Required, MaxLength

// Response
[Feature]Response
  - campo: tipo
```

---

## A — Approach

### Estratégia

<!-- Como o problema será resolvido em alto nível. 3–5 frases. -->

### Padrão(ões) Aplicado(s)

<!-- ex: novo service isolado em Domain.Services/[Feature]/, repositório estendido com query específica -->

- ...

### Decisões de Design

| Decisão | Escolha | Alternativa descartada | Motivo |
|---------|---------|----------------------|--------|
| ... | ... | ... | ... |

---

## S — Structure

### Componentes e Ações

| Camada | Arquivo | Ação |
|--------|---------|------|
| Domain | `Entities/Base/[Entidade].cs` | criar |
| Domain | `DTO/[Feature]/[Feature]Request.cs` | criar |
| Domain | `DTO/[Feature]/[Feature]Response.cs` | criar |
| Domain | `Interfaces/Base/I[Entidade]Repository.cs` | criar |
| Domain.Services | `[Feature]/Interfaces/I[Feature]Service.cs` | criar |
| Domain.Services | `[Feature]/Validators/[Feature]Validator.cs` | criar |
| Domain.Services | `[Feature]/[Feature]Service.cs` | criar |
| Infra | `Mapping/Base/[Entidade]Map.cs` | criar |
| Infra | `Repositories/Base/[Entidade]Repository.cs` | criar |
| Api | `Controllers/[Feature]Controller.cs` | criar |
| Test | `Integration/Fixtures/Entities/[Entidade]Fixture.cs` | criar |
| Test | `Integration/Fixtures/DTO/[Feature]RequestFixture.cs` | criar |
| Test | `Integration/Scenarios/[Feature]/[Feature]ServiceTests.cs` | criar |
| Frontend | `features/[feature]/` | criar |
| scripts-db-pedagogico | `[tipo]/[nome].sql` | criar (se houver mudança de schema) |

### Interface Pública

```csharp
// Domain.Services/[Feature]/Interfaces/I[Feature]Service.cs
public interface I[Feature]Service
{
    Task<ServiceResult<List<[Feature]Response>>> Get([Feature]Request request);
    Task<ServiceResult> Save([Feature]Request request);
}
```

### Registro de DI

```csharp
// Em Program.cs / extensão de DI existente
services.AddTransient<I[Feature]Service, [Feature]Service>();
services.AddTransient<I[Entidade]Repository, [Entidade]Repository>();
```

---

## O — Operations

> Instrução para a IA: execute cada operação em ordem, uma por vez.
> Não implemente nada além do descrito. Siga estritamente Norms e Safeguards.

---

### Operação 1 — Criar entidade `[NomeEntidade]`

**Arquivo:** `backend/EstruturaPedagogica.Domain/Entities/Base/[Entidade].cs`

```csharp
// Estrutura esperada:
[ExcludeFromCodeCoverage]
public class [Entidade] : BaseEntity   // ou StatefulEntity
{
    public virtual string [Propriedade] { get; set; }
    public virtual int [FK]Id { get; set; }
    public virtual [OutraEntidade] [OutraEntidade] { get; set; }
}
```

**Critério:** compila sem erros, propriedades todas `virtual`.

---

### Operação 2 — Criar mapeamento EF Core

**Arquivo:** `backend/EstruturaPedagogica.Infra/Mapping/Base/[Entidade]Map.cs`

```csharp
// Estrutura esperada:
public class [Entidade]Map : IEntityTypeConfiguration<[Entidade]>
{
    public void Configure(EntityTypeBuilder<[Entidade]> builder)
    {
        builder.ToTable("[NomeTabela]");
        builder.Property(x => x.[Propriedade]).HasMaxLength(X).IsRequired();
        builder.HasOne(x => x.Relacao).WithMany(x => x.Colecao).HasForeignKey(x => x.RelacaoId);
    }
}
```

**Critério:** mapping registrado no DbContext.

---

### Operação 3 — Criar interface e repositório

**Arquivos:**
- `backend/EstruturaPedagogica.Domain/Interfaces/Base/I[Entidade]Repository.cs`
- `backend/EstruturaPedagogica.Infra/Repositories/Base/[Entidade]Repository.cs`

```csharp
// Interface
public interface I[Entidade]Repository : IBaseRepository<[Entidade]>
{
    Task<List<[Entidade]>> GetBy[Criterio]([tipo] param);
}

// Repositório (primary constructor)
public class [Entidade]Repository(EstruturaPedagogicaDbContext _context)
    : BaseRepository<[Entidade]>(_context), I[Entidade]Repository
{
    public async Task<List<[Entidade]>> GetBy[Criterio]([tipo] param)
    {
        return await _context.[Entidades]
            .Where(x => x.[Prop] == param && x.Ativo)
            .ToListAsync();
    }
}
```

**Critério:** interface e repositório compilam; query retorna apenas registros `Ativo == true`.

---

### Operação 4 — Criar DTOs

**Arquivos:**
- `backend/EstruturaPedagogica.Domain/DTO/[Feature]/[Feature]Request.cs`
- `backend/EstruturaPedagogica.Domain/DTO/[Feature]/[Feature]Response.cs`

**Critério:** propriedades tipadas, sem lógica.

---

### Operação 5 — Criar interface, validator e service

**Arquivos:**
- `backend/EstruturaPedagogica.Domain.Services/[Feature]/Interfaces/I[Feature]Service.cs`
- `backend/EstruturaPedagogica.Domain.Services/[Feature]/Validators/[Feature]Validator.cs`
- `backend/EstruturaPedagogica.Domain.Services/[Feature]/[Feature]Service.cs`

```csharp
// Service (primary constructor)
public class [Feature]Service(
      I[Entidade]Repository _[entidade]Repository
    , I[Feature]Validator _validator
    , IUsuarioAutenticadoRepository _usuarioAutenticado)
    : I[Feature]Service
{
    public async Task<ServiceResult<List<[Feature]Response>>> Get([Feature]Request request)
    {
        ServiceResult<List<[Feature]Response>> result = new();
        // ...
        return result;
    }
}
```

**Critério:** service retorna `ServiceResult`, todas as dependências injetadas via primary constructor.

---

### Operação 6 — Criar controller

**Arquivo:** `backend/EstruturaPedagogica.Api/Controllers/[Feature]Controller.cs`

```csharp
[ApiController]
[RequiredAuthorization(Funcionalidade.[Funcionalidade])]
[Route("api/[controller]")]
[ExcludeFromCodeCoverage]
public class [Feature]Controller : CustomController
{
    /// <summary>
    /// [Descrição do endpoint]
    /// </summary>
    [HttpPost("get")]
    public async Task<IActionResult> Get(
        [FromServices] I[Feature]Service service,
        [FromBody] [Feature]Request request)
    {
        return Result(await service.Get(request));
    }
}
```

**Critério:** rota `api/[feature]`, usa `[FromServices]` para DI, retorna `Result(...)`.

---

### Operação 7 — Criar fixtures de teste

**Arquivos:**
- `backend/EstruturaPedagogica.Test/Integration/Fixtures/Entities/[Entidade]Fixture.cs`
- `backend/EstruturaPedagogica.Test/Integration/Fixtures/DTO/[Feature]RequestFixture.cs`

```csharp
public class [Entidade]Fixture
{
    public static [Entidade] Gerar(
        int? id = null,
        Guid? hash = null,
        bool ativo = true,
        string [prop] = null)
    {
        return new Faker<[Entidade]>("pt_BR")
            .RuleFor(x => x.Id, x => id ?? x.Random.Int(1))
            .RuleFor(x => x.Hash, x => hash ?? x.Random.Guid())
            .RuleFor(x => x.Ativo, _ => ativo)
            .RuleFor(x => x.[Prop], x => [prop] ?? x.[Bogus_method]());
    }

    public static List<[Entidade]> GerarLista(int quantidade = 3) =>
        Enumerable.Range(0, quantidade).Select(_ => Gerar()).ToList();
}
```

**Critério:** locale `pt_BR`, FKs inteiras nunca atribuídas na fixture (apenas navegação), método `GerarLista`.

---

### Operação 8 — Criar testes de integração

**Arquivo:** `backend/EstruturaPedagogica.Test/Integration/Scenarios/[Feature]/[Feature]ServiceTests.cs`

```csharp
public class [Feature]ServiceTests : BaseTest
{
    private const int _usuarioId = 99999;
    private readonly Mock<UsuarioAutenticadoRepository> _usuarioAutenticadoMock;

    public [Feature]ServiceTests()
    {
        AddGlobalization();
        AddInMemoryDbContext();

        _usuarioAutenticadoMock = new Mock<UsuarioAutenticadoRepository>();
        _usuarioAutenticadoMock.Setup(r => r.IdUsuarioAutenticado).Returns(_usuarioId);

        serviceCollection.AddScoped<IUsuarioAutenticadoRepository, UsuarioAutenticadoRepository>(
            _ => _usuarioAutenticadoMock.Object);

        serviceCollection.AddTransient<I[Entidade]Repository, [Entidade]Repository>();
        serviceCollection.AddTransient<I[Feature]Service, [Feature]Service>();

        AddServiceProvider();
    }

    [Fact]
    public async Task Get_RetornaListaVazia_QuandoNaoExistemRegistros()
    {
        // Arrange
        var service = serviceProvider.GetService<I[Feature]Service>();
        var request = [Feature]RequestFixture.Gerar();

        // Act
        var result = await service.Get(request);

        // Assert
        Assert.NotNull(result);
        Assert.True(result.IsSuccess);
        Assert.Empty(result.Data);
    }
}
```

**Critério:** `UsuarioAutenticadoRepository` sempre mockado; repositórios nunca mockados; padrão AAA; nomenclatura `Metodo_Cenario_ResultadoEsperado`.

---

### Operação 9 — Frontend (se aplicável)

**Estrutura esperada:**

```
frontend/src/app/features/[feature]/
├── [feature].module.ts
├── [feature]-routing.module.ts
├── [feature].component.ts
├── [feature].component.html
├── [feature].component.scss
├── services/
│   └── [feature].service.ts
└── models/
    └── [feature].models.ts
```

```typescript
// [feature].service.ts
@Injectable({ providedIn: 'root' })
export class [Feature]Service {
  constructor(private http: HttpClient) {}

  get(request: [Feature]Request): Observable<[Feature]Response[]> {
    return this.http.post<[Feature]Response[]>('/api/[feature]/get', request);
  }
}
```

**Critério:** componente implementa `OnInit`/`OnDestroy`; subscription limpa com `Subject` + `takeUntil(destroy$)`.

---

### Operação 10 — Script SQL (se aplicável)

**Repositório:** `scripts-db-pedagogico`  
**Arquivo:** `[tipo]/[NomeObjeto].sql`

```sql
-- Criar tabela [NomeTabela]
CREATE TABLE [dbo].[NomeTabela] (
    [Id]    INT          NOT NULL IDENTITY(1,1),
    [Hash]  UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    [Ativo] BIT          NOT NULL DEFAULT 1,
    -- colunas específicas
    CONSTRAINT [PK_NomeTabela] PRIMARY KEY ([Id])
);
```

**Critério:** script revisado e aplicado manualmente antes do deploy.

---

## N — Norms
> Padrões de engenharia do repositório. Toda implementação deve seguir estas regras.

### C# — Convenções

- **Primary constructors** (C# 12) para injeção de dependência nos services e repositórios
- Propriedades de entidades: sempre `virtual` (necessário para lazy loading do EF Core)
- `[ExcludeFromCodeCoverage]` em todas as classes de entidade e controller
- XML doc (`/// <summary>`) em todos os métodos públicos de controllers
- `async/await` em toda operação de I/O; nunca `.Result` ou `.Wait()`
- Nullable: projeto configurado com `disable` — não usar `?` em tipos de referência sem necessidade
- Namespace: `EstruturaPedagogica.[Camada].[Feature]` (ex: `EstruturaPedagogica.Domain.Services.AlteracaoDeCarga`)
- Um arquivo por classe; nome do arquivo igual ao nome da classe

### Services

- Sempre retornar `ServiceResult` ou `ServiceResult<T>` — nunca lançar exceção para erros de negócio
- Usar `result.AddError(mensagem)` para erros de validação e de negócio
- Injetar `IUsuarioAutenticadoRepository` para obter o usuário logado; nunca receber `usuarioId` no DTO
- Validação de request: sempre via `FluentValidation` em `Validators/`

### Repositórios

- Interfaces herdam `IBaseRepository<T>` (já fornece CRUD básico)
- Queries devem sempre filtrar `x.Ativo == true` salvo especificação contrária explícita nas Operations
- Sem raw SQL no repositório — apenas LINQ/EF Core
- Projeções com `Select()` quando apenas campos específicos são necessários

### Controllers

- Herdar de `CustomController`
- DI via `[FromServices]` no parâmetro do método (não no construtor)
- Retornar sempre `Result(await service.Metodo(...))` — nunca `Ok()`, `BadRequest()` diretamente
- `[RequiredAuthorization(Funcionalidade.X)]` na classe, não no método
- Rota no padrão `api/[controller]`

### Banco de Dados

- **Sem EF Migrations** — alterações de schema via scripts manuais em `scripts-db-pedagogico`
- Toda nova tabela deve ter: `Id INT IDENTITY`, `Hash UNIQUEIDENTIFIER`, `Ativo BIT DEFAULT 1`
- Entidades `StatefulEntity` precisam das colunas de auditoria na tabela

### Angular — Frontend

- Componentes no padrão: `OnInit` + `OnDestroy` com `Subject destroy$` para limpeza
- `@Input()` tipados explicitamente
- Serviços HTTP em `services/[feature].service.ts` (não inline no componente)
- Interfaces/tipos em `models/[feature].models.ts`
- Bootstrap 4 para layout; ng-select para dropdowns; Font Awesome para ícones

### Testes

- Herdar `BaseTest`; chamar `AddGlobalization()` e `AddInMemoryDbContext()` no construtor
- `UsuarioAutenticadoRepository` sempre mockado com `_usuarioId = 99999`
- Repositórios de dados: **nunca** mockar — usar in-memory database
- Outros services (externos à feature): **sempre** mockar
- Fixtures com Bogus locale `pt_BR`; assinatura `Gerar([params opcionais])` + `GerarLista(n = 3)`
- FKs inteiras **nunca** atribuídas em fixture — apenas propriedades de navegação
- Nomenclatura de teste: `NomeMetodo_Cenario_ResultadoEsperado`

---

## S — Safeguards
> Limites não negociáveis. Violação = blocker de PR.

### Segurança

- [ ] Nenhum endpoint sem `[RequiredAuthorization]` (exceto endpoints explicitamente públicos documentados)
- [ ] Nunca expor `Id` inteiro em resposta pública — usar `Hash` (Guid) como identificador externo
- [ ] Nunca confiar no `usuarioId` vindo do body da request — sempre ler de `IUsuarioAutenticadoRepository`

### Integridade de Dados

- [ ] Toda query de leitura filtra `Ativo == true` salvo exceção documentada na Operation
- [ ] Inativação: setar `Ativo = false` + preencher campos de auditoria de `StatefulEntity`; nunca DELETE físico
- [ ] Alterações de schema obrigatoriamente em `scripts-db-pedagogico` antes do deploy

### Compatibilidade

- [ ] Não remover nem renomear propriedades de DTOs de resposta sem versionar o endpoint
- [ ] Não alterar comportamento de métodos públicos de `IBaseRepository` — apenas adicionar novos métodos nas interfaces específicas
- [ ] Não alterar tabelas existentes sem avaliar impacto nas views e triggers de `scripts-db-pedagogico`

### Qualidade

- [ ] Zero warnings de compilação introduzidos
- [ ] Todos os novos services cobertos por pelo menos um teste de integração por Operation
- [ ] Nenhuma lógica de negócio em controllers ou repositórios

---

## Histórico de Atualizações

| Data | Versão | O que mudou | Motivo |
|------|--------|-------------|--------|
| YYYY-MM-DD | v1.0 | Criação inicial | — |
