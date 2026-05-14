# tarefas.md — Tarefas de implementação do `document-builder`

> As tarefas devem ser executadas em ordem.
> Ao concluir cada tarefa, registrar em `changelog.md`.

---

## TAREFA 01 — Criar o módulo `document-builder`

**Objetivo:** scaffoldar a estrutura base do novo módulo dentro de `shared/`.

**O que fazer:**
- Criar a pasta `src/shared/document-builder/`
- Criar o `document-builder.module.ts` exportando os componentes que serão criados nas tarefas seguintes
- Criar um `README.md` dentro do módulo com título e seção "Funcionalidades" vazia (será preenchido ao final)
- Criar a pasta `src/shared/document-builder/models/` com o arquivo `document-config.ts` contendo as interfaces:

```typescript
export type PageOrientation = 'portrait' | 'landscape'

export interface DocumentConfig {
  title?: string
  orientation: PageOrientation
  header?: HeaderConfig
  footer?: FooterConfig
  signature?: SignatureConfig
  frame?: FrameConfig
  debug?: boolean
}

export interface HeaderConfig {
  show: boolean
  onAllPages?: boolean
}

export interface FooterConfig {
  show: boolean
}

export interface SignatureConfig {
  show: boolean
  onAllPages?: boolean
  signatories?: string[]
}

export interface FrameConfig {
  show: boolean
  style?: 'blue' | 'gold' | 'gray'
}
```

- Criar a pasta `src/shared/document-builder/models/` com `layout.models.ts`:

```typescript
export interface LayoutComponent {
  name: string
  element: HTMLElement
  height: number
  splittable?: Splittable
}

export interface Page {
  id: string
  index: number
  fake: boolean
  showHeader: boolean
  showFooter: boolean
  showSignature: boolean
  components: LayoutComponent[]
  freeSpace: number
}

export interface Splittable {
  getRowsThatFit(availableHeight: number): number
  split(rowCount: number): { head: any; tail: any }
  getRowHeight(): number
}
```

**Critério de aceite:** módulo existe, compila sem erros, interfaces exportadas corretamente.

---

## TAREFA 02 — Criar o `LayoutEngine`

**Objetivo:** implementar o serviço central de distribuição de componentes entre páginas, sem dependência de DOM no cálculo.

**O que fazer:**
- Criar `src/shared/document-builder/services/layout-engine.service.ts`
- O serviço deve ser `@Injectable({ providedIn: 'root' })`
- Implementar o método principal:

```typescript
distribute(
  components: LayoutComponent[],
  pageAvailableHeight: number,
  signatureHeight: number,
  signatureOnAllPages: boolean
): Page[]
```

**Regras de distribuição:**
1. Começar com a primeira página e `freeSpace = pageAvailableHeight`
2. Para cada componente:
   - Se cabe inteiro: adicionar à página atual, subtrair `height` do `freeSpace`
   - Se não cabe e implementa `Splittable`: chamar `split()` com as linhas que cabem, adicionar `head` na página atual, abrir nova página e adicionar `tail` (recursivo se `tail` também não couber)
   - Se não cabe e não é `Splittable`: abrir nova página, adicionar inteiro
3. A última página deve reservar `signatureHeight` px se `showSignature = true`
4. Se `signatureOnAllPages = true`, todas as páginas reservam espaço de assinatura

- Criar `src/shared/document-builder/services/layout-engine.service.spec.ts` com testes unitários para:
  - Componente simples que cabe em uma página
  - Dois componentes onde o segundo não cabe — deve criar nova página
  - Componente `Splittable` que é dividido entre duas páginas
  - Reserva de espaço de assinatura na última página

**Critério de aceite:** testes passam, nenhuma chamada a DOM ou Angular dentro do `LayoutEngine`.

---

## TAREFA 03 — Criar os componentes base de conteúdo

**Objetivo:** criar os componentes base do `document-builder` em inglês, equivalentes aos do `gerador-documentos`, já preparados para medição via Pretext onde aplicável.

**Pré-requisito desta tarefa:**
- Instalar Pretext: `npm install @chenglou/pretext`
- Adicionar interface `TextMeasurable` ao `layout.models.ts` (ver contrato abaixo)
- Adicionar constantes de página ao `document-config.ts`: `PAGE_CONTENT_WIDTH_PORTRAIT`, `PAGE_CONTENT_WIDTH_LANDSCAPE` (largura da área de conteúdo em px, já descontado padding da página)

**Interface `TextMeasurable` a adicionar em `layout.models.ts`:**
```typescript
export interface TextMeasurable {
  getTextSegments(): Array<{ text: string; font: string }>
  getMaxWidth(): number      // largura do conteúdo em px — derivado da config, nunca do DOM
  getLineHeight(): number    // valor numérico em px — ex: 22 (não '1.5em')
  getVerticalPadding(): number // padding fixo do componente em px
}
```

**O que fazer:**

Criar cada componente abaixo em `src/shared/document-builder/components/`:

