# EFC-5976_QA — Guia de Testes: Escopos de Componente Formativo no Configurador de Avaliações

> **Destinatário:** DEV/QA sem conhecimento prévio do fluxo  
> **Ambiente:** Homologação (ElevaPortalHomolog)  
> **Data de referência dos dados:** 2026-04-20

---

## 1. O que foi alterado (resumo para o QA)

O **Configurador de Avaliações** é a tela onde gestores configuram as colunas (etapas) e linhas (disciplinas/avaliações) que aparecem no boletim. Antes desta entrega, existiam apenas 3 tipos de boletim configuráveis:

| # | Tipo |
|---|------|
| 1 | Boletim Regular |
| 2 | Boletim Diversificado |
| 3 | Outras avaliações |

Com o **Novo Ensino Médio**, as escolas passaram a ter **Itinerários Formativos (IF)** — disciplinas optativas com ciclos distintos (Anual, Semestral, Trimestral, Bimestral). Esta entrega adiciona 4 novos tipos de escopo ao configurador:

| # | Tipo | Ciclo IF no banco |
|---|------|-------------------|
| 4 | Componente Formativo — Anual | Id = 1 |
| 5 | Componente Formativo — Semestral | Id = 2 |
| 6 | Componente Formativo — Trimestral | Id = 4 |
| 7 | Componente Formativo — Bimestral | Id = 5 |

> **Por que os IDs não são sequenciais?** O registro Id=3 foi excluído do banco no passado. Não há bug — é o estado real.

### Como acessar o Configurador de Avaliações

`Menu lateral → Configuradores → Avaliações`

---

## 2. Pré-condições gerais

Antes de qualquer teste, confirme:

1. A coluna `ItinerarioFormativoCiclo` existe na tabela `EstruturaAvaliacao` (migração aplicada):

```sql
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME   = 'EstruturaAvaliacao'
  AND COLUMN_NAME  = 'ItinerarioFormativoCiclo';
-- Esperado: 1 linha retornada, IS_NULLABLE = 'YES'
```

2. A tabela `ItinerarioFormativoCiclo` contém os 4 ciclos:

```sql
SELECT Id, Nome, Anual, Ordem
FROM ItinerarioFormativoCiclo
ORDER BY Ordem;
-- Esperado: Id=1 Anual | Id=2 Semestral | Id=4 Trimestral | Id=5 Bimestral
```

---

## 3. Dados reais de homologação (mapeamento de cenários)

A tabela abaixo lista os dados reais encontrados no banco e qual cenário de teste cada um suporta.

| Rede | Agrupamento | Ano | Flag Separado | Ciclos CF disponíveis | Usada em |
|------|-------------|-----|:---:|---|---|
| Ábaco | 1ª série do EM | 2026 | ✅ true | Anual, Semestral, Trimestral, Bimestral | CT-02, CT-07, CT-08, CT-10 |
| Ábaco | 2ª série do EM | 2026 | ✅ true | Semestral | CT-11 |
| Alfa | 1ª série do EM | 2026 | ❌ false | Anual, Semestral, Trimestral, Bimestral | CT-04 |
| Ábaco | 1º ano do EFAI | 2026 | ❌ false | nenhum | CT-01, CT-03 |

> **Importante:** Nenhuma `EstruturaAvaliacao` foi configurada ainda com `ItinerarioFormativoCiclo` preenchido em homolog. Isso significa que os cenários CT-05, CT-06 e CT-12 **não têm dados para validação ainda** — eles precisam de setup manual descrito em cada caso de teste.

---

## 4. Cenários de Teste

---

### CT-01 — Escopos regulares continuam funcionando (regressão)

**Objetivo:** Garantir que o comportamento dos 3 escopos existentes não foi quebrado.

**Dados de teste:**
- Rede: `Ábaco`
- Agrupamento: `1º ano do EFAI`
- Ano Letivo: `2026`

