# Plano Técnico — EFC-6322

## Atividade

- **Chave:** EFC-6322
- **Título:** Não permitir que a mesma disciplina faça parte de Componentes Formativos de múltiplos ciclos
- **Tipo:** Story
- **Status:** Aberta

## Critérios de Aceite

Consulte `Docs/criterios-aceite-EFC-6322.md`

## Fases

### Fase 1 — Consulta de disciplinas bloqueadas por ciclo no repositório _(infraestrutura — CA-01, CA-02, CA-03)_

**Status:** pendente

Adicionar método `GetDisciplinasBloqueadasPorCiclo` ao `ItinerarioFormativoRepository` e declarar a assinatura na interface `IItinerarioFormativoRepository`.

**Arquivos a alterar:**
- `backend/EstruturaPedagogica.Infra/Repositories/Stateful/ItinerarioFormativoRepository.cs`
- `backend/EstruturaPedagogica.Domain/Interfaces/Stateful/IItinerarioFormativoRepository.cs`

**Lógica:**
Consultar todos os `ItinerarioFormativoRedeSerieDisciplina` ativos, navegando até o `ItinerarioFormativo.ItinerarioFormativoCicloId`, filtrando pela mesma combinação Ano + Rede + Agrupamento e **excluindo** o ciclo informado no request. O resultado é a lista de `BaseResponse` (Id, Hash, Descricao) das disciplinas que já estão associadas a um CF de ciclo diferente dentro da mesma combinação.

**Assinatura:**
```csharp
Task<List<BaseResponse>> GetDisciplinasBloqueadasPorCiclo(ItinerarioFormativoFilterRequest request, List<int> redesDoUsuario);
```

**Implementação (EF Core):**
```csharp
public async Task<List<BaseResponse>> GetDisciplinasBloqueadasPorCiclo(
    ItinerarioFormativoFilterRequest request, List<int> redesDoUsuario)
{
    return await QueryableAtivos()
        .Where(it => request.HashCiclo == null || it.ItinerarioFormativoCiclo.Hash != request.HashCiclo)
        .SelectMany(it => it.ItinerarioFormativoRedeSeries
            .Where(irs =>
                irs.DataInativacao == null
                && irs.RedeSerie.AnoLetivo.Hash == request.HashAnoLetivo
                && irs.RedeSerie.Rede.Hash == request.HashRede
                && irs.RedeSerie.Agrupamento.Hash == request.HashAgrupamento
                && redesDoUsuario.Contains(irs.RedeSerie.RedeId))
            .SelectMany(irs => irs.ItinerarioFormativoRedeSerieDisciplinas
                .Where(d => d.DataInativacao == null)
                .Select(d => new BaseResponse
                {
                    Id = d.DisciplinaId,
                    Hash = d.Disciplina.Hash,
                    Descricao = d.Disciplina.Nome
                })))
        .Distinct()
        .OrderBy(x => x.Descricao)
        .ToListAsync();
}
```

**Regras:**
- CA-02: o filtro `it.ItinerarioFormativoCiclo.Hash != request.HashCiclo` exclui o próprio ciclo — disciplinas usadas no mesmo ciclo não aparecem como bloqueadas.
- CA-03: filtro por Ano+Rede+Agrupamento garante que outras combinações não geram bloqueio.
- Se `request.HashCiclo` for null, todas as disciplinas já alocadas em qualquer ciclo são bloqueadas.

---

### Fase 2 — DTO de response enriquecido _(infraestrutura — CA-01)_

**Status:** pendente

Adicionar a propriedade `DisciplinasBloqueadasPorCiclo` ao DTO de response.

**Arquivo a alterar:**
- `backend/EstruturaPedagogica.Domain/DTO/ItinerarioFormativo/ItinerarioFormativoDisciplinaResponse.cs`

**Alteração:**
```csharp
public class ItinerarioFormativoDisciplinaResponse
{
    public List<BaseResponse> Disciplinas { get; set; }
    public List<BaseResponse> DisciplinasFormacaoBasica { get; set; }
    public List<BaseResponse> DisciplinasBloqueadasPorCiclo { get; set; }
}
```

