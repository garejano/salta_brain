# EFC-5976 — Registro de Mudanças de Código

Documento que consolida todos os arquivos modificados, trechos alterados e o motivo de cada mudança durante a implementação da feature e resolução dos bugs da tarefa EFC-5976 (suporte a escopos de Componente Formativo no Configurador de Avaliações).

---

## Visão geral dos commits

| Data | Hash | Descrição |
|---|---|---|
| 2026-04-16 | `8837aa6` | Feature principal — suporte a CF no configurador |
| 2026-04-20 | `e130f72` | Fix — ciclo não era gravado ao criar estrutura |
| 2026-04-22 | `f35f4f4` | Fix — `ConfiguracaoJaExiste` ignorava o ciclo CF |
| 2026-04-27 | `f5203ba` | Fix — Boletim Regular exibia avaliações CF + CF exibia disciplinas fora do ciclo |
| 2026-04-30 | `daf99f1` | Fix — adiciona filtro IFRSD ao bloco CF de `GetAvaliacoes` + typo |
| 2026-05-04 | `db21246` | Fix — `GetAgrupamentos` exibia opção CF com `ItinerarioFormativo.Ativo = false` |
| 2026-05-05 | *(staged)* | Fix — `GetAvaliacoes` CF retornava grid vazio (cross-join IFRSD em memória) |

---

## Mudanças por arquivo

---

### `Eleva.Portal/ConfiguradorAvaliacao/Enum/EscopoEnum.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
// Novos valores do enum
ComponenteFormativo_Anual       = 4,
ComponenteFormativo_Semestral   = 5,
ComponenteFormativo_Trimestral  = 6,
ComponenteFormativo_Bimestral   = 7

// Nova classe de extensão no mesmo arquivo
public static class EscopoEnumExtensions
{
   private static readonly Dictionary<EscopoEnum, int> MapaCicloId = new Dictionary<EscopoEnum, int>
   {
      { EscopoEnum.ComponenteFormativo_Anual,      1 },
      { EscopoEnum.ComponenteFormativo_Semestral,  2 },
      { EscopoEnum.ComponenteFormativo_Trimestral, 4 },
      { EscopoEnum.ComponenteFormativo_Bimestral,  5 }
   };

   public static bool EhEscopoCF(this EscopoEnum escopo) => MapaCicloId.ContainsKey(escopo);
   public static int GetIdCicloIF(this EscopoEnum escopo) => MapaCicloId[escopo];
}
```

**Motivo:** O enum existia com apenas 3 valores (Regular, Diversificado, Simulados). Para suportar os 4 ciclos de CF foi necessário adicionar os novos valores e um mapa que traduz `EscopoEnum → ItinerarioFormativoCiclo.Id` no banco (os IDs não são sequenciais: 1=Anual, 2=Semestral, 4=Trimestral, 5=Bimestral, pois o Id=3 foi deletado). Os métodos de extensão centralizam essa tradução e evitam switch-cases espalhados pelo código.

---

### `Eleva.Portal/ItinerariosFormativos/ItinerarioFormativoCiclo.cs` *(novo arquivo)*
**Commit:** `8837aa6`

**Motivo:** Entidade `ItinerarioFormativoCiclo` não estava mapeada no domínio C#. Era necessária para que `EstruturaAvaliacao.ItinerarioFormativoCiclo` tivesse tipagem forte e para que os filtros por `Ciclo.Id` funcionassem via LINQ/NHibernate.

---

### `Eleva.Portal/ItinerariosFormativos/NHMapping/ItinerarioFormativoCicloMap.cs` *(novo arquivo)*
**Commit:** `8837aa6`

**Motivo:** Mapeamento NHibernate da entidade `ItinerarioFormativoCiclo` para a tabela correspondente no banco. Sem o mapping, NHibernate não conseguiria hidratar a entidade nas queries.

---

### `Eleva.Portal/ItinerariosFormativos/ItinerarioFormativo.cs`
**Commit:** `8837aa6` (adicionou `Ciclo`) · `db21246` (adicionou `Ativo`)

**Trecho adicionado em `8837aa6`:**
```csharp
public virtual ItinerarioFormativoCiclo Ciclo { get; set; }
```
**Motivo:** A propriedade de navegação `Ciclo` era necessária para que `GetAgrupamentos` conseguisse percorrer `IFRS.ItinerarioFormativo.Ciclo.Id` via LINQ.

**Trecho adicionado em `db21246`:**
```csharp
public virtual bool Ativo { get; set; }
```
**Motivo:** Fix de bug (ver [duvidas do dev.md — Dúvida 5]). A query de `GetAgrupamentos` consultava `ItinerarioFormativoRedeSerie` filtrando apenas `IFRS.Ativo`, mas não verificava `ItinerarioFormativo.Ativo`. Um IF inativo podia vazar para a lista de ciclos disponíveis, fazendo o dropdown exibir uma opção CF sem dados. A propriedade precisou ser mapeada para ser usada no LINQ.

---

### `Eleva.Portal/ItinerariosFormativos/NHMapping/ItinerarioFormativoMap.cs`
**Commit:** `8837aa6` (mapeou `Ciclo`) · `db21246` (mapeou `Ativo`)

**Trecho adicionado em `8837aa6`:**
```csharp
ManyToOne(x => x.Ciclo, n => { n.Column("ItinerarioFormativoCiclo"); ... });
```

**Trecho adicionado em `db21246`:**
```csharp
Property(f => f.Ativo);
```

**Motivo:** Sem os mapeamentos, NHibernate não carregaria as propriedades; qualquer acesso via LINQ seria ignorado ou geraria exceção.

---

### `Eleva.Portal/ItinerariosFormativos/IItinerarioFormativoRedeSerieRepository.cs`
### `Eleva.Portal/ItinerariosFormativos/Repositories/ItinerarioFormativoRedeSerieRepository.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
IQueryable<ItinerarioFormativoRedeSerie> GetPorAgrupamentoAnoLetivoRede(
    Guid hashAgrupamento, Guid hashAnoLetivo, Guid hashRede);