**Verificação de pré-condição (executar antes do teste):**
```sql
SELECT eac.PossuiItinerarioFormativo, eac.PossuiItinerarioFormativoSeparadoNoBoletim
FROM EstruturaAvaliacaoConfiguracao eac
INNER JOIN Agrupamento a ON a.Id = eac.Agrupamento
INNER JOIN Rede r ON r.Id = eac.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1º ano do EFAI'
  AND eac.AnoLetivo = 2026
  AND eac.Ativo = 1;
-- Esperado: PossuiItinerarioFormativo = 0, PossuiItinerarioFormativoSeparadoNoBoletim = 0
```

**Passos:**
1. Acessar o Configurador de Avaliações.
2. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1º ano do EFAI`.
3. Observar o dropdown de Escopo.
4. Selecionar `Boletim Regular` e observar o grid.
5. Repetir para `Boletim Diversificado` e `Outras avaliações`.

**Resultado esperado:**
- Dropdown exibe exatamente 3 opções: `Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`.
- Nenhuma opção de "Componente Formativo" aparece.
- Grid de `Boletim Regular` carrega com as etapas configuradas (ex.: 1º Trimestre, 2º Trimestre, 3º Trimestre).
- Nenhum erro no console do navegador.

**Query de validação pós-teste (confirmar que grid está usando dados corretos):**
```sql
SELECT e.Nome AS Etapa, ea.Editavel, ea.ItinerarioFormativoCiclo
FROM EstruturaAvaliacao ea
INNER JOIN Ciclo c ON c.Id = ea.Ciclo
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN Agrupamento a ON a.Id = ea.Agrupamento
INNER JOIN Rede r ON r.Id = ea.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1º ano do EFAI'
  AND ea.AnoLetivo = 2026
  AND ea.Ativo = 1
  AND e.Boletim = 1
  AND e.Diversificada = 0
  AND e.Simulados = 0;
-- Esperado: todas as linhas com ItinerarioFormativoCiclo = NULL
```

---

### CT-02 — Opções de CF aparecem no dropdown quando há itinerários com ciclo configurado

**Objetivo:** Validar que as opções de escopo CF surgem corretamente, de acordo com os ciclos existentes.

**Dados de teste:**
- Rede: `Ábaco`
- Agrupamento: `1ª série do EM`
- Ano Letivo: `2026`

**Verificação de pré-condição:**
```sql
SELECT ifc.Id AS IdCiclo, ifc.Nome AS NomeCiclo, COUNT(DISTINCT ifrs.Id) AS QtdItinerarios
FROM ItinerarioFormativoRedeSerie ifrs
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND rs.AnoLetivo = 2026
  AND ifrs.Ativo = 1
GROUP BY ifc.Id, ifc.Nome
ORDER BY ifc.Id;
-- Esperado: 4 linhas — IdCiclo 1 (Anual/2), IdCiclo 2 (Semestral/34), IdCiclo 4 (Trimestral/3), IdCiclo 5 (Bimestral/3)
```

**Passos:**
1. Acessar o Configurador de Avaliações.
2. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1ª série do EM`.
3. Observar o dropdown de Escopo.

**Resultado esperado:**
- Dropdown exibe **7 opções** nesta ordem:
  1. Boletim Regular
  2. Boletim Diversificado
  3. Outras avaliações
  4. Componente Formativo — Anual
  5. Componente Formativo — Semestral
  6. Componente Formativo — Trimestral
  7. Componente Formativo — Bimestral

---

### CT-03 — Opções CF não aparecem quando não há itinerários com ciclo configurado

**Objetivo:** Verificar que agrupamentos sem IF com ciclo não exibem opções CF.

**Dados de teste:**
- Rede: `Ábaco`
- Agrupamento: `1º ano do EFAI`
- Ano Letivo: `2026`

