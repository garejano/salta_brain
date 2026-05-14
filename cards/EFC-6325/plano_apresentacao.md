# Plano — Apresentação: document-builder × IA (Guilda de Devs)

> **Arquivo de planejamento.** Refinar antes de desenvolver o HTML.  
> **Rota destino:** `exemplos/document-builder-ia-guide`  
> **Referência visual:** `./document-builder-design/Tour - Document Builder.html`  
> **Público:** Guilda de desenvolvedores da empresa  
> **Foco:** o processo, não o produto — como a IA participou e o que isso significa

---

## Números reais (base para os slides)

| Métrica | Valor |
|---|---|
| Período de desenvolvimento | 07–12 mai 2026 — **6 dias úteis** |
| Commits | 11 commits (develop) |
| Arquivos no módulo `document-builder/` | **73 arquivos** (ts + html + scss + md) |
| Linhas de código no módulo | **~5.400 linhas** |
| Alterações totais no repositório | 59 arquivos, +4.943 / -297 linhas |
| Tasks executadas | **9 core tasks + 18 DEV tasks = 27 tasks** |
| DEV tasks concluídas | 22 de 27 |
| Componentes criados | 14 componentes de conteúdo + 5 de infraestrutura |
| Modelos de documentos prontos | 8 (lista presença × 3, tabelas × 4, debug) |
| Estratégias de print/save | 3 (`css`, `html2canvas`, `html-to-image`) |
| Testes unitários (LayoutEngine) | 11 testes |

---

## Estrutura dos slides (roteiro)

### Slide 1 — Abertura
**Título:** `como construímos um módulo completo em 6 dias`  
**Subtítulo:** `document-builder × IA · Guilda de Devs · mai/2026`

Breve: o que vamos ver — não é apresentação de produto, é apresentação de processo.

---

### Slide 2 — O contexto (dados do Jira)
**Título:** `250+ chamados. O mesmo problema, repetido por anos.`

- Tabela: Boletim 100+, Ata 68, Ficha 60, Certificado 22 tickets (2022–2026)
- Top 3 reclamações do usuário:
  - *"A ficha sai em 2 páginas"*
  - *"A assinatura fica sobreposta"*
  - *"O PDF sai em branco"*
- Tag `[IA analisou 250+ tickets no Jira para montar esse slide]`
- Nota: esse processo não foi refinado — foi um experimento. Tem margem de melhoria.

**Por que esse slide importa para a guilda:** a IA não só escreveu código — ela ajudou a *entender o problema* antes de escrever uma linha.

---

### Slide 3 — O legado (o que havia antes)
**Título:** `o gerador-documentos: funcional, mas com limitações estruturais`

Cards mostrando os 5 problemas técnicos do legado:
1. `setTimeout` frágil no layout
2. Lógica de paginação acoplada a cada documento
3. Componentes não sabiam se dividir
4. Sem debug de layout
5. Nomes em português misturados com inglês

Footer: `"cada novo documento era reinventar a roda"`

---

### Slide 4 — A inspiração (o filtro)
**Título:** `a ideia veio de outro módulo: o filtro`

Comparação side-by-side:

```
filtro                          document-builder
──────────────────              ─────────────────────
FilterConfig                    DocumentConfig
FilterComponent                 DocumentViewerComponent
campos injetados por config     componentes injetados por config
"o dev declara o quê"           "o dev declara o quê"
```

> *"Um documento é apenas um arquivo de configuração bem definido."*  
> — inspiração direta no padrão do `FiltroComponent`

Demonstrar a tela `exemplos/filtros` como referência visual de onde veio o padrão.

---

### Slide 5 — O processo com IA
**Título:** `como foi o desenvolvimento`

Timeline horizontal dos 6 dias:

```
07 mai  →  08 mai  →  11 mai  →  12 mai
  │           │           │           │
Estrutura   Viewer +   DEV tasks   WideTable +
base        Testes     (07–11)     Múltiplos docs
(T01–T06)   (T07–T09)  DEV_003→   DEV_015–018
                       DEV_014
```

Mecânica do processo:
- Dev escreve a **task** com critérios precisos → IA implementa + reporta no changelog
- Dev valida no browser → abre DEV para refinamento
- IA detecta bugs e propõe fix (DEV_009, DEV_014)
- IA propõe novas interfaces quando necessário (DEV_017: `ColumnSplittable`)

---