| Componente | Input principal | Implementa | Observação |
|---|---|---|---|
| `DocTitleComponent` | `title: string`, `centered?: boolean` | `TextMeasurable` | fonte: `'bold 18px Nunito'` |
| `DocHeaderComponent` | `institutionName: string`, `logoUrl?: string` | `TextMeasurable` | área do logo: **60×60px fixo** (`object-fit: contain`); texto via Pretext |
| `DocFooterComponent` | `currentPage: number`, `totalPages: number` | — | altura fixa (não depende de texto variável) |
| `DocSignatureComponent` | `signatories: SignatoryConfig[]`, `city?: string` | `TextMeasurable` | texto dos nomes/cargos via Pretext + padding fixo entre assinaturas |
| `DocFrameComponent` | `style: 'blue' \| 'gold' \| 'gray'` | — | borda pura, sem texto a medir |
| `DocInfoGridComponent` | `data: InfoGridData` | — | grid CSS multicoluna; colunas sem largura fixa por texto |
| `DocTextFieldComponent` | `label: string`, `value: string` | `TextMeasurable` | usar `prepareRichInline` para label negrito + valor normal |
| `DocLegendComponent` | `items: LegendItem[]` | `TextMeasurable` | `prepare` + `layout` por item; soma das alturas |
| `DocTextComponent` | `label: string`, `value: string` | `TextMeasurable` | fonte: `'14px Nunito'` |

Adicionar as interfaces de input em `models/document-config.ts`:

```typescript
export interface SignatoryConfig {
  role: string
  name?: string
}

export interface InfoGridData {
  [key: string]: string | undefined
}

export interface LegendItem {
  symbol: string
  description: string
}

// Larguras de conteúdo em pixels (A4, descontado padding de 10px em cada lado)
export const PAGE_CONTENT_WIDTH_PORTRAIT = 772   // 210mm ≈ 794px - 22px padding
export const PAGE_CONTENT_WIDTH_LANDSCAPE = 1102  // 297mm ≈ 1122px - 20px padding
```

**Regras de migração:**
- Copiar estilos e template do componente equivalente atual
- Renomear para inglês
- Substituir qualquer `any` por tipo concreto
- NÃO copiar lógica de layout (paginação, medição) — isso é responsabilidade do `LayoutEngine`
- Corrigir o typo "Outrubro" → "Outubro" no `DocSignatureComponent`
- Para cada componente que implementa `TextMeasurable`: declarar font string, line-height e padding como **constantes TypeScript** no arquivo do componente (não apenas no CSS) — risco de dessincronização se CSS mudar
- `DocHeaderComponent`: logo sempre em box `60px × 60px`, sem exceção

**Critério de aceite:**
- Todos os componentes compilam e são exportados pelo `document-builder.module.ts`
- `DocTitle`, `DocTextField` e `DocText` implementam `TextMeasurable` e têm `getTextSegments()`, `getMaxWidth()`, `getLineHeight()` e `getVerticalPadding()` retornando valores sem tocar DOM
- `DocHeaderComponent` tem área de logo com dimensões fixas no template

---

## TAREFA 04 — Criar `DocumentPageComponent` e `DocumentViewerComponent`

**Objetivo:** criar os componentes de infraestrutura que renderizam as páginas e orquestram o fluxo de print/save. O `DocumentViewer` recebe `DocumentEntry[]` — a API declarativa do desenvolvedor — e gerencia todo o ciclo interno (instanciação, medição, layout, render).

**O que fazer:**

### `DocumentPageComponent`
- Criar `src/shared/document-builder/components/document-page/`
- Inputs: `page: Page`, `config: DocumentConfig`, `index: number`, `total: number`
- Deve renderizar header, footer, frame e signature conforme a config e os flags da `Page`
- Expor `getElement(): HTMLElement` para uso no `PrintService`
- Páginas com `page.fake === true` têm `transform: scale(0)` — servem como container de medição DOM para componentes sem `TextMeasurable`

### `MeasurementService`
- Criar `src/shared/document-builder/services/measurement.service.ts`
- Responsabilidade: dado um componente instanciado, retornar sua altura em pixels

```typescript
@Injectable({ providedIn: 'root' })
export class MeasurementService {
  async measure(instance: object, element: HTMLElement): Promise<number>
  // internamente:
  //   se isTextMeasurable(instance) → measureWithPretext(instance)
  //   senão                         → measureWithDOM(element)

  private async measureWithPretext(component: TextMeasurable): Promise<number>
  private async measureWithDOM(element: HTMLElement): Promise<number>
}
```

### `DocumentViewerComponent`
- Criar `src/shared/document-builder/components/document-viewer/`
- Injeta `LayoutEngineService`, `MeasurementService` e `PrintService`

**Input público:**
```typescript
@Input() config: DocumentConfig
@Input() entries: DocumentEntry[]   // ← API do desenvolvedor
```

**Método `init()` — pipeline em 3 fases:**

```
FASE 1 — Instanciação e medição
  await document.fonts.ready        ← obrigatório antes de qualquer prepare() Pretext
  para cada entry em entries:
    instance = viewContainerRef.createComponent(entry.componentType)
    instance.setInput('data', entry.data)
    height  = await measurementService.measure(instance, instance.location.nativeElement)
    → acumula LayoutComponent[]

FASE 2 — Layout
  pages = layoutEngine.distribute(layoutComponents, pageAvailableHeight, signatureHeight, ...)

FASE 3 — Render
  destruir instâncias de medição
  renderizar DocumentPageComponent para cada page
  pretext.clearCache()              ← liberar cache após medição
```

**Métodos públicos:** `print(fileName?: string)`, `save(fileName: string)`

**`@ViewChildren(DocumentPageComponent)`** para acessar páginas renderizadas no print/save.

**Uso esperado pelo desenvolvedor:**
```typescript
// No template do documento:
<app-document-viewer [config]="docConfig" [entries]="entries" #viewer />

// No componente:
entries: DocumentEntry[] = [
  { data: this.grades,      componentType: GradeTableComponent,    name: 'Notas' },
  { data: this.attendance,  componentType: AttendanceComponent,     name: 'Frequência' },
  { data: this.signature,   componentType: DocSignatureComponent,   name: 'Assinatura' },
]

ngAfterViewInit() {
  this.viewer.init()
}
```

