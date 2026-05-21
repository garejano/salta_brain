Novas tarefas do card EFC-5976.
Tudo analisado e executado deve ser documentado no changelog em @_EFC-5976/EFC-5976_tarefas_changelog.md

---

## Tarefa 1 — Botão "Filtrar" não validava escopo CF em agrupamento não configurado ✅

**Problema:** Ao filtrar uma Rede com "Exibir Componentes Formativos separadamente no boletim" = false, selecionar um escopo CF exibia a mensagem de erro (`msg_componente_nao_configurado`), mas o botão "Filtrar" permanecia ativo e permitia filtrar normalmente.

**Mensagem:** "O agrupamento não está configurado para exibir Componentes Formativos separadamente no boletim. Configure-o antes de prosseguir."

**Solução implementada:** Ao clicar em "Filtrar" nesse cenário, exibir a mesma mensagem e bloquear a filtragem.

---

## Tarefa 2 — Validar fluxos de operações em massa para escopos CF ✅

**Objetivo:** Validar se "Edição em Massa", "Criar Avaliação Padrão" e "Copiar de Outra Coluna" filtram corretamente pelos escopos de Componente Formativo.

**Resultado:** Todos os três fluxos estão corretos — nenhum ajuste necessário.

---

## Tarefa 3 — Criação de coluna duplicada dentro do mesmo escopo ✅

**Objetivo:** Garantir que não seja possível criar uma coluna com a mesma configuração (Etapa + Tipo + Ciclo) no mesmo escopo.

**Resultado:** Controle de duplicidade (`ConfiguracaoJaExiste`) existia e já foi corrigido para tratar escopo CF separadamente do regular — nenhum ajuste adicional necessário.

---

## Tarefa 4 — Colunas automáticas não apareciam nos escopos CF ✅

**Problema:** As colunas automáticas (aquelas com `TipoAvaliacao.Total`, `TipoAvaliacao.Media`, `TipoAvaliacao.FaltaEtapa` ou `TipoAvaliacao.Situacao = true`) não eram exibidas ao filtrar por um escopo de Componente Formativo.

**Solução implementada:** `GetEstrutura` e `GetAvaliacoes` foram ajustados para incluir colunas automáticas nos escopos CF, com deduplicação correta no expand loop de disciplinas.

---

## Tarefa 5 — Nova etapa criada pela sub-modal não aparecia no select de Etapa ✅

**Problema:** Na modal "Nova Configuração" (criar coluna), o campo "Etapa" possui um botão "+ Incluir" que abre a modal "Nova Etapa". Após criar a etapa e fechar a sub-modal, a nova etapa não aparecia no select de Etapa da modal principal.

**Solução implementada:** `ColetarIdsParaEtapa` em `EdicaoEstruturaManager.cs` não considerava escopos CF ao calcular as flags da etapa — salvava `Boletim = false` quando o escopo era CF. Como `GetEtapas` para CF filtra `Boletim == true`, a nova etapa nunca era retornada. Corrigido adicionando `|| EhEscopoCF()` na atribuição de `EtapaDeBoletim`.




## Tarefa 6 — Boletim Regular exibia disciplinas de CF quando o agrupamento tem CF habilitado ✅

**Problema (QA):** Com `PossuiItinerarioFormativoSeparadoNoBoletim = true`, ao selecionar "Boletim Regular", disciplinas que fazem parte de um Componente Formativo continuavam aparecendo — violando a regra: "apenas disciplinas que não façam parte de um CF devem ser exibidas no Boletim Regular".

**Solução implementada:** `GetAvaliacoes` (branch regular) já excluía as colunas CF, mas não excluía as disciplinas CF das colunas regulares. Quando a mesma disciplina existe em `RedeSerieDisciplina` (currículo regular) e em `ItinerarioFormativoRedeSerieDisciplina` (CF), ela ainda aparecia nas colunas regulares. Corrigido buscando os hashes das disciplinas CF do IFRSD (apenas de IFs ativos) e filtrando-as da queryable quando `EscopoAvaliacoes == Boletim_Regular && PossuiItinerarioFormativoSeparadoNoBoletim`.



## Tarefa 7 — Frentes de disciplinas CF apareciam no select de disciplinas do Boletim Regular ✅

**Problema (QA):** Com `Rede: Nosso CEI / Ano: 2026 / Agrupamento: 1ª série do EM / Escopo: Boletim Regular`, a disciplina "Academic English 1" aparecia na lista. O QA identificou que ela está vinculada a um Componente Formativo.

**Diagnóstico no banco:** "Academic English 1" (Id 9218) é frente da disciplina mãe "Academic English" (Id 9217). A mãe (9217) está em `ItinerarioFormativoRedeSerieDisciplina` (CF) E em `RedeSerieDisciplina` (regular). A `ViewConfiguradorAvaliacaoDisciplina` expande automaticamente a mãe para suas frentes via join por `DisciplinaMae` — por isso 9218 aparece na view com `PossuiAvaliacoesRegulares = true`.

**Solução implementada:** `GetDisciplinas` em `BuscaManager.cs` não tinha filtro CF. Corrigido: quando `Boletim_Regular && PossuiItinerarioFormativoSeparadoNoBoletim = true`, busca IDs das mães CF via IFRSD, expande para todas as frentes via `DisciplinaRepository.GetPorDisciplinaMae(List<int>)`, e exclui todos esses hashes do queryable.


Tarefa 8


A ViewConfiguradorAvaliacao vai passar a ter colunas novas :
EtapaDeComponenteAnual
EtapaDeComponenteSemestral
EtapaDeComponenteTrimestral
EtapaDeComponenteBimestral

Isso para facilitar a montagem das disciplinas conforme o filtro de Escopo, 
planeje em EFC-5976-T8.md como aplicar essas mudancas para simplificar o processo, o plano deve
ser apenas para o metodo GetAvaliacoes do BuscaManager