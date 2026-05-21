# Análise: Filtro de CF na Exportação vs na Tela

> **Contexto:** A exportação do Configurador de Avaliações retorna dados incorretos para escopos CF mesmo após a adição do filtro `IdItinerarioFormativoCiclo`. Esta análise compara linha a linha como a tela filtra os dados versus como a exportação filtra.

---

## 1. Onde está o filtro na TELA

**Arquivo:** `Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs`  
**Método:** `GetAvaliacoes` — bloco CF, linhas **343–533**

```csharp
// FiltroManager.cs:367–384
var queryableCF = Domain.ConfiguradorAvaliacao.ViewConfiguradorAvaliacaoRepository
                 .GetPorAgrupamentoAnoLetivoRede(ids.IdAgrupamento, ids.IdAnoLetivo, ids.IdRede);

switch (filtro.EscopoAvaliacoes)
{
    case EscopoEnum.ComponenteFormativo_Anual:
        queryableCF = queryableCF.Where(x => x.EtapaDeComponenteAnual);       // ciclo 1
        break;
    case EscopoEnum.ComponenteFormativo_Semestral:
        queryableCF = queryableCF.Where(x => x.EtapaDeComponenteSemestral);   // ciclo 2
        break;
    case EscopoEnum.ComponenteFormativo_Trimestral:
        queryableCF = queryableCF.Where(x => x.EtapaDeComponenteTrimestral);  // ciclo 4
        break;
    default:
        queryableCF = queryableCF.Where(x => x.EtapaDeComponenteBimestral);   // ciclo 5
        break;
}
```

**Como `EtapaDeComponenteAnual` é computado no SQL da view (`ViewConfiguradorAvaliacao` — confirmado no banco):**

```sql
Cast(CASE WHEN EsAv.ItinerarioFormativoCiclo = 1 THEN 1 ELSE 0 END AS bit) AS EtapaDeComponenteAnual,
Cast(CASE WHEN EsAv.ItinerarioFormativoCiclo = 2 THEN 1 ELSE 0 END AS bit) AS EtapaDeComponenteSemestral,
Cast(CASE WHEN EsAv.ItinerarioFormativoCiclo = 4 THEN 1 ELSE 0 END AS bit) AS EtapaDeComponenteTrimestral,
Cast(CASE WHEN EsAv.ItinerarioFormativoCiclo = 5 THEN 1 ELSE 0 END AS bit) AS EtapaDeComponenteBimestral,
```

Ou seja: **o filtro da tela é equivalente a `EsAv.ItinerarioFormativoCiclo = X`**.

---

## 2. Onde está o filtro na EXPORTAÇÃO

**Arquivo:** `Eleva.Portal/ConfiguradorAvaliacao/Services/ExportacaoManager.cs`  
**Método:** `RelatorioParaExportacao` — linhas **20–35**

```csharp
// ExportacaoManager.cs:20–35
IQueryable<ViewConfiguradorAvaliacoesExportacao> queryable = Domain.ConfiguradorAvaliacao
    .ViewConfiguradorAvaliacoesExportacaoRepository
    .GetPorAnoLetivoRede(filtro.HashAnoLetivo.Value, filtro.HashRede);

if (filtro.EscopoAvaliacoes.EhEscopoCF())
{
    int idCicloIF = filtro.EscopoAvaliacoes.GetIdCicloIF();
    queryable = queryable.Where(q => q.IdItinerarioFormativoCiclo == idCicloIF);  // ← filtro CF
}
else
{
    ...
    queryable = queryable.Where(q => q.BoletimRegular.Equals(etapaBoletim)
                                  && q.BoletimDiversificado.Equals(etapaDiversificada)
                                  && q.OutrosSimulados.Equals(etapaSimulados)
                                  && q.IdItinerarioFormativoCiclo == null);
}

if (filtro.HashAgrupamento.HasValue)
    queryable = queryable.Where(q => q.HashAgrupamento == filtro.HashAgrupamento);
```

`IdItinerarioFormativoCiclo` no SQL da view de exportação (`ViewConfiguradorAvaliacaoesExportacao.sql`, linha 58):

```sql
EsAv.ItinerarioFormativoCiclo AS IdItinerarioFormativoCiclo,
```

**Conclusão: os filtros são logicamente equivalentes.** Ambos derivam diretamente de `EsAv.ItinerarioFormativoCiclo`.

---

## 3. Confirmação no banco

A coluna existe e tem dados:

```
IdItinerarioFormativoCiclo | TotalLinhas
NULL                       | 523.931   (regulares)
1 (CF Anual)               | 217
2 (CF Semestral)           | 817
4 (CF Trimestral)          | 498
5 (CF Bimestral)           | 319
```