**Critério de aceite:**
- Developer só precisa preencher `DocumentEntry[]` e `DocumentConfig` — nenhuma lógica de paginação no componente do documento
- `init()` aguarda `document.fonts.ready` antes de medir
- Componentes com `TextMeasurable` não são montados na fake page
- Componentes sem `TextMeasurable` medem via DOM (fake page)
- `print()` e `save()` funcionam após `init()`

---

## TAREFA 05 — Melhorar o `PrintService`

**Objetivo:** adaptar o `PrintService` existente para o `document-builder`, aplicando as melhorias identificadas em `analise_melhorias.md`.

**O que fazer:**
- Copiar `print.service.ts` para `src/shared/document-builder/services/print.service.ts`
- Aplicar as melhorias:

**1. Geração paralela de imagens:**
```typescript
// substituir loop sequencial por:
const images = await Promise.all(
  pages.map(page => htmlToImage.toPng(page.getElement(), options))
)
```

**2. Ativar compressão:**
```typescript
// mudar compress: false → compress: true
new jsPDF({ ..., compress: true })
```

**3. Tratamento de erro por página:**
```typescript
const images = await Promise.allSettled(
  pages.map(page => htmlToImage.toPng(page.getElement(), options))
)
// páginas com erro devem logar o índice e não interromper o PDF
```

**4. Remover dependência de `underscore`** — não deve ser importado neste serviço.

**Critério de aceite:** PDF gerado com `compress: true`, geração de imagens paralela, erro em uma página não interrompe geração das demais.

---

## TAREFA 06 — Criar `DocumentDebugComponent`

**Objetivo:** criar o componente de debug de layout descrito em `product.md`.

**O que fazer:**
- Criar `src/shared/document-builder/components/document-debug/`
- O componente recebe `pages: Page[]` e `config: DocumentConfig`
- Renderizar como **sidebar fixa** à direita do viewer, visível apenas quando `config.debug === true`
- Conteúdo do painel:

**Header do painel:**
- Total de páginas
- Orientação
- Debug ativo: sim

**Por página (colapsável):**
- Número da página
- Espaço total / usado / livre (em px)
- `[H]` se tem header, `[A]` se tem assinatura, `[F]` se tem footer
- Lista de componentes:
  - Nome
  - Altura em px
  - `[S]` se implementa `Splittable`
  - `[T]` se implementa `TextMeasurable` (medido via Pretext, sem DOM)
  - Se dividido: `head (N linhas)` ou `tail`

**Estilo:**
- Fundo escuro semi-transparente, fonte monospace pequena
- Não deve interferir no layout de impressão — usar `@media print { display: none }`

**Critério de aceite:** painel aparece quando `debug: true`, dados correspondem ao layout real, some na impressão.

---

## TAREFA 07 — Criar rota `documents` no módulo de exemplos

**Objetivo:** criar a tela de exemplos para testar o `document-builder` sem dependência de backend.

**O que fazer:**
- Localizar o módulo de exemplos do projeto e adicionar uma nova rota `/documents`
- Criar `src/shared/document-builder/exemplos/documents/documents.component.ts`
- A tela deve listar pelo menos um documento de exemplo que usa o `document-builder`
- Criar um documento de exemplo simples: "Documento de Teste" com:
  - `DocHeaderComponent` com nome da escola mockado
  - `DocTitleComponent` com título
  - `DocTextFieldComponent` com alguns campos
  - `DocSignatureComponent` com dois signatários mockados
  - `DocumentViewerComponent` orquestrando tudo
- Dados devem ser completamente mockados — sem chamada de API

**Critério de aceite:** rota `/documents` acessível, documento de teste renderiza e imprime corretamente.

---

## TAREFA 08 — Implementar `Splittable` em um componente de tabela

**Objetivo:** validar o contrato `Splittable` com um componente real que quebra entre páginas, usando Pretext para calcular `getRowHeight()` sem DOM.

**O que fazer:**
- Criar `src/shared/document-builder/components/doc-table/doc-table.component.ts`
- O componente renderiza uma tabela genérica com `columns: string[]`, `rows: string[][]` e `rowHeight?: number`
- Implementar a interface `Splittable`:
  - `getRowHeight()`: usar Pretext para medir o texto da célula mais longa com a fonte da tabela — **sem DOM**:
    ```typescript
    getRowHeight(): number {
      const longestCell = this.findLongestCellText()
      const prepared = prepare(longestCell, DOC_TABLE_FONT)  // ex: '10px Nunito'
      const { height } = layout(prepared, this.columnWidth, DOC_TABLE_LINE_HEIGHT)
      return height + DOC_TABLE_CELL_PADDING_VERTICAL  // padding como constante TS
    }
    ```
  - `getRowsThatFit(availableHeight)`: `Math.floor(availableHeight / this.getRowHeight())`
  - `split(rowCount)`: retornar `SplitResult` com `headHeight` e `tail: LayoutComponent` completo
- `DOC_TABLE_FONT`, `DOC_TABLE_LINE_HEIGHT` e `DOC_TABLE_CELL_PADDING_VERTICAL` devem ser constantes TypeScript exportadas — não valores apenas no CSS
- Adicionar `DocTableComponent` ao documento de exemplo da TAREFA 07 com 50+ linhas para forçar quebra de página

**Critério de aceite:**
- `getRowHeight()` retorna valor correto sem nenhuma operação DOM
- Tabela com 50+ linhas quebra corretamente entre páginas sem lógica no documento de exemplo
- As constantes de fonte e padding estão declaradas em TypeScript e coincidem com o CSS

---

## TAREFA 09 — Atualizar o `README.md` do módulo

