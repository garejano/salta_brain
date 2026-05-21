# Plano de Correção — Exportação do Configurador de Avaliações

> **Problema reportado:** QA identificou que a exportação retorna linhas incoerentes (1793 linhas em homolog vs 1218 em produção).  
> **Hipótese do tech lead:** "ou usa outra view, ou não teve o tratamento do escopo."  
> **Resultado da análise:** **ambas as hipóteses estão corretas.**

---

## Causa raiz

### 1. O exportador usa uma view diferente da tela

A tela usa `ViewConfiguradorAvaliacao` (via `FiltroManager.GetAvaliacoes`).  
A exportação usa `ViewConfiguradorAvaliacoesExportacao` (via `ExportacaoManager.RelatorioParaExportacao`).

### 2. O escopo CF não foi tratado no `ExportacaoManager`

`ExportacaoManager.RelatorioParaExportacao` (linha 15–38) só conhece os 3 escopos originais:

```csharp
bool etapaBoletim      = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Regular
                       || filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
bool etapaDiversificada = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
bool etapaSimulados    = (filtro.EscopoAvaliacoes == EscopoEnum.Outros_Simulados);

queryable = queryable.Where(q => q.BoletimRegular.Equals(etapaBoletim)
                               && q.BoletimDiversificado.Equals(etapaDiversificada)
                               && q.OutrosSimulados.Equals(etapaSimulados));
```

Quando um escopo CF é selecionado (ex: `ComponenteFormativo_Anual`), as três flags ficam `false`. A query retorna **todas** as avaliações onde `BoletimRegular=false AND BoletimDiversificado=false AND OutrosSimulados=false` — o que inclui avaliações CF de **todos os ciclos** misturadas, sem filtro por ciclo.

### 3. A view de exportação não tem a coluna `ItinerarioFormativoCiclo`

`ViewConfiguradorAvaliacoesExportacao.sql` faz JOIN em `EstruturaAvaliacao AS EsAv` mas **não seleciona** `EsAv.ItinerarioFormativoCiclo`. Portanto, não há como filtrar por ciclo CF no C# sem alterar a view.

---

## Arquivos a alterar

| # | Repositório | Arquivo | Tipo de mudança |
|---|-------------|---------|-----------------|
| 1 | `scripts-db-pedagogico` | `Views/ViewConfiguradorAvaliacaoesExportacao.sql` | Adicionar coluna `IdItinerarioFormativoCiclo` |
| 2 | `portal-atlas` | `Eleva.Portal/ConfiguradorAvaliacao/ViewConfiguradorAvaliacoesExportacao.cs` | Adicionar propriedade |
| 3 | `portal-atlas` | `Eleva.Portal/ConfiguradorAvaliacao/NHMapping/ViewConfiguradorAvaliacoesExportacaoMap.cs` | Mapear nova propriedade |
| 4 | `portal-atlas` | `Eleva.Portal/ConfiguradorAvaliacao/Services/ExportacaoManager.cs` | Adicionar branch CF |

---

## Mudanças detalhadas

### Arquivo 1 — `ViewConfiguradorAvaliacaoesExportacao.sql`

Adicionar `EsAv.ItinerarioFormativoCiclo` ao SELECT (após `EsAv.Ordem`):

```sql
-- ANTES (linha ~57):
EsAv.Ordem,

-- DEPOIS:
EsAv.Ordem,
EsAv.ItinerarioFormativoCiclo AS IdItinerarioFormativoCiclo,
```

Adicionar ao GROUP BY (no final da lista, antes do `;`):

```sql
-- ANTES:
GROUP BY ..., EsAv.Ordem, EsAv.TipoSubstituicao, ...

-- DEPOIS:
GROUP BY ..., EsAv.Ordem, EsAv.ItinerarioFormativoCiclo, EsAv.TipoSubstituicao, ...
```

---

### Arquivo 2 — `ViewConfiguradorAvaliacoesExportacao.cs`

Adicionar a propriedade após a região `#region TipoResultado` (após `OutrosSimulados`, por exemplo):

```csharp
// Adicionar após a propriedade BoletimRegular (linha ~79):
public virtual int? IdItinerarioFormativoCiclo { get; set; }
```

---

