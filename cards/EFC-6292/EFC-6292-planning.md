# EFC-6292 — Planning Técnico

> Migração do endpoint da Ficha Individual do módulo `notas` para `estrutura-pedagogica`.  
> Branch: `feature/EFC-6292` em ambos os repos.

---

## Contexto

O módulo `documentacao-pedagogica` consome dois endpoints do módulo `notas` para montar a Ficha Individual do aluno. A decisão arquitetural é mover esses endpoints para `estrutura-pedagogica`, que passará a ser o módulo central do time. Ambos os módulos usam o **mesmo banco de dados**.

---

## Estado Atual — O que existe em `notas`

### Controller
| Arquivo | Endpoint | Método |
|---------|----------|--------|
| `Notas.Api/Controllers/DocumentosController.cs` | `POST /api/documentos/getfichaindividual` | `GetModeloCompleto` |
| `Notas.Api/Controllers/DocumentosController.cs` | `POST /api/documentos/getfichaindividualresumida` | `GetModeloResumido` |

> ⚠️ O mesmo controller tem um terceiro endpoint (`getrelatorioderendimento`) que **não deve ser migrado** — pertence ao DiarioDeClasse.

### Service
| Arquivo | Descrição |
|---------|-----------|
| `Notas.Domain.Services/FichaIndividual/IFichaIndividualGetService.cs` | Interface com `GetModeloCompleto` e `GetModeloResumido` |
| `Notas.Domain.Services/FichaIndividual/FichaIndividualGetService.cs` | Implementação: formata a ficha a partir dos dados dos repositórios |