**Objetivo:** documentar o `document-builder` com as funcionalidades implementadas.

**O que fazer:**
- Preencher `src/shared/document-builder/README.md` com:
  - Visão geral do módulo
  - Como criar um documento (exemplo de código mínimo)
  - Lista de componentes base disponíveis, com coluna indicando se implementa `TextMeasurable` e/ou `Splittable`
  - Como implementar `Splittable` em um componente customizado
  - Como implementar `TextMeasurable` em um componente customizado (incluindo requisito de constantes TS para font/padding)
  - Como ativar o `DocumentDebug` e o que os indicadores `[S]` e `[T]` significam
  - Referência às interfaces principais de `document-config.ts`
  - Seção "Limitações do Pretext" com link para `analise/pretext_analise.md`

**Critério de aceite:** README descreve corretamente como usar o módulo sem precisar ler o código-fonte.

---

---

## Limitações do Pretext para implementação

Esta seção documenta o que o Pretext **não consegue fazer** e o que isso impõe ao desenvolvimento. Ler antes de implementar qualquer componente com `TextMeasurable`.

### Limitações técnicas da biblioteca

| Limitação | Impacto prático |
|---|---|
| `document.fonts.ready` obrigatório antes de `prepare()` | `DocumentViewer.init()` deve ser async e aguardar fontes carregadas |
| Canvas 2D obrigatório | Sem impacto — app roda em browser; mas impede uso em SSR puro |
| `Intl.Segmenter` obrigatório | Sem impacto — browsers do `browserslist` do projeto suportam |
| `system-ui` não confiável no macOS | Sempre usar `'Nunito'` explícito — nunca `font: inherit` em `getTextSegments()` |
| `white-space: pre` e `nowrap` não suportados | Sem impacto — documentos usam `white-space: normal` |
| `font-feature-settings` e `font-optical-sizing` não modelados | Sem impacto — projeto não usa features OpenType |
| `prepare()` é async | A fase de medição no `DocumentViewer` deve ser totalmente async |
| Cache cresce com texto variado | Chamar `clearCache()` após geração de PDF em documentos longos |

### O que Pretext NÃO mede

Estes casos **nunca** devem implementar `TextMeasurable` — continuam usando fake page DOM:

- Componentes cuja altura depende de `display: flex` com wrapping automático
- Componentes cuja altura depende de `display: grid` com linhas implícitas
- Componentes com `CSS calc()` dependente de tamanho do pai
- Imagens e elementos de mídia com dimensões não fixas
- Tabelas com `table-layout: auto` (largura de coluna pelo conteúdo mais largo)
- Qualquer componente com `overflow: visible` que cresce além do seu container

### Regras de implementação para `TextMeasurable`

Estas regras são obrigatórias para qualquer componente que implementar `TextMeasurable`:

1. **`getMaxWidth()` derivado de constante** — nunca ler `element.offsetWidth`. Usar `PAGE_CONTENT_WIDTH_PORTRAIT` ou `PAGE_CONTENT_WIDTH_LANDSCAPE` menos margens internas do componente (constantes TS).

2. **Font string explícito em TypeScript** — declarar como constante: `const DOC_TITLE_FONT = 'bold 18px Nunito'`. O CSS do componente deve usar a mesma fonte. Se o CSS mudar, a constante TypeScript **deve** ser atualizada junto.

3. **`getLineHeight()` em pixels numéricos** — não `1.5`, não `'normal'`. Calcular: `fontSize * lineHeightMultiplier`. Ex: `18 * 1.4 = 25.2`.

4. **`getVerticalPadding()` como constante** — declarar: `const DOC_TITLE_PADDING_V = 16`. Reflete o padding CSS total vertical (`padding-top + padding-bottom`). Atualizar junto com o CSS.

5. **Dessincronização é um risco real** — se o CSS mudar e as constantes TS não forem atualizadas, as alturas calculadas ficam erradas e o layout quebra silenciosamente. Por isso as constantes devem ficar no arquivo do componente (não em um arquivo de constantes global), próximas ao template.

---

## Ordem de execução recomendada

```
TAREFA 01 → TAREFA 02 → TAREFA 03 → TAREFA 04 → TAREFA 05
                                                      ↓
TAREFA 09 ← TAREFA 08 ← TAREFA 07 ← TAREFA 06 ←────┘
```

## Status

| Tarefa | Descrição | Status |
|---|---|---|
| 01 | Criar módulo `document-builder` | ✅ concluída |
| 02 | Criar `LayoutEngine` | ✅ concluída |
| 03 | Criar componentes base | ✅ concluída |
| 04 | Criar `DocumentPage` e `DocumentViewer` | ✅ concluída |
| 05 | Melhorar `PrintService` | ✅ concluída |
| 06 | Criar `DocumentDebug` | ✅ concluída |
| 07 | Criar rota `documents` | ✅ concluída |
| 08 | Implementar `Splittable` em tabela | ✅ concluída |
| 09 | Atualizar README do módulo | ✅ concluída |




## Tarefas do DEV para IA

DEV_001: 

existe uma lib: https://pretextjs.net/ que inovou na forma de calcular quanto um texto ocupa em tela sem
usar o DOM, isso seria uma melhoria inovadora em todo document-builder.

analise se ela pode ser usada e como isso pode impactar na forma de criar documentos. preciso de uma analisa minuciosa
no quanto o uso da lib ajudaria e quais problemas ela resolveria. crie um analise/pretext_analise.md 


DEV_002: meu pensamento eh que esse document-builder precisa ser facil para o desenvolvedor e IA usar,
gostaria que para o desenvolvedor informar os "componentes" de um documento fosse basicamente definir uma lista exemplo