### Arquivo 3 — `ViewConfiguradorAvaliacoesExportacaoMap.cs`

Adicionar o mapeamento após `Property(x => x.OutrosSimulados, ...)` (linha ~39):

```csharp
Property(x => x.IdItinerarioFormativoCiclo, n => n.NotNullable(false));
```

---

### Arquivo 4 — `ExportacaoManager.cs`

Substituir o bloco de filtro atual (linhas 17–26) pelo seguinte:

```csharp
// ANTES:
bool etapaBoletim = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Regular || filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
bool etapaDiversificada = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
bool etapaSimulados = (filtro.EscopoAvaliacoes == EscopoEnum.Outros_Simulados);

IQueryable<ViewConfiguradorAvaliacoesExportacao> queryable = Domain.ConfiguradorAvaliacao.ViewConfiguradorAvaliacoesExportacaoRepository
                                                            .GetPorAnoLetivoRede(filtro.HashAnoLetivo.Value, filtro.HashRede)
                                                            .Where(q => q.BoletimRegular.Equals(etapaBoletim)
                                                                     && q.BoletimDiversificado.Equals(etapaDiversificada)
                                                                     && q.OutrosSimulados.Equals(etapaSimulados)
                                                                  );

// DEPOIS:
IQueryable<ViewConfiguradorAvaliacoesExportacao> queryable = Domain.ConfiguradorAvaliacao.ViewConfiguradorAvaliacoesExportacaoRepository
                                                            .GetPorAnoLetivoRede(filtro.HashAnoLetivo.Value, filtro.HashRede);

if (filtro.EscopoAvaliacoes.EhEscopoCF())
{
    int idCicloIF = filtro.EscopoAvaliacoes.GetIdCicloIF();
    queryable = queryable.Where(q => q.IdItinerarioFormativoCiclo == idCicloIF);
}
else
{
    bool etapaBoletim      = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Regular
                           || filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
    bool etapaDiversificada = (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Diversificado);
    bool etapaSimulados    = (filtro.EscopoAvaliacoes == EscopoEnum.Outros_Simulados);

    queryable = queryable.Where(q => q.BoletimRegular.Equals(etapaBoletim)
                                  && q.BoletimDiversificado.Equals(etapaDiversificada)
                                  && q.OutrosSimulados.Equals(etapaSimulados)
                                  && q.IdItinerarioFormativoCiclo == null);
}
```

> **Nota sobre `q.IdItinerarioFormativoCiclo == null` no branch else:** garante que escopos regulares (Boletim Regular, Diversificado, Simulados) não retornem avaliações CF que por acaso tenham os mesmos flags de Etapa. Sem esse filtro, avaliações CF podem vazar para exportações regulares em ambientes que já têm dados CF configurados.

---

## Ordem de execução

1. **`scripts-db-pedagogico`** — alterar e aplicar o `ALTER VIEW` em homolog. Crie o script em scripts-db-pedagogico que eu mesmo vou rodar ele
2. **`portal-atlas`** — as 3 mudanças de C# podem ser feitas em paralelo e deployadas juntas.

O deploy do banco **deve preceder** o deploy do C# para evitar erro de coluna inexistente no NHibernate.

---

## Validação pós-deploy

### Query de verificação da view atualizada

```sql
SELECT TOP 5
    IdItinerarioFormativoCiclo,
    NomeEtapa,
    NomeCiclo,
    NomeAgrupamento
FROM ViewConfiguradorAvaliacoesExportacao
WHERE IdItinerarioFormativoCiclo IS NOT NULL
ORDER BY IdItinerarioFormativoCiclo;
-- Deve retornar linhas com IdItinerarioFormativoCiclo = 1, 2, 4 ou 5
-- Se retornar 0 linhas, ainda não há avaliações CF configuradas (ok — coluna existe)
```

### Teste manual com o escopo CF

1. Na tela do Configurador de Avaliações, selecionar um escopo CF (ex: CF Anual).
2. Clicar em **Exportar**.
3. Conferir que o arquivo CSV retorna apenas avaliações do ciclo selecionado.

### Teste de regressão — escopos regulares

1. Selecionar **Boletim Regular**.
2. Clicar em **Exportar**.
3. Confirmar que nenhuma avaliação CF aparece no CSV.