### Slide 6 — Os números
**Título:** `6 dias, 73 arquivos, 5.400 linhas`

Visual de impacto:

```
73 arquivos criados
5.400 linhas de código
27 tasks executadas
11 testes unitários no LayoutEngine
3 estratégias de print/save
8 modelos de documentos prontos
```

Subtexto: `"quanto tempo levaria sem IA?"`

---

### Slide 7 — Sem IA vs. Com IA
**Título:** `uma comparação honesta`

| | Sem IA | Com IA |
|---|---|---|
| Análise do legado | 1–2 dias de leitura de código | 2h (IA leu + resumiu) |
| Levantar dores dos usuários | reunião de product + pesquisa manual | 30min (JQL + análise automática) |
| Scaffolding do módulo (T01–T03) | 2–3 dias | 1 dia |
| Implementação do LayoutEngine + testes | 3–5 dias | 1 dia |
| Diagnóstico de páginas em branco (DEV_007–008) | meio dia de investigação manual | IA diagnosticou 3 causas raiz + propôs fix |
| Total estimado sem IA | **4–6 semanas** | — |
| Total real com IA | — | **6 dias úteis** |

Nota: esses números assumem que o dev entende o domínio (document-builder era baseado em feature existente). A IA amplifica — não substitui — quem conhece o problema.

---

### Slide 8 — O que facilitou o trabalho da IA
**Título:** `boas práticas que amplificaram a IA`

4 práticas que fizeram diferença:

**1. Interfaces formais**
```typescript
interface Splittable { getRowsThatFit, split, getRowHeight }
interface TextMeasurable { getTextSegments, getMaxWidth, getLineHeight, getVerticalPadding }
interface ColumnSplittable { splitColumns }
```
Contratos claros → IA sabe exatamente o que implementar em cada componente.

**2. Tasks com critérios de aceite**
> *"se a task é vaga, o código é vago"*  
Cada DEV tinha: problema, causa raiz identificada, o que fazer, critério de aceite.

**3. Separação de responsabilidades**
`LayoutEngine` sem DOM → IA pode testar unitariamente.  
`PrintService` isolado → IA pode trocar estratégia sem tocar o viewer.

**4. changelog + tarefas.md como memória**
IA manteve contexto entre sessões porque o estado estava escrito, não só na memória de conversa.

---

### Slide 9 — IA analisando dados do Jira
**Título:** `de 250+ tickets para decisões de design`

Como funcionou:
1. IA consultou projetos EFC e SP via MCP (Atlassian API)
2. Buscas JQL por `boletim`, `ficha`, `ata`, `certificado`
3. Resultado: padrões de problemas, volumetria, casos extremos
4. Saída: `analise_documentacao_pedagogica.md` — 9 categorias de problemas

**Exemplo de decisão influenciada:**
- "Ficha saindo em 2 páginas" → alta frequência → `Splittable` virou prioridade no MVP
- "Nome errado em lote" → `DocumentDefinition` isolada por documento
- "PDF em branco" → investigação dedicada (DEV_007 + DEV_008)

**Nota de honestidade:**
> *"esse foi um experimento — o processo de análise não foi refinado e pode ter gaps (ex: busca por acentos falhou no JQL). Mas a direção está certa."*

---

### Slide 10 — O guide como documentação viva
**Título:** `documentação gerada junto com o produto`

Esta própria rota (`exemplos/document-builder-ia-guide`) é um exemplo.

O que a IA gerou automaticamente a partir do produto:
- `README.md` do módulo (como usar, contratos, limitações)
- `dores_resolvidas.md` (mapeamento problema → solução)
- `analise_documentacao_pedagogica.md` (dados do Jira)
- Esta apresentação

> *"A IA não documenta depois — documenta enquanto constrói."*

Possibilidade: qualquer POC ou feature desenvolvida com IA pode gerar sua documentação na mesma sessão.

---

### Slide 11 — O filtro como padrão (demonstração)
**Título:** `componentes injetáveis: o padrão que escala`

Mostrar o padrão do `FiltroComponent`:
- Dev define uma `FilterConfig` (o quê)
- Componente injeta os campos dinamicamente (o onde/como)
- Zero lógica de UI no consumidor

O document-builder segue a mesma lógica:
- Dev define `DocumentEntry[]` (o quê)
- `DocumentViewer` injeta + distribui entre páginas (o onde)
- Zero lógica de paginação no consumidor