```

**Motivo:** Nenhuma query existia para buscar os IFRSs filtrando simultaneamente por agrupamento, ano letivo e rede. Esse método é a fonte de dados para `GetAgrupamentos` montar a lista de ciclos CF disponíveis por combinação de filtro.

---

### `Eleva.Portal/ItinerariosFormativos/IItinerarioFormativoRedeSerieDisciplinaRepository.cs`
### `Eleva.Portal/ItinerariosFormativos/Repositories/ItinerarioFormativoRedeSerieDisciplinaRepository.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
IQueryable<ItinerarioFormativoRedeSerieDisciplina> GetPorAgrupamentoAnoLetivoRede(
    Guid hashAgrupamento, Guid hashAnoLetivo, Guid hashRede);
```

**Motivo:** Necessário para `BuscaManager.GetDisciplinas` e `FiltroManager.GetAvaliacoes` acessarem as disciplinas vinculadas a um IF filtrando pelo mesmo trio (agrupamento, ano letivo, rede) que os demais filtros do configurador.

---

### `Eleva.Portal/ConfiguradorAvaliacao/EstruturaAvaliacao.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
public virtual ItinerarioFormativoCiclo ItinerarioFormativoCiclo { get; set; }
```

**Motivo:** Colunas de avaliação de CF precisam ser distinguíveis das regulares. A FK `ItinerarioFormativoCiclo` é `null` para avaliações regulares e aponta para o ciclo correspondente para avaliações CF. Sem essa propriedade não haveria como separar os dois escopos no banco.

---

### `Eleva.Portal/ConfiguradorAvaliacao/NHMapping/EstruturaAvaliacaoMap.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
ManyToOne(x => x.ItinerarioFormativoCiclo, n => { n.Column("ItinerarioFormativoCiclo"); n.NotNullable(false); ... });
```

**Motivo:** Mapeamento da FK `ItinerarioFormativoCiclo` na tabela `EstruturaAvaliacao`. A coluna é nullable (regular = null, CF = valor).

---

### `Eleva.Portal/ConfiguradorAvaliacao/DTO/AgrupamentoConfiguradorDTO.cs` *(novo arquivo)*
**Commit:** `8837aa6`

```csharp
public class AgrupamentoConfiguradorDTO
{
   public Guid Hash { get; set; }
   public string Descricao { get; set; }
   public bool PossuiItinerarioFormativoSeparadoNoBoletim { get; set; }
   public List<int> CiclosItinerarioFormativoExistentes { get; set; }
}
```

**Motivo:** `GetAgrupamentos` retornava apenas `{ Hash, Descricao }`. Para o frontend construir o dropdown de escopos CF dinamicamente era necessário saber: (a) se o agrupamento tem a flag `PossuiItinerarioFormativoSeparadoNoBoletim` ativa na `EstruturaAvaliacaoConfiguracao`; (b) quais ciclos CF existem de fato para aquele agrupamento/rede/ano letivo.

---

### `Eleva.Portal/ConfiguradorAvaliacao/DTO/GetEstruturaResponse.cs`
**Commit:** `8837aa6`

**Trecho adicionado:**
```csharp
public bool AgrupamentoNaoConfiguradoParaCF { get; set; }
public bool TipoLinkEscopoVazio { get; set; }
```

**Motivo:** Novos casos de resposta para o frontend: `AgrupamentoNaoConfiguradoParaCF` avisa que o agrupamento não tem `EstruturaAvaliacaoConfiguracao` habilitada para CF; `TipoLinkEscopoVazio` sinaliza que o escopo CF selecionado existe no dropdown mas não tem estrutura ou disciplinas configuradas (grid vazio esperado).

---

### `Eleva.Portal/ConfiguradorAvaliacao/Services/IFiltroManager.cs`
**Commit:** `8837aa6`

**Trecho alterado:**
```csharp
// Antes
IEnumerable<AgrupamentoDTO> GetAgrupamentos(FiltroConfiguradorAvaliacaoDTO filtro);