**Verificação de pré-condição:**
```sql
SELECT COUNT(*) AS QtdItinerariosComCiclo
FROM ItinerarioFormativoRedeSerie ifrs
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1º ano do EFAI'
  AND rs.AnoLetivo = 2026
  AND ifrs.Ativo = 1
  AND iff.ItinerarioFormativoCiclo IS NOT NULL;
-- Esperado: 0
```

**Passos:**
1. Acessar o Configurador de Avaliações.
2. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1º ano do EFAI`.
3. Observar o dropdown de Escopo.

**Resultado esperado:**
- Dropdown exibe exatamente 3 opções: `Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`.
- Nenhuma opção de "Componente Formativo" aparece.

---

### CT-04 — Alerta ao selecionar escopo CF em agrupamento não configurado para separar CF no boletim

**Objetivo:** Quando o agrupamento tem IFs com ciclo (opções aparecem no dropdown) mas a flag "Exibir Componentes Formativos separadamente no boletim" está desativada, selecionar um escopo CF deve exibir um alerta e cancelar a seleção.

**Dados de teste:**
- Rede: `Alfa`
- Agrupamento: `1ª série do EM`
- Ano Letivo: `2026`

**Verificação de pré-condição:**
```sql
SELECT eac.PossuiItinerarioFormativo,
       eac.PossuiItinerarioFormativoSeparadoNoBoletim,
       ifc.Nome AS CiclosDisponiveis,
       COUNT(DISTINCT ifrs.Id) AS QtdItinerarios
FROM EstruturaAvaliacaoConfiguracao eac
INNER JOIN Agrupamento a ON a.Id = eac.Agrupamento
INNER JOIN Rede r ON r.Id = eac.Rede
INNER JOIN RedeSerie rs ON rs.Agrupamento = eac.Agrupamento
                        AND rs.AnoLetivo = eac.AnoLetivo
                        AND rs.Rede = eac.Rede
                        AND rs.Ativo = 1
INNER JOIN ItinerarioFormativoRedeSerie ifrs ON ifrs.RedeSerie = rs.Id AND ifrs.Ativo = 1
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
WHERE r.Nome = 'Alfa'
  AND a.Nome = '1ª série do EM'
  AND eac.AnoLetivo = 2026
  AND eac.Ativo = 1
GROUP BY eac.PossuiItinerarioFormativo, eac.PossuiItinerarioFormativoSeparadoNoBoletim, ifc.Nome
ORDER BY ifc.Nome;
-- Esperado: PossuiItinerarioFormativoSeparadoNoBoletim = 0 (false)
--           Ciclos disponíveis: Anual, Bimestral, Semestral, Trimestral
```

**Passos:**
1. Acessar o Configurador de Avaliações.
2. Selecionar: Rede = `Alfa` → Ano Letivo = `2026` → Agrupamento = `1ª série do EM`.
3. Observar que as opções CF aparecem no dropdown (porque os ciclos existem).
4. Selecionar `Componente Formativo — Semestral`.

**Resultado esperado:**
- Um modal/alerta exibe a mensagem:  
  *"O agrupamento não está configurado para exibir Componentes Formativos separadamente no boletim. Configure-o antes de prosseguir."*
- Após fechar o alerta, o dropdown de Escopo volta para sem seleção (vazio).
- O grid **não** é carregado.

---

### CT-05 — Escopo CF carrega somente colunas do ciclo selecionado

> ⚠️ **Este cenário requer setup manual de dados.** Não há `EstruturaAvaliacao` configurada para CF em homolog ainda. Siga as instruções de setup abaixo antes de executar.

**Objetivo:** Confirmar que ao selecionar um escopo CF, o grid exibe apenas colunas (etapas) cujo `ItinerarioFormativoCiclo` corresponde ao ciclo selecionado — e nenhuma coluna regular ou de outro ciclo.

**Setup de dados (executar via SQL antes do teste):**
```sql
-- Inserir 2 estruturas CF Semestral usando um ciclo existente da Ábaco 1ª série EM 2026
-- ATENÇÃO: substitua IdCicloExistente por um Id real de Ciclo com Etapa de Boletim Regular
-- Use a query abaixo para encontrar um IdCiclo válido:
SELECT TOP 1 c.Id AS IdCiclo, e.Nome AS Etapa
FROM Ciclo c
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN EstruturaAvaliacao ea ON ea.Ciclo = c.Id
WHERE ea.Agrupamento = 11 AND ea.Rede = 60 AND ea.AnoLetivo = 2026
  AND ea.ItinerarioFormativoCiclo IS NULL AND e.Boletim = 1;
