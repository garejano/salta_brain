# SPDD — Commands Sugeridos para Claude Code

**Baseado em:** `inbox/spdd-artigo-completo.md`, `inbox/spdd-resumo.md`, `templates/spdd/`  
**Data:** 2026-04-29  
**Objetivo:** Acelerar o workflow SPDD dentro do contexto salta_brain — integrando templates existentes, cards Jira e repository_map.

---

## Visão Geral do Workflow vs. Commands

```
Jira Card
   │
   ▼
[/spdd-init]       → Bootstrap da estrutura de arquivos para o card
   │
   ▼
[/spdd-story]      → Gera story.md preenchido (INVEST)
   │
   ▼
[/spdd-analysis]   → Gera analysis.md (varre repos, extrai domínio)
   │
   ▼
[/spdd-canvas]     → Gera reasons-canvas.md (artefato principal)
   │
   ▼
[/spdd-generate]   → Executa operações do Canvas, uma a uma
   │
   ▼
[/spdd-api-test]   → Gera scripts de teste a partir das Operations
   │
   ├── lógica muda → [/spdd-update]  → atualiza Canvas → regenera código
   └── refatora    → [/spdd-sync]    → sincroniza Canvas com código atual
```

**Comandos de suporte:**
- `/spdd-status` — onde estou no workflow para um card?
- `/spdd-review` — valida código gerado contra o Canvas

---

## Commands Detalhados

---

### 1. `/spdd-init [card]`

**Prioridade:** Alta  
**Etapa:** Pré-workflow (setup)

**O que faz:**  
Cria a estrutura de diretório SPDD para um card Jira existente em `cards/EFC-xxx/`. Copia os templates de `templates/spdd/` (story.md, analysis.md, reasons-canvas.md) para `cards/EFC-xxx/spdd/`, pré-preenchendo os campos de cabeçalho com dados já disponíveis no card sincronizado (título, data, repositório inferido via `repository_map.md`).

**Por que é valioso:**  
Hoje iniciar um SPDD num card exige copiar templates manualmente e preencher cabeçalho repetitivo. Este comando transforma isso em um único passo. Também garante estrutura consistente em todos os cards.

**Inputs esperados:**  
- `[card]` — número do card (ex: `EFC-6203`) ou executado de dentro do diretório do card

**Output:**  
```
cards/EFC-6203/
└── spdd/
    ├── story.md           ← template + cabeçalho pré-preenchido
    ├── analysis.md        ← template + referência ao repositório inferido
    └── reasons-canvas.md  ← template + metadados do card
```

**Dependências:**  
Card já sincronizado via `/jira_sync`. `repository_map.md` atualizado.

---

### 2. `/spdd-story [card]`

**Prioridade:** Alta  
**Etapa:** 1 — User Stories

**O que faz:**  
Lê a descrição do card Jira sincronizado em `cards/EFC-xxx/` e preenche `spdd/story.md` com user stories no formato INVEST. Quebra o requisito em stories independentes, gera critérios de aceite e checklist INVEST. Sugere ordem de entrega.

**Por que é valioso:**  
O artigo original usa `/spdd-story` como ponto de entrada. A versão integrada com os dados do Jira já sincronizados elimina o retrabalho de recopiar contexto — o AI já tem a descrição, AC e comentários do card.

**Inputs esperados:**  
- `[card]` — número do card ou diretório atual

**Output:**  
`cards/EFC-xxx/spdd/story.md` preenchido com stories derivadas do card Jira.

**Dependências:**  
`/spdd-init` executado antes (ou executa implicitamente).

---

### 3. `/spdd-analysis [card]`

**Prioridade:** Alta  
**Etapa:** 2 — Análise de Domínio

**O que faz:**  
Lê `spdd/story.md` e o card Jira, infere o repositório alvo via `repository_map.md`, varre o código relevante nos repos identificados, e preenche `spdd/analysis.md` com: conceitos de domínio, arquivos/módulos relevantes tocados, riscos identificados, direção estratégica e dependências externas.

**Por que é valioso:**  
Esta é a etapa onde o AI economiza mais tempo — a varredura de codebase para entender o que será tocado é custosa e propensa a erro manual. O command faz isso de forma sistemática e documenta o resultado como artefato rastreável. É o equivalente ao que o artigo descreve como "extract domain keywords, scan relevant codebase sections".

**Inputs esperados:**  
- `[card]` — número do card

**Output:**  
`cards/EFC-xxx/spdd/analysis.md` preenchido com conceitos, código relevante, riscos e direção.

**Dependências:**  
`/spdd-story` concluído. `repository_map.md` atualizado.

---

### 4. `/spdd-canvas [card]`