// Depois
IEnumerable<AgrupamentoConfiguradorDTO> GetAgrupamentos(FiltroConfiguradorAvaliacaoDTO filtro);
```

**Motivo:** Mudança de tipo de retorno para carregar os novos campos CF junto com cada agrupamento.

---

### `Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs`
Este é o arquivo com mais iterações durante a tarefa.

#### Mudança 1 — `GetAgrupamentos` (`8837aa6`)
**Trecho adicionado:**
```csharp
var ciclosExistentes = Domain.ItinerariosFormativos.ItinerarioFormativoRedeSerieRepository
    .GetPorAgrupamentoAnoLetivoRede(agrupamento.Hash, filtro.HashAnoLetivo.Value, filtro.HashRede)
    .Where(x => x.ItinerarioFormativo.Ciclo != null)
    .Select(x => x.ItinerarioFormativo.Ciclo.Id)
    .Distinct()
    .ToList();
```
**Motivo:** Popular `CiclosItinerarioFormativoExistentes` no DTO para que o frontend saiba quais escopos CF mostrar no dropdown.

#### Mudança 2 — `GetAgrupamentos` filtro `Ativo` (`db21246`)
**Trecho alterado:**
```csharp
// Antes
.Where(x => x.ItinerarioFormativo.Ciclo != null)

// Depois
.Where(x => x.ItinerarioFormativo.Ativo
         && x.ItinerarioFormativo.Ciclo != null)
```
**Motivo:** Fix de bug (Dúvida 5 / Dúvida 6). `GetPorAgrupamentoAnoLetivoRede` filtra apenas `IFRS.Ativo`, não `ItinerarioFormativo.Ativo`. Um IF inativo com `IFRS` ativo (caso Motivo/2026/CF Anual) vazava para a lista de ciclos e exibia a opção no dropdown sem que nenhum dado existisse no banco. Filtrar `ItinerarioFormativo.Ativo` torna o dropdown consistente com o que as queries de dados retornam.

#### Mudança 3 — `GetAvaliacoes` branch CF — primeira iteração (`f5203ba`)
**Trecho alterado (substituição do filtro por disciplina por filtro direto em EstruturaAvaliacao):**
```csharp
// Antes — filtrava por disciplinas do IFRSD (misturava escopos)
.Where(x => x.EtapaDeBoletim && !x.EtapaDiversificada && !x.EtapaDeSimulados
         && disciplinasDoCiclo.Contains(x.IdDisciplina.Value));

// Depois — filtra diretamente pelos IDs das estruturas CF do ciclo
var estruturasCFIds = Domain.ConfiguradorAvaliacao.EstruturaAvaliacaoRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Where(x => x.ItinerarioFormativoCiclo != null && x.ItinerarioFormativoCiclo.Id == idCicloIF)
    .Select(x => x.Id).ToList();