```

> Após identificar um `IdCiclo`, inserir um registro de EstruturaAvaliacao com `ItinerarioFormativoCiclo = 2` (Semestral) via operação de negócio na própria tela (escopo Semestral → adicionar coluna). **Não inserir diretamente via SQL** para evitar inconsistências de auditoria.

**Dados de teste (após setup):**
- Rede: `Ábaco`
- Agrupamento: `1ª série do EM`
- Ano Letivo: `2026`

**Query de validação pós-setup:**
```sql
SELECT ea.Id, ifc.Nome AS CicloCF, e.Nome AS Etapa, ea.Ativo
FROM EstruturaAvaliacao ea
LEFT JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = ea.ItinerarioFormativoCiclo
INNER JOIN Ciclo c ON c.Id = ea.Ciclo
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN Agrupamento a ON a.Id = ea.Agrupamento
INNER JOIN Rede r ON r.Id = ea.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND ea.AnoLetivo = 2026
  AND ea.Ativo = 1
ORDER BY ea.ItinerarioFormativoCiclo, e.Nome;
-- Esperado após setup: linhas com ItinerarioFormativoCiclo = NULL (regulares)
--                    + linhas com ItinerarioFormativoCiclo = 2 (Semestral)
```

**Passos:**
1. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1ª série do EM`.
2. Selecionar Escopo = `Componente Formativo — Semestral`.
3. Observar as colunas do grid.

**Resultado esperado:**
- Grid exibe apenas as colunas com `ItinerarioFormativoCiclo = 2`.
- Colunas regulares (`ItinerarioFormativoCiclo NULL`) **não** aparecem.
- Colunas de outros ciclos CF (Anual, Trimestral, Bimestral) **não** aparecem.

---

### CT-06 — Filtro de Disciplinas exibe somente disciplinas CF do ciclo selecionado

> ⚠️ **Depende do setup do CT-05.**

**Objetivo:** Ao filtrar por disciplina dentro de um escopo CF, apenas disciplinas vinculadas aos itinerários daquele ciclo devem aparecer.

**Dados de teste:**
- Rede: `Ábaco` / Agrupamento: `1ª série do EM` / Ano: `2026`
- Escopo: `Componente Formativo — Semestral`

**Disciplinas esperadas para CF Semestral (Ábaco / 1ª série / 2026):**

```sql
SELECT DISTINCT d.Nome AS Disciplina
FROM ItinerarioFormativoRedeSerie ifrs
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
INNER JOIN ItinerarioFormativoRedeSerieDisciplina ifrsd
    ON ifrsd.ItinerarioFormativoRedeSerie = ifrs.Id AND ifrsd.Ativo = 1
INNER JOIN Disciplina d ON d.Id = ifrsd.Disciplina
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND rs.AnoLetivo = 2026
  AND ifrs.Ativo = 1
  AND ifc.Id = 2
ORDER BY d.Nome;
-- Resultado esperado (32 disciplinas), incluindo:
-- Aplicativos 2026 - I, Aplicativos 2026 II, Argumentação 1, Argumentação 2,
-- Bem- Estar Físico e Mental 1, Bem-estar Físico e Mental 2,
-- Desenvolvimento Econômico e Organismos Internacionais 1/2,
-- Direito 1/2, Economia, Economia 2, Educação Financeira II 1ºS/2ºS,
-- Empreendedorismo 1/2, Inteligência Artificial e Tecnologias do Futuro 1/2,
-- Leitura e Técnicas de Interpretação / 2, Marketing 1/2,
-- Neurociência / 2, Programação 1/2, Simplificando a Política 1/2,
-- Tecnologia na Medicina 1/2, Tutorial da Vida Adulta / 2
```

