# Análise: Filtro de Disciplinas por Escopo no Configurador de Avaliações

> Contexto: EFC-5976 — suporte a escopos de Componente Formativo (CF) no Configurador de Avaliações.
> Este documento explica a cadeia completa de dados e código para que o filtro de disciplinas por escopo seja implementado corretamente.

---

## 1. Modelo de dados relevante

### 1.1 Disciplina

```
Disciplina
  Id           int
  Hash         Guid
  Nome         string
  DisciplinaMae int (FK para Disciplina.Id)
```

Uma disciplina é considerada **mãe** quando `DisciplinaMae.Id == Id` (aponta para si mesma).  
Uma disciplina é uma **frente** quando `DisciplinaMae.Id != Id` (aponta para outra disciplina).

> Exemplo confirmado no banco:
> - `9217` "Academic English" → mãe (`DisciplinaMae = 9217`)
> - `9218` "Academic English 1" → frente (`DisciplinaMae = 9217`)

---

### 1.2 RedeSerieDisciplina (RSD)

Tabela do currículo regular da rede.

```
RedeSerieDisciplina
  Id                        int
  RedeSerie                 int (FK → RedeSerie → Rede + AnoLetivo + Agrupamento)
  Disciplina                int (FK → Disciplina.Id)  ← SEMPRE aponta para a mãe
  PossuiAvaliacoesRegulares bool
  PossuiAvaliacoesDiversificadas bool
  Ativo                     bool
```

**Importante:** `RSD.Disciplina` aponta sempre para a **disciplina mãe**. Frentes não aparecem diretamente aqui.

---

### 1.3 ItinerarioFormativoRedeSerieDisciplina (IFRSD)

Tabela do currículo de Componente Formativo (Itinerário Formativo).

```
ItinerarioFormativoRedeSerieDisciplina
  Id                           int
  ItinerarioFormativoRedeSerie int (FK → IF × RedeSerie → Rede + AnoLetivo + Agrupamento + Ciclo)
  Disciplina                   int (FK → Disciplina.Id)  ← TAMBÉM aponta para a mãe
  Ativo                        bool
```

**Importante:** assim como RSD, `IFRSD.Disciplina` aponta para a **mãe**. Frentes não aparecem aqui diretamente.

---

### 1.4 EstruturaAvaliacaoConfiguracao

```
EstruturaAvaliacaoConfiguracao
  Agrupamento                              int (FK)
  PossuiItinerarioFormativoSeparadoNoBoletim bool
```

Flag que controla se o agrupamento exibe CF separado do boletim regular.  
**Quando `true`:** disciplinas CF não devem aparecer no escopo `Boletim_Regular`, e vice-versa.

---

## 2. As duas views e suas diferenças críticas

### 2.1 ViewConfiguradorAvaliacao

Join entre **EstruturaAvaliacao** e **RedeSerieDisciplina**:

```sql
-- (simplificado)
FROM EstruturaAvaliacao ea
JOIN Ciclo c ON c.Id = ea.Ciclo
JOIN RedeSerieDisciplina rsd ON rsd.RedeSerie = c.Etapa.RedeSerie
JOIN Disciplina d ON d.Id = rsd.Disciplina   ← join DIRETO com a mãe
```

**Resultado:** retorna uma linha por `(EstruturaAvaliacao × mãe)`. Frentes **não aparecem**.  
Usada por: `FiltroManager.GetAvaliacoes` (colunas/estruturas do boletim).

---

### 2.2 ViewConfiguradorAvaliacaoDisciplina

Join entre **RedeSerieDisciplina** e **Disciplina**, porém com expansão de frentes:

```sql
-- (SQL real)
FROM RedeSerieDisciplina rsd
JOIN Disciplina d ON d.DisciplinaMae = rsd.Disciplina   ← join pela DisciplinaMae!
```

**Resultado:** retorna uma linha por `(RSD.mãe, frente)`.  
Para cada mãe no currículo, a view expande para a mãe + todas as suas frentes.  
Usada por: `BuscaManager.GetDisciplinas` (lista de disciplinas no filtro da UI).

> Exemplo: se 9217 "Academic English" está em RSD, a view retorna:
> - linha com HashDisciplina = hash(9217) → a mãe
> - linha com HashDisciplina = hash(9218) → a frente "Academic English 1"
>
> Ambas herdam `PossuiAvaliacoesRegulares` da entrada do RSD (da mãe).

---

## 3. Fluxo atual dos dois métodos

### 3.1 GetDisciplinas (BuscaManager.cs)