[
  {data:data.x, componentType: TabelaAulasComponent},
  {data:data.y, componentType: TabelaDisciplinasComponent},
  {data:data.z, componentType: FrequenciaAluno},
]

como isso pode funcionar no que ja temos construido?



DEV_003: ✅ CONCLUÍDA
Na tela de exemplos o funcionamento nao eta como esperado.
- a tela deve ter botoes para testar uma lista de documentos que vai ser feita para teste
- a tela tem que ser um "controlador de teste para geracao de documentos"

o documento fica visivel em um componente (que existia no outro repositorio e agora estou adicionando nesse) 
o componente eh overlay-impresao que esta no gerador-documentos

- overlay-impressao deve ser refeito e adicionado ao modulo document-builder (pode renomear para print-overlay)

toda visualizacao de documento eh feita dentro do print-overlay

**Implementado:**
- `PrintOverlayComponent` criado em `src/shared/document-builder/components/print-overlay/`
  - Backdrop escuro + barra de controle azul (mesmo visual do overlay-impressao)
  - Botões Imprimir e Salvar PDF
  - Botão voltar (fechar)
  - `ng-content` para receber o `DocumentViewerComponent`
  - Sem os selects de tipo/ano/segunda-via (específicos do gerador-documentos legado)
  - `@media print { display: none }` na barra de controle
  - Adicionado ao `document-builder.module.ts`
- Tela de exemplos (`src/app/features/exemplos/documents/`) refatorada para controlador de testes:
  - 4 documentos de teste: simples, tabela retrato, tabela paisagem, debug ativo
  - Grid de cards — clicar em um card abre o `PrintOverlayComponent` com o `DocumentViewerComponent` dentro
  - `viewer.init()` chamado via `setTimeout(0)` após overlay abrir (aguarda ciclo de renderização)
  - Botões do overlay delegam para `viewer.print()` e `viewer.save()`



DEV_004: ✅ CONCLUÍDA

- o numero da pagina sempre vai no canto direito inferior (
  pelo que analise o que acontece eh que o componente da assinatura, como por padrao eh o ultimo da pagina quando ele existe,
  esta fazendo com que o componente de numero da pagina fique acima da assinatura.  
)

a estrutura de uma pagina tem uma logica fixa

**Causa raiz:** em `document-page.component.html` a ordem era `content → footer → signature`.
Com `flex-direction: column` e `flex:1` no content, a assinatura ficava embaixo do footer/número de página.

**Correção:** invertida a ordem para `content → signature → footer`.
A matemática do layout NÃO mudou — ambos têm altura fixa e são irmãos do `flex:1`, então o espaço disponível para o content continua exatamente o mesmo.

**Estrutura de página agora:**
```
page-inner (flex column, height: 100%)
  ├── header  (altura variável, opcional)
  ├── content (flex:1 — cresce para preencher)
  ├── signature (120px fixo, opcional — acima do rodapé)
  └── footer  (18px fixo — sempre no fundo: "sem emendas" + número de página)
```



DEV_005: ✅ CONCLUÍDA
- incluir uma configuracao para definir o gap entre componentes dentro de uma pagina

**Implementado:**
- `DocumentConfig.componentGap?: number` — espaçamento em px entre componentes (padrão: 0)
- `DocumentViewerComponent.measureAll()` — soma `gap` à altura medida de cada componente, para que o LayoutEngine reserve o espaço corretamente
- `document-page.component.html` — `[style.gap.px]="config.componentGap ?? 0"` no `#content`
- `document-page.component.scss` — `#content` virou flex container coluna para o `gap` CSS funcionar
- Documento de exemplo "Tabela retrato" atualizado com `componentGap: 12`

**Nota de design:** o gap é somado a cada componente (não N-1), reservando 1 gap extra por página. Com gaps típicos (8–16px) a diferença é imperceptível e evita subflow.


DEV_006: ✅ CONCLUÍDA
Modificar a forma de 'criar a config de um documento'.

**Implementado em `documents.component.ts`:**
- Criada interface `DocumentDefinition { config, headerData, entries }` — contrato mínimo de um documento
- `DocumentSample extends DocumentDefinition` — adiciona `key`, `label`, `description`, `fileName`
- Cada documento extraído para uma `const` independente (`docSimples`, `docTabelaRetrato`, `docTabelaPaisagem`, `docDebug`)
- Array `samples` usa spread (`...docSimples`) — apenas metadados de exibição inline

**Padrão resultante para novos documentos:**
```typescript
const docListaPresencaSemanal: DocumentDefinition = {
  config: { orientation: 'portrait', ... },
  headerData: HEADER_DATA,
  entries: [
    { componentType: ListaPresencaComponent, data: dados, name: '...' },
  ],
}
```

DEV_007: ✅ CONCLUÍDA

**Causa raiz das páginas em branco — 3 problemas identificados:**

1. **`html-to-image` first-render bug** — na 1ª chamada a `toPng()`, recursos externos
   (fontes, imagens) não estão no cache do contexto SVG clonado → canvas renderiza branco.
   Fix: double-render (1ª chamada aquece o cache, 2ª captura o resultado real).

2. **Memory pressure (OOM silencioso)** — `pixelRatio: 4` × 10 páginas em paralelo ≈ 570MB
   de canvas simultâneo. O browser descarta canvases silenciosamente → páginas em branco.
   Fix: `pixelRatio: 2` no preset padrão; modo `sequential` disponível no preset `high`.

3. **`cacheBust: true`** — forçava re-fetch entre as duas chamadas do double-render,
   impedindo que o aquecimento do cache funcionasse. Removido.