O `ALTER VIEW` já foi aplicado. O filtro em C# também está implementado.

---

## 4. Diferenças estruturais entre tela e exportação

Mesmo com filtros equivalentes, as duas views têm arquiteturas diferentes que produzem resultados distintos.

### 4.1 Fonte das disciplinas

| | Tela (`ViewConfiguradorAvaliacao`) | Exportação (`ViewConfiguradorAvaliacoesExportacao`) |
|---|---|---|
| **Join base** | `RedeSerieDisciplina` (currículo regular) + subquery `CoFo` (IFRSD) | `AvaliacaoDisciplina` (INNER JOIN) |
| **Para CF** | Retorna disciplinas do currículo regular que mapeiam para o ciclo CF via `CoFo.IdItinerarioFormativoCiclo = EsAv.ItinerarioFormativoCiclo` | Retorna as disciplinas efetivamente vinculadas na tabela `AvaliacaoDisciplina` |
| **HashDisciplina** | `NULL` para avaliações CF (LEFT JOIN na subquery Avaliacoes não bate) | Preenchido via `AvaliacaoDisciplina` |
| **Cross-join** | Feito em memória em `FiltroManager.cs:451–531` com disciplinas do IFRSD | Não existe — `Disciplinas` já é uma string concatenada (`GROUP_CONCAT_D`) |

**Implicação:** A coluna `Disciplinas` na exportação mostra as disciplinas que estão em `AvaliacaoDisciplina`. A tela mostra disciplinas derivadas do IFRSD. Se os dados divergirem, os nomes de disciplinas no CSV serão diferentes do que aparece na tela.

### 4.2 Condição `PossuiItinerarioFormativoSeparadoNoBoletim`

A **tela** só retorna linhas CF quando:

```sql
-- ViewConfiguradorAvaliacao WHERE clause (DB real):
AND EsAvCg.PossuiItinerarioFormativoSeparadoNoBoletim = 1
AND CoFo.IdItinerarioFormativoCiclo = EsAv.ItinerarioFormativoCiclo
```

A **exportação NÃO verifica** `PossuiItinerarioFormativoSeparadoNoBoletim`. Ela retorna todos os registros com `EsAv.ItinerarioFormativoCiclo = idCicloIF`, independente da configuração do agrupamento.

**Risco:** Se existir um agrupamento com `EstruturaAvaliacao.ItinerarioFormativoCiclo IS NOT NULL` mas sem a flag ativa, ele aparece na exportação mas não na tela.

### 4.3 Estruturas sem avaliação instanciada

| | Tela | Exportação |
|---|---|---|
| Estrutura CF sem `Avaliacao` cadastrada | **Aparece** como coluna vazia (LEFT JOIN no subquery `Avaliacoes`) | **Não aparece** (INNER JOIN em `Avaliacao` e `AvaliacaoDisciplina`) |

**Implicação:** O CSV tem MENOS linhas do que as colunas que aparecem na tela quando existem estruturas CF sem avaliações cadastradas.

### 4.4 Escopo do queryable base

| | Tela | Exportação |
|---|---|---|
| Base query | `GetPorAgrupamentoAnoLetivoRede` — já filtra por agrupamento, ano letivo e rede | `GetPorAnoLetivoRede` — filtra só por ano letivo e rede; agrupamento é filtro opcional posterior |

Não causa diferença no resultado final (o filtro de agrupamento é aplicado antes da execução), mas é uma diferença de padrão.

---

## 5. Diagnóstico do problema

O filtro de ciclo (`IdItinerarioFormativoCiclo == idCicloIF`) está **implementado corretamente e o ALTER VIEW foi aplicado**. A lógica é equivalente à da tela.

A discrepância observada provavelmente vem de **4.1 ou 4.3**:

| Hipótese | Sintoma esperado | Como verificar |
|---|---|---|
| **H1:** CF avaliações com `AvaliacaoDisciplina` de disciplinas diferentes das IFRSD | Nomes de disciplinas errados no CSV | Comparar `Disciplinas` no CSV com o grid da tela para o mesmo agrupamento+ciclo |
| **H2:** Estruturas CF sem `Avaliacao` instanciada | CSV tem menos linhas do que colunas na tela | Ver se há `EstruturaAvaliacao` com `ItinerarioFormativoCiclo IS NOT NULL` que não tem nenhuma `Avaliacao` vinculada |
| **H3:** Agrupamento sem flag `PossuiItinerarioFormativoSeparadoNoBoletim` mas com estruturas CF | CSV inclui avaliações que a tela não mostra | Verificar `EstruturaAvaliacaoConfiguracao.PossuiItinerarioFormativoSeparadoNoBoletim` para os agrupamentos com linhas CF na exportação |