---

### Fase 3 — Service GetDisciplinas populando DisciplinasBloqueadasPorCiclo _(CA-01, CA-02, CA-03)_

**Status:** pendente

No `ItinerarioFormativoGetService.GetDisciplinas`, chamar o novo método do repositório e preencher `result.Data.DisciplinasBloqueadasPorCiclo`.

**Arquivo a alterar:**
- `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/ItinerarioFormativoGetService.cs`

**Lógica:**
Após as consultas existentes de `Disciplinas` e `DisciplinasFormacaoBasica`, adicionar:
```csharp
var disciplinasBloqueadas = await _itinerarioFormativoRepository
    .GetDisciplinasBloqueadasPorCiclo(request, redesDoUsuario);

result.Data.DisciplinasBloqueadasPorCiclo = disciplinasBloqueadas;
```

Inicializar a lista no construtor do result:
```csharp
Data = new ItinerarioFormativoDisciplinaResponse
{
    Disciplinas = [],
    DisciplinasFormacaoBasica = [],
    DisciplinasBloqueadasPorCiclo = []
}
```

---

### Fase 4 — Validação de ciclo cruzado no Save _(CA-04)_

**Status:** pendente

No `ItinerarioFormativoSaveService`, após resolver o ciclo e antes do `Create`/`Update`, verificar se alguma disciplina do request está bloqueada por ciclo cruzado.

**Arquivo a alterar:**
- `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/ItinerarioFormativoSaveService.cs`

**Lógica (posicionar antes do bloco `if (request.Hash.HasValue)`):**
```csharp
var redesDoUsuario = await _usuarioAcessoRepository
    .GetRedeIdByFuncionalidadeUsuarioAutenticado(Funcionalidade.Configurador_Itinerario_Formativo);

var disciplinasBloqueadas = await _itinerarioFormativoRepository
    .GetDisciplinasBloqueadasPorCiclo(
        new ItinerarioFormativoFilterRequest
        {
            HashAnoLetivo = request.HashAnoLetivo,
            HashRede = request.HashRede,
            HashAgrupamento = request.HashAgrupamento,
            HashCiclo = request.HashCiclo
        },
        redesDoUsuario
    );

var conflitos = disciplinasBloqueadas
    .Where(d => request.HashDisciplinas.Contains(d.Hash))
    .ToList();

if (conflitos.Any())
{
    var nomes = string.Join(", ", conflitos.Select(c => c.Descricao));
    return result.WithError(
        $"As seguintes disciplinas já estão associadas a um Componente Formativo de outro Ciclo: {nomes}.");
}
```

---

### Fase 5 — Frontend: modelo e interface _(CA-01)_

**Status:** pendente

Atualizar a interface do frontend para refletir o novo campo do response e adequar a tipagem das disciplinas para suportar `locked`.

**Arquivos a alterar:**
- `frontend/src/app/features/itinerario-formativo/itinerario-formativo.models.ts`
- `frontend/src/app/features/itinerario-formativo/editar-itinerario/editar-itinerario.component.ts`

**Alterações:**

1. Em `itinerario-formativo.models.ts`, adicionar `disciplinasBloqueadasPorCiclo`:
```typescript
export interface ItinerarioFormativoDisciplinaResponse {
    disciplinas: BaseResponse[];
    disciplinasFormacaoBasica: BaseResponse[];
    disciplinasBloqueadasPorCiclo: BaseResponse[];
}
```

2. Em `editar-itinerario.component.ts`, importar `MultiSelectOption` e alterar o tipo de `disciplinasItinerario`:
```typescript
disciplinasItinerario: MultiSelectOption[] = [];
```

---

### Fase 6 — Frontend: componente editar-itinerario com locked e tooltip _(CA-01, CA-02, CA-03)_

**Status:** pendente

Alterar o componente de edição para usar `MultiSelectOption[]` e configurar o tooltip no template.

**Arquivos a alterar:**
- `frontend/src/app/features/itinerario-formativo/editar-itinerario/editar-itinerario.component.ts`
- `frontend/src/app/features/itinerario-formativo/editar-itinerario/editar-itinerario.component.html`

