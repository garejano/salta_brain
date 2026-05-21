# Turno exibido é o do AulaEvento, não o da Turma

## O cenário

A tela de listagem (`listar.component.html`) exibe a coluna **Turno** para cada linha de evento. O comportamento especificado é:

> O turno exibido deve corresponder ao `AulaEvento.Turno`, **não** ao `Turma.Turno`.

Isso é relevante porque ambas as entidades possuem `TurnoId` e é tecnicamente possível que sejam diferentes (ex: uma turma cadastrada como Manhã que tenha um evento avulso registrado no turno Tarde).

---

## Onde o campo é renderizado

**Arquivo:** `frontend/src/app/features/lancamento-frequencia/listar/listar.component.html`

```html
<!-- linha 66-70 -->
<td>
  <span class="col-turno">
    <span class="material-icons-outlined turno-icone">{{ turnoIcon(evento) }}</span>
    {{ evento.nomeTurno }}
  </span>
</td>
```

Os campos usados são `evento.nomeTurno`, `evento.ehManha`, `evento.ehTarde`, `evento.ehNoite`, `evento.ehIntegral` — todos vindos do backend via `LancamentoFrequenciaEventoResponse`.

---

## Fluxo no backend

```
POST /api/lancamentofrequencia/get-eventos
  └─ GetEventosService.Get()
       └─ AulaEventoRepository.GetEventosParaFrequencia()
            └─ SELECT AulaEvento.Turno.Nome → AulaEventoListingRaw.NomeTurno
  └─ FormatarResponsePorAulaParaCoordenacao()  ← usa eventosDaTurma[0].NomeTurno
  └─ FormatarResponsePorDiaOuTurno()           ← usa evento.NomeTurno
```

**Arquivo chave:** `EstruturaPedagogica.Infra/Repositories/Stateful/AulaEventoRepository.cs`

```csharp
// O NomeTurno vem de AulaEvento → Turno, não de Turma → Turno
.Select(x => new AulaEventoListingRaw
{
    TurnoId  = x.TurnoId,
    NomeTurno = x.Turno.Nome,   // ← AulaEvento.Turno
    ...
})
```

`Turma` também tem `TurnoId`/`Turno`, mas **não é consultado** no caminho de montagem do response.

---

## Como montar o dado para testar

Para validar o cenário, precisamos de uma `AulaEvento` cujo `TurnoId` seja **diferente** do `TurnoId` da sua `Turma`, com `PossuiFrequencia = 1` e data no período testado.

### Query para encontrar um caso real no banco

```sql
SELECT TOP 5
    t.Id          AS TurmaId,
    t.Nome        AS NomeTurma,
    tturno.Id     AS TurnoTurmaId,
    tturno.Nome   AS TurnoTurma,
    ae.Id         AS AulaEventoId,
    ae.DataInicio,
    aeturno.Id    AS TurnoEventoId,
    aeturno.Nome  AS TurnoEvento,
    e.Nome        AS Escola,
    r.Nome        AS Rede
FROM dbo.AulaEvento ae
JOIN dbo.Turno      aeturno ON aeturno.Id = ae.Turno
JOIN dbo.Turma      t       ON t.Id       = ae.Turma       AND t.Ativo  = 1
JOIN dbo.Turno      tturno  ON tturno.Id  = t.Turno
JOIN dbo.EscolaSerie escser ON escser.Id  = t.EscolaSerie
JOIN dbo.Escola     e       ON e.Id       = escser.Escola  AND e.Ativo  = 1
JOIN dbo.Rede       r       ON r.Id       = e.Rede         AND r.Ativo  = 1
WHERE ae.Ativo          = 1
  AND ae.PossuiFrequencia = 1
  AND ae.Turno           <> t.Turno        -- turno do evento ≠ turno da turma
  AND ae.DataInicio      >= '2026-01-01'
ORDER BY ae.DataInicio DESC;
```

> Resultado no homolog (consultado em 2026-05-19): **dado existe** na rede Máxima.

### Exemplo real no homolog (sem necessidade de criar dado)

| Campo | Valor |
|-------|-------|
| **Rede / Escola** | Máxima / Campo Grande (EscolaId 2424) |
| **Data do evento** | 2026-12-11 |
| **Turma** | 6º ano bilíngue A - I (TurmaId 291598) |
| **Turno da Turma** | Integral (Id 4) |
| **Turno do AulaEvento** | Manhã (Id 1) — o que deve aparecer na listagem |
| **Usuário de teste (tipo A)** | `cristiane.sartorelli@escolamaxima.com.br` (UsuarioId 2436286) |

**Passo a passo para validar:**
1. Logar como `cristiane.sartorelli@escolamaxima.com.br`
2. Selecionar Rede **Máxima** → Escola **Campo Grande**
3. Filtrar pela data **11/12/2026**
4. Verificar que a linha do **6º ano bilíngue A - I** exibe o turno **"Manhã"** (e não "Integral")

Outros casos na mesma escola/data: `8º ano bilíngue A - I` (Id 291580), `8º ano bilíngue B - I` (Id 291577), `9º ano bilíngue A - I` (Id 291589), `7º ano bilíngue B - I` (Id 291595).

---

### Como criar o dado manualmente (se necessário)

1. Escolha uma turma ativa com `TurnoId = 1` (Manhã), por exemplo.
2. Insira (ou peça ao time) um `AulaEvento` para essa turma com `TurnoId = 2` (Tarde), com `PossuiFrequencia = 1` e `DataInicio` em uma data que você vai filtrar.
3. Use um usuário do tipo A (coordenador) da escola dessa turma para logar e aplicar o filtro com a data do evento.
4. Verifique que a coluna Turno na listagem exibe **"Tarde"** (e não "Manhã").

---

## Referência dos TurnoIds

| Id | Nome     | Enum          |
|----|----------|---------------|
| 1  | Manhã    | `TurnoEnum.Manha` |
| 2  | Tarde    | `TurnoEnum.Tarde` |
| 3  | Noite    | `TurnoEnum.Noite` |
| 4  | Integral | `TurnoEnum.Integral` |
| 5  | N/A      | `TurnoEnum.NA` |

---

## Arquivos relevantes

| Caminho | O que faz |
|---------|-----------|
| `backend/.../Repositories/Stateful/AulaEventoRepository.cs` | Busca eventos; lê `AulaEvento.Turno.Nome` |
| `backend/.../Services/LancamentoFrequencia/GetEventosService.cs` | Formata o response; propaga `NomeTurno` do raw |
| `backend/.../DTO/LancamentoFrequencia/LancamentoFrequenciaEventoResponse.cs` | DTO com `NomeTurno`, `EhManha`, `EhTarde`, `EhNoite`, `EhIntegral` |
| `frontend/.../listar/listar.component.html` | Renderiza `evento.nomeTurno` na coluna Turno |