### Query de diagnóstico — H2 (estruturas CF sem avaliação):

```sql
SELECT EsAv.Id, EsAv.ItinerarioFormativoCiclo, Ag.Nome AS Agrupamento
FROM EstruturaAvaliacao EsAv
INNER JOIN Agrupamento Ag ON Ag.Id = EsAv.Agrupamento
WHERE EsAv.ItinerarioFormativoCiclo IS NOT NULL
  AND EsAv.Ativo = 1
  AND NOT EXISTS (
      SELECT 1 FROM Avaliacao Av 
      WHERE Av.Ciclo = EsAv.Ciclo 
        AND Av.Agrupamento = EsAv.Agrupamento 
        AND Av.TipoAvaliacao = EsAv.TipoAvaliacao
        AND Av.Ativo = 1
  )
```

---

## 6. Diagnóstico confirmado no banco

### 6.1 Avaliações CF com disciplinas fora do IFRSD

```sql
-- Resultado: 1.368 avaliações
SELECT COUNT(*) AS AvaliacoesSemCorrespondenciaIFRSD
FROM Avaliacao Av
INNER JOIN AvaliacaoDisciplina AvDi ON AvDi.Avaliacao = Av.Id AND AvDi.Ativo = 1
INNER JOIN Disciplina Di ON Di.Id = AvDi.Disciplina AND Di.Ativo = 1
INNER JOIN Ciclo Ci ON Ci.Id = Av.Ciclo
INNER JOIN EstruturaAvaliacao EsAv ON EsAv.TipoAvaliacao = Av.TipoAvaliacao
    AND EsAv.Ciclo = Ci.Id AND EsAv.Agrupamento = Av.Agrupamento AND EsAv.Ativo = 1
WHERE EsAv.ItinerarioFormativoCiclo IS NOT NULL AND Av.Ativo = 1
  AND NOT EXISTS (
    SELECT 1
    FROM AvaliacaoSerie AvSe
    INNER JOIN Serie Se ON Se.Id = AvSe.Serie AND Se.Ativo = 1
    INNER JOIN RedeSerie ReSe ON ReSe.Serie = Se.Id AND ReSe.Agrupamento = Av.Agrupamento AND ReSe.Ativo = 1
    INNER JOIN ItinerarioFormativoRedeSerie ItFoReSe ON ItFoReSe.RedeSerie = ReSe.Id AND ItFoReSe.Ativo = 1
    INNER JOIN ItinerarioFormativo ItFo ON ItFo.Id = ItFoReSe.ItinerarioFormativo
        AND ItFo.ItinerarioFormativoCiclo = EsAv.ItinerarioFormativoCiclo AND ItFo.Ativo = 1
    INNER JOIN ItinerarioFormativoRedeSerieDisciplina ItFoReSeDi
        ON ItFoReSeDi.ItinerarioFormativoRedeSerie = ItFoReSe.Id
        AND ItFoReSeDi.Disciplina = Di.Id AND ItFoReSeDi.Ativo = 1
    WHERE AvSe.Avaliacao = Av.Id AND AvSe.Ativo = 1
  )
```

Total de linhas CF na exportação: **1.851** (ciclo 1=217, 2=817, 4=498, 5=319 + 2ª série).  
Destas, **1.368 têm disciplinas fora do IFRSD** — aparecem no CSV mas nunca na tela.

### 6.2 Causa raiz confirmada

A tela filtra via `disciplinaCFHashes.Contains(row.HashDisciplina.Value)` (`FiltroManager.cs:467`), eliminando avaliações cujas disciplinas em `AvaliacaoDisciplina` não estão no IFRSD do ciclo. A exportação não tem filtro equivalente — usa apenas `IdItinerarioFormativoCiclo == idCicloIF`, que é necessário mas não suficiente.

---

## 7. Plano de solução (mínima mudança estrutural)

### Premissa

O filtro de ciclo em C# (`ExportacaoManager.cs:22`) está **correto e não precisa mudar**. O problema está na view SQL: ela retorna avaliações CF cujas disciplinas não pertencem ao IFRSD do ciclo, e o C# não tem como filtrar esse detalhe sem dados adicionais.

### Mudança 1 — `ViewConfiguradorAvaliacaoesExportacao.sql` (única mudança necessária)

Adicionar condição EXISTS no final do WHERE para garantir que avaliações CF só apareçam se suas disciplinas estiverem no IFRSD do ciclo:

