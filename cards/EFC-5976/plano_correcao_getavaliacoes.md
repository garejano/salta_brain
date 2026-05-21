# Plano de Correção — GetAvaliacoes (FiltroManager)

## Problema observado

Com o filtro CF Anual (Rede=Nosso CEI, Ano=2026, Agrupamento=1ª série EM), o grid exibe ~16 colunas por linha de disciplina, mas deveriam ser apenas **5 colunas** (ATF1, AP1, Faltas, Média, Média Recuperada — todas do 1º Trimestre, `ItinerarioFormativoCiclo=1`).

Este problema persiste após a correção do `GetEstrutura` (remoção do OR clause). A origem está em `FiltroManager.GetAvaliacoes`.

---

## Causa raiz identificada no banco

### Bug 1 — estruturasAutomaticasIds OR clause

`GetAvaliacoes` carrega antecipadamente os IDs de colunas automáticas do boletim regular:

```csharp
var estruturasAutomaticasIds = Domain.ConfiguradorAvaliacao.EstruturaAvaliacaoRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Where(x => x.ItinerarioFormativoCiclo == null
             && x.Ciclo.Etapa.Boletim == true
             && x.Ciclo.Etapa.Diversificada == false
             && x.Ciclo.Etapa.Simulados == false
             && (x.TipoAvaliacao.FaltaEtapa || x.TipoAvaliacao.Total || x.TipoAvaliacao.Media || x.TipoAvaliacao.Situacao))
    .Select(x => x.Id)
    .ToList();
```

**Evidência no banco** — essa query retorna 13 IDs:

| Id | Sigla | Ciclo | Etapa |
|----|-------|-------|-------|
| 687607 | Média | Média do 1º Trimestre | 1º Trimestre |
| 694802 | Faltas | Faltas do 1º Trimestre | 1º Trimestre |
| 689966 | Média | Média Recuperada do 1º Trimestre | 1º Trimestre |
| 687608 | Média | Média do 2º Trimestre | 2º Trimestre |
| 694803 | Faltas | Faltas do 2º Trimestre | 2º Trimestre |
| 689967 | Média | Média Recuperada do 2º Trimestre | 2º Trimestre |
| 687606 | Média | Média do 3º Trimestre | 3º Trimestre |
| 694800 | Faltas | Faltas do 3º Trimestre | 3º Trimestre |
| 689964 | Média | Média Recuperada do 3º Trimestre | 3º Trimestre |
| 677272 | Média | Média Anual | Resultados |
| 692869 | Média | Média Final | Resultados |
| 692870 | Média | Média Final 2 | Resultados |
| 679071 | Situação | Situação | Resultados |

O switch case adiciona essas 13 estruturas à query da view via OR:

```csharp
case EscopoEnum.ComponenteFormativo_Anual:
    queryableCF = queryableCF.Where(x => x.EtapaDeComponenteAnual
                                      || estruturasAutomaticasIds.Contains(x.IdEstrutura));
    break;
```

As 13 estruturas do boletim regular são então expandidas para todas as disciplinas CF via cross-join, gerando ~13 × 37 = 481 linhas extras.

**Por que esse OR foi criado?** Foi um fallback para enquanto o tech lead ainda não havia criado colunas automáticas (Média, Situação) com `ItinerarioFormativoCiclo` preenchido. Após o tech lead criar essas colunas, o fallback se tornou desnecessário e passa a trazer colunas erradas.

**Validação**: as colunas automáticas CF já estão no banco com `EtapaDeComponenteAnual=true` na view:

| IdEstrutura | Sigla | NomeCiclo | EtapaDeComponenteAnual |
|-------------|-------|-----------|------------------------|
| 694806 | ATF1 | Ciclo 1 | true |
| 694805 | AP1 | Ciclo 1 | true |
| 694815 | Faltas | Faltas do 1º Trimestre | true |
| 694831 | Média | Média do 1º Trimestre | true |
| 694844 | Média | Média Recuperada do 1º Trimestre | true |

Ou seja, filtrar apenas `EtapaDeComponenteAnual = true` já traz as 5 colunas corretas, incluindo as automáticas de Média.

---

### Bug 2 — Sem deduplicação para linhas null-discipline das estruturas CF

A `ViewConfiguradorAvaliacao` retorna **39 linhas** por estrutura CF (ex.: ATF1, IdEstrutura=694806):
- **38 linhas** com `HashDisciplina=null` (todos `IdSerie=2, IdEscola=null`)
- **1 linha** com `HashDisciplina` de "Academic English II"

