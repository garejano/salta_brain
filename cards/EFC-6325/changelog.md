# changelog.md — Registro de alterações

---

## 2026-05-12 — DEV_012: Lista de Presença reimplementada com document-builder

Resumo em `tarefas.md` (DEV_012). Criados 3 modelos (diária/semanal/mensal) usando `DocTableComponent` com `Splittable`. Adicionado campo `measureColumnWidth` em `DocTableData` para tabelas com muitas colunas. Header `onAllPages: false` em todos os modelos.

---

## 2026-05-12 — DEV_011: Cabeçalho configurável por página

`HeaderConfig.onAllPages: false` implementado. `LayoutEngine` agora calcula `firstPageHeight` e `otherPageHeight` separadamente. Novo sample `header-first-only` nos exemplos.

---

## 2026-05-12 — DEV_009: Fix quebra de tabela entre páginas

`DocTableComponent.getRowsThatFit()` não subtraía `DOC_TABLE_HEADER_HEIGHT` antes de dividir. Corrigido em `doc-table.component.ts` e `createTableSplittable`. Fix adicional para head de splits de nível 2+.

---

## 2026-05-12 — DEV_008: Estratégias de print/save

Adotado `css` (window.print) para imprimir e `html2canvas` para salvar PDF, eliminando páginas em branco do pipeline SVG do html-to-image. Análise completa em `analise/doc_builder_lib_analise.md`.

---

## 2026-05-12 — DEV_007: Fix páginas em branco

Double-render fix para html-to-image (aquece cache SVG), `pixelRatio: 2` para reduzir pressão de memória, remoção do `cacheBust`. Presets `draft`/`standard`/`high` no `PrintService`.

---

## 2026-05-12 — DEV_006: Refatoração da config de documento

Interface `DocumentDefinition { config, headerData, entries }` + `DocumentSample`. Cada documento extraído para uma `const` independente em `documents.component.ts`.

---

## 2026-05-12 — DEV_005: componentGap na config

`DocumentConfig.componentGap?: number` adicionado. `measureAll()` soma gap à altura de cada componente. Template de página usa `[style.gap.px]`.

---

## 2026-05-12 — DEV_004: Ordem footer/assinatura na página

`document-page.component.html` reordenado: `content → signature → footer`. A assinatura fica acima do rodapé (número de página sempre no fundo).

---

## 2026-05-12 — DEV_003: PrintOverlayComponent + tela de exemplos como controlador

`PrintOverlayComponent` criado com backdrop + barra de controle. Tela de exemplos refatorada para grid de 4 documentos de teste. Viewer iniciado via `setTimeout(0)` após overlay abrir.

---

## 2026-05-07 — TAREFA 01: Criar módulo `document-builder`

**O que foi feito:**
- Criado `src/shared/document-builder/document-builder.module.ts` — módulo Angular base (declarations e exports vazios, será preenchido nas tarefas seguintes)
- Criado `src/shared/document-builder/models/document-config.ts` — interfaces de configuração: `DocumentConfig`, `HeaderConfig`, `FooterConfig`, `SignatureConfig`, `SignatoryConfig`, `FrameConfig`, `InfoGridData`, `LegendItem`
- Criado `src/shared/document-builder/models/layout.models.ts` — interfaces de layout: `Splittable` (contrato de divisão entre páginas), `LayoutComponent`, `Page`
- Criado `src/shared/document-builder/README.md` — esqueleto de documentação a ser preenchido na TAREFA 09

**Por que:**
- Estabelece a estrutura base e os tipos que todas as tarefas seguintes dependem
- O contrato `Splittable` em `layout.models.ts` é o ponto central do novo módulo — componentes que implementam essa interface sabem se dividir entre páginas sem lógica no documento
- Padrão de módulo seguido igual ao `FormularioModule` já existente no projeto

**Build:** passou sem erros (12767ms)

---

## 2026-05-07 — TAREFA 02: Criar o `LayoutEngine`

**O que foi feito:**
- Atualizado `layout.models.ts`: interface `Splittable` agora define `split()` retornando `SplitResult { headHeight, tail: LayoutComponent }` — necessário para o engine distribuir recursivamente o tail sem conhecer o tipo concreto do componente. `element` em `LayoutComponent` passou a ser opcional (engine não usa DOM).
- Criado `src/shared/document-builder/services/layout-engine.service.ts` — distribuição de componentes entre páginas sem dependência de DOM
- Criado `src/shared/document-builder/services/layout-engine.service.spec.ts` — 11 testes cobrindo: página única, quebra de página sem split, split em 2 e 3 páginas, componente maior que página inteira (guard), assinatura na última página, assinatura em todas as páginas

**Por que:**
- A mudança no retorno de `split()` é necessária para que o engine possa continuar distribuindo o `tail` recursivamente sem lógica específica por tipo de componente — esse é o ponto central do contrato `Splittable`
- O `LayoutEngine` não faz chamadas de DOM; toda a lógica é sobre altura (números), tornando-o unitariamente testável
- O guard contra componente maior que a página evita loop infinito no caso de dados inválidos