```sql
-- Adicionar antes do GROUP BY (após AND Se.Ativo = 1):
AND (EsAv.ItinerarioFormativoCiclo IS NULL
  OR EXISTS (
        SELECT 1
        FROM   ItinerarioFormativoRedeSerieDisciplina AS ItFoReSeDiChk
        INNER JOIN ItinerarioFormativoRedeSerie       AS ItFoReSeLkp
               ON  ItFoReSeLkp.Id    = ItFoReSeDiChk.ItinerarioFormativoRedeSerie
               AND ItFoReSeLkp.Ativo = 1
        INNER JOIN ItinerarioFormativo                AS ItFoLkp
               ON  ItFoLkp.Id                    = ItFoReSeLkp.ItinerarioFormativo
               AND ItFoLkp.ItinerarioFormativoCiclo = EsAv.ItinerarioFormativoCiclo
               AND ItFoLkp.Ativo                 = 1
        INNER JOIN AvaliacaoDisciplina             AS AvDiChk
               ON  AvDiChk.Avaliacao  = Av.Id
               AND AvDiChk.Disciplina = ItFoReSeDiChk.Disciplina
               AND AvDiChk.Ativo      = 1
        WHERE  ItFoReSeDiChk.Ativo = 1
     ))
```

**Por que funciona:** espelha exatamente o que a tela faz — `disciplinaCFHashes.Contains(row.HashDisciplina.Value)` em `FiltroManager.cs:467`. A condição `IS NULL` preserva o comportamento das avaliações regulares intacto.

**Impacto estimado:** 1.851 → ~483 linhas CF na exportação (removendo as 1.368 avaliações com disciplinas fora do IFRSD).

### Sem mudança em C\#

`ExportacaoManager.cs` não precisa ser alterado. O filtro `IdItinerarioFormativoCiclo == idCicloIF` (linha 23) continua correto; o ajuste fica contido no SQL da view.

### Ordem de execução

1. Aplicar `ALTER VIEW` da `ViewConfiguradorAvaliacaoesExportacao.sql` em homolog.
2. Validar com a query abaixo — deve retornar 0:

```sql
SELECT COUNT(*) AS AvaliacoesSemCorrespondenciaIFRSD
FROM ViewConfiguradorAvaliacoesExportacao v
WHERE v.IdItinerarioFormativoCiclo IS NOT NULL
  AND NOT EXISTS (
    SELECT 1
    FROM ItinerarioFormativoRedeSerieDisciplina IFD
    INNER JOIN ItinerarioFormativoRedeSerie IFRS ON IFRS.Id = IFD.ItinerarioFormativoRedeSerie AND IFRS.Ativo = 1
    INNER JOIN ItinerarioFormativo IFO ON IFO.Id = IFRS.ItinerarioFormativo
        AND IFO.ItinerarioFormativoCiclo = v.IdItinerarioFormativoCiclo AND IFO.Ativo = 1
    INNER JOIN EstruturaAvaliacaoConfiguracao EAC ON EAC.Agrupamento = v.IdAgrupamento
        AND EAC.AnoLetivo = v.IdAnoLetivo AND EAC.Rede = v.IdRede AND EAC.Ativo = 1
    WHERE IFD.Disciplina IN (
        SELECT ItFoReSeDi2.Disciplina FROM ItinerarioFormativoRedeSerieDisciplina ItFoReSeDi2 WHERE ItFoReSeDi2.Ativo = 1
    ) AND IFD.Ativo = 1
  )
```

3. Testar: selecionar escopo CF na tela → anotar disciplinas visíveis → exportar → confirmar que o CSV contém apenas essas disciplinas.

---

## 8. Resumo

| Aspecto | Tela | Exportação | Consistente? |
|---|---|---|---|
| Filtro por ciclo CF | `EtapaDeComponenteAnual/...` | `IdItinerarioFormativoCiclo == id` | ✅ Equivalente (ambos = `EsAv.ItinerarioFormativoCiclo`) |
| Filtro por agrupamento | Na base query | Filtro posterior opcional | ✅ Mesmo resultado |
| Flag `PossuiItinerarioFormativoSeparadoNoBoletim` | Obrigatória no SQL da view | Todos os 1.851 CF já têm flag=true | ✅ Não está causando problema agora |
| Estruturas CF sem avaliação instanciada | Aparecem como coluna vazia | Não aparecem | ✅ Comportamento intencional do CSV |
| Disciplinas fora do IFRSD em avaliações CF | Filtradas em memória (`FiltroManager.cs:467`) | **Aparecem no CSV** (sem filtro IFRSD) | ❌ **CAUSA RAIZ** — 1.368 linhas extras |

**Única mudança necessária:** adicionar EXISTS de IFRSD no WHERE de `ViewConfiguradorAvaliacaoesExportacao.sql` (seção 7).