```
EhEscopoCF() == true
  → busca IFRSD, filtra pelo ciclo do IF
  → retorna disciplinas mãe do ciclo
  ✅ correto para escopo CF

EhEscopoCF() == false (Regular, Diversificado)
  → consulta ViewConfiguradorAvaliacaoDisciplina
  → filtra PossuiAvaliacoesRegulares ou PossuiAvaliacoesDiversificadas
  ❌ NÃO verifica PossuiItinerarioFormativoSeparadoNoBoletim
  ❌ NÃO exclui disciplinas cujas mães estão em IFRSD
  → retorna mãe + frentes de TODAS as disciplinas, incluindo as CF
```

---

### 3.2 GetAvaliacoes (FiltroManager.cs)

```
EhEscopoCF() == true
  → busca estruturas CF do ciclo + automáticas
  → filtra view pela lista de estruturas
  → expande para disciplinas IFRSD via cross-join em memória
  ✅ correto para escopo CF

EhEscopoCF() == false (Regular, Diversificado)
  → consulta ViewConfiguradorAvaliacao com flags etapa
  → exclui estruturas CF (ItinerarioFormativoCiclo != null)
     ✅ as COLUNAS CF são excluídas
  ❌ NÃO exclui disciplinas cujas mães estão em IFRSD das colunas regulares
  → disciplinas que estão em RSD E em IFRSD aparecem nas colunas regulares
```

---

## 4. O problema concreto: "Academic English 1" no Boletim Regular

### Por que aparece em GetDisciplinas

```
IFRSD: 9217 (mãe) está como disciplina CF
RSD:   9217 (mãe) também está no currículo regular, PossuiAvaliacoesRegulares = true

ViewConfiguradorAvaliacaoDisciplina expande 9217 para:
  → 9217 (mãe) com PossuiAvaliacoesRegulares = true
  → 9218 (frente) com PossuiAvaliacoesRegulares = true  ← via DisciplinaMae join

GetDisciplinas escopo Regular:
  → filtra PossuiAvaliacoesRegulares = true
  → retorna 9218 ("Academic English 1") ← não deveria
```

### Por que aparece em GetAvaliacoes

```
ViewConfiguradorAvaliacao retorna 9217 (mãe) nas colunas regulares
  → 9218 (frente) NÃO aparece aqui (join direto com mãe)
  → mas 9217 (mãe) aparece

GetAvaliacoes escopo Regular:
  → exclui estruturas CF (ItinerarioFormativoCiclo != null)
  → mas 9217 está em colunas REGULARES (sem ItinerarioFormativoCiclo)
  → 9217 aparece nas colunas regulares ← não deveria
  (9218 não aparece em GetAvaliacoes pois a view não a retorna)
```

---

## 5. O que precisa ser filtrado e onde

### Regra de negócio

Quando `PossuiItinerarioFormativoSeparadoNoBoletim = true` E escopo = `Boletim_Regular`:

> **Qualquer disciplina cuja mãe esteja em IFRSD (para o mesmo agrupamento/anoLetivo/rede) deve ser excluída.**

Isso inclui:
- A própria mãe (ex.: 9217 "Academic English")
- Todas as frentes da mãe (ex.: 9218 "Academic English 1")

---

### 5.1 Fix em GetDisciplinas (BuscaManager.cs)

**Posição:** após o filtro `PossuiAvaliacoesRegulares`, antes do `return queryable`.

**Lógica:**
```csharp
if (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Regular)
{
    var possuiCFSeparado = Domain.ConfiguradorAgrupamento.EstruturaAvaliacaoConfiguracaoRepository
        .GetPorAgrupamentoAnoLetivoRede(filtro.HashAgrupamento.Value, filtro.HashAnoLetivo.Value, filtro.HashRede)
        .Select(x => x.PossuiItinerarioFormativoSeparadoNoBoletim)
        .FirstOrDefault();

    if (possuiCFSeparado)
    {
        // IDs das disciplinas mãe configuradas como CF
        var disciplinasCFMaeIds = Domain.ItinerariosFormativos
            .ItinerarioFormativoRedeSerieDisciplinaRepository
            .GetPorAgrupamentoAnoLetivoRede(filtro.HashAgrupamento.Value, filtro.HashAnoLetivo.Value, filtro.HashRede)
            .Where(x => x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ativo)
            .Select(x => x.Disciplina.Id)
            .Distinct()
            .ToList();

        if (disciplinasCFMaeIds.Any())
        {
            // GetPorDisciplinaMae(List<int>) retorna WHERE DisciplinaMae.Id IN (ids)
            // → retorna a própria mãe E todas as frentes dela
            var disciplinasCFHashes = Domain.EstruturaEscolar.DisciplinaRepository
                .GetPorDisciplinaMae(disciplinasCFMaeIds)
                .Select(x => x.Hash)
                .ToList();

            if (disciplinasCFHashes.Any())
                queryable = queryable.Where(x => !disciplinasCFHashes.Contains(x.HashDisciplina));
        }
    }
}
```