**Disciplinas que NÃO devem aparecer (são de ciclo Anual):**
```sql
SELECT DISTINCT d.Nome AS Disciplina
FROM ItinerarioFormativoRedeSerie ifrs
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
INNER JOIN ItinerarioFormativoRedeSerieDisciplina ifrsd
    ON ifrsd.ItinerarioFormativoRedeSerie = ifrs.Id AND ifrsd.Ativo = 1
INNER JOIN Disciplina d ON d.Id = ifrsd.Disciplina
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND rs.AnoLetivo = 2026
  AND ifrs.Ativo = 1
  AND ifc.Id = 1
ORDER BY d.Nome;
-- Não devem aparecer no escopo Semestral:
-- Aplicativos 2026 - I (aparece nos dois!), Argumentação 1 (idem), 
-- Bem- Estar Físico e Mental 1 (idem), Biologia
-- Obs: disciplinas que aparecem em múltiplos ciclos devem aparecer no escopo do ciclo selecionado
```

**Passos:**
1. Selecionar Escopo = `Componente Formativo — Semestral`.
2. Abrir o filtro de Disciplina.
3. Comparar a lista exibida com o resultado da primeira query acima.

**Resultado esperado:**
- Lista contém as 32 disciplinas do ciclo Semestral.
- Disciplinas exclusivas do ciclo Anual que não existem no Semestral (ex.: `Biologia`) **não aparecem**.
- Disciplinas regulares (Matemática, Português, etc.) **não aparecem**.

---

### CT-07 — Escopo CF sem estrutura configurada exibe grid vazio

**Objetivo:** Confirmar que selecionar um escopo CF válido, mas sem `EstruturaAvaliacao` configurada, resulta em grid vazio (não em erro).

**Dados de teste:**
- Rede: `Ábaco`
- Agrupamento: `1ª série do EM`
- Ano Letivo: `2026`
- Escopo: qualquer opção CF (ex.: `Componente Formativo — Anual`)

**Verificação de pré-condição:**
```sql
SELECT COUNT(*) AS QtdEstruturasConfiguradas
FROM EstruturaAvaliacao ea
INNER JOIN Agrupamento a ON a.Id = ea.Agrupamento
INNER JOIN Rede r ON r.Id = ea.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND ea.AnoLetivo = 2026
  AND ea.Ativo = 1
  AND ea.ItinerarioFormativoCiclo IS NOT NULL;
-- Esperado: 0 (confirmar que não há estruturas CF configuradas)
```

