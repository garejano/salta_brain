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