**Por que `GetPorDisciplinaMae` cobre mãe + frente:**
```csharp
// Implementação em DisciplinaRepository.cs
public IQueryable<Disciplina> GetPorDisciplinaMae(List<int> idDisciplinaeMae)
{
    return GetAtivos().Where(x => idDisciplinaeMae.Contains(x.DisciplinaMae.Id));
}
// Para 9217 (mãe): DisciplinaMae.Id == 9217 → ✅ incluída
// Para 9218 (frente): DisciplinaMae.Id == 9217 → ✅ incluída
```

---

### 5.2 Fix em GetAvaliacoes (FiltroManager.cs)

**Posição:** no bloco `else` (branch regular), após excluir `estruturasCFIds`.

**Lógica:**
```csharp
// Já existente: exclui colunas CF
if (estruturasCFIds.Count > 0)
    queryable = queryable.Where(x => !estruturasCFIds.Contains(x.IdEstrutura));

// NOVO: exclui disciplinas CF das colunas regulares
// Ler possuiCFSeparado do configuracaoAgrupamento
// (configuracaoVariaPorEscola já está sendo buscado nessa região — combinar numa só query)
if (filtro.EscopoAvaliacoes == EscopoEnum.Boletim_Regular && possuiCFSeparado)
{
    var disciplinasCFHashes = Domain.ItinerariosFormativos
        .ItinerarioFormativoRedeSerieDisciplinaRepository
        .GetPorAgrupamentoAnoLetivoRede(filtro.HashAgrupamento.Value, filtro.HashAnoLetivo.Value, filtro.HashRede)
        .Where(x => x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ativo)
        .Select(x => x.Disciplina.Hash)
        .Distinct()
        .ToList();

    if (disciplinasCFHashes.Any())
        queryable = queryable.Where(x =>
            !x.HashDisciplina.HasValue || !disciplinasCFHashes.Contains(x.HashDisciplina.Value));
}
```

**Observação:** aqui filtrar apenas os hashes das mães (via IFRSD) é suficiente porque a `ViewConfiguradorAvaliacao` **não expande frentes** — ela retorna `HashDisciplina` da mãe diretamente. Diferente da `ViewConfiguradorAvaliacaoDisciplina`.

---

## 6. Pré-requisito: obter possuiCFSeparado em GetAvaliacoes

A query de `configuracaoVariaPorEscola` já existe em `GetAvaliacoes` (~linha 343). Ela precisa ser ampliada para incluir `PossuiItinerarioFormativoSeparadoNoBoletim`:

```csharp
// ANTES (query atual):
var configuracaoVariaPorEscola = Domain.ConfiguradorAgrupamento.EstruturaAvaliacaoConfiguracaoRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Select(x => x.ConfiguracaoVariaPorEscola)
    .FirstOrDefault();

// DEPOIS (combinar em objeto anônimo):
var configuracaoAgrupamento = Domain.ConfiguradorAgrupamento.EstruturaAvaliacaoConfiguracaoRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Select(x => new { x.ConfiguracaoVariaPorEscola, x.PossuiItinerarioFormativoSeparadoNoBoletim })
    .FirstOrDefault();

var configuracaoVariaPorEscola = configuracaoAgrupamento?.ConfiguracaoVariaPorEscola ?? false;
var possuiCFSeparado           = configuracaoAgrupamento?.PossuiItinerarioFormativoSeparadoNoBoletim ?? false;
```

---

## 7. Mapa dos arquivos e linhas a alterar

| Arquivo | Método | Linha aprox. | O que fazer |
|---|---|---|---|
| `FiltroManager.cs` | `GetAvaliacoes` | ~343 | Ampliar query de configuração para incluir `PossuiItinerarioFormativoSeparadoNoBoletim` |
| `FiltroManager.cs` | `GetAvaliacoes` | ~550 (após excluir estruturasCFIds) | Adicionar filtro de disciplinas mãe CF quando `Boletim_Regular && possuiCFSeparado` |
| `BuscaManager.cs` | `GetDisciplinas` | ~124 (após filtro PossuiAvaliacoesRegulares) | Adicionar filtro de mãe + frentes CF quando `Boletim_Regular && possuiCFSeparado` |

---

## 8. Cenários de teste

| Cenário | Esperado |
|---|---|
| Agrupamento **sem** CF separado (`PossuiItinerarioFormativoSeparadoNoBoletim = false`), escopo Regular | Todas as disciplinas do currículo aparecem normalmente (sem filtro CF) |
| Agrupamento **com** CF separado, escopo Regular | Disciplinas cujas mães estão em IFRSD — mãe e frentes — **não** aparecem |
| Agrupamento com CF separado, escopo CF (ex.: ComponenteFormativo_Anual) | Apenas disciplinas mães do ciclo CF aparecem |
| Disciplina em IFRSD com `ItinerarioFormativo.Ativo = false` | **Não** deve ser excluída do Boletim Regular (o IF inativo não gera escopo CF ativo) |
