# EFC-5976 — Análise dos Bugs Encontrados em QA

> **Origem:** Transcrição de teste do analista de suporte (`bug_before_testing.md`)  
> **Data da análise:** 2026-04-29  
> **Método:** Exploração de código + validação de DTOs + tentativa de validação no banco (servidor offline)

---

## Resumo dos Problemas Relatados

O analista reportou dois comportamentos incorretos ao testar o escopo CF Anual:

1. **"Ele montou com todas as disciplinas"** — Ao criar uma coluna no escopo CF Anual, o grid exibiu todas as disciplinas do agrupamento, sem distinguir se são formativas ou regulares. O esperado é que cada escopo CF exiba somente as disciplinas do ciclo correspondente.

2. **"Atribuiu nota máxima na tabela só para a primeira linha"** — Após criar a coluna com nota máxima configurada, o valor apareceu apenas na primeira linha da tabela. *(Ver análise abaixo — não é bug de código.)*

O analista também descreveu o comportamento correto esperado:
- CF Anual → somente disciplinas Anuais
- CF Semestral → somente disciplinas Semestrais
- Disciplinas CF **não devem** aparecer no boletim regular

---

## Bug 1 — Grid exibe todas as disciplinas no escopo CF

### Status: BUG CONFIRMADO — FIX NECESSÁRIO

### Causa raiz

`FiltroManager.GetAvaliacoes` (branch CF) filtra `ViewConfiguradorAvaliacao` apenas por estrutura:

```csharp
queryable = ViewConfiguradorAvaliacaoRepository
           .GetPorAgrupamentoAnoLetivoRede(...)
           .Where(x => estruturasCFIds.Contains(x.IdEstrutura));
```

A view `ViewConfiguradorAvaliacao` inclui **todas as disciplinas do agrupamento** nas suas linhas, não apenas as CF. Filtrar por `IdEstrutura` não é suficiente para isolar as disciplinas CF do ciclo selecionado — retorna regulares e CF de outros ciclos junto.

Compare com `BuscaManager.GetDisciplinas`, que já faz o filtro correto (join com `ItinerarioFormativo.Ciclo.Id`). A mesma lógica precisa ser aplicada ao `GetAvaliacoes`.

### Fix — `Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs`

No branch CF de `GetAvaliacoes`, adicionar filtro por hash de disciplinas CF do ciclo selecionado:

```csharp
// Após obter estruturasCFIds, adicionar:
var disciplinasCFHashes = Domain.ItinerariosFormativos
                         .ItinerarioFormativoRedeSerieDisciplinaRepository
                         .GetPorAgrupamentoAnoLetivoRede(
                             filtro.HashAgrupamento.Value,
                             filtro.HashAnoLetivo.Value,
                             filtro.HashRede)
                         .Where(x => x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ciclo != null
                                  && x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ciclo.Id == idCicloIF)
                         .Select(x => x.Disciplina.Hash)
                         .Distinct()
                         .ToList();

queryable = Domain.ConfiguradorAvaliacao.ViewConfiguradorAvaliacaoRepository
           .GetPorAgrupamentoAnoLetivoRede(ids.IdAgrupamento, ids.IdAnoLetivo, ids.IdRede)
           .Where(x => estruturasCFIds.Contains(x.IdEstrutura)
                    && x.HashDisciplina.HasValue                              // campo confirmado: ViewConfiguradorAvaliacao.cs:139
                    && disciplinasCFHashes.Contains(x.HashDisciplina.Value)); // ADIÇÃO
```

**Campo confirmado:** `ViewConfiguradorAvaliacao.HashDisciplina` (`Guid?`, linha 139 do arquivo) — o mesmo campo usado no `Select` do método (linhas 401, 572, 579).

### Efeito colateral a verificar — disciplinas CF no boletim regular

O analista também apontou: disciplinas CF aparecem no boletim regular. O branch regular de `GetAvaliacoes` já exclui **estruturas CF** da query, mas não exclui **disciplinas CF** explicitamente.

**Após implementar o fix do branch CF, testar o CT-01** (boletim regular, Ábaco / 1º ano EFAI / 2026). Se disciplinas de IFs ainda aparecerem no boletim regular, adicionar ao branch regular:

```csharp
var todasDisciplinasCFHashes = Domain.ItinerariosFormativos
                              .ItinerarioFormativoRedeSerieDisciplinaRepository
                              .GetPorAgrupamentoAnoLetivoRede(
                                  filtro.HashAgrupamento.Value,
                                  filtro.HashAnoLetivo.Value,
                                  filtro.HashRede)
                              .Where(x => x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ciclo != null)
                              .Select(x => x.Disciplina.Hash)
                              .Distinct()
                              .ToList();

if (todasDisciplinasCFHashes.Count > 0)
    queryable = queryable.Where(x => !x.HashDisciplina.HasValue
                                  || !todasDisciplinasCFHashes.Contains(x.HashDisciplina.Value));
```