**Passos:**
1. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1ª série do EM`.
2. Selecionar Escopo = `Componente Formativo — Anual`.

**Resultado esperado:**
- O grid é exibido **vazio** (sem colunas).
- Uma mensagem informativa aparece indicando que não há estrutura configurada para este escopo.
- **Nenhum erro** é exibido (sem tela vermelha, sem exception).
- A mensagem pode conter um link para configuração de componentes formativos.

---

### CT-08 — Trocar agrupamento reseta a seleção de escopo

**Objetivo:** Garantir que ao mudar de agrupamento, o escopo selecionado é limpo e o dropdown é reconstruído para o novo agrupamento.

**Dados de teste:**
- Agrupamento A: `Ábaco` / `1ª série do EM` / 2026 (tem CF ciclos)
- Agrupamento B: `Ábaco` / `1º ano do EFAI` / 2026 (sem CF ciclos)

**Passos:**
1. Selecionar Rede = `Ábaco`, Ano Letivo = `2026`.
2. Selecionar Agrupamento = `1ª série do EM`.
3. Confirmar que opções CF aparecem no dropdown de Escopo.
4. Selecionar Escopo = `Componente Formativo — Semestral`.
5. Confirmar que o grid (vazio, conforme CT-07) é exibido.
6. Mudar Agrupamento para `1º ano do EFAI`.

**Resultado esperado após o passo 6:**
- Campo Escopo volta para estado não selecionado (vazio).
- Grid some / fica bloqueado.
- Dropdown de Escopo agora exibe apenas 3 opções (`Boletim Regular`, `Boletim Diversificado`, `Outras avaliações`) — sem opções CF.

---

### CT-09 — Label atualizado no Configurador de Agrupamento

**Objetivo:** Confirmar que o campo `PossuiItinerarioFormativoSeparadoNoBoletim` exibe o novo rótulo na tela de edição de agrupamento.

**Como acessar:**
`Menu lateral → Configuradores → Agrupamento → clicar em Editar em qualquer agrupamento`

**Passos:**
1. Acessar o Configurador de Agrupamento.
2. Clicar em Editar em qualquer agrupamento (ex.: `1ª série do EM` da rede `Ábaco`).
3. Localizar o campo que controla a exibição de Itinerários/Componentes Formativos.

**Resultado esperado:**
- O label do campo exibe: **"Exibir Componentes Formativos separadamente no boletim:"**
- **Não** deve exibir o texto antigo: ~~"Itinerários são semestrais:"~~

**Verificação da flag no banco para o agrupamento testado:**
```sql
SELECT eac.PossuiItinerarioFormativoSeparadoNoBoletim
FROM EstruturaAvaliacaoConfiguracao eac
INNER JOIN Agrupamento a ON a.Id = eac.Agrupamento
INNER JOIN Rede r ON r.Id = eac.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND eac.AnoLetivo = 2026
  AND eac.Ativo = 1;
-- Esperado: 1 (true) — confirmar que flag está habilitada para este agrupamento
```

---

### CT-10 — Escopo regular não exibe colunas de CF (isolamento)

**Objetivo:** Confirmar que ao selecionar `Boletim Regular`, nenhuma coluna de CF aparece — mesmo que existam `EstruturaAvaliacao` com `ItinerarioFormativoCiclo` preenchido para o mesmo agrupamento.

**Dados de teste:**
- Rede: `Ábaco` / Agrupamento: `1ª série do EM` / Ano: `2026`

> ⚠️ Este cenário fica **totalmente validável** após o setup do CT-05 (quando houver `EstruturaAvaliacao` com `ItinerarioFormativoCiclo` preenchido). Mesmo sem o setup, validar o passo 4 (query confirma).

**Passos:**
1. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `1ª série do EM`.
2. Selecionar Escopo = `Boletim Regular`.
3. Observar o grid.
4. Executar a query abaixo e comparar com o que aparece na tela.

**Query de validação:**
```sql
SELECT e.Nome AS Etapa, ea.ItinerarioFormativoCiclo
FROM EstruturaAvaliacao ea
INNER JOIN Ciclo c ON c.Id = ea.Ciclo
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN Agrupamento a ON a.Id = ea.Agrupamento
INNER JOIN Rede r ON r.Id = ea.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND ea.AnoLetivo = 2026
  AND ea.Ativo = 1
  AND e.Boletim = 1
  AND e.Diversificada = 0
  AND e.Simulados = 0
