# EFC-5976 — Changelog das Novas Tarefas

---

## Tarefa 1 — Botão "Filtrar" permitia filtrar com escopo CF em agrupamento não configurado

### Problema
Quando o filtro tem `PossuiItinerarioFormativoSeparadoNoBoletim = false` e o usuário seleciona um escopo de Componente Formativo, o `escopoSelecionado.subscribe` exibe a mensagem de erro e tenta resetar o escopo para `null`. Porém o botão "Filtrar" permanecia ativo (pois `filtroAplicado = false` após `BloquearExibicao`) e não validava a mesma condição — permitindo que o usuário clicasse em "Filtrar" e disparasse `GetEstrutura()` em um estado inválido.

### Causa raiz
`AplicarFiltro` em [Listagem.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Listagem.js) não possuía guard para o cenário `escopoSelecionado >= 4 && !agrupamentoConfiguradoParaCF`. O guard existia apenas no subscribe de `escopoSelecionado`, mas não na ação de filtrar.

### Fix implementado

**Arquivo:** [Listagem.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Listagem.js)

**Trecho adicionado em `AplicarFiltro`:**
```javascript
// Antes
self.AplicarFiltro = function () {
   self.escolas([]);
   if (self.filtroAplicado()) { return app.alerta('Filtro já aplicado.'); }
   else if (!self.PossuiValor(self.hashAgrupamento())) { return app.alerta('Informe todos os dados antes de aplicar o filtro.'); }
   else if (self.carregando()) { return app.alerta('Aguarde a conclusão da operação atual.'); }
   GetTiposResultado();
   ...

// Depois
self.AplicarFiltro = function () {
   self.escolas([]);
   if (self.filtroAplicado()) { return app.alerta('Filtro já aplicado.'); }
   else if (!self.PossuiValor(self.hashAgrupamento())) { return app.alerta('Informe todos os dados antes de aplicar o filtro.'); }
   else if (self.carregando()) { return app.alerta('Aguarde a conclusão da operação atual.'); }
   else if (self.escopoSelecionado() >= 4 && !self.agrupamentoConfiguradoParaCF()) { return app.alerta('O agrupamento não está configurado para exibir Componentes Formativos separadamente no boletim. Configure-o antes de prosseguir.'); }
   GetTiposResultado();
   ...
```

**Motivo do guard em `AplicarFiltro` e não só no subscribe:** o subscribe reseta `escopoSelecionado` para `null` de forma assíncrona (via `app.alerta`). Se o usuário clicar em "Filtrar" enquanto o observable ainda carrega o valor CF, ou se por qualquer outro motivo o estado chegar a `AplicarFiltro` com `escopoSelecionado >= 4`, a mesma mensagem é exibida e a filtragem é bloqueada.

---

## Tarefa 2 — Validação dos fluxos de operações em massa para escopos CF

### Operações analisadas: Edição em Massa, Criar Avaliação Padrão, Copiar de Outra Coluna

#### Edição em Massa