**Testes:** TypeScript sem erros; testes Karma com `--include` não executaram por erros pré-existentes no projeto (imports quebrados em `gerador-documentos` e `step-manager`), mas a compilação TypeScript dos specs passou sem erros.
**Build:** passou sem erros (13124ms)

---

## 2026-05-08 — TAREFA 09: Atualizar README.md do módulo

**O que foi feito:**
- Preenchido `src/shared/document-builder/README.md` com:
  - Visão geral e fluxo interno do `DocumentViewer`
  - Exemplo de código mínimo (componente de conteúdo + config + template)
  - Tabela de componentes base com indicadores `TextMeasurable` e `Splittable`
  - Guia de implementação de `TextMeasurable` (com regras sobre constantes TS obrigatórias)
  - Guia de implementação de `Splittable` (com padrão `displayRows` + `renderData`)
  - Documentação do `DocumentDebug` e significado dos indicadores `[S]`, `[T]`, `[H]`, `[F]`, `[A]`
  - Referência das interfaces de `document-config.ts`
  - Seção "Limitações do Pretext" com link para análise completa

---

## 2026-05-08 — TAREFA 08: Implementar Splittable em DocTableComponent

**O que foi feito:**
- Adicionado `renderData?: { componentType, data }` ao `LayoutComponent` — mecanismo para criar elementos DOM de tails sem instância Angular prévia
- Adicionado `isSplittable()` type guard em `layout.models.ts`
- Adicionado `DocTableData` em `document-config.ts`
- Criado `DocTableComponent` implementando `Splittable`:
  - `getRowHeight()` usa Pretext (`prepare` + `layout`) com a célula mais longa da tabela — sem DOM
  - `split(n)` limita `displayRows` do head e retorna tail com `renderData` + `createTableSplittable` para splits recursivos
  - Constantes exportadas: `DOC_TABLE_FONT`, `DOC_TABLE_LINE_HEIGHT`, `DOC_TABLE_CELL_PADDING_V`, `DOC_TABLE_HEADER_HEIGHT`
- Atualizado `DocumentViewerComponent`:
  - `measureAll()` detecta `Splittable` via `isSplittable()` e popula `layoutComponent.splittable`
  - `distributeElements()` cria componentes via `renderData` para tails sem `element`
- Adicionada tabela com 55 linhas ao exemplo de `DocumentsComponent`

**Por que:**
- `displayRows` (separado de `@Input() data`) permite que `split()` limite o que o head renderiza sem mutar o input — change detection pega a mudança no próximo `cdr.detectChanges()` dentro de `init()`
- Limitação conhecida: split de tail (tabelas com 3+ páginas) renderiza linhas incorretas no head-do-tail — requer `headRenderData` em `SplitResult` para ser corrigido (fora do escopo do MVP)

**Build:** passou sem erros (15562ms)

---

## 2026-05-07 — TAREFA 07: Criar rota documents no módulo de exemplos

**O que foi feito:**
- Criado `TestDocBodyComponent` em `src/app/features/exemplos/documents/test-doc-body/` — componente de conteúdo com `@Input() data: TestDocBodyData`; usa `app-doc-title` e `app-doc-text-field` internamente; medido via DOM (não implementa `TextMeasurable`)
- Criado `DocumentsComponent` em `src/app/features/exemplos/documents/` — tela de exemplo com toolbar (imprimir, salvar PDF, toggle debug) e `DocumentViewerComponent` com dados completamente mockados
- Adicionada rota `documents` em `exemplos-routing.module.ts` (condicionada a `environment.useExempleModule`)
- Atualizado `exemplos.module.ts`: importado `DocumentBuilderModule`; declarados `DocumentsComponent` e `TestDocBodyComponent`

**Por que:**
- `TestDocBodyComponent` precisa ser declarado em `ExemplosModule` (não em `DocumentBuilderModule`) pois é específico do exemplo, não da biblioteca
- `DocumentBuilderModule` deve ser importado em `ExemplosModule` para que os seletores dos componentes base (`app-doc-title`, etc.) estejam disponíveis no template de `TestDocBodyComponent`

**Build:** passou sem erros (21855ms); warnings CommonJS de canvg/jspdf são pré-existentes

---

## 2026-05-07 — TAREFA 06: Criar DocumentDebugComponent

**O que foi feito:**
- Adicionado `textMeasurable?: boolean` ao `LayoutComponent` em `layout.models.ts` — setado em `DocumentViewer.measureAll()` via `isTextMeasurable(instance)`
- Criado `src/shared/document-builder/components/document-debug/` — sidebar fixa à direita com fundo escuro semi-transparente, fonte monospace
- Painel exibe: total de páginas, orientação; por página (colapsável via `<details>`): espaço total/usado/livre, flags `[H]`/`[F]`/`[A]`/`[fake]`, e por componente: nome, altura, `[S]` se `Splittable`, `[T]` se `TextMeasurable`
- `DocumentDebugComponent` incluído no template do `DocumentViewerComponent` — aparece automaticamente quando `config.debug === true`
- `@media print { display: none }` garante ausência no PDF
- Atualizado `document-builder.module.ts`

