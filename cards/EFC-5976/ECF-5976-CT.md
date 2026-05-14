# ECF-5976-CT — Cenários de Teste: Configurador de Avaliações com Escopos de Componente Formativo

---

## Pré-condições Gerais

Antes de executar qualquer cenário abaixo, verifique:

1. **Migração de banco aplicada** — coluna `EstruturaAvaliacao.ItinerarioFormativoCiclo` (INT NULL, FK → `ItinerarioFormativoCiclo.Id`) existe.
2. **Tabela `ItinerarioFormativoCiclo`** contém os IDs utilizados:
   | Id | Nome |
   |----|------|
   | 1  | Anual |
   | 2  | Semestral |
   | 4  | Trimestral |
   | 5  | Bimestral |
3. **Rede/Ano Letivo/Agrupamento** de teste configurados no ambiente.
4. Usuário logado com acesso ao **Configurador de Avaliações**.

---

## CT-01 — Escopos regulares não são afetados (regressão)

**Objetivo:** Garantir que as alterações não quebram o comportamento dos escopos 1–3 existentes.

**Pré-condições:**
- Agrupamento sem `PossuiItinerarioFormativoSeparadoNoBoletim` marcado.
- Estruturas de avaliação existentes para Boletim Regular, Boletim Diversificado e Outras Avaliações.

**Passos:**
1. Abrir o Configurador de Avaliações.
2. Selecionar Rede, Ano Letivo e o Agrupamento acima.
3. Observar o dropdown de Escopo.

**Resultado Esperado:**
- Dropdown exibe apenas as 3 opções: `Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`.
- Nenhuma opção de Componente Formativo aparece.
- Selecionar `Boletim Regular` → grid carrega normalmente, mostrando somente colunas com `ItinerarioFormativoCiclo IS NULL`.
- Selecionar `Boletim Diversificado` → grid carrega normalmente.
- Selecionar `Outras avaliações` → grid carrega normalmente.

---

## CT-02 — Opções de CF aparecem quando `ItinerarioFormativo.Ciclo` está configurado

**Objetivo:** Validar que as opções de escopo CF surgem no dropdown ao selecionar um agrupamento com IF configurados.

**Pré-condições:**
- Existem registros `ItinerarioFormativoRedeSerie` com `ItinerarioFormativo.ItinerarioFormativoCicloId` preenchido (ex.: Id = 2 — Semestral) vinculados à Rede/Ano Letivo/Agrupamento de teste.
- `PossuiItinerarioFormativoSeparadoNoBoletim` pode estar `true` ou `false` — o aparecimento no dropdown depende apenas dos ciclos existentes.

**Passos:**
1. Abrir o Configurador de Avaliações.
2. Selecionar Rede e Ano Letivo.
3. Selecionar o Agrupamento configurado com IF Semestral.

**Resultado Esperado:**
- Dropdown de Escopo exibe as 3 opções base **mais** a opção `Componente Formativo — Semestral` (e somente ela, pois só o ciclo 2 existe).
- Opções de outros ciclos CF (Anual, Trimestral, Bimestral) **não** aparecem.

---

## CT-03 — Opções CF não aparecem quando não há IF com Ciclo configurado

**Objetivo:** Validar ausência de opções CF quando o agrupamento não tem IFs com ciclo definido.

**Pré-condições:**
- Agrupamento de teste possui registros `ItinerarioFormativoRedeSerie`, mas `ItinerarioFormativo.ItinerarioFormativoCicloId` é NULL em todos.

**Passos:**
1. Abrir o Configurador de Avaliações.
2. Selecionar Rede, Ano Letivo e o Agrupamento acima.

**Resultado Esperado:**
- Dropdown exibe apenas `Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`.
- Nenhuma opção de Componente Formativo aparece.

---

## CT-04 — Selecionar escopo CF quando `PossuiItinerarioFormativoSeparadoNoBoletim = false` exibe alerta