**Prioridade:** Alta  
**Etapa:** 3 — REASONS Canvas (artefato principal)

**O que faz:**  
Lê `spdd/story.md` + `spdd/analysis.md` e gera `spdd/reasons-canvas.md` completo com todas as 7 dimensões REASONS: Requirements (com DoD e fora de escopo), Entities (com invariantes), Approach (estratégia + padrões + decisões), Structure (componentes + interfaces públicas), Operations (passos concretos e testáveis), Norms (padrões do projeto inferidos do repo), Safeguards (limites não negociáveis).

**Por que é valioso:**  
O Canvas é o artefato mais complexo do SPDD e o que mais se beneficia de geração assistida. Com story + analysis já preenchidos, o AI tem contexto suficiente para produzir um Canvas de alta qualidade que serve como blueprint executável. Reduz horas para minutos na fase de design.

**Inputs esperados:**  
- `[card]` — número do card  
- Opcionalmente: instrução de foco ou restrição adicional

**Output:**  
`cards/EFC-xxx/spdd/reasons-canvas.md` preenchido e versionado (v1.0).

**Dependências:**  
`/spdd-analysis` concluído e validado.

---

### 5. `/spdd-generate [card] [operacao]`

**Prioridade:** Alta  
**Etapa:** 4 — Geração de Código

**O que faz:**  
Lê `spdd/reasons-canvas.md`, localiza o repositório alvo, e executa **uma operação específica** do bloco `O — Operations` do Canvas no código real. Segue estritamente as Norms e Safeguards. Não improvisa nada além do que está descrito. Após cada operação, atualiza o status no Canvas (ex: `[x] Operação 1 — concluída`).

**Por que é valioso:**  
A regra "no improvisation, no features beyond what the spec defines" só é aplicável na prática se o comando for granular — uma operação por vez. Permite revisão incremental e evita geração em bloco que perde o controle. Mantém o Canvas como fonte de verdade da execução.

**Inputs esperados:**  
- `[card]` — número do card  
- `[operacao]` — número ou nome da operação (ex: `1` ou `criar-repositorio`)  
- Se omitido: executa a próxima operação pendente

**Output:**  
Código gerado no repositório alvo. Canvas atualizado com status da operação.

**Dependências:**  
`/spdd-canvas` validado e aprovado.

---

### 6. `/spdd-api-test [card]`

**Prioridade:** Média  
**Etapa:** 5 — Testes

**O que faz:**  
Lê as `O — Operations` do Canvas e gera scripts de teste (cURL, Postman collection, ou testes unitários conforme o stack do repositório) cobrindo: cenários normais de cada operação, condições de boundary definidas nos Safeguards, e casos de erro mapeados nos Risks da análise.

**Por que é valioso:**  
Testes gerados a partir do Canvas (spec) são mais precisos do que testes gerados a partir do código — evitam o viés de "testar o que foi implementado" em vez de "testar o que foi especificado". O artigo enfatiza explicitamente essa distinção.

**Inputs esperados:**  
- `[card]` — número do card

**Output:**  
`cards/EFC-xxx/spdd/tests/` com scripts de teste gerados.

**Dependências:**  
`/spdd-generate` com pelo menos uma operação concluída.

---

### 7. `/spdd-update [card]`

**Prioridade:** Média  
**Etapa:** 6a — Atualização por mudança de requisito

**O que faz:**  
Quando um requisito muda (novo AC no Jira, feedback de review, mudança de escopo), o command: (1) atualiza `spdd/reasons-canvas.md` com a mudança, (2) incrementa a versão do Canvas, (3) identifica e lista quais Operations são afetadas pela mudança e precisam ser regeneradas via `/spdd-generate`.

**Por que é valioso:**  
Implementa a regra fundamental do SPDD: *"fix the prompt first — then update the code."* Sem um comando dedicado, a tendência natural é editar o código diretamente e o Canvas fica desatualizado. O command faz a mudança no lugar certo e rastreia o impacto.

**Inputs esperados:**  
- `[card]` — número do card  
- Descrição da mudança de requisito (inline ou arquivo)

**Output:**  
Canvas atualizado com nova versão. Lista das operações a regenerar.

**Dependências:**  
Canvas v1.0+ existente.

---

### 8. `/spdd-sync [card]`

**Prioridade:** Média  
**Etapa:** 6b — Sincronização pós-refatoração

**O que faz:**  
Quando o código foi refatorado (sem mudança de comportamento — apenas estrutura/estilo), o command lê o diff do código, compara com o Canvas atual e atualiza as seções `S — Structure` e `O — Operations` para refletir os novos caminhos de arquivo, nomes de interfaces e organização de componentes.