**Implementado em `print.service.ts`:**
- `PdfQuality = 'draft' | 'standard' | 'high'` — tipo exportado
- `PdfRenderPreset` — interface exportada com `pixelRatio`, `quality`, `doubleRender`, `sequential`, `skipFonts`
- `PDF_RENDER_PRESETS` — constante exportada com os 3 presets
- `ACTIVE_PRESET` — constante no topo do arquivo para mudança global
- `renderPage()` — aplica double-render automaticamente quando `preset.doubleRender === true`
- Modo sequencial para preset `high` (evita pico de memória em docs longos)
- `await document.fonts.ready` antes de qualquer renderização
- Comentário inline documentando cada causa e fix

**`DocumentConfig.pdfQuality?: 'draft' | 'standard' | 'high'`** — para override por documento.

**Guia de debug:**
```
branco no 'standard' → testar 'draft' (sem fontes, sem double-render)
  ainda branco → problema de DOM/visibilidade, não de recurso
  funciona em draft → problema de fonte/imagem externa → usar 'high' (sequential)
```


DEV_008: ✅ CONCLUÍDA

**Causa raiz confirmada:** pipeline SVG da `html-to-image` (DOM → SVG → canvas) não carrega
recursos externos no contexto clonado → canvas em branco. Double-render (DEV_007) não
foi suficiente em todos os browsers.

**Estratégia adotada:**
- `Imprimir` → `'css'` (padrão): `window.print()` com `@media print` CSS. Zero risco de branco,
  renderização nativa, máxima performance.
- `Salvar PDF` → `'html2canvas'` (padrão): renderiza DOM diretamente em canvas sem pipeline SVG.
  Elimina a causa raiz.
- `'html-to-image'` → mantido como fallback com double-render.

**Instalado:** `html2canvas` v1.4.1

**Implementado em `print.service.ts`:**
- `PrintStrategy = 'css' | 'html2canvas' | 'html-to-image'`
- `ACTIVE_PRINT_STRATEGY = 'css'` e `ACTIVE_SAVE_STRATEGY = 'html2canvas'` (conf. central)
- `printWithCSS()` — estratégia sem library
- `getImagesViaHtml2canvas()` — estratégia sem pipeline SVG
- `getImagesViaHtmlToImage()` — fallback com double-render

**`DocumentConfig.printStrategy?`** — override por documento.

**`@media print` CSS adicionado em:**
- `print-overlay.component.scss` — esconde backdrop, controles e margens
- `document-viewer.component.scss` — esconde measure-wrapper, remove fundo cinza
- `document-page.component.scss` — uma página por folha (`break-after: page`)

**Análise completa:** `EFC-666/doc_builder_lib_analise.md`


## DEV_009 — Correção da quebra de tabela entre páginas ✅ CONCLUÍDA

**Problema:** `DocTableComponent.getRowsThatFit()` não subtraía `DOC_TABLE_HEADER_HEIGHT` (24px) antes de dividir pela altura da linha. Isso fazia o layout engine colocar linhas demais na cabeça (head) da divisão — as linhas excedentes ficavam ocultas por `overflow: hidden`, e a cauda (tail) começava mais tarde do que deveria, causando as linhas "desaparecidas" entre as páginas.

**Correção em `doc-table.component.ts`:**
- `DocTableComponent.getRowsThatFit`: `Math.floor((availableHeight - DOC_TABLE_HEADER_HEIGHT) / rowHeight)`
- `createTableSplittable.getRowsThatFit`: mesma correção
- `createTableSplittable.split`: passa `headLc` por referência e atualiza `renderData.data` para a fatia correta de linhas ao dividir tails subsequentes (fix do bug de head com dados errados em splits de nível 2+)
- `DocTableComponent.split`: cria `tailLc` separadamente antes de construir o `Splittable` para poder passar a referência ao `createTableSplittable`

DEV_010:
- incluir nos exemplos de documentos, novos documentos com tabelaas que tenha 100,500,1000 items na tebela

- incluir documentos que possuem mais de 1 tabela e que entre as tabelas tenha outros elemeentos (o objetivo eh testar a quebra de tabelas entre paginas)


## DEV_011 — Cabeçalho configurável: primeira página ou todas ✅ CONCLUÍDA

**`HeaderConfig.onAllPages?: boolean`** já existia no modelo — apenas faltava a implementação.

**Comportamento:**
- `header: { show: true }` ou `header: { show: true, onAllPages: true }` → cabeçalho em todas as páginas (padrão anterior)
- `header: { show: true, onAllPages: false }` → cabeçalho apenas na página 1; páginas 2+ têm `DOC_HEADER_HEIGHT` a mais de espaço disponível

**Impacto na altura (ponto crítico da tarefa):**
- `firstPageHeight` = base − header − footer (página 1 tem cabeçalho)
- `otherPageHeight` = base − footer (páginas 2+ sem cabeçalho, mais espaço)
- Layout engine usa as duas alturas separadamente: `freeSpace` da página 1 ≠ `freeSpace` das páginas seguintes
- Componentes `Splittable` (ex: `DocTableComponent`) recebem o `freeSpace` correto de cada página ao chamar `getRowsThatFit(freeSpace)` — não há underflow nem overflow ao dividir tabelas que começam na página 1 e continuam na 2+

**Arquivos alterados:**

`layout-engine.service.ts`:
- `distribute()` agora recebe `firstPageHeight`, `otherPageHeight` e `headerOnAllPages` em vez de um único `pageAvailableHeight`
- `createPage()` aceita `showHeader: boolean` (default `true`)
- Páginas 2+ criadas com `showHeader = headerOnAllPages`
- `applySignature()` usa `otherPageHeight` para a página extra de assinatura (que nunca tem cabeçalho)