### DTOs
| Arquivo | Tipo |
|---------|------|
| `Notas.Domain/DTO/FichaIndividual/Request/FichaIndividualGetRequest.cs` | `HashUsuario`, `HashTurma`, `RetornarResultadosParciais` |
| `Notas.Domain/DTO/FichaIndividual/Request/FichaIndividualInternalGetRequest.cs` | `RedeId`, `PessoaId`, `AnoLetivoId`, `SerieId`, `TurmaId` |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualGetResponse.cs` | Raiz: 4 escopos + Legenda |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualInternalGetResponse.cs` | Projeção flat da view `RelatorioAlunoNota` |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualEscopoGetResponse.cs` | Etapas + Disciplinas |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualEtapaGetResponse.cs` | Hash, Descricao, Colunas |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualColunaGetResponse.cs` | Hash, Descricao, NotaMaxima, EhResultado, EhSituacao |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualColunasPorEtapa.cs` | HashEstruturaAvaliacao + HashEtapa + nota |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualDisciplinaGetResponse.cs` | HashDisciplina, NomeDisciplina, Notas |
| `Notas.Domain/DTO/FichaIndividual/Response/FichaIndividualLegendaGetResponse.cs` | Sigla, Descricao |

### Repositórios usados pelo FichaIndividual
| Interface | Implementação | Método relevante |
|-----------|---------------|-----------------|
| `Notas.Domain/Interfaces/Base/IAlunoEscolaRepository.cs` | `Notas.Infra/Repositories/Base/AlunoEscolaRepository.cs` | `GetParaFichaIndividual(request)` — resolves Hashes em IDs internos |
| `Notas.Domain/Interfaces/Views/IRelatorioAlunoNotaRepository.cs` | `Notas.Infra/Repositories/Views/RelatorioAlunoNotaRepository.cs` | `GetParaFichaIndividual` e `GetParaFichaIndividualResumida` |
| `Notas.Domain/Interfaces/Base/ICicloRepository.cs` | `Notas.Infra/Repositories/Base/CicloRepository.cs` | `GetParaFichaIndividualResumida(request)` |
| `Notas.Domain/Interfaces/Base/IRedeSerieCicloRepository.cs` | `Notas.Infra/Repositories/Base/RedeSerieCicloRepository.cs` | `GetParaFichaIndividual(request)` |

### Entidades
| Arquivo | Banco | Observação |
|---------|-------|-----------|
| `Notas.Domain/Entities/Views/RelatorioAlunoNota.cs` | View `rel.RelatorioAlunoNota` | Mapeado via `Notas.Infra/Mapping/Views/RelatorioAlunoNotaMap.cs` |
| `Notas.Domain/Entities/Base/Ciclo.cs` | Tabela `Ciclo` | Navega para `Etapa` e `RedeSerieCiclo` |
| `Notas.Domain/Entities/Base/RedeSerieCiclo.cs` | Tabela `RedeSerieCiclo` | Navega para `Ciclo` e `RedeSerie` |
| `Notas.Domain/Entities/Base/TipoResultado.cs` | Tabela `TipoResultado` | Usado só como constantes (`Nota=1, Situacao=3, Faltas=4, Formativa=5`) |

---

## Estado em `estrutura-pedagogica` — O que já existe

| Item | Existe? | Arquivo |
|------|---------|---------|
| `AlunoEscola` entity | ✅ | `EstruturaPedagogica.Domain/Entities/Base/AlunoEscola.cs` |
| `IAlunoEscolaRepository` | ✅ | `EstruturaPedagogica.Domain/Interfaces/Base/IAlunoEscolaRepository.cs` |
| `AlunoEscolaRepository` | ✅ | `EstruturaPedagogica.Infra/Repositories/Base/AlunoEscolaRepository.cs` |
| `Etapa` entity | ✅ | `EstruturaPedagogica.Domain/Entities/Base/Etapa.cs` |
| `RedeSerie` entity | ✅ | `EstruturaPedagogica.Domain/Entities/Base/RedeSerie.cs` |
| `Ciclo` entity | ❌ | — |
| `RedeSerieCiclo` entity | ❌ | — |
| `TipoResultado` entity | ❌ | — |
| `RelatorioAlunoNota` entity (view) | ❌ | — |
| Qualquer código de FichaIndividual | ❌ | — |

---

## O Que Precisa Ser Feito

### FASE 1 — Criar em `estrutura-pedagogica` (branch `feature/EFC-6292`)

#### 1.1 Entidades novas no Domain

```
EstruturaPedagogica.Domain/Entities/Base/Ciclo.cs
EstruturaPedagogica.Domain/Entities/Base/RedeSerieCiclo.cs
EstruturaPedagogica.Domain/Entities/Base/TipoResultado.cs   ← apenas as constantes
EstruturaPedagogica.Domain/Entities/Views/RelatorioAlunoNota.cs
```

> **Atenção:** `Ciclo` em notas referencia `Avaliacao` e `Prova` (entidades exclusivas de notas). Na versão de EP, omitir essas navigation properties — só incluir o que é necessário para FichaIndividual (`Etapa`, `RedeSerieCiclo`, flags de total/média/situação).

#### 1.2 Mapeamentos EF Core no Infra

```
EstruturaPedagogica.Infra/Mapping/Views/RelatorioAlunoNotaMap.cs    ← idêntico ao de notas
EstruturaPedagogica.Infra/Mapping/Base/CicloMap.cs                  ← novo (sem Migrations)
EstruturaPedagogica.Infra/Mapping/Base/RedeSerieCicloMap.cs         ← novo (sem Migrations)
```

Adicionar os DbSets ao `ApplicationContext` de EP:
- `DbSet<RelatorioAlunoNota>`
- `DbSet<Ciclo>` (se não mapeado ainda)
- `DbSet<RedeSerieCiclo>` (se não mapeado ainda)

> **Sem EF Migrations** — EP gerencia schema via scripts SQL manuais. As tabelas `Ciclo`, `RedeSerieCiclo` e a view `rel.RelatorioAlunoNota` já existem no banco compartilhado.

#### 1.3 DTOs no Domain (10 arquivos)

```
EstruturaPedagogica.Domain/DTO/FichaIndividual/Request/FichaIndividualGetRequest.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Request/FichaIndividualInternalGetRequest.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualInternalGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualEscopoGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualEtapaGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualColunaGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualColunasPorEtapa.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualDisciplinaGetResponse.cs
EstruturaPedagogica.Domain/DTO/FichaIndividual/Response/FichaIndividualLegendaGetResponse.cs
```

Namespace: `EstruturaPedagogica.Domain.DTO.FichaIndividual` (em vez de `Notas.Domain.DTO`).

#### 1.4 Interfaces de repositório no Domain

```
EstruturaPedagogica.Domain/Interfaces/Views/IRelatorioAlunoNotaRepository.cs
EstruturaPedagogica.Domain/Interfaces/Base/ICicloRepository.cs
EstruturaPedagogica.Domain/Interfaces/Base/IRedeSerieCicloRepository.cs
```

Adicionar em `IAlunoEscolaRepository.cs` existente:
```csharp
Task<FichaIndividualInternalGetRequest> GetParaFichaIndividual(FichaIndividualGetRequest request);
```

> Todas devem herdar de `IBaseRepository` para o scanner de DI funcionar automaticamente.

#### 1.5 Implementações de repositório no Infra

```
EstruturaPedagogica.Infra/Repositories/Views/RelatorioAlunoNotaRepository.cs   ← métodos FichaIndividual apenas
EstruturaPedagogica.Infra/Repositories/Base/CicloRepository.cs                 ← GetParaFichaIndividualResumida
EstruturaPedagogica.Infra/Repositories/Base/RedeSerieCicloRepository.cs        ← GetParaFichaIndividual
```

Adicionar em `AlunoEscolaRepository.cs` existente:
- Implementação do `GetParaFichaIndividual` (igual a notas, mas com namespace EP)

> Usar `Queryable(stateless: true)` — padrão de EP para leitura.

#### 1.6 Service no Domain.Services

```
EstruturaPedagogica.Domain.Services/FichaIndividual/IFichaIndividualGetService.cs
EstruturaPedagogica.Domain.Services/FichaIndividual/FichaIndividualGetService.cs
```

- Usar **primary constructor** (padrão EP, C# 12) — não usar `this._field = field`
- Herdar `IBaseService` na interface

#### 1.7 Controller no Api

```
EstruturaPedagogica.Api/Controllers/FichaIndividualController.cs
```

Endpoints:
- `POST /api/fichaindividual/getfichaindividual`
- `POST /api/fichaindividual/getfichaindividualresumida`

Adicionar constante de funcionalidade em:
```
EstruturaPedagogica.Domain/Entities/Base/Funcionalidade.cs
```
Exemplo: `public const string EstruturaPedagogica_FichaIndividual = "EstruturaPedagogica_FichaIndividual";`

---

### FASE 2 — Atualizar `documentacao-pedagogica`

- Localizar onde `documentacao-pedagogica` chama os endpoints de `notas` (`/api/documentos/getfichaindividual` e `/api/documentos/getfichaindividualresumida`)
- Atualizar a URL base para apontar para `estrutura-pedagogica`
- Testar o fluxo ponta-a-ponta

---

### FASE 3 — Remover de `notas` (após FASE 2 estabilizada)

| O que remover | Arquivo | Cuidado |
|---------------|---------|---------|
| Endpoints FichaIndividual | `DocumentosController.cs` | Manter `getrelatorioderendimento` |
| Service + Interface | `FichaIndividual/FichaIndividualGetService.cs` + `IFichaIndividualGetService.cs` | Remoção total |
| 10 DTOs de FichaIndividual | `DTO/FichaIndividual/` | Remoção total |
| Método `GetParaFichaIndividual` | `AlunoEscolaRepository.cs` | Verificar outros usos antes |
| Métodos FichaIndividual | `CicloRepository.cs` + `RelatorioAlunoNotaRepository.cs` | Verificar outros usos antes |

> **Repositórios (`CicloRepository`, `RedeSerieCicloRepository`, `RelatorioAlunoNotaRepository`, `AlunoEscolaRepository`) têm outros métodos em uso — não remover os repositórios, apenas os métodos FichaIndividual-específicos.**

---

## Riscos e Cuidados

| Risco | Mitigação |
|-------|-----------|
| `Ciclo` em EP tem navprops para `Avaliacao`/`Prova` (exclusivas de `notas`) | Omitir essas navigation properties na entidade EP — não fazem sentido aqui |
| `AlunoEscola` em EP tem estrutura diferente (sem `AlunoEscola_key`) | Verificar se a query `GetParaFichaIndividual` precisa de ajuste de mapeamento |
| `RelatorioAlunoNotaRepository` em `notas` também tem `GetParaRelatorioDeRendimento` | Não migrar esse método — pertence ao DiarioDeClasse de notas |
| DI registration em EP é por convenção (herança de `IBaseRepository`/`IBaseService`) | Garantir que todas novas interfaces herdam corretamente |
| Sem EF Migrations em EP | Não criar migration — tabelas/view já existem no banco compartilhado |

---

## Ordem de Execução Recomendada

1. Criar entidades (`Ciclo`, `RedeSerieCiclo`, `TipoResultado`, `RelatorioAlunoNota`) em EP
2. Criar mappings EF e registrar no `ApplicationContext`
3. Criar DTOs
4. Adicionar `GetParaFichaIndividual` na `IAlunoEscolaRepository` + implementação
5. Criar `IRelatorioAlunoNotaRepository`, `ICicloRepository`, `IRedeSerieCicloRepository` + implementações
6. Criar service `IFichaIndividualGetService` + `FichaIndividualGetService`
7. Criar `FichaIndividualController`
8. Adicionar constante em `Funcionalidade.cs`
9. Testar o endpoint em EP
10. Atualizar `documentacao-pedagogica`
11. Remover código de `notas`