---

## "Bug 2" — Nota máxima só para a primeira linha

### Status: NÃO É BUG DE CÓDIGO — comportamento esperado

### Análise completa

`NotaMaxima` aparece em dois níveis distintos na tela:

| Nível | Campo | Fonte | Onde aparece |
|-------|-------|-------|--------------|
| **Coluna** | `EstruturaAvaliacaoDTO.NotaMaxima` | `EstruturaAvaliacao.NotaMaxima` no banco | Header da coluna (`Listagem.html:314`, `foreach: CiclosETipos`) |
| **Célula** | `AvaliacaoPorDisciplinaMaeETipoDTO.NotaMaxima` | `ViewConfiguradorAvaliacao.NotaMaxima` | Dropdown expandido da célula, visível apenas quando `IdAvaliacao != null` |

O **header** mostra o valor para a coluna inteira — visualmente aparece na "primeira linha" da tabela (a linha de header). As células só mostram `NotaMaxima` individualmente quando existe uma `Avaliacao` configurada para aquela disciplina naquela coluna.

Para uma coluna recém-criada sem avaliações lançadas, todas as células ficam sem nota máxima no nível de célula — o valor está no header, não por linha. Isso é comportamento correto confirmado em `ConverterParaAvaliacaoPorDisciplinaMaeETipo` (linha 546 de `FiltroManager.cs`):

```csharp
var query = lista.Where(x => x.IdAvaliacao.HasValue); // só avaliações configuradas entram em Avaliacoes
```

**O que o analista observou:** O valor de nota máxima aparecia no header (primeira linha visual da tabela) mas não nas linhas de disciplina, porque nenhuma avaliação havia sido configurada por disciplina ainda.

**Ação:** Nenhuma correção de código necessária. Se a experiência for confusa para usuários, pode ser endereçado com UX (label ou tooltip no header explicando que é preciso adicionar avaliações por disciplina) — mas isso está fora do escopo deste card.

---

## Bug 3 — Typo em Estrutura.Inclusao.js

### Status: BUG CONFIRMADO — FIX NECESSÁRIO (menor)

**Arquivo:** `Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Estrutura/Estrutura.Inclusao.js:533`

```javascript
// ATUAL (quebrado):
|| self.PossuiVaor(self.desempenhoMinimoParaAtingirNotaMaxima())

// CORRETO:
|| self.PossuiValor(self.desempenhoMinimoParaAtingirNotaMaxima())
```

`PossuiVaor` não existe no viewmodel. A função `EstruturaFoiAlterada()` nunca detecta alterações em `desempenhoMinimoParaAtingirNotaMaxima`, permitindo que o modal feche sem avisar que há mudanças não salvas nesse campo.

---

## Resumo das Correções

| # | Bug | Arquivo | Linha | Ação |
|---|-----|---------|-------|------|
| 1 | Grid CF exibe todas as disciplinas | `FiltroManager.cs` | Branch CF de `GetAvaliacoes` | Adicionar `disciplinasCFHashes.Contains(x.HashDisciplina.Value)` no Where |
| 1b | Disciplinas CF no boletim regular | `FiltroManager.cs` | Branch regular de `GetAvaliacoes` | Verificar após fix acima; adicionar filtro se necessário |
| 2 | Nota máxima só no header | — | — | Não é bug; documentar comportamento para QA |
| 3 | Typo `PossuiVaor` | `Estrutura.Inclusao.js` | 533 | `PossuiVaor` → `PossuiValor` |

---

## Cenários de Teste Pós-Correção

Usar os casos de teste do `EFC-5976_QA.md`:

| CT | O que valida | Resultado esperado após fix |
|----|-------------|----------------------------|
| CT-01 | Regressão boletim regular | Somente 3 escopos; sem disciplinas CF nos rows |
| CT-02 | CF aparece no dropdown | 7 opções para Ábaco / 1ª série EM / 2026 |
| CT-05 | Grid CF exibe só colunas do ciclo | Grid com colunas CF Semestral apenas |
| CT-06 | Filtro disciplinas por ciclo | Somente as 32 disciplinas CF Semestral |
| CT-10 | Regular não vaza CF | Nenhuma coluna CF no boletim regular |

**Query de validação para CT-06 após o fix:**

```sql
SELECT DISTINCT d.Nome
FROM ItinerarioFormativoRedeSerieDisciplina ifrsd
INNER JOIN ItinerarioFormativoRedeSerie ifrs ON ifrs.Id = ifrsd.ItinerarioFormativoRedeSerie
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
INNER JOIN Disciplina d ON d.Id = ifrsd.Disciplina
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco' AND a.Nome = '1ª série do EM'
  AND rs.AnoLetivo = 2026 AND ifc.Id = 2
  AND ifrs.Ativo = 1 AND ifrsd.Ativo = 1
ORDER BY d.Nome;
-- O grid CF Semestral deve conter exatamente estas disciplinas
```
