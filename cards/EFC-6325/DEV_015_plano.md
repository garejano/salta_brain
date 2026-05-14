# DEV_015 — Multi-documento em um único PDF

**Repositório:** `estrutura-pedagogica`  
**Data do plano:** 2026-05-12

---

## Objetivo

Permitir que o `document-builder` gere vários documentos em um único PDF.
Caso de uso principal: histórico escolar de uma turma inteira — um documento por aluno, mas tudo em um único arquivo para download.

**Restrições:**
- Não quebrar o fluxo single-doc existente
- `PrintOverlayComponent` não precisa mudar
- `LayoutEngineService` e `PrintService` não precisam mudar

---

## Interface nova — `DocumentBundle`

**Arquivo:** `src/shared/document-builder/models/document-config.ts`

```typescript
export interface DocumentBundle {
  config: DocumentConfig
  headerData?: DocHeaderData
  entries: DocumentEntry[]
  label?: string  // label para debug
}
```

---

## `DocumentViewerComponent` — mudanças

**Arquivo:** `src/shared/document-builder/components/document-viewer/document-viewer.component.ts`

### Novo @Input
```typescript
@Input() documents?: DocumentBundle[]
```

### Novos campos privados
```typescript
private pageConfigs: DocumentConfig[] = []
private pageHeaderDatas: (DocHeaderData | undefined)[] = []
private pageLocalNumbers: { index: number; total: number }[] = []
private currentMeasureWidth = 0
```

### `init()` — delegação
```typescript
async init(): Promise<void> {
  if (this.isLoading) return
  this.isLoading = true
  try {
    await document.fonts.ready
    if (this.documents?.length) {
      await this.initMultiple(this.documents)
    } else {
      await this.initSingle()
    }
  } finally {
    this.isLoading = false
  }
}
```

### `initSingle()` — lógica atual extraída sem mudança funcional
```typescript
private async initSingle(): Promise<void> {
  this.currentMeasureWidth = this.getContentWidthFor(this.config)
  this.cdr.detectChanges()
  const layoutComponents = this.measureBundle(this.config, this.entries)
  const headerOnAllPages = this.config.header?.show
    ? (this.config.header.onAllPages ?? true)
    : false
  const firstH = this.getPageAvailableHeightFor(this.config, this.config.header?.show ?? false)
  const otherH = this.getPageAvailableHeightFor(this.config,
    this.config.header?.show ? headerOnAllPages : false)
  const sigH = this.config.signature?.show ? DOC_SIGNATURE_HEIGHT : 0
  const sigOnAll = this.config.signature?.onAllPages ?? false
  this.pages = this.layoutEngine.distribute(
    layoutComponents, firstH, otherH, sigH, sigOnAll, headerOnAllPages
  )
  this.pageConfigs = this.pages.map(() => this.config)
  this.pageHeaderDatas = this.pages.map(() => this.headerData)
  this.pageLocalNumbers = this.pages.map((_, i) => ({ index: i + 1, total: this.pages.length }))
  this.cdr.detectChanges()
  this.distributeElements()
  clearCache()
}
```

### `initMultiple()` — loop por bundle
```typescript
private async initMultiple(bundles: DocumentBundle[]): Promise<void> {
  this.pages = []
  this.pageConfigs = []
  this.pageHeaderDatas = []
  this.pageLocalNumbers = []

  for (const bundle of bundles) {
    this.currentMeasureWidth = this.getContentWidthFor(bundle.config)
    this.cdr.detectChanges()

    const layoutComponents = this.measureBundle(bundle.config, bundle.entries)
    const headerOnAllPages = bundle.config.header?.show
      ? (bundle.config.header.onAllPages ?? true)
      : false
    const firstH = this.getPageAvailableHeightFor(bundle.config,
      bundle.config.header?.show ?? false)
    const otherH = this.getPageAvailableHeightFor(bundle.config,
      bundle.config.header?.show ? headerOnAllPages : false)
    const sigH = bundle.config.signature?.show ? DOC_SIGNATURE_HEIGHT : 0
    const sigOnAll = bundle.config.signature?.onAllPages ?? false

    const bundlePages = this.layoutEngine.distribute(
      layoutComponents, firstH, otherH, sigH, sigOnAll, headerOnAllPages
    )

    this.pages.push(...bundlePages)
    this.pageConfigs.push(...bundlePages.map(() => bundle.config))
    this.pageHeaderDatas.push(...bundlePages.map(() => bundle.headerData))
    this.pageLocalNumbers.push(
      ...bundlePages.map((_, i) => ({ index: i + 1, total: bundlePages.length }))
    )
  }

  this.cdr.detectChanges()
  this.distributeElements()
  clearCache()
}
```