**JS:** [Avaliacao.EdicaoEmMassa.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Avaliacao/Avaliacao.EdicaoEmMassa.js)
**Backend:** `BuscaManager.GetAvaliacoesParaEdicaoEmMassa` ([BuscaManager.cs:449](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs#L449))

**Análise:** a modal é aberta passando `obj` (coluna/estrutura) e o `filtro` completo. `GetAvaliacoesParaEdicaoEmMassa` localiza a `EstruturaAvaliacao` pelo `hashEstrutura` e consulta a view por `GetPorEstrutura(idEstruturaAvaliacao)`. O escopo CF está implícito: a estrutura em si já é uma `EstruturaAvaliacao` com `ItinerarioFormativoCiclo` definido, portanto as avaliações retornadas são exclusivamente as dessa coluna.

**Resultado: OK — nenhum ajuste necessário.**

---

#### Criar Avaliação Padrão

**JS:** [Avaliacao.Padrao.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Avaliacao/Avaliacao.Padrao.js)
**Backend:** `EdicaoAvaliacaoManager.SetAvaliacaoPadrao` ([EdicaoAvaliacaoManager.cs:485](../Eleva.Portal/ConfiguradorAvaliacao/Services/EdicaoAvaliacaoManager.cs#L485))

**Análise:**
- A modal recebe `filtro` (com `EscopoAvaliacoes`) e `disciplinas` (que para CF já vêm corretamente do `GetDisciplinas` → IFRSD).
- `SetAvaliacaoPadrao` cria `Avaliacao` usando `IdCiclo` e `IdTipoAvaliacao` da coluna — ambos obtidos da estrutura CF.
- A entidade `Avaliacao` não possui `ItinerarioFormativoCiclo` — essa FK pertence à `EstruturaAvaliacao` (a coluna). A avaliação é associada às séries e disciplinas informadas no filtro.
- O filtro de exibição no grid (`FiltroManager.GetAvaliacoes`) usa `estruturasCFIds.Contains(x.IdEstrutura)` — avaliações criadas com o mesmo `Ciclo/TipoAvaliacao` aparecem apenas nas estruturas correspondentes à combinação filtrada.

**Resultado: OK — o escopo CF é mantido porque as disciplinas passadas são IFRSD (correto) e a exibição no grid já filtra por `IdEstrutura` CF. Nenhum ajuste necessário.**

---

#### Copiar de Outra Coluna

**JS:** [Avaliacao.Copiar.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Avaliacao/Avaliacao.Copiar.js)
**Backend:** `BuscaManager.GetEstruturasRelacionadasComAtual` ([BuscaManager.cs:320](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs#L320)) + `BuscaManager.GetAvaliacoesParaCopia` ([BuscaManager.cs:428](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs#L428))

**Análise:**
- O filtro montado em `Avaliacao.Copiar.js` (linha 36) já inclui `EscopoAvaliacoes: filtro.EscopoAvaliacoes`.
- `GetEstruturasRelacionadasComAtual` implementado na feature principal (`8837aa6`) possui branch CF que filtra `x.ItinerarioFormativoCiclo != null && x.ItinerarioFormativoCiclo.Id == idCicloIF` — garante que apenas colunas do mesmo ciclo CF aparecem como opções de cópia.
- `GetAvaliacoesParaCopia` é scoped por `hashEstrutura` (a coluna de origem selecionada) — inherentemente correto.

**Resultado: OK — `GetEstruturasRelacionadasComAtual` já foi implementado com suporte a CF. Nenhum ajuste necessário.**

---

## Tarefa 3 — Controle de criação de coluna duplicada no mesmo escopo

### Análise

O controle de duplicidade existe em `EdicaoEstruturaManager.ConfiguracaoJaExiste` ([EdicaoEstruturaManager.cs:25](../Eleva.Portal/ConfiguradorAvaliacao/Services/EdicaoEstruturaManager.cs#L25)).

Esse controle verifica se já existe uma `EstruturaAvaliacao` para o mesmo `Agrupamento/AnoLetivo/Ciclo/TipoAvaliacao`. Antes da task, ele não considerava `ItinerarioFormativoCiclo`, o que fazia com que uma coluna CF e uma coluna regular com mesmo Ciclo/TipoAvaliacao fossem tratadas como duplicatas.

**O fix já foi implementado no commit `f35f4f4` como parte do fluxo de ajuste da feature:**

```csharp
if (dto.EscopoAvaliacoes.HasValue && dto.EscopoAvaliacoes.Value.EhEscopoCF())
{
    var idCicloIF = dto.EscopoAvaliacoes.Value.GetIdCicloIF();
    query = query.Where(q => q.ItinerarioFormativoCiclo != null
                          && q.ItinerarioFormativoCiclo.Id == idCicloIF);
}
else
{
    query = query.Where(q => q.ItinerarioFormativoCiclo == null);
}
```

- Escopo CF: verifica duplicidade apenas entre colunas CF do mesmo ciclo (ex.: dois CF Semestral com mesmo TipoAvaliacao/Ciclo).
- Escopo regular: exclui colunas CF da verificação, evitando falsos positivos.

**Resultado: controle existe e já trata CF corretamente. Nenhum ajuste adicional necessário.**

---

## Tarefa 1 — Correção do guard (revisão)

### Problema adicional identificado

O fix inicial adicionava o guard `escopoSelecionado() >= 4 && !agrupamentoConfiguradoParaCF()` em `AplicarFiltro`, mas o guard era inoperante: o subscribe já chamava `self.escopoSelecionado(null)` antes que `AplicarFiltro` pudesse verificar o valor — `null >= 4` é `false` e o guard nunca disparava.

### Fix complementar

**Arquivo:** [Listagem.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Listagem.js)

Removido `self.escopoSelecionado(null)` do subscribe. O escopo CF permanece selecionado após o alerta, permitindo que o guard em `AplicarFiltro` o detecte quando o usuário clicar em "Filtrar".

Removido também `debugger;` residual que havia ficado de sessão de debug.

---

## Tarefa 4 — Colunas automáticas não apareciam nos escopos CF

### Problema

Ao filtrar por um escopo de Componente Formativo, as colunas automáticas (TipoAvaliacao com flag `Total`, `Media`, `FaltaEtapa` ou `Situacao = true`) nunca eram exibidas. Apenas as colunas CF específicas (`ItinerarioFormativoCiclo != null`) eram retornadas.

### Causa raiz

**`GetEstrutura`:** o filtro CF era `ItinerarioFormativoCiclo != null && Id == idCicloIF`, excluindo totalmente as colunas automáticas (que têm `ItinerarioFormativoCiclo = null`).

**`GetAvaliacoes`:** `estruturasCFIds` só incluía estruturas com `ItinerarioFormativoCiclo != null`. O filtro da view (`estruturasCFIds.Contains(x.IdEstrutura)`) excluía as automáticas. Além disso, as colunas automáticas têm `HashDisciplina != null` na view (são estruturas regulares, fazem join com `RedeSerieDisciplina`) — o expand loop as descartaria por não estarem em `disciplinasCF`.

### Fix implementado

**Arquivos alterados:**

- [ViewConfiguradorAvaliacaoInternalDTO.cs](../Eleva.Portal/ConfiguradorAvaliacao/DTO/ViewConfiguradorAvaliacaoInternalDTO.cs) — adicionado `public bool EhEstruturaAutomatica { get; set; }`
- [FiltroManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs)

---

#### `GetEstrutura` — ampliar filtro CF para incluir automáticas

```csharp
// Antes
queryable = queryable.Where(x => x.ItinerarioFormativoCiclo != null
                              && x.ItinerarioFormativoCiclo.Id == idCicloIF);

// Depois
queryable = queryable.Where(x =>
   (x.ItinerarioFormativoCiclo != null && x.ItinerarioFormativoCiclo.Id == idCicloIF)
   ||
   (x.ItinerarioFormativoCiclo == null
    && x.Ciclo.Etapa.Boletim == true
    && x.Ciclo.Etapa.Diversificada == false
    && x.Ciclo.Etapa.Simulados == false
    && (x.TipoAvaliacao.FaltaEtapa || x.TipoAvaliacao.Total || x.TipoAvaliacao.Media || x.TipoAvaliacao.Situacao)));
```

O escopo `Boletim=true, Diversificada=false, Simulados=false` é o mesmo das etapas regulares — Itinerário Formativo é um track paralelo dentro do boletim regular, portanto as automáticas desse escopo devem ser compartilhadas.

---

#### `GetAvaliacoes` — separar IDs CF dos IDs automáticos

```csharp
// Adicionado após estruturasCFIds
var estruturasAutomaticasIds = Domain.ConfiguradorAvaliacao.EstruturaAvaliacaoRepository
                              .GetPorAgrupamentoAnoLetivoRede(...)
                              .Where(x => x.ItinerarioFormativoCiclo == null
                                       && x.Ciclo.Etapa.Boletim == true
                                       && x.Ciclo.Etapa.Diversificada == false
                                       && x.Ciclo.Etapa.Simulados == false
                                       && (x.TipoAvaliacao.FaltaEtapa || x.TipoAvaliacao.Total || x.TipoAvaliacao.Media || x.TipoAvaliacao.Situacao))
                              .Select(x => x.Id)
                              .ToList();

// Early return: antes só verificava estruturasCFIds; agora aceita só automáticas
if (!disciplinasCF.Any() || (!estruturasCFIds.Any() && !estruturasAutomaticasIds.Any()))
   return new List<ViewConfiguradorAvaliacaoDTO>();

// View query: inclui ambas as listas
var estruturasParaFiltrarIds = estruturasCFIds.Concat(estruturasAutomaticasIds).ToList();
var queryableCF = ... .Where(x => estruturasParaFiltrarIds.Contains(x.IdEstrutura));

// SELECT: marca quais linhas vêm de estruturas automáticas
EhEstruturaAutomatica = estruturasAutomaticasIds.Contains(x.IdEstrutura)
```

---

#### `GetAvaliacoes` — expand loop com deduplicação de automáticas

As colunas automáticas na view retornam uma linha por `RedeSerieDisciplina` (disciplinas regulares, não CF). O expand loop precisa:
1. Ignorar as linhas duplicadas de uma mesma automática (mesma combinação de etapa/ciclo/tipoAvaliacao/série/escola)
2. Expandir uma única vez para todas as disciplinas CF

```csharp
// Antes: dois ramos (HashDisciplina != null → keep/skip; null → expand)
// Depois: três ramos (automática com dedup → expand; CF com disciplina → keep/skip; CF sem disciplina → expand)

var automaticaExpandidas = new HashSet<(Guid, Guid, Guid, Guid, Guid?)>();
foreach (var row in viewRows)
{
   if (!row.EhEstruturaAutomatica && row.HashDisciplina.HasValue)
   {
      if (disciplinasCF.Any(d => d.Hash == row.HashDisciplina.Value))
         listaExpandida.Add(row);
      continue;
   }

   if (row.EhEstruturaAutomatica)
   {
      var key = (row.HashEtapa, row.HashCiclo, row.HashTipoAvaliacao, row.HashSerie, row.HashEscola);
      if (!automaticaExpandidas.Add(key))
         continue;
   }

   foreach (var disc in disciplinasCF.OrderBy(d => d.Nome))
   {
      listaExpandida.Add(new ViewConfiguradorAvaliacaoInternalDTO { ... });
   }
}
```

A chave de deduplicação `(HashEtapa, HashCiclo, HashTipoAvaliacao, HashSerie, HashEscola)` garante que somente a primeira linha de cada coluna automática por série/escola é expandida — eliminando as M cópias que a view gerava (uma por disciplina regular).

---

## Tarefa 5 — Nova etapa criada pela sub-modal não aparecia no select de Etapa

### Problema

Na modal "Nova Configuração" (criar coluna), o campo "Etapa" possui um botão "+ Incluir" que abre a modal "Nova Etapa". Após criar a etapa com sucesso e fechar a sub-modal, `IncluirEtapa` em `Estrutura.Inclusao.js` chama `GetEtapas()` para recarregar a lista. A lista era recarregada, mas a nova etapa não aparecia no select.

### Causa raiz

**Arquivo:** [EdicaoEstruturaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/EdicaoEstruturaManager.cs)

`ColetarIdsParaEtapa` calcula as flags da etapa antes de salvá-la:

```csharp
// Antes
dto.EtapaDeBoletim = (dto.EscopoEtapa == EscopoEnum.Boletim_Regular
                   || dto.EscopoEtapa == EscopoEnum.Boletim_Diversificado);
```

Quando o usuário abre "Nova Configuração" em um escopo CF (ex.: `ComponenteFormativo_Anual = 4`), o filtro passado para a sub-modal `Etapa.Inclusao` contém `EscopoAvaliacoes = 4`. A sub-modal envia esse valor como `EscopoEtapa` ao backend. Como `4 == Boletim_Regular` e `4 == Boletim_Diversificado` são ambos `false`, a etapa era salva com `Boletim = false`.

`GetEtapas` para escopo CF filtra `x.Boletim == true`:
```csharp
.Where(x => x.Boletim && !x.Diversificada && !x.Simulados)
```

A etapa recém-criada (`Boletim = false`) não atendia esse critério e nunca era retornada — o select ficava igual ao estado anterior.

### Fix implementado

```csharp
// Depois
dto.EtapaDeBoletim = (dto.EscopoEtapa == EscopoEnum.Boletim_Regular
                   || dto.EscopoEtapa == EscopoEnum.Boletim_Diversificado)
                   || (dto.EscopoEtapa.HasValue && dto.EscopoEtapa.Value.EhEscopoCF());
```

Escopos CF são uma subdivisão do Boletim Regular — etapas criadas nesses escopos devem ter `Boletim = true` para que `GetEtapas` as retorne tanto no escopo regular quanto no CF.
