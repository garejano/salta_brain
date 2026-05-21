# EFC-5976 — Análise da Descrição do Tech Lead

Documento que cruza os requisitos descritos pelo tech lead com o status de implementação de cada ponto.

**Legenda:**
- ✅ Implementado e validado
- ⚠️ Parcialmente implementado / necessita validação manual
- ❌ Não implementado (pendente ou fora do escopo deste card)

---

## Bloco 1 — Agrupamento NÃO configurado para exibir CF separadamente (`PossuiItinerarioFormativoSeparadoNoBoletim = false`)

---

**Filtro deve exibir apenas os escopos "Boletim Regular", "Boletim Diversificado" e "Outras avaliações".**

✅ `AtualizarEscopos()` em [Listagem.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Listagem.js) constrói o dropdown com base em `agrupamento.CiclosItinerarioFormativoExistentes`. Como os escopos CF só são inseridos quando o array de ciclos é não-vazio E `PossuiItinerarioFormativoSeparadoNoBoletim = true`, um agrupamento sem CF exibe apenas os 3 escopos fixos.

---

**Ao selecionar "Boletim Regular" devem ser exibidas todas as disciplinas que tenham "Possui avaliações regulares" selecionado no Configurador de Disciplinas. Isso inclui disciplinas que façam parte de Componentes Formativos, mesmo que não sejam anuais.**

✅ Comportamento pré-existente não alterado. Quando `PossuiItinerarioFormativoSeparadoNoBoletim = false`, nenhuma `EstruturaAvaliacao` CF existe para este agrupamento; `estruturasCFIds` fica vazio e o filtro `!estruturasCFIds.Contains(x.IdEstrutura)` tem efeito nulo. Disciplinas que participam de Itinerários Formativos mas também existem no currículo regular continuam aparecendo normalmente via `RedeSerieDisciplina`.

---

**Ao selecionar "Boletim Diversificado"**, disciplinas com "Possui avaliações diversificadas". **Ao selecionar "Outras avaliações"**, disciplinas com "Possui avaliações regulares".

✅ Comportamento pré-existente não alterado. Esses escopos não têm branch CF no código; os filtros de etapa (`Diversificada`, `Simulados`) continuam funcionando como antes.

---

**Para "Boletim Regular", as colunas automáticas de Total/Média/Falta e Situação devem ser exibidas, conforme configuração do agrupamento.**

✅ Comportamento pré-existente. Colunas automáticas são `EstruturaAvaliacao` com `ItinerarioFormativoCiclo = null` e flags de `TipoAvaliacao` — estão dentro do filtro regular.

---

### Sub-caso: agrupamento que anteriormente tinha CF ativo e foi revertido para não separar

---

**Colunas diferentes que tenham sido configuradas nesses escopos não devem ser exibidas na visão de boletim regular, mesmo que as disciplinas agora sejam.**

✅ Fix B1 ([FiltroManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs)): o branch `else` de `GetAvaliacoes` exclui todas as `IdEstrutura` CF via `!estruturasCFIds.Contains(x.IdEstrutura)`. Mesmo que a flag tenha voltado para `false`, as estruturas CF continuam no banco com `ItinerarioFormativoCiclo != null` e são excluídas.

---

**Se colunas iguais (mesmo Tipo + Ciclo) tenham sido configuradas nesses escopos e recebido avaliações diferentes, essas avaliações devem ser exibidas na visão de boletim regular, na coluna correspondente.**

❌ **Não implementado.** Avaliações (`Avaliacao`) são vinculadas à `EstruturaAvaliacao.Id`. Uma coluna CF e uma coluna regular são registros distintos — mesmo com mesma combinação de `TipoAvaliacao + Ciclo`, as avaliações de uma não aparecem na outra. Implementar este requisito exigiria lógica de merge ou de reutilização de `EstruturaAvaliacao` entre escopos, o que está fora do escopo deste card.

> **Ação necessária:** alinhar com o tech lead se este ponto é um requisito obrigatório deste card ou de uma atividade futura.

---

**Ao selecionar incluir uma nova coluna, a lista de tipos/etapas/ciclos deve incluir qualquer opção criada durante o uso do escopo CF.**

✅ `GetTiposAvaliacao` em [BuscaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs) não filtra por escopo — retorna todos os `TipoAvaliacao` não-automáticos da rede/ano letivo. Tipos criados enquanto o CF estava ativo continuam disponíveis.

---

**Ao selecionar incluir uma nova coluna com combinação que já existiu para o escopo CF, o sistema deve permitir incluí-la para Boletim Regular sem tratar como coluna repetida.**