`document-viewer.component.ts`:
- `getPageAvailableHeight(includeHeader: boolean)` — extraído como helper
- `init()` calcula `firstPageHeight` e `otherPageHeight` separadamente e passa ao layout engine

`documents.component.ts`:
- Novo sample `header-first-only` com `onAllPages: false` e 60 linhas de tabela para demonstrar a diferença de espaço entre páginas

## DEV_012 — Lista de Presença reimplementada com document-builder ✅ CONCLUÍDA

**Análise do legado (`gerador-documentos/exemplos/lista-presenca`):**
- 3 variantes geradas por templates HTML string com placeholders (`@turma`, `@studentsList`, etc.)
- Paginação manual: `limitePrimeiraPagina` / `limite` por tipo, `divideEmPaginas()` custom
- PDF via `html2pdf.js`, sem type safety, sem Splittable

**Reimplementação com document-builder:**
Cada variante usa `DocTableComponent` (já implementa `Splittable` — paginação automática) + `TestDocBodyComponent` (bloco de info da turma/data/inspetor).

| Variante | Orientação | Colunas da tabela | Sample key |
|---|---|---|---|
| Diária | Retrato A4 | Nº, RA, Nome, Assinatura | `presenca-diaria` |
| Semanal | Paisagem A4 | Nº, RA, Nome, Seg, Ter, Qua, Qui, Sex, Sáb | `presenca-semanal` |
| Mensal | Paisagem A4 | Nº, RA, Nome, 1–31 | `presenca-mensal` |

**Melhoria técnica adicionada — `DocTableData.measureColumnWidth?`:**
Para a mensal (34 colunas), `columnWidth = 772/34 ≈ 22px` faria o Pretext medir o nome como 12+ linhas (vs 1 linha real). O campo `measureColumnWidth?: number` sobrescreve a largura usada na medição Pretext. Semanal e mensal usam `measureColumnWidth: 200` — largura aproximada da coluna de nome.

**Dados mockados:** 25 alunos com nomes reais, RA `2024001`–`2024025`, turma 9º Ano A.

**`header.onAllPages: false`** aplicado — cabeçalho institucional só na página 1; páginas seguintes têm mais espaço para linhas de alunos.

**Arquivos alterados:**
- `document-config.ts` — `measureColumnWidth?: number` em `DocTableData`
- `doc-table.component.ts` — `columnWidth` getter usa `data.measureColumnWidth` quando fornecido
- `documents.component.ts` — `PRESENCA_ALUNOS`, `docPresencaDiaria`, `docPresencaSemanal`, `docPresencaMensal`, 3 novos samples


DEV_013:
A lista-presenca esta usando para Turno, Data,Inspecto,N de Presenca no comonente TestDocBodyComponent
mas isso no documento atual eh uma tabela simples que o usuario preenche manualmente na primeira pagina

essa tabela nao tem cabecalho (eh mais um grid para organizar a informacoes e permitir que o usuario anote algo)
nesse modelo:


| NomeTurma Vem do Sistema | Data |
| Inspetor: usuario preenche | Numero Presencas|

todos os 3 modelos devem ser assim.

crie um componente para isso que pode ser usado no document-builder


DEV_014: no exemplo mensal vi que a tabela esta quebrando para a segunda pagina, mesmo nao tendo necessidade, fica aparecendo apenas o cabecalho na segunda pagina

DEV_015:

repositorio: estutura-pedagogica
use repository-map 

nova features: ser possivel gerar varios documentos em apenas 1 pdf.
podem ter casos onde vou ter dados para gerar multiplas versoes do mesmo documento.
no caso de gerar historico para uma turma inteira.

normalmente seria 1 pdf por aluno, mas em alguns casos, pode ser necessario que todos os alunos gerem no mesmo pdf.

- nao deve quebrar a forma que funciona atualmente
- o document-viewer e o overlay tm que ser capaz de lidar com mltiplos documentos.
- na tela de exemplos de documentos crie uma sessao para tertarmos multiplos documentos


o document-builder precisa ser capaz de lidar com isso, 


---


DEV_016: Critico

as tabelas que vao nos documentos, atualmente tem padding: 4px 6px; isso eh ok, mas tem casos onde a escola precisa economizar folhas.
entao, pode ser necessario diminuir esses paddings para que a tabela ocupe menos espaco.

- por padrao, esse padding pode continuar 4px 6px
- deve ser poossivel configurar esse padding para os componentes com tabelas, (seria interessante que componentes desse tipo, com split e tabela tivessem que assinar algma interface e isso fique documentado) para ter garantia dessa funcionalidade
- na configuracao, crie uma nova sessao para configuracao do padding
- essa configracao so fica visivel se algum documento possui componentes do tipo tabela que implementem a configuracao de padding
- no arquivo Painel de COnfiguracao.html tem uma sessao Padding das células deve ser implementado visualmente da mesma forma.
- o tamanho do padding tem que ser usado para calcular o espaco que uma tabela ocupa na pagina e garantir que a quebra funcione corretamente


---


## DEV_017 — `DocWideTableComponent`: quebra de colunas + linhas ✅ CONCLUÍDA

**Problema:** tabelas com muitas colunas (ex: lista de presença mensal com 31 dias) ultrapassam
a largura da página. O `DocTableComponent` não tem mecanismo para quebrar colunas.

**Solução — nova interface `ColumnSplittable` + `DocWideTableComponent`:**

