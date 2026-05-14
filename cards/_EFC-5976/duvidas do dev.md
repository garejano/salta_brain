
---

## Dúvida 1 — O agrupamento criado via "Configurar Agrupamento" tem vínculo com o filtro?

**Sim.** A entidade `EstruturaAvaliacaoConfiguracao` ([EstruturaAvaliacaoConfiguracao.cs:19-23](../Eleva.Portal/ConfiguradorAgrupamento/EstruturaAvaliacaoConfiguracao.cs#L19-L23)) possui três FKs obrigatórias: `Rede`, `AnoLetivo` e `Agrupamento`. Quando o usuário abre o "Configurar Agrupamento" a partir do configurador de avaliações, esses três valores são carregados do filtro ativo e gravados no novo registro. Sem eles, as queries como `GetPorAgrupamentoAnoLetivoRede` não retornariam o registro e o configurador continuaria exibindo "sem configuração".

---

## Dúvida 2 — Quando é definida a distinção "Regular / Bimestral / Trimestral / Semestral / Anual"?

São momentos diferentes para coisas diferentes — importante não misturar:

### As OPÇÕES no dropdown (quais escopos aparecem)
Dependem dos **Itinerários Formativos** configurados no sistema. `GetAgrupamentos` ([FiltroManager.cs:95-100](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs#L95-L100)) consulta `ItinerarioFormativoRedeSerieRepository` e lista quais `ItinerarioFormativoCiclo.Id` existem para aquele agrupamento. Se só há IFs com ciclo Semestral (Id=2), só aparece "Componente Formativo — Semestral". Isso é independente de qualquer avaliação.

### As COLUNAS do grid (cada coluna pertence a qual escopo)
São `EstruturaAvaliacao` com o campo `ItinerarioFormativoCiclo` preenchido. Esse campo é gravado quando o usuário **adiciona uma coluna** no configurador dentro de um escopo CF. Colunas regulares têm `ItinerarioFormativoCiclo = NULL`. Colunas de CF têm `ItinerarioFormativoCiclo = 2` (Semestral), `= 1` (Anual), etc.

O `EstruturaAvaliacaoConfiguracao` em si **não** tem a distinção de ciclo — ele só tem as flags `PossuiItinerarioFormativo` e `PossuiItinerarioFormativoSeparadoNoBoletim`. O ciclo pertence ao `ItinerarioFormativo` e às colunas de `EstruturaAvaliacao`.

---

## Dúvida 3 — Com filtro Boletim Regular, a tabela pode ter colunas Bimestral/Semestral/Trimestral/Anual?

**Depende do que você chama de "Bimestral/Semestral":**

- **Etapas do período regular** (ex.: "1º Bimestre", "2º Bimestre", "1º Semestre") — **SIM**, podem aparecer normalmente. São as etapas do currículo regular, identificadas pelas flags `Etapa.Boletim = true, Diversificada = false, Simulados = false`.

- **Colunas de Componente Formativo** (que têm `ItinerarioFormativoCiclo != null`) — **NÃO**, são explicitamente excluídas. O filtro em [FiltroManager.cs:214](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs#L214) exige `x.ItinerarioFormativoCiclo == null` para escopos regulares, justamente para que colunas CF nunca "vazem" para o Boletim Regular.

Resumindo: o nome da etapa (bimestral, semestral, etc.) é independente do escopo. O que distingue uma coluna CF de uma regular é a FK `ItinerarioFormativoCiclo`.

---

## Dúvida 4 — Boletim Regular × Componente Formativo Semestral: o que filtra cada um?

**Boletim Regular:** o que não deve aparecer são as colunas/linhas de Componentes Formativos — ou seja, `EstruturaAvaliacao` com `ItinerarioFormativoCiclo != null`. O código filtra com `ItinerarioFormativoCiclo == null` na query de estrutura e exclui os `IdEstrutura` de CF na query de avaliações ([FiltroManager.cs:379-386](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs#L379-L386)).

**Componente Formativo — Semestral:** retorna:
- Colunas (`EstruturaAvaliacao`) com `ItinerarioFormativoCiclo.Id == 2`
- Disciplinas vinculadas a `ItinerarioFormativo` com `Ciclo.Id == 2`
- Avaliações cruzando os dois: `IdEstrutura` que são CF Semestral **e** `HashDisciplina` que pertence ao ciclo Semestral

Isso está implementado em [FiltroManager.cs:202-207](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs#L202-L207) (estrutura) e [BuscaManager.cs:87-111](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs#L87-L111) (disciplinas).

Sua leitura estava correta — a separação é exatamente essa.




## Dúvida 5 — Por que "Componente Formativo — Anual" aparece para Motivo/2026/1ª série do EM mas não retorna dados?

**Validado com MCP SQL Server em 2026-05-04.**

### O que o banco diz

| Entidade | Dado encontrado |
|---|---|
| `EstruturaAvaliacaoConfiguracao` | `PossuiItinerarioFormativo = true`, `PossuiItinerarioFormativoSeparadoNoBoletim = true` |
| `ItinerarioFormativoRedeSerie.Id=1233` | Ativo, vinculado ao `RedeSerie` de 2026 (Rede=Motivo, Agrupamento=1ª série) |
| `ItinerarioFormativo.Id=935` | `ItinerarioFormativoCiclo = 1` (Anual) — **`Ativo = false`** |
| `EstruturaAvaliacao` com `ItinerarioFormativoCiclo=1` | Nenhuma |

### Causa raiz — bug de consistência no `GetPorAgrupamentoAnoLetivoRede`

`ItinerarioFormativoRedeSerieRepository.GetPorAgrupamentoAnoLetivoRede` usa `GetAtivos()`, que filtra apenas `ItinerarioFormativoRedeSerie.Ativo`. Ele **não** filtra `ItinerarioFormativo.Ativo`.

Resultado: o `ItinerarioFormativoRedeSerie.Id=1233` (ativo) aponta para o `ItinerarioFormativo.Id=935` (inativo com `Ciclo.Id=1`). A query em `FiltroManager.GetAgrupamentos` que monta `CiclosItinerarioFormativoExistentes` retorna `[1]` — e a opção "CF Anual" aparece no dropdown.

Mas quando o usuário seleciona esse escopo:
- `GetFlagsConfiguracao` busca disciplinas via `ItinerarioFormativoRedeSerieDisciplinaRepository` que filtra por `ItinerarioFormativo.Ativo = true` → retorna 0 → `PossuiDisciplinasParaEscopo = false`
- `GetEstrutura` não encontra nenhuma `EstruturaAvaliacao` com `ItinerarioFormativoCiclo = 1`
- Grid fica vazio

### Resumo do problema

A opção aparece por causa de um IF **inativo** cujo ciclo vaza para a lista de escopos. É um bug — não deveria aparecer.

### Fix

Em [FiltroManager.cs:95-100](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs#L95-L100), adicionar filtro de `ItinerarioFormativo.Ativo`:

```csharp
var ciclosExistentes = Domain.ItinerariosFormativos.ItinerarioFormativoRedeSerieRepository
    .GetPorAgrupamentoAnoLetivoRede(agrupamento.Hash, filtro.HashAnoLetivo.Value, filtro.HashRede)
    .Where(x => x.ItinerarioFormativo.Ativo          // ← adicionar este filtro
             && x.ItinerarioFormativo.Ciclo != null)
    .Select(x => x.ItinerarioFormativo.Ciclo.Id)
    .Distinct()
    .ToList();
```

Esse filtro garante que apenas IFs ativos contribuem para a lista de ciclos disponíveis, tornando o dropdown consistente com o que as queries de dados retornam.


## Dúvida 6 — É possível ter "CF Anual" disponível para Motivo/2026/1ª série? O que precisa ser feito?

**Validado com MCP SQL Server em 2026-05-04.**

### Tudo já existe — só o `ItinerarioFormativo` está inativo

| Entidade | Estado |
|---|---|
| `EstruturaAvaliacaoConfiguracao.PossuiItinerarioFormativoSeparadoNoBoletim` | ✅ `true` |
| `ItinerarioFormativoRedeSerie.Id=1233` (Motivo / 1ª série / 2026) | ✅ Ativo |
| `ItinerarioFormativoRedeSerieDisciplina` (2 disciplinas vinculadas) | ✅ Ativas |
| `ItinerarioFormativo.Id=935` (Ciclo=Anual) | ❌ **Inativo** |
| `EstruturaAvaliacao` com `ItinerarioFormativoCiclo=1` | ❌ Nenhuma |

Para confirmar o padrão: todos os anos anteriores têm o IF ativo — só 2026 está inativo.

| AnoLetivo | IF.Id | Ativo |
|---|---|---|
| 2023 | 177 | ✅ |
| 2024 | 488, 489 | ✅ |
| 2025 | 702, 703 | ✅ |
| 2026 | **935** | ❌ |

### O que precisa ser feito

**Um único passo:** reativar o `ItinerarioFormativo.Id=935` pelo **Configurador de Itinerários Formativos** (não via SQL direto).

Após a reativação, com o fix da Dúvida 5 já aplicado:
1. `GetAgrupamentos` encontra `CiclosItinerarioFormativoExistentes = [1]` → "CF Anual" aparece no dropdown
2. As 2 disciplinas já vinculadas (IFRSD.Id=4663 e 4664) aparecem no filtro de disciplinas
3. O usuário pode então adicionar colunas de `EstruturaAvaliacao` com `ItinerarioFormativoCiclo=1` via o próprio configurador

**Não é necessário** criar nenhum novo registro de IFRS ou IFRSD — a estrutura de 2026 já existe, só o IF-pai está desativado.




## Dúvida 7 — Com filtro Motivo/2026/1ª série do EM/CF Semestral, a lista de disciplinas e o grid estão errados

**Validado com MCP SQL Server em 2026-05-05.**

Dois problemas independentes foram identificados.

---

### Causa A — Dado incompleto: IF.Id=1360 tem apenas 1 disciplina cadastrada

`GetDisciplinas` para escopo CF consulta `ItinerarioFormativoRedeSerieDisciplinaRepository` filtrando por `ItinerarioFormativoCiclo.Id == idCicloIF`. Para Motivo/2026/1ª série/CF Semestral isso aponta para `ItinerarioFormativo.Id=1360` (Ciclo=Semestral, Ativo=true) — que tem apenas **1 disciplina vinculada: "Artes"**.

O `GetDisciplinas` está correto; o dado no banco é que está incompleto.

| Entidade | Estado |
|---|---|
| `ItinerarioFormativo.Id=1360` | Ativo, Ciclo=Semestral (Id=2) |
| `ItinerarioFormativoRedeSerie` vinculado | Ativo |
| `ItinerarioFormativoRedeSerieDisciplina` | 1 disciplina — "Artes" |

**Fix:** adicionar as demais disciplinas de CF Semestral para Motivo/2026/1ª série via **Configurador de Itinerários Formativos** (não via SQL direto). Nenhuma alteração de código é necessária para esta causa.

---

### Causa B — Bug de arquitetura: `ViewConfiguradorAvaliacao` não carrega disciplinas IFRSD para estruturas CF

`GetAvaliacoes` (escopo regular) usa a view `ViewConfiguradorAvaliacao`, que cruza `RedeSerieDisciplina × EstruturaAvaliacao`. Para estruturas de CF (ex.: `EstruturaAvaliacao.Id=694797`, com `ItinerarioFormativoCiclo=2`), a view gera **19 linhas, todas com `HashDisciplina=null`** — porque a view foi projetada para o currículo regular e não conhece `ItinerarioFormativoRedeSerieDisciplina`.

O bloco CF original em `FiltroManager.GetAvaliacoes` filtrava com `x.HashDisciplina.HasValue`, o que eliminava todas as 19 linhas → grid sempre vazio para qualquer escopo CF.

| Consulta | Resultado |
|---|---|
| `EstruturaAvaliacao` com `ItinerarioFormativoCiclo=2` para esse agrupamento | Id=694797 encontrado |
| `ViewConfiguradorAvaliacao` cruzando `IdEstrutura=694797` | 19 linhas, `HashDisciplina=null` em todas |
| Disciplinas IFRSD para IF.Id=1360 | 1 linha ("Artes") |

**Fix implementado (Opção 2) em [FiltroManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs) — bloco CF de `GetAvaliacoes`:**

1. Busca `estruturasCFIds` via `EstruturaAvaliacao` com `ItinerarioFormativoCiclo==idCicloIF`.
2. Busca `disciplinasCF` diretamente do IFRSD (com `Hash`, `Nome`, `HashMae`, `NomeMae`).
3. Consulta a view para as estruturas CF **sem** o filtro `HashDisciplina.HasValue`.
4. Expande em memória: linhas com `HashDisciplina!=null` passam direto (se a disciplina estiver em `disciplinasCF`); linhas com `HashDisciplina==null` são multiplicadas — uma cópia por disciplina do IFRSD.
5. Retorna via `ConverterParaConfiguradorDisciplinaDTO` igual ao fluxo regular.

Esse bypass garante que o grid exiba as disciplinas corretas (vindas do IFRSD) independentemente do que a view retorna no campo `HashDisciplina`.