> *"padrões bem estabelecidos no projeto se tornam referência para novos módulos — e a IA reconhece e replica esses padrões"*

Link para `exemplos/filtros` para quem quiser explorar.

---

### Slide 12 — A ferramenta (seção existente do Tour)
**Título:** `document-builder — a ferramenta`

⚠️ **Esta seção já existe como referência visual em `./document-builder-design/Tour - Document Builder.html`** — manter integralmente, encaixar na sequência da apresentação aqui.

Conteúdo da seção:
- Como criar um documento (API `DocumentEntry[]`)
- Componentes base disponíveis
- Debug panel
- Modelos prontos
- Live demo dos exemplos

---

### Slide 13 (final) — O dev ainda precisa estar no controle
**Título:** `mas o dev ainda precisa estar no controle`  
*(tom: irônico, leve, verdadeiro)*

Três "falhas" reais do processo que a IA não resolveu sozinha:

1. **DEV_010, DEV_013, DEV_014, DEV_016** — 4 tasks ainda pendentes.  
   A IA não decide o que é prioridade — o dev decide.

2. **Diagnóstico de páginas em branco (DEV_007–008)**  
   A IA propôs o fix correto — mas foi o dev que testou no browser e confirmou.  
   *"A IA não tem olhos."*

3. **A análise do Jira perdeu dados**  
   JQL sem suporte a acentos → algumas buscas retornaram zero. A IA reportou,  
   mas só quem conhece o domínio sabe quando os dados estão incompletos.

---

Visual sugerido para o slide final:

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│   IA escreve o código.                               │
│   IA lê o Jira.                                      │
│   IA documenta.                                      │
│   IA testa (às vezes).                               │
│                                                      │
│   Mas a ideia ainda precisa vir de alguém            │
│   que entende o problema.                            │
│                                                      │
│                           — você, provavelmente.    │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## Estrutura técnica da rota

**Rota:** `exemplos/document-builder-ia-guide`  
**Componente:** `DocumentBuilderIaGuideComponent`  
**Condição:** `environment.useExempleModule` (igual às demais rotas de exemplos)

**Implementação sugerida:**
- Mesma estrutura do `Tour - Document Builder.html` (deck de slides navegável)
- Slides em HTML/CSS dentro do componente Angular, sem dependência de lib de apresentação
- Botões de navegação: anterior / próximo / slide N de 13
- Teclas de teclado: `←` / `→`
- Slide 12 incorpora ou linka o `Tour - Document Builder.html` existente
- Slide final pode ter animação simples (texto aparece linha a linha)

---

## Dúvidas a refinar antes de desenvolver

1. **O slide de comparação com/sem IA** — os números de estimativa sem IA são especulativos. Preferir deixar como "estimativa" explícita ou remover e focar só no "com IA"?
pode deixar como especulativo e impreciso

2. **Slide 12 (a ferramenta)** — encorporar o HTML do Tour diretamente no componente Angular (via `innerHTML` sanitizado ou `<iframe>`) ou apenas linkar para a rota `exemplos/documents`?
nao precisa linkar para exempls/documentos, aqui pode ser para outra rota que tenha so o tour do documento mesmo document-builder-tour

3. **Animações** — a referência visual usa animações CSS. Manter o mesmo nível de polish ou simplificar para um slide estático navegável?
pode manter animacoes, ja eh um exemplo do que a ia pode deixar bonitinho

4. **Slide do filtro** — mostrar código real (`.ts`) inline no slide ou apenas o conceito?
apenas contexto, quem quiser que procure mais

5. **Tom do slide final** — irônico leve (atual) ou preferir um tom mais assertivo sobre a colaboração humano-IA?
mais assertivo sobre a colaboracao humano-IA

6. **Navegação** — slideshow puro (uma tela = um slide, fullscreen) ou scroll contínuo (tipo long-page)?
slideshow comomeh feito no modelo feito pelo claude code, a apresentacao deve ocupar a tela toda, mesmo o modulo tendo top-bar, esse modulo so vive em homolog mesmo

---

## Ordem de desenvolvimento sugerida

```
1. Scaffolding da rota + componente base (navegação, chrome)
2. Slides 1–4 (contexto, legado, filtro)
3. Slides 5–8 (processo, números, comparação, boas práticas)
4. Slides 9–11 (Jira, guide, filtro demo)
5. Slide 12 — integração do Tour existente
6. Slide 13 — slide final irônico
7. Polish visual + animações
```
