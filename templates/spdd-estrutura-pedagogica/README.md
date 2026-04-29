# SPDD — estrutura-pedagogica

Templates de desenvolvimento baseados no workflow SPDD, pré-configurados com as convenções do repositório `estrutura-pedagogica`.

**Repositório:** `c:/projects/estrutura-pedagogica`  
**Stack:** .NET 8 · EF Core · Angular 20 (standalone) · SQL Server  
**Referência SPDD:** `templates/spdd/README.md`

---

## Como usar

```
1. Copie story.md        → preencha os requisitos da feature
2. Copie analysis.md     → levante domínio, riscos e dependências
3. Copie reasons-canvas.md → preencha R, E, A, S(tructure), O
   (N — Norms e S — Safeguards já estão pré-preenchidos)
4. Gere o código seguindo as Operations do Canvas
5. Gere os testes com base nas Operations
6. Ao revisar: correção de lógica → atualize o Canvas primeiro
              refatoração → atualize o Canvas depois
```

---

## Arquitetura de Referência

```
EstruturaPedagogica.Domain/
  Entities/
    Base/          → herda BaseEntity (sem auditoria)
    Stateful/      → herda StatefulEntity (com auditoria de usuário)
  DTO/             → request/response por feature
  Interfaces/      → contratos de repositório
  Enums/

EstruturaPedagogica.Domain.Services/
  [Feature]/
    Interfaces/    → IXxxService
    Validators/    → FluentValidation
    XxxService.cs  → implementação com primary constructor

EstruturaPedagogica.Infra/
  Repositories/
    Base/          → implementa IBaseRepository
    Stateful/
  Mapping/         → configuração EF Core (sem migrations)

EstruturaPedagogica.Api/
  Controllers/     → herda CustomController
                     [RequiredAuthorization(Funcionalidade.X)]

EstruturaPedagogica.Test/
  Integration/
    Fixtures/      → Bogus (pt_BR), método estático Gerar()
    Scenarios/     → herda BaseTest, xUnit [Fact]
```

---

## Camadas e Dependências

```
Api → Domain.Services → Domain ← Infra
                     ↖ Extensions
```

---

## Arquivos

| Arquivo | Uso |
|---------|-----|
| `story.md` | Quebrar requisito em stories INVEST |
| `analysis.md` | Levantamento de domínio e riscos |
| `reasons-canvas.md` | Canvas REASONS — artefato principal |