queryable = ...ViewConfiguradorAvaliacaoRepository...
    .Where(x => estruturasCFIds.Contains(x.IdEstrutura));
```
**Motivo:** O filtro original por `IdDisciplina` retornava linhas de `EstruturaAvaliacao` regulares quando a disciplina também existia no currículo regular, misturando colunas de diferentes escopos no grid.

#### Mudança 4 — `GetAvaliacoes` branch regular — exclusão de estruturas CF (`f5203ba`)
**Trecho adicionado no branch `else`:**
```csharp
var estruturasCFIds = Domain.ConfiguradorAvaliacao.EstruturaAvaliacaoRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Where(x => x.ItinerarioFormativoCiclo != null)
    .Select(x => x.Id).ToList();

if (estruturasCFIds.Count > 0)
    queryable = queryable.Where(x => !estruturasCFIds.Contains(x.IdEstrutura));
```
**Motivo:** Avaliações CF usam os mesmos flags de etapa (`Boletim=true`) que avaliações regulares. Sem excluir explicitamente os `IdEstrutura` de CF, o Boletim Regular exibia disciplinas e avaliações de Itinerário Formativo.

#### Mudança 5 — `GetAvaliacoes` branch CF — adiciona filtro IFRSD (`daf99f1`)
**Trecho adicionado:**
```csharp
var disciplinasCFHashes = Domain.ItinerariosFormativos.ItinerarioFormativoRedeSerieDisciplinaRepository
    .GetPorAgrupamentoAnoLetivoRede(...)
    .Where(x => x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ciclo != null
             && x.ItinerarioFormativoRedeSerie.ItinerarioFormativo.Ciclo.Id == idCicloIF)
    .Select(x => x.Disciplina.Hash)
    .Distinct().ToList();

queryable = ...Where(x => estruturasCFIds.Contains(x.IdEstrutura)
                       && x.HashDisciplina.HasValue
                       && disciplinasCFHashes.Contains(x.HashDisciplina.Value));
```
**Motivo:** Tentativa de restringir o grid às disciplinas do IFRSD. Essa abordagem foi posteriormente descartada (ver Mudança 6) por um problema arquitetural da view.

#### Mudança 6 — `GetAvaliacoes` branch CF — cross-join IFRSD em memória (`staged / 2026-05-05`)
**Substituição completa do bloco CF** (ver diff completo em `git diff HEAD -- FiltroManager.cs`).

**Motivo (Causa B, Dúvida 7):** `ViewConfiguradorAvaliacao` foi projetada para o currículo regular e cruza `RedeSerieDisciplina × EstruturaAvaliacao`. Para estruturas CF, a view gera linhas com `HashDisciplina = null` — a disciplina vem do IFRSD, não do `RedeSerieDisciplina`. O filtro `x.HashDisciplina.HasValue` da Mudança 5 elimina todas essas linhas, resultando em grid sempre vazio para qualquer escopo CF.

**Solução implementada:**
1. Busca `disciplinasCF` do IFRSD com dados completos (`Hash`, `Nome`, `HashDisciplinaMae`, `NomeDisciplinaMae`).
2. Consulta a view para as `estruturasCFIds` **sem** o filtro `HashDisciplina.HasValue`.
3. Projeta para `ViewConfiguradorAvaliacaoInternalDTO`.
4. Expande em memória: linhas com `HashDisciplina != null` passam direto (se a disciplina está em `disciplinasCF`); linhas com `HashDisciplina == null` são multiplicadas — uma cópia por disciplina IFRSD.
5. Retorna via `ConverterParaConfiguradorDisciplinaDTO` igual ao fluxo regular.

---

### `Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs`
**Commit:** `8837aa6`

**Trechos adicionados:** branches CF em quatro métodos.

**`GetEscolas`:**
```csharp
if (filtro.EscopoAvaliacoes.EhEscopoCF())
{
    int idCicloIF = filtro.EscopoAvaliacoes.GetIdCicloIF();
    // filtra EscolasRedeSerie por IFRS com Ciclo.Id == idCicloIF
}
```
**Motivo:** Escolas para CF são as que têm `ItinerarioFormativoRedeSerie` ativo para o ciclo selecionado, não todas as escolas do agrupamento.

**`GetDisciplinas`:**
```csharp
if (filtro.EscopoAvaliacoes.EhEscopoCF())
{
    int idCicloIF = filtro.EscopoAvaliacoes.GetIdCicloIF();
    return ...ItinerarioFormativoRedeSerieDisciplinaRepository
            .GetPorAgrupamentoAnoLetivoRede(...)
            .Where(x => Ciclo.Id == idCicloIF)...
}
```
**Motivo:** Disciplinas de CF vêm do `IFRSD`, não do `RedeSerieDisciplina`. Retornar as disciplinas regulares para um escopo CF exibiria disciplinas que não pertencem ao itinerário.

**`GetEtapas`:**
```csharp
if (filtro.EscopoAvaliacoes.EhEscopoCF())
    query = query.Where(x => estruturasCFIds.Contains(x.IdEstrutura));