ORDER BY ea.ItinerarioFormativoCiclo, e.Nome;
-- Resultado: linhas com ItinerarioFormativoCiclo = NULL são as que devem aparecer no grid
-- Linhas com ItinerarioFormativoCiclo preenchido NÃO devem aparecer no Boletim Regular
```

**Resultado esperado:**
- Grid exibe somente etapas cujo `ItinerarioFormativoCiclo IS NULL`.
- Nenhuma coluna CF aparece no escopo regular.

---

### CT-11 — Dropdown exibe somente os ciclos CF que existem para o agrupamento

**Objetivo:** Confirmar que o dropdown não exibe opções de ciclos que não estão configurados para aquele agrupamento.

**Dados de teste:**
- Rede: `Ábaco`
- Agrupamento: `2ª série do EM`
- Ano Letivo: `2026`

**Verificação de pré-condição:**
```sql
SELECT ifc.Id AS IdCiclo, ifc.Nome AS NomeCiclo, COUNT(DISTINCT ifrs.Id) AS QtdItinerarios
FROM ItinerarioFormativoRedeSerie ifrs
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
INNER JOIN RedeSerie rs ON rs.Id = ifrs.RedeSerie AND rs.Ativo = 1
INNER JOIN Agrupamento a ON a.Id = rs.Agrupamento
INNER JOIN Rede r ON r.Id = rs.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '2ª série do EM'
  AND rs.AnoLetivo = 2026
  AND ifrs.Ativo = 1
GROUP BY ifc.Id, ifc.Nome
ORDER BY ifc.Id;
-- Esperado: APENAS IdCiclo = 2 (Semestral, 32 itinerários)
-- NÃO deve retornar: Anual (1), Trimestral (4), Bimestral (5)
```

**Passos:**
1. Selecionar: Rede = `Ábaco` → Ano Letivo = `2026` → Agrupamento = `2ª série do EM`.
2. Observar o dropdown de Escopo.

**Resultado esperado:**
- Dropdown exibe **4 opções**:
  1. Boletim Regular
  2. Boletim Diversificado
  3. Outras avaliações
  4. Componente Formativo — Semestral
- **Não** aparecem: Componente Formativo — Anual, Componente Formativo — Trimestral, Componente Formativo — Bimestral.

---

### CT-12 — Filtro de Escolas restringe ao ciclo CF selecionado

> ⚠️ **Este cenário requer setup manual de dados** (mesmas condições do CT-05).

**Objetivo:** Ao filtrar por Escola dentro de um escopo CF, apenas escolas com avaliações configuradas para disciplinas daquele ciclo devem aparecer.

**Dados de teste:**
- Rede: `Ábaco` / Agrupamento: `1ª série do EM` / Ano: `2026`
- Escopo: `Componente Formativo — Semestral`

**Query de validação (verificar escolas esperadas):**
```sql
SELECT DISTINCT e.Nome AS Escola
FROM ViewConfiguradorAvaliacao vca
INNER JOIN Escola e ON e.Id = vca.IdEscola
INNER JOIN EstruturaAvaliacao ea ON ea.Id = vca.IdEstrutura
INNER JOIN Agrupamento a ON a.Id = vca.IdAgrupamento
INNER JOIN Rede r ON r.Id = vca.IdRede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND vca.NomeAnoLetivo = '2026'
  AND vca.EtapaDeBoletim = 1
  AND vca.EtapaDiversificada = 0
  AND vca.EtapaDeSimulados = 0
  AND ea.ItinerarioFormativoCiclo = 2
  AND vca.IdEscola IS NOT NULL
ORDER BY e.Nome;
-- Escolas que devem aparecer no filtro de CF Semestral
```

**Passos:**
1. Selecionar Escopo = `Componente Formativo — Semestral`.
2. Abrir o filtro de Escola.
3. Comparar com o resultado da query acima.

**Resultado esperado:**
- Apenas escolas que possuem avaliações configuradas para disciplinas CF Semestral aparecem.
- Escolas sem avaliações CF Semestral **não aparecem**.

---

## 5. Query diagnóstica geral

Use esta query para ter um panorama completo da situação CF de qualquer filtro:

```sql
SELECT
    r.Nome                                                      AS Rede,
    a.Nome                                                      AS Agrupamento,
    al.Id                                                       AS AnoLetivo,
    eac.PossuiItinerarioFormativo                               AS PossuiIF,
    eac.PossuiItinerarioFormativoSeparadoNoBoletim              AS SeparadoNoBoletim,
    ifc.Id                                                      AS IdCiclo,
    ifc.Nome                                                    AS NomeCiclo,
    COUNT(DISTINCT ifrs.Id)                                     AS QtdItinerariosComCiclo,
    COUNT(DISTINCT ea.Id)                                       AS QtdEstruturasConfiguradas,
    CASE WHEN COUNT(DISTINCT ea.Id) > 0
         THEN 'Sim' ELSE 'Nao — grid vazio'
    END                                                         AS TeriaResultadosNoGrid