**Por que é valioso:**  
Implementa o ciclo fechado bidirecional: código muda → Canvas atualiza. Sem isso, o Canvas vai apodrecendo como documentação stale. Especialmente relevante após sessões de refatoração ou code review que sugerem mudanças estruturais.

**Inputs esperados:**  
- `[card]` — número do card  
- Opcionalmente: diff específico ou range de commits

**Output:**  
Canvas atualizado com versão incrementada e seção de histórico preenchida.

**Dependências:**  
Canvas existente. Mudanças no código commitadas ou staged.

---

### 9. `/spdd-status [card]`

**Prioridade:** Média  
**Etapa:** Qualquer momento

**O que faz:**  
Inspeciona `cards/EFC-xxx/spdd/` e reporta o estado atual do workflow SPDD: quais arquivos existem, quais seções estão preenchidas vs. pendentes, qual operação do Canvas está em andamento, e qual é o próximo passo recomendado.

**Por que é valioso:**  
Ao trabalhar em múltiplos cards simultaneamente ou retomar um card após dias, é fácil perder o fio do workflow. Este command dá um "onde estou" instantâneo sem precisar abrir e ler cada arquivo. Também serve para onboarding — outro dev consegue ver rapidamente o estado SPDD de um card.

**Inputs esperados:**  
- `[card]` — número do card (ou lista todos os cards com SPDD iniciado se omitido)

**Output:**  
```
EFC-6203 — SPDD Status
  ✅ story.md        — 3 stories definidas
  ✅ analysis.md     — revisado em 2026-04-28
  ✅ reasons-canvas.md — v1.2, 5 operações
  🔄 Operação 3/5   — em andamento
  ⏳ tests/          — não gerado
  Próximo: /spdd-generate EFC-6203 3
```

**Dependências:**  
`/spdd-init` executado.

---

### 10. `/spdd-review [card]`

**Prioridade:** Baixa  
**Etapa:** Após geração de código

**O que faz:**  
Revisa o código gerado para um card contra os critérios do Canvas: verifica se cada operação foi implementada conforme especificado, se as Norms estão sendo seguidas (naming, observabilidade, coding standards) e se nenhum Safeguard foi violado. Gera um relatório de conformidade.

**Por que é valioso:**  
Transforma o code review de "avaliar qualidade subjetiva" para "verificar conformidade com spec". Isso acelera reviews de PR (o revisor humano valida a spec, não reinventa critérios) e reduz ciclos de feedback. Especialmente útil em times maiores onde o autor do Canvas e o implementador são pessoas diferentes.

**Inputs esperados:**  
- `[card]` — número do card  
- Opcionalmente: path específico ou operação específica

**Output:**  
Relatório de conformidade: o que está alinhado, o que diverge, sugestões de correção.

**Dependências:**  
Canvas + código gerado existentes.

---

## Resumo por Prioridade

| Prioridade | Command | Etapa | Motivo |
|-----------|---------|-------|--------|
| Alta | `/spdd-init` | Setup | Fundação — sem isso nenhum outro funciona |
| Alta | `/spdd-story` | 1 | Ponto de entrada obrigatório do workflow |
| Alta | `/spdd-analysis` | 2 | Maior economia de tempo (varredura de código) |
| Alta | `/spdd-canvas` | 3 | Artefato principal — maior complexidade |
| Alta | `/spdd-generate` | 4 | Execução disciplinada do Canvas |
| Média | `/spdd-api-test` | 5 | Testes spec-driven |
| Média | `/spdd-update` | 6a | Mantém regra fundamental (prompt first) |
| Média | `/spdd-sync` | 6b | Ciclo fechado bidirecional |
| Média | `/spdd-status` | Qualquer | Orientação no workflow, multi-card |
| Baixa | `/spdd-review` | Pós-geração | Review estruturado contra Canvas |

---

## Integração com Commands Existentes

| Situação | Sequência sugerida |
|----------|--------------------|
| Card novo no Jira | `/jira_sync` → `/spdd-init` → `/spdd-story` → ... |
| Card com feature já descrita | `/refinar-feature` (para alinhar escopo) → `/spdd-init` → `/spdd-canvas` → ... |
| Decisão de arquitetura complexa | `/refinar-tech` (para plano técnico) → `/spdd-canvas` (absorve o plano) → ... |
| Bug com mudança de comportamento | `/identificar-bug` → `/spdd-update` (atualiza Canvas) → `/spdd-generate` |

---

## Nota sobre Implementação

Os commands seriam criados em `.claude/commands/spdd-*.md` seguindo o padrão dos commands existentes. Cada arquivo define o comportamento esperado do AI quando o comando for invocado, com acesso aos templates em `templates/spdd/` e aos dados dos cards em `cards/EFC-xxx/`.