```
**Motivo:** Etapas do grid CF devem ser filtradas pelas `EstruturaAvaliacao` do ciclo CF, não pelas etapas do currículo regular.

**`GetEstruturasRelacionadasComAtual`:**
```csharp
if (escopo.EhEscopoCF())
    query = query.Where(x => x.ItinerarioFormativoCiclo != null
                           && x.ItinerarioFormativoCiclo.Id == idCicloIF);
else
    query = query.Where(x => x.ItinerarioFormativoCiclo == null);
```
**Motivo:** Ao editar uma `EstruturaAvaliacao`, as "estruturas relacionadas" (mesmo agrupamento/ano/ciclo) não devem misturar regular com CF.

---

### `Eleva.Portal/ConfiguradorAvaliacao/DTO/EstruturaAvaliacaoDTO.cs`
**Commit:** `e130f72`

**Trecho adicionado:**
```csharp
public EscopoEnum? EscopoAvaliacoes { get; set; }
```

**Motivo:** O DTO que trafega entre o frontend (Estrutura.Inclusao.js) e o backend não carregava o escopo selecionado. Sem ele, `EdicaoEstruturaManager` não sabia se a nova estrutura era CF ou regular e não conseguia preencher `ItinerarioFormativoCiclo`.

---

### `Eleva.Portal/ConfiguradorAvaliacao/Services/EdicaoEstruturaManager.cs`
**Commit:** `e130f72` (gravação do ciclo) · `f35f4f4` (validação de duplicidade)

#### Mudança 1 — gravação do ciclo ao criar estrutura (`e130f72`)
**Trecho adicionado:**
```csharp
var estruturaAvaliacao = new EstruturaAvaliacao(dto);

if (dto.EscopoAvaliacoes.HasValue && dto.EscopoAvaliacoes.Value.EhEscopoCF())
    estruturaAvaliacao.ItinerarioFormativoCiclo = new ItinerarioFormativoCiclo(dto.EscopoAvaliacoes.Value.GetIdCicloIF());
```
**Motivo:** Sem essa atribuição, toda `EstruturaAvaliacao` criada em escopo CF seria salva com `ItinerarioFormativoCiclo = null`, tornando-a indistinguível de uma estrutura regular e quebrando todos os filtros CF.

#### Mudança 2 — `ConfiguracaoJaExiste` filtra por ciclo (`f35f4f4`)
**Trecho adicionado:**
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
**Motivo:** `ConfiguracaoJaExiste` verificava se já existe uma `EstruturaAvaliacao` para o mesmo agrupamento/ano letivo/ciclo/tipo de avaliação. Sem filtrar por `ItinerarioFormativoCiclo`, uma estrutura regular e uma CF com mesmos parâmetros eram consideradas duplicatas entre si, bloqueando a criação da estrutura CF.

---

### `Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Listagem.js`
**Commit:** `8837aa6`

**Trechos adicionados:**
- `mapaEscoposCF`: dicionário que associa `ItinerarioFormativoCiclo.Id` ao valor do `EscopoEnum` correspondente (ex.: `{1: 4, 2: 5, 4: 6, 5: 7}`).
- `AtualizarEscopos()`: função que reconstrói o dropdown de escopos dinamicamente com base em `agrupamento.CiclosItinerarioFormativoExistentes`. Cada ciclo CF gera uma opção adicional no dropdown.
- Validação ao selecionar escopo CF: verifica `PossuiItinerarioFormativoSeparadoNoBoletim`; se falso, exibe mensagem e bloqueia o carregamento.
- Reset de escopo ao trocar agrupamento: evita que o escopo CF de um agrupamento permaneça selecionado ao mudar para outro sem CF.

**Motivo:** O dropdown de escopos era estático (apenas 3 opções). Para suportar escopos CF variáveis por agrupamento, o dropdown precisou se tornar dinâmico, carregado a partir dos dados devolvidos por `GetAgrupamentos`.

---

### `Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Estrutura/Estrutura.Inclusao.js`
**Commit:** `e130f72` (envia escopo) · `daf99f1` (typo fix)

**Trecho adicionado em `e130f72`:**
```javascript
data.escopoAvaliacoes = self.hashEscopo();
```
**Motivo:** Garantir que o escopo selecionado seja enviado ao backend junto com os dados da nova estrutura, permitindo que `EdicaoEstruturaManager` grave `ItinerarioFormativoCiclo` corretamente.

**Trecho corrigido em `daf99f1`:**
```javascript
// Antes
|| self.PossuiVaor(self.desempenhoMinimoParaAtingirNotaMaxima())