✅ Fix B4/Tarefa 3 em [EdicaoEstruturaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/EdicaoEstruturaManager.cs): `ConfiguracaoJaExiste` agora segmenta a verificação de duplicidade por `ItinerarioFormativoCiclo`. Uma coluna CF e uma regular com mesmo Tipo+Ciclo não se bloqueiam mutuamente.

---

**A opção de ordenação deve listar apenas as colunas atualmente configuradas para o escopo boletim regular.**

✅ `GetOrdenacao()` em [Estrutura.Inclusao.js](../Eleva.Portal.Web/app/viewmodels/Configuradores/Avaliacoes/Estrutura/Estrutura.Inclusao.js) usa `estruturasRelacionadas`, que vem de `GetEstruturasRelacionadasComAtual`. Este método filtra `ItinerarioFormativoCiclo == null` para escopo não-CF — retorna apenas colunas regulares.

---

**Não deve ser possível incluir 2 colunas com a mesma configuração de Etapa + Tipo + Ciclo para o mesmo escopo.**

✅ Fix B4/Tarefa 3 — `ConfiguracaoJaExiste` garante unicidade por escopo (CF ou regular separadamente).

---

**Ao selecionar incluir ou editar uma avaliação, apenas as disciplinas exibidas no grid devem estar disponíveis para seleção.**

✅ `GetDisciplinas` em [BuscaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs) retorna disciplinas do `RedeSerieDisciplina` para escopo regular (comportamento pré-existente).

---

**Ao selecionar "Edição em massa", "Copiar coluna" ou "Criar avaliação padrão", apenas as disciplinas/avaliações que aparecem no grid devem ser exibidas.**

✅ Validado na Tarefa 2 — os três fluxos estão corretamente escopados (ver [EFC-5976_tarefas_changelog.md](EFC-5976_tarefas_changelog.md)).

---

**Ao selecionar "Exportar", as avaliações e disciplinas retornadas devem corresponder ao que aparece no grid.**

❌ **Pendente — atividade futura explícita.** Consta ao final do documento do tech lead: *"A opção de exportar precisa ser adaptada em uma outra atividade futura."*

---

## Bloco 2 — Agrupamento CONFIGURADO para exibir CF separadamente (`PossuiItinerarioFormativoSeparadoNoBoletim = true`)

---

**Filtro deve exibir "Boletim Regular", "Boletim Diversificado", "Outras avaliações" e todos os ciclos CF que tenham algum Componente Formativo configurado para o agrupamento.**

✅ `GetAgrupamentos` popula `CiclosItinerarioFormativoExistentes` com os IDs de ciclo presentes no `ItinerarioFormativoRedeSerie` ativo (com `ItinerarioFormativo.Ativo = true`, fix B5). `AtualizarEscopos()` cria uma opção no dropdown por ciclo presente.

---

**Ao selecionar "Boletim Regular" devem ser exibidas todas as disciplinas com "Possui avaliações regulares" que NÃO façam parte de um Componente Formativo.**

✅ Fix B1 ([FiltroManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/FiltroManager.cs)): `GetAvaliacoes` exclui `IdEstrutura` CF do scope regular, deixando apenas estruturas com `ItinerarioFormativoCiclo = null`.

---

**Ao selecionar "Boletim Diversificado" devem ser exibidas todas as disciplinas com "Possui avaliações diversificadas", incluindo as que façam parte de Componentes Formativos.**

✅ O filtro de exclusão de CF em `GetAvaliacoes` afeta apenas as `EstruturaAvaliacao` (colunas), não as disciplinas diretamente. Disciplinas de IF que também existem no `RedeSerieDisciplina` com `Diversificada = true` continuam sendo retornadas pelas colunas diversificadas. As `EstruturaAvaliacao` CF são excluídas, mas colunas diversificadas regulares permanecem — e suas linhas de view incluem disciplinas CF que possuam flag diversificada no currículo.

---

**Ao selecionar "Outras avaliações" devem ser exibidas todas as disciplinas com "Possui avaliações regulares", incluindo as de Componentes Formativos.**

✅ Mesmo raciocínio do Boletim Diversificado: o filtro de exclusão afeta estruturas, não disciplinas. CF disciplines that have `Simulados = false` in `RedeSerieDisciplina` aparecem nas colunas de "Outras avaliações".

---

**Ao selecionar "Componentes Formativos Anuais/Semestrais/Trimestrais/Bimestrais" devem ser exibidas todas as disciplinas com "Possui avaliações regulares" que façam parte do respectivo Componente Formativo.**

✅ Fix B2 + Tarefa 6 (cross-join IFRSD em memória): `GetDisciplinas` usa o branch CF que consulta `ItinerarioFormativoRedeSerieDisciplina`. `GetAvaliacoes` filtra por `estruturasCFIds` do ciclo correspondente e expande disciplinas a partir do IFRSD.

