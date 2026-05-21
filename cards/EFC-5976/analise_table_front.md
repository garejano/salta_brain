# Análise: Colunas Extras no Grid CF Anual

## Filtro observado

| Campo | Valor |
|---|---|
| Rede | Nosso CEI (Id=56) |
| Ano Letivo | 2026 (Id=2026) |
| Agrupamento | 1ª série do EM (Id=11) |
| Escopo | Componente Formativo — Anual (ItinerarioFormativoCiclo.Id=1) |

---

## Problema

O grid exibia **~16 colunas de dados** por linha de disciplina, enquanto o cabeçalho visível mostrava apenas **5 colunas** (ATF1, AP1, Faltas, MT1, MTF1). Causa: o `FiltroManager.GetEstrutura` retornava colunas de dois contextos diferentes misturados.

---

## Causa raiz — OR clause no FiltroManager.GetEstrutura

O código antigo continha:

```csharp
if (filtro.EscopoAvaliacoes.EhEscopoCF())
{
    int idCicloIF = filtro.EscopoAvaliacoes.GetIdCicloIF();
    queryable = queryable.Where(x =>
        (x.ItinerarioFormativoCiclo != null && x.ItinerarioFormativoCiclo.Id == idCicloIF)
        ||
        (x.ItinerarioFormativoCiclo == null
         && x.Ciclo.Etapa.Boletim == true
         && x.Ciclo.Etapa.Diversificada == false
         && x.Ciclo.Etapa.Simulados == false
         && (x.TipoAvaliacao.FaltaEtapa || x.TipoAvaliacao.Total || x.TipoAvaliacao.Media || x.TipoAvaliacao.Situacao)));
}
```

O segundo branch do `OR` foi introduzido como fallback para incluir colunas automáticas (Média/Total/Situação/Faltas) enquanto o tech lead ainda não havia criado essas colunas com `ItinerarioFormativoCiclo` preenchido. Após o tech lead criar as colunas automáticas diretamente em `EstruturaAvaliacao` com `ItinerarioFormativoCiclo` setado, esse fallback passou a trazer **colunas do boletim regular** misturadas com as colunas CF.

---

## Evidência do banco (ElevaPortalHomolog)

### Branch 1 — CF Anual específico (`ItinerarioFormativoCiclo = 1`) → 5 colunas

| Id | Ordem | Sigla | Tipo | NotaMax | Ciclo | Etapa |
|----|-------|-------|------|---------|-------|-------|
| 694806 | 1 | ATF1 | Avaliação | 10 | Ciclo 1 | 1º Trimestre |
| 694805 | 2 | AP1 | Avaliação | 10 | Ciclo 1 | 1º Trimestre |
| 694815 | 81 | Faltas | FaltaEtapa | 0 | Faltas do 1º Trimestre | 1º Trimestre |
| 694831 | 92 | Média | Média | 10 | Média do 1º Trimestre | 1º Trimestre |
| 694844 | 92 | Média | Média | 10 | Média Recuperada do 1º Trimestre | 1º Trimestre |

### Branch 2 — Boletim regular auto-colunas (`ItinerarioFormativoCiclo IS NULL`) → 13 colunas extras

| Ordem | Sigla | Tipo | Ciclo/Etapa |
|-------|-------|------|------------|
| 4 | Média | Média | Média do 1º Trimestre |
| 6 | Faltas | FaltaEtapa | Faltas do 1º Trimestre |
| 9 | Média | Média | Média Recuperada do 1º Trimestre |
| 14 | Média | Média | Média do 2º Trimestre |
| 16 | Faltas | FaltaEtapa | Faltas do 2º Trimestre |
| 17 | Média | Média | Média Recuperada do 2º Trimestre |
| 21 | Média | Média | Média do 3º Trimestre |
| 22 | Faltas | FaltaEtapa | Faltas do 3º Trimestre |
| 23 | Média | Média | Média Recuperada do 3º Trimestre |
| 95 | Média | Média | Média Anual |
| 97 | Média | Média | Média Final |
| 99 | Média | Média | Média Final 2 |
| 100 | Situação | Situação | Situação |

**Total com o código antigo: 5 + 13 = 18 colunas** para um escopo que deveria ter 5.

---

## Correção aplicada

Remoção do segundo branch do `OR` em `FiltroManager.GetEstrutura`. O filtro CF passou a ser:

```csharp
queryable = queryable.Where(x => x.ItinerarioFormativoCiclo != null && x.ItinerarioFormativoCiclo.Id == idCicloIF);
```

O tech lead criou as colunas automáticas (Média, Situação) diretamente com `ItinerarioFormativoCiclo` preenchido em `EstruturaAvaliacao`, portanto elas são incluídas naturalmente pelo filtro `Id == idCicloIF` — sem necessidade do fallback no boletim regular.

**Arquivo alterado:** `Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs`

---

## Tabela correta após a correção (CF Anual — 5 colunas)

Agrupadas sob o cabeçalho **1º Trimestre**:

| Componente Curricular | ATF1 (max 10) | AP1 (max 10) | Faltas | MT1 / Média (max 10) | MTF1 / Média Rec (max 10) |
|---|---|---|---|---|---|
| Academic English II | 10 | 10 | F | 10 | 10 |
| As grandes guerras da história | - | - | F | 10 | 10 |
| As grandes guerras da história II | - | - | F | 10 | 10 |
| Biologia Aplicada | - | - | F | 10 | 10 |
| Ciência Forense | - | - | F | 10 | 10 |
| *(demais disciplinas)* | - | - | F | 10 | 10 |

> **Legenda:** `-` = disciplina não participa dessa avaliação; `F` = coluna de Faltas; valores numéricos = NotaMaxima configurada.

---

## Impacto da correção nos outros escopos

A remoção do OR clause não afeta os escopos 1–3 (Boletim Regular, Diversificado, Simulados), pois eles são tratados no `else` independente. O filtro `ItinerarioFormativoCiclo == null` já existia no `else` e permanece inalterado.