**Objetivo:** Garantir que o sistema avisa o usuário e bloqueia a seleção quando o agrupamento não está configurado para separar CF no boletim.

**Pré-condições:**
- Agrupamento com `PossuiItinerarioFormativoSeparadoNoBoletim = false`.
- IF com ciclo existente para o agrupamento (para que a opção apareça no dropdown — CT-02).

**Passos:**
1. Selecionar o Agrupamento acima.
2. No dropdown de Escopo, selecionar qualquer opção `Componente Formativo — *`.

**Resultado Esperado:**
- Modal/alerta exibe a mensagem: *"O agrupamento não está configurado para exibir Componentes Formativos separadamente no boletim. Configure-o antes de prosseguir."*
- O dropdown de Escopo retorna para o valor vazio/nenhum (`null`).
- O grid **não** é carregado.

---

## CT-05 — Escopo CF carrega somente estruturas com `ItinerarioFormativoCiclo` correspondente

**Objetivo:** Validar que `GetEstrutura` retorna somente colunas do ciclo selecionado.

**Pré-condições:**
- `PossuiItinerarioFormativoSeparadoNoBoletim = true` no agrupamento.
- `EstruturaAvaliacao` com `ItinerarioFormativoCicloId = 2` (Semestral) existente.
- `EstruturaAvaliacao` com `ItinerarioFormativoCicloId = NULL` (regular) também existente.
- `EstruturaAvaliacao` com `ItinerarioFormativoCicloId = 1` (Anual) existente (para testar isolamento entre ciclos).

**Passos:**
1. Selecionar Rede, Ano Letivo e o Agrupamento.
2. Selecionar Escopo `Componente Formativo — Semestral`.
3. Observar o grid carregado.

**Resultado Esperado:**
- Grid exibe **apenas** as colunas (etapas) cujas `EstruturaAvaliacao` têm `ItinerarioFormativoCicloId = 2`.
- Colunas regulares (NULL) e de outros ciclos (1, 4, 5) **não** aparecem no grid.

---

## CT-06 — Escopo CF filtra somente disciplinas CF do ciclo selecionado

**Objetivo:** Garantir que o filtro de Disciplinas/Componentes exibe apenas disciplinas vinculadas ao IF do ciclo selecionado.

**Pré-condições:**
- IF com ciclo 2 (Semestral) vinculado a disciplinas D1 e D2.
- IF com ciclo 1 (Anual) vinculado a disciplina D3.
- Disciplina D4 regular (sem vínculo com IF).

**Passos:**
1. Selecionar Escopo `Componente Formativo — Semestral`.
2. Abrir o filtro de Disciplinas.

**Resultado Esperado:**
- Lista exibe D1 e D2.
- D3 e D4 **não** aparecem.

---

## CT-07 — Escopo CF sem estrutura configurada exibe mensagem de escopo vazio

**Objetivo:** Validar comportamento quando o escopo CF existe (opção no dropdown) mas não há `EstruturaAvaliacao` configurada para ele.

**Pré-condições:**
- IF com ciclo 4 (Trimestral) vinculado ao agrupamento, mas **sem** `EstruturaAvaliacao` com `ItinerarioFormativoCicloId = 4`.
- `PossuiItinerarioFormativoSeparadoNoBoletim = true`.

**Passos:**
1. Selecionar Escopo `Componente Formativo — Trimestral`.

**Resultado Esperado:**
- `GetEstrutura` retorna estrutura vazia.
- `TipoLinkEscopoVazio = 'disciplinas'` (ou `'componentes'`, conforme implementação).
- Mensagem de escopo vazio é exibida com link correto para criação de estrutura.

---

## CT-08 — Trocar agrupamento reseta a seleção de escopo

**Objetivo:** Garantir que a seleção de escopo é limpa ao mudar de agrupamento, evitando estado inconsistente.

**Pré-condições:**
- Agrupamento A com escopo `Componente Formativo — Semestral` selecionado.
- Agrupamento B sem IF configurados.