O loop de expansão atual só deduplica linhas marcadas como `EhEstruturaAutomatica=true`. Para linhas CF (não automáticas, sem disciplina), não há deduplicação — o loop roda 38 vezes por estrutura, gerando 38 × 37 = 1.406 linhas para cada estrutura CF. As linhas são idênticas (mesmo HashCiclo, HashEtapa, HashTipoAvaliacao, HashSerie, HashEscola), criando duplicatas.

O frontend provavelmente agrupa por (HashDisciplina, HashCiclo, HashTipoAvaliacao) ao renderizar, descartando os duplicados. Porém o processamento é desnecessariamente custoso e indica ausência de controle.

---

## Solução planejada

### Mudança 1 — Remover `estruturasAutomaticasIds` do `GetAvaliacoes`

**O que mudar:**
- Remover a query que carrega `estruturasAutomaticasIds`
- Remover o campo `EhEstruturaAutomatica` da projeção do `ViewConfiguradorAvaliacaoInternalDTO`
- Simplificar o switch para usar apenas o flag CF da view, sem OR:

```csharp
// Antes
case EscopoEnum.ComponenteFormativo_Anual:
    queryableCF = queryableCF.Where(x => x.EtapaDeComponenteAnual
                                      || estruturasAutomaticasIds.Contains(x.IdEstrutura));
    break;

// Depois
case EscopoEnum.ComponenteFormativo_Anual:
    queryableCF = queryableCF.Where(x => x.EtapaDeComponenteAnual);
    break;
```

**Por que é seguro:** as 5 estruturas com `EtapaDeComponenteAnual=true` já incluem as colunas automáticas criadas pelo tech lead. Não há necessidade de fallback para o boletim regular.

---

### Mudança 2 — Deduplicate linhas null-discipline das estruturas CF

**O que mudar:**
Unificar a lógica de deduplicação para cobrir tanto as linhas automáticas (boletim regular, que serão removidas) quanto as linhas CF sem disciplina. A deduplicação passa a ser aplicada a **todas as linhas com `HashDisciplina == null`**:

```csharp
// Antes
if (row.EhEstruturaAutomatica)
{
    var key = (row.HashEtapa, row.HashCiclo, row.HashTipoAvaliacao, row.HashSerie, row.HashEscola);
    if (!automaticaExpandidas.Add(key))
        continue;
}

// Depois (sem EhEstruturaAutomatica, aplica a todas as linhas sem disciplina)
if (!row.HashDisciplina.HasValue)
{
    var key = (row.HashEtapa, row.HashCiclo, row.HashTipoAvaliacao, row.HashSerie, row.HashEscola);
    if (!automaticaExpandidas.Add(key))
        continue;
}
```

**Por que é necessário:** cada estrutura CF gera 38 linhas null-discipline idênticas na view. Sem deduplicação, o expansion loop roda 38 vezes por estrutura, gerando 38 × 37 = 1.406 linhas por estrutura CF.

---

## Impacto esperado após a correção

| Métrica | Antes | Depois |
|---------|-------|--------|
| Estruturas CF Anual retornadas | 5 CF + 13 boletim = 18 | 5 |
| Execuções do expansion loop por estrutura CF | 38 (sem dedup) | 1 (com dedup) |
| Linhas geradas por estrutura CF (antes de dedup do frontend) | 38 × 37 = 1.406 | 1 × 37 = 37 |
| Colunas visíveis no grid CF Anual | ~16 (com boletim misturado) | 5 (correto) |

---

## Arquivos a modificar

| Arquivo | Mudança |
|---------|---------|
| `Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs` | Remover `estruturasAutomaticasIds`, simplificar switch, unificar deduplicação |

---

## Validação pós-implementação

Executar no banco após deploy:

```sql
SELECT v.IdEstrutura, v.SiglaTipoAvaliacao, v.NomeCiclo, v.NomeEtapa,
       v.EtapaDeComponenteAnual
FROM dbo.ViewConfiguradorAvaliacao v
WHERE v.IdAgrupamento = 11
  AND v.IdAnoLetivo = 2026
  AND v.IdRede = 56
  AND v.EtapaDeComponenteAnual = 1
GROUP BY v.IdEstrutura, v.SiglaTipoAvaliacao, v.NomeCiclo, v.NomeEtapa, v.EtapaDeComponenteAnual
ORDER BY v.IdEstrutura
```

**Esperado:** 5 registros (ATF1, AP1, Faltas, Média, Média Recuperada) — sem nenhuma estrutura do boletim regular.

---

## Dependências

- A correção do `GetEstrutura` (OR clause removido) já foi aplicada — alinhada com esta mudança.
- A correção do `BuscaManager.GetDisciplinas` (uso de `IdItinerarioFormativoCiclo` na view) já foi aplicada — independente desta.