### `measureBundle()` — parametrizado (substitui `measureAll()`)
```typescript
private measureBundle(config: DocumentConfig, entries: DocumentEntry[]): LayoutComponent[] {
  const result: LayoutComponent[] = []
  const gap = config.componentGap ?? 0
  const contentWidth = this.getContentWidthFor(config)
  for (const entry of entries) {
    const ref = this.measureVcr.createComponent(entry.componentType as Type<{ data: unknown }>)
    const inputNames = new Set(
      reflectComponentType(entry.componentType as Parameters<typeof reflectComponentType>[0])
        ?.inputs.map(i => i.propName) ?? []
    )
    ref.setInput('data', entry.data)
    if (inputNames.has('contentWidth')) ref.setInput('contentWidth', contentWidth)
    if (config.fontSize !== undefined && inputNames.has('fontSize'))
      ref.setInput('fontSize', config.fontSize)
    this.cdr.detectChanges()
    const element = (ref.location as ElementRef<HTMLElement>).nativeElement
    const instance = ref.instance as object
    const measured = this.measurementService.measure(instance, element)
    const height = measured + gap
    const textMeasurable = isTextMeasurable(instance)
    const splittable = isSplittable(instance) ? (instance as Splittable) : undefined
    this.componentRefs.push(ref)
    result.push({
      name: entry.name ?? (entry.componentType as { name: string }).name,
      element, height, textMeasurable, splittable
    })
  }
  return result
}
```

### `getContentWidthFor()` e `getPageAvailableHeightFor()` — helpers parametrizados
```typescript
private getContentWidthFor(config: DocumentConfig): number {
  const margin = config?.margin ?? 10
  return (config?.orientation === 'landscape' ? 1123 : 794) - margin * 2
}

private getPageAvailableHeightFor(config: DocumentConfig, includeHeader: boolean): number {
  const isPortrait = config.orientation === 'portrait'
  const margin = config.margin ?? 10
  let available = (isPortrait ? PAGE_HEIGHT_PORTRAIT : PAGE_HEIGHT_LANDSCAPE) - margin * 2
  if (includeHeader) available -= DOC_HEADER_HEIGHT
  if (config.footer?.show) available -= DOC_FOOTER_HEIGHT
  return available
}
```

### `distributeElements()` — usa `pageConfigs[i]`
```typescript
private distributeElements(): void {
  const pageComps = this.pageComponents.toArray()
  this.pages.forEach((page, i) => {
    const contentEl = pageComps[i].getContentEl()
    const cfg = this.pageConfigs[i] ?? this.config
    const contentWidth = this.getContentWidthFor(cfg)
    page.components.forEach(lc => {
      if (lc.element) {
        contentEl.appendChild(lc.element)
      } else if (lc.renderData) {
        const ref = this.measureVcr.createComponent(
          lc.renderData.componentType as Type<{ data: unknown }>
        )
        ref.setInput('data', lc.renderData.data)
        ref.setInput('contentWidth', contentWidth)
        if (cfg.fontSize !== undefined) ref.setInput('fontSize', cfg.fontSize)
        this.cdr.detectChanges()
        contentEl.appendChild((ref.location as ElementRef<HTMLElement>).nativeElement)
        this.componentRefs.push(ref)
      }
    })
  })
}
```

### `print()` e `save()` — usam config do primeiro bundle em multi-doc
```typescript
private get activeConfig(): DocumentConfig {
  return this.documents?.[0]?.config ?? this.config
}

print(fileName?: string): Promise<void> {
  const elements = this.pageComponents.toArray().map(p => p.getElement())
  const cfg = this.activeConfig
  return this.printService.print(
    elements, fileName ?? cfg.title ?? 'documento', cfg.pdfQuality, cfg.printStrategy
  )
}

save(fileName?: string): Promise<void> {
  const elements = this.pageComponents.toArray().map(p => p.getElement())
  const cfg = this.activeConfig
  return this.printService.save(
    elements, fileName ?? cfg.title ?? 'documento', cfg.pdfQuality, cfg.printStrategy
  )
}
```

### `measureWidth` getter — usa `currentMeasureWidth` quando disponível
```typescript
get measureWidth(): number {
  return this.currentMeasureWidth || this.getContentWidthFor(this.config)
}
```

---

## Template — `document-viewer.component.html`

```html
<div class="measure-wrapper" [style.width.px]="measureWidth">
  <ng-container #measureHost></ng-container>
</div>

<div class="viewer-pages">
  <app-document-page
    *ngFor="let page of pages; let i = index"
    [page]="page"
    [config]="pageConfigs[i] ?? config"
    [index]="pageLocalNumbers[i]?.index ?? i + 1"
    [total]="pageLocalNumbers[i]?.total ?? pages.length"
    [headerData]="pageHeaderDatas[i] ?? headerData">
  </app-document-page>
</div>

<app-document-debug [pages]="pages" [config]="config"></app-document-debug>
```