FROM EstruturaAvaliacaoConfiguracao eac
INNER JOIN Agrupamento a ON a.Id = eac.Agrupamento
INNER JOIN Rede r ON r.Id = eac.Rede
INNER JOIN AnoLetivo al ON al.Id = eac.AnoLetivo
INNER JOIN RedeSerie rs ON rs.Agrupamento = eac.Agrupamento
                        AND rs.AnoLetivo   = eac.AnoLetivo
                        AND rs.Rede        = eac.Rede
                        AND rs.Ativo       = 1
INNER JOIN ItinerarioFormativoRedeSerie ifrs ON ifrs.RedeSerie = rs.Id AND ifrs.Ativo = 1
INNER JOIN ItinerarioFormativo iff ON iff.Id = ifrs.ItinerarioFormativo AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = iff.ItinerarioFormativoCiclo
LEFT JOIN EstruturaAvaliacao ea ON ea.Agrupamento            = eac.Agrupamento
                                AND ea.Rede                  = eac.Rede
                                AND ea.AnoLetivo             = eac.AnoLetivo
                                AND ea.ItinerarioFormativoCiclo = ifc.Id
                                AND ea.Ativo                 = 1
WHERE eac.PossuiItinerarioFormativoSeparadoNoBoletim = 1
  AND eac.Ativo = 1
  AND al.Id >= 2025
GROUP BY r.Nome, a.Nome, al.Id, eac.PossuiItinerarioFormativo,
         eac.PossuiItinerarioFormativoSeparadoNoBoletim, ifc.Id, ifc.Nome
ORDER BY al.Id DESC, r.Nome, a.Nome, ifc.Id;
```

---

## 6. Status dos cenários em homolog (2026-04-20)

| CT | Descrição | Testável agora? | Observação |
|----|-----------|:---:|---|
| CT-01 | Regressão escopos regulares | ✅ Sim | Usar Ábaco / 1º ano EFAI / 2026 |
| CT-02 | CF aparece no dropdown | ✅ Sim | Usar Ábaco / 1ª série EM / 2026 |
| CT-03 | CF não aparece sem IF ciclo | ✅ Sim | Usar Ábaco / 1º ano EFAI / 2026 |
| CT-04 | Alerta quando Separado=false | ✅ Sim | Usar Alfa / 1ª série EM / 2026 |
| CT-05 | Grid exibe só colunas do ciclo | ⚠️ Setup | Criar EstruturaAvaliacao CF via tela primeiro |
| CT-06 | Disciplinas filtradas por ciclo | ✅ Sim | Verificar lista do filtro (sem precisar de grid) |
| CT-07 | Grid vazio sem estrutura CF | ✅ Sim | Estado atual de todos os agrupamentos CF |
| CT-08 | Reset ao trocar agrupamento | ✅ Sim | Usar Ábaco 1ª série → 1º ano EFAI |
| CT-09 | Label atualizado | ✅ Sim | Configuradores → Agrupamento → Editar |
| CT-10 | Regular não vaza CF | ✅ Sim* | *Validação completa após setup do CT-05 |
| CT-11 | Só ciclos existentes aparecem | ✅ Sim | Usar Ábaco / 2ª série EM / 2026 (só Semestral) |
| CT-12 | Escolas filtradas por ciclo | ⚠️ Setup | Mesmas condições do CT-05 |