**Alterações em `.ts`:**
- Atualizar assinatura do método `start` para receber `MultiSelectOption[]` no parâmetro de disciplinas.

**Alterações em `.html`:**
- Adicionar `[iconTooltip]` ao `<multi-select>` de disciplinas:
```html
<multi-select
  #selectDisciplinas
  [label]="'Disciplina(s)'"
  [placeholder]="'Selecione'"
  [options]="disciplinasItinerario"
  [required]="true"
  [enabled]="!loading && disciplinasItinerario?.length > 0"
  [control]="form.get('disciplinas')"
  [iconTooltip]="'Disciplina já selecionada para um Componente Formativo de outro Ciclo'"
>
</multi-select>
```

---

### Fase 7 — Frontend: listar-itinerarios monta disciplinas com locked _(CA-01, CA-02, CA-03)_

**Status:** pendente

No `listar-itinerarios.component.ts`, construir o array `MultiSelectOption[]` mapeando `locked` com base em `disciplinasBloqueadasPorCiclo`.

**Arquivo a alterar:**
- `frontend/src/app/features/itinerario-formativo/listar-itinerarios/listar-itinerarios.component.ts`

**Lógica (no bloco `subscribe` do `forkJoin`, após receber `disciplinasResult`):**
```typescript
const bloqueadas = new Set(
  disciplinasResult.data.disciplinasBloqueadasPorCiclo?.map(d => d.hash) ?? []
);

this.disciplinas = disciplinasResult.data.disciplinas.map(d => ({
  hash: d.hash,
  descricao: d.descricao,
  locked: bloqueadas.has(d.hash),
}));

this.formacaoBasica = disciplinasResult.data.disciplinasFormacaoBasica.map(d => ({
  hash: d.hash,
  descricao: d.descricao,
  locked: bloqueadas.has(d.hash),
}));
```

Alterar o tipo das propriedades `disciplinas` e `formacaoBasica` para `MultiSelectOption[]` e importar o tipo.

---

### Fase 8 — Testes de integração _(CA-01, CA-02, CA-03, CA-04)_

**Status:** pendente

Adicionar cenários de teste para os novos comportamentos.

**Arquivos a alterar:**
- `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/ItinerarioFormativoServiceTests.cs`
- `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/ItinerarioFormativoSaveServiceTests.cs`

**Cenários para `ItinerarioFormativoServiceTests.cs`:**
- `GetDisciplinas_Retorna_DisciplinasBloqueadasPorCiclo_QuandoDisciplinaUsadaEmCicloDiferente` — cria dois CFs com ciclos diferentes na mesma combinação Ano+Rede+Agrupamento; espera que a disciplina do CF de ciclo diferente apareça em `DisciplinasBloqueadasPorCiclo`.
- `GetDisciplinas_NaoBloqueaDisciplina_QuandoMesmoCiclo` — (CA-02) cria dois CFs com o mesmo ciclo; verifica que `DisciplinasBloqueadasPorCiclo` está vazio.
- `GetDisciplinas_NaoBloqueaDisciplina_QuandoCombinacaoDiferente` — (CA-03) cria CFs em Ano+Rede+Agrupamento diferentes; verifica que `DisciplinasBloqueadasPorCiclo` está vazio.

**Cenários para `ItinerarioFormativoSaveServiceTests.cs`:**
- `Save_DeveRetornarErro_QuandoDisciplinaEmCicloCruzado` — (CA-04) configura dois CFs em ciclos distintos (mesma combinação), tenta salvar novo CF com ciclo diferente reusando disciplina já ocupada; verifica `result.IsSuccess == false` e mensagem contendo "já estão associadas a um Componente Formativo de outro Ciclo".
- `Save_DevePermitirDisciplina_QuandoMesmoCiclo` — (CA-02/CA-04 negativo) mesmo setup, mas ciclo igual; verifica sucesso.
- `Save_DevePermitirDisciplina_QuandoCombinacaoDiferente` — (CA-03/CA-04 negativo) disciplina ocupada em outra combinação Ano+Rede+Agrupamento; verifica sucesso.