> **Nota:** `DocumentDebugComponent` continua recebendo `this.config` — debug multi-doc não é escopo desta tarefa.

---

## Tela de exemplos — `documents.component.ts`

Adicionar uma nova seção "Multi-documentos" com:

### Interface para o sample multi-doc
```typescript
interface MultiDocumentSample {
  key: string
  label: string
  description: string
  fileName: string
  documents: DocumentBundle[]
}
```

### Exemplos a criar

| Sample key | Descrição | Bundles |
|---|---|---|
| `multi-historico-turma` | Histórico Escolar — Turma 9º A | 3 alunos, configuração landscape idêntica, entries com dados do aluno diferentes |
| `multi-declaracao-turma` | Declaração de Matrícula — Turma | 3 alunos, configuração portrait simples |

### Estrutura do bundle por aluno
```typescript
function criarHistoricoBundle(aluno: AlunoMock): DocumentBundle {
  return {
    config: { ...HISTORICO_CONFIG },
    headerData: MOCK_ESCOLA_HEADER,
    label: aluno.nome,
    entries: [
      { componentType: DocSectionComponent, data: { title: 'Identificação do Aluno' } },
      { componentType: DocInfoRowComponent, data: {
        fields: [
          { label: 'Nome', value: aluno.nome },
          { label: 'RA', value: aluno.ra },
          { label: 'Turma', value: aluno.turma },
        ]
      }},
      { componentType: DocTableComponent, data: {
        columns: ['Ano', 'Série', 'Disciplina', 'Nota', 'Freq.', 'Resultado'],
        rows: aluno.disciplinas,
      }},
      { componentType: DocStatementComponent, data: {
        text: 'O presente histórico é emitido a pedido do interessado.',
        centered: false,
      }},
    ],
  }
}
```

---

## UI — `documents.component.html`

Adicionar seção separada abaixo das seções existentes:

```html
<!-- Seção: Multi-documentos -->
<section class="samples-section">
  <h2>Multi-documentos</h2>
  <p class="section-desc">
    Vários documentos gerados em um único PDF — útil para emissão por turma.
  </p>
  <div class="samples-grid">
    <div class="sample-card" *ngFor="let s of multiSamples" (click)="openMultiDoc(s)">
      <div class="card-icon">...</div>
      <div class="card-body">
        <h3>{{ s.label }}</h3>
        <p>{{ s.description }}</p>
        <span class="badge">{{ s.documents.length }} documentos</span>
      </div>
    </div>
  </div>
</section>
```

O overlay existente (`PrintOverlayComponent`) é reutilizado — apenas muda o viewer para receber `[documents]="activeMultiDocSample.documents"` ao invés de `[config]` e `[entries]`.

---

## Arquivos a modificar

| Arquivo | O que muda |
|---|---|
| `models/document-config.ts` | Adicionar `DocumentBundle` |
| `document-viewer.component.ts` | Input `documents`, `initMultiple()`, `measureBundle()`, arrays por-página |
| `document-viewer.component.html` | Bindings por-página (`pageConfigs[i]`, `pageLocalNumbers[i]`) |
| `documents.component.ts` | Interface `MultiDocumentSample`, array `multiSamples`, método `openMultiDoc()` |
| `documents.component.html` | Nova seção "Multi-documentos" |

---

## O que NÃO muda

- `PrintService` — já recebe `HTMLElement[]`, agnóstico a quantos documentos existem
- `PrintOverlayComponent` — delega para viewer, sem mudança
- `LayoutEngineService` — chamado uma vez por bundle, sem mudança
- Todos os componentes base — sem mudança
- Fluxo single-doc — `initSingle()` preserva a lógica atual exata

---

## Comportamento da numeração de página

Cada documento tem sua própria numeração:
- Documento 1 (3 páginas): rodapé mostra **1/3**, **2/3**, **3/3**
- Documento 2 (2 páginas): rodapé mostra **1/2**, **2/2**

Isso é controlado por `pageLocalNumbers[]` no viewer — o `DocumentPageComponent` continua recebendo `[index]` e `[total]` como hoje, sem mudança nele.

---

## Limitação conhecida

Para documentos com orientações mistas (ex: bundle 1 retrato + bundle 2 paisagem), componentes que **não** têm `contentWidth` @Input medem via DOM e podem ter altura ligeiramente errada porque o `measure-wrapper` troca de largura entre bundles com `detectChanges()`. Componentes com `TextMeasurable` (Pretext) ou com `contentWidth` @Input não são afetados. Essa combinação é rara no uso real.