**Passos:**
1. Selecionar Agrupamento A e escopo `Componente Formativo — Semestral`.
2. Trocar para Agrupamento B.

**Resultado Esperado:**
- Dropdown de Escopo retorna para estado não selecionado (`null`).
- Grid é ocultado/bloqueado.
- Dropdown de Escopo de Agrupamento B exibe apenas os 3 escopos base.

---

## CT-09 — Label no Configurador de Agrupamento exibe texto correto

**Objetivo:** Verificar que o label do campo `PossuiItinerarioFormativoSeparadoNoBoletim` foi atualizado.

**Passos:**
1. Acessar **Configuradores → Agrupamento → Editar** (qualquer agrupamento).
2. Localizar o campo que controla a flag CF.

**Resultado Esperado:**
- Label exibe: `Exibir Componentes Formativos separadamente no boletim:`
- (Não mais: `Itinerários são semestrais:`)

---

## CT-10 — Escopo regular não exibe colunas de CF (isolamento)

**Objetivo:** Garantir que ao selecionar escopo regular, nenhuma coluna de CF "vaza" para o grid.

**Pré-condições:**
- `EstruturaAvaliacao` com `ItinerarioFormativoCicloId = 2` existente para o agrupamento.
- `EstruturaAvaliacao` regular (`ItinerarioFormativoCicloId NULL`) existente.

**Passos:**
1. Selecionar Escopo `Boletim Regular`.
2. Observar o grid.

**Resultado Esperado:**
- Grid exibe somente colunas regulares (`ItinerarioFormativoCicloId IS NULL`).
- Nenhuma coluna de ciclo CF aparece.

---

## CT-11 — Múltiplos ciclos CF presentes — apenas os existentes aparecem

**Objetivo:** Validar que o dropdown reflete exatamente os ciclos disponíveis no agrupamento.

**Pré-condições:**
- IF com ciclo 1 (Anual) e ciclo 5 (Bimestral) vinculados ao agrupamento.
- Ciclos 2 (Semestral) e 4 (Trimestral) **não** vinculados.

**Passos:**
1. Selecionar o Agrupamento acima.

**Resultado Esperado:**
- Dropdown exibe: `Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`, `Componente Formativo — Anual`, `Componente Formativo — Bimestral`.
- `Componente Formativo — Semestral` e `Componente Formativo — Trimestral` **não** aparecem.

---

## CT-12 — Escolas filtradas corretamente para escopo CF

**Objetivo:** Verificar que o filtro de Escolas, quando em escopo CF, retorna apenas escolas com avaliações CF do ciclo selecionado.

**Pré-condições:**
- Escola E1 possui avaliações com disciplinas do IF Semestral (ciclo 2).
- Escola E2 possui apenas avaliações regulares.

**Passos:**
1. Selecionar Escopo `Componente Formativo — Semestral`.
2. Abrir filtro de Escolas.

**Resultado Esperado:**
- Somente E1 aparece na lista de escolas.
- E2 não aparece.

---

## Mapeamento de `EscopoEnum` × `ItinerarioFormativoCiclo.Id`

| Hash Frontend | EscopoEnum | IdCiclo DB | Descrição |
|:---:|:---:|:---:|---|
| 1 | Boletim_Regular | — | Boletim Regular |
| 2 | Boletim_Diversificado | — | Boletim Diversificado |
| 3 | Outros_Simulados | — | Outras avaliações |
| 4 | CF_Anual | 1 | Componente Formativo — Anual |
| 5 | CF_Semestral | 2 | Componente Formativo — Semestral |
| 6 | CF_Trimestral | 4 | Componente Formativo — Trimestral |
| 7 | CF_Bimestral | 5 | Componente Formativo — Bimestral |

> **Atenção:** O ID 3 da tabela `ItinerarioFormativoCiclo` foi removido do banco. Os hashes 6 e 7 mapeiam para IDs de DB 4 e 5 respectivamente — não confundir hash de frontend com ID de banco.