**Por que:**
- `textMeasurable` precisa ser registrado durante a medição (onde `isTextMeasurable` é chamado) — depois dessa fase a instância não está mais disponível no viewer
- `<details>/<summary>` nativos eliminam a necessidade de estado Angular para colapsar páginas

**Build:** passou sem erros (13038ms)

---

## 2026-05-07 — TAREFA 05: Melhorar o PrintService

**O que foi feito:**
- `compress: false` → `compress: true` em `buildPdf()`
- Loop sequencial `for...of` substituído por `Promise.allSettled` — todas as páginas são convertidas para PNG em paralelo
- Páginas com erro de renderização logam `[PrintService] failed to render page N:` e são filtradas, sem interromper o restante do PDF

**Por que:**
- Geração paralela reduz o tempo total de conversão em documentos com múltiplas páginas
- `Promise.allSettled` (ao invés de `Promise.all`) garante que falha em uma página não aborta as demais
- `compress: true` reduz o tamanho do PDF sem perda de qualidade nas imagens

**Build:** passou sem erros (12900ms)

---

## 2026-05-07 — TAREFA 04: Criar DocumentPageComponent, DocumentViewerComponent e MeasurementService

**O que foi feito:**
- Adicionado ao `document-config.ts`: constantes de página (`PAGE_HEIGHT_PORTRAIT = 1123`, `PAGE_HEIGHT_LANDSCAPE = 794`, `PAGE_PADDING_V = 20`, `DOC_SIGNATURE_HEIGHT = 120`) e campo `city?` em `SignatureConfig`
- Criado `src/shared/document-builder/services/print.service.ts` — versão base do PrintService com parâmetros tipados (`HTMLElement[]`), sem cache de PDFs, sem import de `underscore`
- Criado `src/shared/document-builder/components/document-page/` — componente de página único; expõe `getElement()` e `getContentEl()`; `.fake` aplica `transform: scale(0)` para páginas de medição DOM
- Criado `src/shared/document-builder/services/measurement.service.ts` — mede via Pretext se `isTextMeasurable(instance)`, via DOM caso contrário; ambos síncronos
- Criado `src/shared/document-builder/components/document-viewer/` — orquestra 3 fases: (1) `measureAll()` cria componentes em container oculto e mede, (2) `LayoutEngine.distribute()`, (3) `detectChanges()` + `distributeElements()` move elementos para páginas reais
- Atualizado `document-builder.module.ts` com `DocumentPageComponent` e `DocumentViewerComponent`

**Por que:**
- `prepare()` do Pretext 0.0.6 é síncrono (não async como documentado anteriormente) — `MeasurementService` simplificado sem async
- `document.fonts.ready` ainda é aguardado no `init()` antes de qualquer `prepare()` para garantir métricas corretas de Canvas
- A distribuição de elementos via `appendChild` (mover de `measureHost` para `#content` da página) evita re-criar componentes e mantém o estado Angular

**Build:** passou sem erros (14927ms)

---

## 2026-05-07 — TAREFA 03: Criar os componentes base de conteúdo

**O que foi feito:**
- Instalado `@chenglou/pretext`
- Adicionado `TextMeasurable` + `isTextMeasurable()` ao `layout.models.ts`
- Adicionado `DocHeaderData`, `DocGridData`, `PAGE_CONTENT_WIDTH_PORTRAIT`, `PAGE_CONTENT_WIDTH_LANDSCAPE` ao `document-config.ts`
- Criados 9 componentes em `src/shared/document-builder/components/`:
  - `DocTitleComponent` — implementa `TextMeasurable`
  - `DocTextFieldComponent` — implementa `TextMeasurable`
  - `DocTextComponent` — implementa `TextMeasurable`
  - `DocLegendComponent` — implementa `TextMeasurable`
  - `DocHeaderComponent` — altura fixa (`DOC_HEADER_HEIGHT = 80`); logo em box `60×60px object-fit: contain`
  - `DocFooterComponent` — altura fixa (`DOC_FOOTER_HEIGHT = 18`)
  - `DocSignatureComponent` — typo "Outrubro" corrigido para "Outubro"; usa `SignatoryConfig[]`
  - `DocFrameComponent` — usa `FrameConfig`; estilos `blue`, `gold`, `gray`
  - `DocInfoGridComponent` — usa `DocGridData` com campos em inglês
- Atualizado `document-builder.module.ts` com todos os componentes declarados e exportados

**Por que:**
- `DocHeader` e `DocSignature` ficaram sem `TextMeasurable` pois o cálculo de altura depende de layout flex multi-elemento (logo+texto lado a lado; assinaturas em linha) — fallback DOM é mais correto para esses casos no MVP
- Tipos externos (`DadosCabecalho`, `Assinatura`, `GridInfo`) foram substituídos por interfaces próprias do módulo para eliminar dependência do `gerador-documentos`
- Constantes de fonte/padding declaradas em TypeScript ao lado do componente (ex: `DOC_TITLE_FONT`, `DOC_TITLE_LINE_HEIGHT`) para manter sincronia com o CSS

**Build:** passou sem erros (19017ms)