// Depois
|| self.PossuiValor(self.desempenhoMinimoParaAtingirNotaMaxima())
```
**Motivo:** Typo no nome do método (`PossuiVaor` → `PossuiValor`) causava erro de runtime ao verificar o estado do formulário quando o campo `desempenhoMinimoParaAtingirNotaMaxima` estava preenchido.

---

### `Eleva.Portal.Web/app/views/Configuradores/Agrupamento/Edicao.html`
**Commit:** `8837aa6`

**Trecho alterado:**
```html
<!-- Antes -->
<label>Possui Itinerário Formativo</label>

<!-- Depois -->
<label>Possui Itinerário Formativo separado no Boletim</label>
```

**Motivo:** O label original era ambíguo. A flag `PossuiItinerarioFormativoSeparadoNoBoletim` controla especificamente se o boletim do Novo Ensino Médio deve exibir uma seção separada para as avaliações de Componente Formativo. O novo label comunica com precisão o impacto da opção.

---

### `Eleva.Portal/Eleva.Portal.csproj`
**Commit:** `8837aa6`

**Linhas adicionadas:** entradas `<Compile>` para `ItinerarioFormativoCiclo.cs`, `ItinerarioFormativoCicloMap.cs` e `AgrupamentoConfiguradorDTO.cs`.

**Motivo:** O projeto usa SDK-style parcial ou geração manual de `.csproj`; novos arquivos precisaram ser registrados explicitamente para serem incluídos no build.

---

## Resumo dos bugs corrigidos

| # | Sintoma | Causa | Arquivo(s) corrigido(s) | Commit |
|---|---|---|---|---|
| B1 | Boletim Regular exibia avaliações de CF | Branch `else` de `GetAvaliacoes` não excluía `IdEstrutura` de CF | `FiltroManager.cs` | `f5203ba` |
| B2 | Escopo CF exibia disciplinas/colunas fora do ciclo | Filtro por `IdDisciplina` cruzava com estruturas regulares | `FiltroManager.cs` | `f5203ba` |
| B3 | Ciclo não era gravado ao criar estrutura CF | `EdicaoEstruturaManager` não recebia o escopo | `EstruturaAvaliacaoDTO.cs`, `EdicaoEstruturaManager.cs`, `Estrutura.Inclusao.js` | `e130f72` |
| B4 | Estrutura CF era recusada como duplicata de Regular | `ConfiguracaoJaExiste` não filtrava por ciclo | `EdicaoEstruturaManager.cs` | `f35f4f4` |
| B5 | Dropdown exibia opção CF para IF inativo | `GetAgrupamentos` não filtrava `ItinerarioFormativo.Ativo` | `ItinerarioFormativo.cs`, `ItinerarioFormativoMap.cs`, `FiltroManager.cs` | `db21246` |
| B6 | Grid CF sempre vazio com avaliações configuradas | `ViewConfiguradorAvaliacao` retorna `HashDisciplina=null` para CF; filtro `HasValue` eliminava todas as linhas | `FiltroManager.cs` | *(staged)* |
| B7 | Typo `PossuiVaor` causava erro de runtime | Nome de método incorreto | `Estrutura.Inclusao.js` | `daf99f1` |