### Interface `ColumnSplittable` (`layout.models.ts`)
```typescript
interface ColumnSplittable {
  splitColumns(pageContentWidth: number): LayoutComponent[]
}
```
- Retorna um `LayoutComponent` por grupo de colunas
- Cada grupo pode ainda implementar `Splittable` (quebra por linhas)
- `DocumentViewer.measureBundle()` detecta via `isColumnSplittable()` e expande o entry em múltiplos `LayoutComponent`s
- Componentes existentes NÃO são afetados — sem mudança de comportamento

### `DocWideTableComponent` (`components/doc-wide-table/`)
- Implementa `ColumnSplittable` — **componente fábrica**, não renderiza nada diretamente
- `splitColumns(contentWidth)` divide as colunas em grupos que cabem na largura da página
- Cada grupo é renderizado como `DocTableComponent` (reuso total da infra existente)
- `getRowHeight()` mede por coluna via Pretext (mais preciso que `DocTableComponent` para tabelas com colunas de larguras muito diferentes)
- Suporta `fixedColumns?: number` — colunas repetidas em todos os grupos (ex: Nº, RA, Nome)

### `DocWideTableData` (`document-config.ts`)
```typescript
interface DocWideTableData {
  name?: string
  columns: string[]
  rows: string[][]
  columnWidths?: number[]     // px explícito por coluna
  dataColumnWidth?: number    // largura uniforme quando columnWidths ausente; padrão 40
  fixedColumns?: number       // primeiras N colunas em todos os grupos; padrão 0
}
```

### Inputs aceitos pelo `DocumentViewer` (automático via reflexão)
`data`, `contentWidth`, `fontSize`, `cellPadding`, `cellPaddingH`

### Exemplos adicionados (`documents.component.ts`)
| Key | Descrição | Grupos de colunas | Páginas |
|---|---|---|---|
| `presenca-mensal-wide` | Lista mensal com 40px/dia (paisagem) | 2 (dias 1–20, 21–31) | ~2 |
| `wide-relatorio` | Boletim com 10 disciplinas × 75px (retrato, 50 alunos) | 2 (disc. 1–8, 9–11) + quebra por linha | ~4 |

### Arquivos alterados
- `models/layout.models.ts` — `ColumnSplittable`, `isColumnSplittable`
- `models/document-config.ts` — `DocWideTableData`
- `components/doc-wide-table/` — novo componente (3 arquivos)
- `components/document-viewer/document-viewer.component.ts` — `measureBundle()` com `isColumnSplittable` check
- `document-builder.module.ts` — declaração e export
- `documents.component.ts` — 2 novos samples



---
DEV_018: ✅ PLANEJADA — ver `dev018_plano.md` e `dev018_design_description.md`

~~Planejar / Critico~~

Um dos problemas prncipais de gerara documento eh a quantidade de paginas, por motivos de economia de papel
quanto mentos paginas um documento gerar melhor.
as configuracoes existente tem essa finalidade, dar ao usuario a liberdade de conseguir gerar o documento qeu ele quer (e ele pode querer o minimo de paginas)

objetivo: planejar uma feature "reduzir o minimo de paginas"
onde a ideia eh ir de forma organizada reduzindo as configuracoes (gap, font-size, margem, padding da celula da tabela e etc) ate ter o minimo de pagnas possiveis.
- nao deve reduzir tudo ao minimo e inicio e sim aos poucos e ir validando se reduziu paginas o suficiente
- deve ter um 'loading' que exiba o que a ferramenta esta tentando fazer no documento para reduzir as paginas (uma forma do usuario visualizar a acao de forma amigavel)
- crie uma descricao que vou usar no 'claude design' para decrever a funcionalidade e ele gerar o design
- o design sera anexado e referenciado no plano posteriormente



## Status das DEV Tasks

| Task | Descrição | Status |
|---|---|---|
| DEV_001 | Análise da lib Pretext | ✅ concluída — ver `analise/pretext_analise.md` |
| DEV_002 | API declarativa `DocumentEntry[]` | ✅ concluída — implementado em `DocumentViewerComponent` |
| DEV_003 | Tela de exemplos + `PrintOverlayComponent` | ✅ concluída |
| DEV_004 | Ordem correta footer/assinatura na página | ✅ concluída |
| DEV_005 | `componentGap` na config do documento | ✅ concluída |
| DEV_006 | Refatoração `DocumentDefinition` + `DocumentSample` | ✅ concluída |
| DEV_007 | Fix páginas em branco (double-render + pixelRatio) | ✅ concluída |
| DEV_008 | Estratégias de print/save (`css`, `html2canvas`, fallback) | ✅ concluída — ver `analise/doc_builder_lib_analise.md` |
| DEV_009 | Fix quebra de tabela (`getRowsThatFit` com header height) | ✅ concluída |
| DEV_010 | Exemplos com tabelas grandes (100/500/1000 linhas + multi-tabela) | 🔲 pendente |
| DEV_011 | Cabeçalho só na primeira página (`onAllPages: false`) | ✅ concluída |
| DEV_012 | Lista de Presença reimplementada (diária, semanal, mensal) | ✅ concluída |
| DEV_013 | Componente `DocPresencaInfoComponent` para cabeçalho de presença | 🔲 pendente |
| DEV_014 | Fix tabela mensal quebrando para segunda página desnecessariamente | 🔲 pendente |
| DEV_015 | Gerar múltiplos documentos em um único PDF | ✅ concluída |
| DEV_016 | Padding configurável nas tabelas | 🔲 pendente |
| DEV_017 | `DocWideTableComponent` — quebra de colunas + linhas | ✅ concluída |
| DEV_018 | Feature "Minimizar páginas" | ✅ concluída |