---

**Apenas as colunas correspondentes ao escopo devem ser exibidas. Para "Boletim Regular" e qualquer escopo CF, isso inclui as colunas automáticas de Total/Média/Falta e Situação.**

- Para Boletim Regular: ✅ comportamento pré-existente.
- Para escopos CF: ✅ **implementado na Tarefa 4** — `GetEstrutura` e `GetAvaliacoes` agora incluem colunas automáticas (`TipoAvaliacao.FaltaEtapa || Total || Media || Situacao`, `ItinerarioFormativoCiclo = null`, etapa de boletim regular) nos escopos CF.

---

### Sub-caso: agrupamento que anteriormente estava sem separação CF e depois foi habilitado

---

**Caso uma coluna correspondente (mesmo Tipo + Etapa + Ciclo) seja criada no escopo CF, qualquer avaliação que já existisse para as disciplinas do escopo deve ser exibida.**

⚠️ **A validar.** O cenário descrito pressupõe que a `Avaliacao` criada no modo regular seja reutilizada ou visível no modo CF. Como `Avaliacao` é vinculada a `EstruturaAvaliacao.Id` (e as estruturas CF são novos registros), as avaliações da coluna regular não aparecem automaticamente na coluna CF correspondente. Pode ser que o tech lead esteja descrevendo um comportamento esperado que ainda não existe — confirmar com ele.

---

**As opções de Tipo, Etapa e Ciclo disponíveis para criação de nova coluna devem ser as mesmas existentes para Boletim Regular e qualquer escopo CF — é a mesma lista.**

✅ `GetTiposAvaliacao` em [BuscaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs) não distingue escopo — a lista é global para rede/ano letivo.

---

**Não deve ser possível incluir 2 colunas com a mesma Etapa + Tipo + Ciclo para o mesmo escopo, mas é possível incluir a mesma configuração que já exista em outro escopo.**

✅ Fix B4/Tarefa 3 — `ConfiguracaoJaExiste` diferencia CF de regular. Permite criação de coluna CF com mesma combinação que uma regular já existente (e vice-versa).

---

**A opção de ordenação deve listar apenas as colunas atualmente configuradas para o escopo selecionado.**

✅ `GetEstruturasRelacionadasComAtual` em [BuscaManager.cs](../Eleva.Portal/ConfiguradorAvaliacao/Services/BuscaManager.cs) possui branch CF que filtra por `ItinerarioFormativoCiclo.Id == idCicloIF`. O `dados()` enviado pelo frontend inclui `escopoAvaliacoes` (fix de `e130f72`), portanto a ordenação é escopada corretamente.

---

**Ao selecionar incluir ou editar uma avaliação, apenas as disciplinas exibidas no grid devem estar disponíveis para seleção.**

✅ `GetDisciplinas` branch CF retorna disciplinas do IFRSD do ciclo selecionado.

---

**Ao selecionar "Edição em massa", "Copiar coluna" ou "Criar avaliação padrão", apenas as disciplinas/avaliações do grid devem ser exibidas.**

✅ Validado na Tarefa 2 — todos os três fluxos funcionam corretamente para escopos CF.

---

**Ao selecionar "Exportar", as avaliações e disciplinas retornadas devem corresponder ao que aparece no grid.**

❌ **Pendente — atividade futura explícita.**

---

## Resumo

| Ponto | Status |
|---|---|
| Dropdown de escopos dinâmico por agrupamento | ✅ |
| Boletim Regular exclui disciplinas/colunas CF | ✅ |
| Boletim Regular inclui colunas automáticas | ✅ |
| Escopos CF mostram disciplinas do IFRSD do ciclo | ✅ |
| Escopos CF incluem colunas automáticas | ✅ (Tarefa 4) |
| Colunas automáticas no Boletim Regular (flag=false) | ✅ |
| Bloquear filtro CF em agrupamento não configurado | ✅ (Tarefa 1) |
| `ConfiguracaoJaExiste` distingue CF de regular | ✅ (Tarefa 3/B4) |
| Ordenação de nova coluna escopada corretamente | ✅ |
| Tipos de avaliação: mesma lista em todos escopos | ✅ |
| Edição em massa / Copiar / Criar padrão escopados | ✅ (Tarefa 2) |
| Boletim Diversificado / Outras avaliacoes: disciplinas CF via RegularSD | ✅ |
| Dropdown CF não exibe IFs inativos | ✅ (B5) |
| Grid CF não vazio (cross-join IFRSD) | ✅ (B6/Tarefa 6) |
| Avaliações de coluna regular aparecem em coluna CF correspondente (retorno do modo não-separado) | ❌ a alinhar |
| Exportar adaptado para escopo CF | ❌ atividade futura |
