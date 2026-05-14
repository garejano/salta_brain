# Editor de Documentos — Plano de Produto e Implementação

> **Contexto**: O `DocumentViewerComponent` já existe e funciona — ele recebe `DocumentEntry[]` + `DocumentConfig` e produz páginas prontas para impressão/PDF. Esta feature adiciona uma tela que **produz** essa entrada: um editor visual WYSIWYG que monta o documento por blocos e entrega o resultado ao viewer existente.

---

## 1. Problema e Proposta de Valor

Hoje, criar um documento requer escrever código TypeScript: definir `entries[]`, escolher `componentType`, montar `data`. Isso funciona para templates fixos, mas impede que usuários não-técnicos (diretores, secretários) criem ou ajustem documentos sem um desenvolvedor.

O editor resolve isso expondo a API do document-builder como uma interface visual drag-and-drop.

**O que o usuário consegue fazer:**
- Abrir o editor, escolher uma orientação e ver a folha em branco
- Arrastar blocos da biblioteca para a folha (ou clicar para inserir)
- Configurar cada bloco pelo painel direito
- Reordenar blocos arrastando pelo handle
- Visualizar o resultado paginado (usando o viewer existente)
- Gerar PDF / Imprimir sem sair do editor

---

## 2. Refinamento da Tela Design

O mockup `Novo Documento.html` estabelece o esqueleto certo. Abaixo, cada decisão de refinamento com justificativa.

### 2.1 Layout Geral: 3 painéis

```
┌─────────────────────────────────────────────────────────┐
│ TOPBAR (64px)  ← back | nome doc | ações                │
├──────────┬─────────────────────────────┬────────────────┤
│  LEFTRAIL│        CANVAS               │  RIGHTRAIL     │
│  288px   │     (scroll livre)          │    320px       │
│  Blocos  │  ┌──── A4 sheet ────┐       │ Doc / Bloco    │
│  Drag &  │  │  [bloco 1]       │       │  Inspector     │
│  Drop    │  │  [bloco 2]       │       │                │
│          │  │  ...             │       │                │
└──────────┴─────────────────────────────┴────────────────┘
```

**Decisão**: o canvas é modo **Edição** — não pagina. Blocos ficam empilhados num único scroll. A paginação acontece apenas ao apertar "Visualizar" (abre `PrintOverlayComponent` com `DocumentViewerComponent`).

**Motivo**: paginar em tempo real exigiria rodar `LayoutEngineService` a cada keypress, o que é pesado. A edição plana é mais rápida e previsível.

### 2.2 Modos do Canvas

| Modo | Descrição | Implementação |
|------|-----------|---------------|
| **Editar** | Blocos empilhados com handles, seleção, toolbars | Renderização própria do editor |
| **Pré-visualizar** | Paginado, igual ao output final | `DocumentViewerComponent` dentro de `PrintOverlayComponent` |
| **JSON** | Dump do `DocumentDefinition` serializado | `<pre>` com `JSON.stringify` |

### 2.3 Bloco vs. Entry

Cada "bloco" no editor corresponde a um `DocumentEntry` + metadados de editor:

```typescript
interface EditorBlock {
  id: string;                       // UUID para tracking
  type: BlockType;                  // chave no registro de blocos
  data: unknown;                    // dado tipado para o componentType
  label?: string;                   // rótulo visual (nome do entry)
}
```

O `DocumentEntry[]` é derivado de `EditorBlock[]` no momento de gerar preview/print.

### 2.4 Biblioteca de Blocos — o que expor

Mapeamento de blocos disponíveis para criar no editor:

| Categoria | Label UI | `BlockType` | `componentType` | Data padrão |
|-----------|----------|-------------|-----------------|-------------|
| Identificação | Cabeçalho da escola | `header` | `DocHeaderComponent` | HEADER_DATA do contexto |
| Identificação | Título | `title` | `DocTitleComponent` | `{ title: '', border: false, centered: true }` |
| Identificação | Dados do aluno | `info-grid` | `DocInfoGridComponent` | campos vazios |
| Identificação | Linha de dados | `info-row` | `DocInfoRowComponent` | 2 campos vazios |
| Conteúdo | Texto rico | `statement` | `DocStatementComponent` | `{ text: '' }` |
| Conteúdo | Seção | `section` | `DocSectionComponent` | `{ title: '' }` |
| Dados | Tabela | `table` | `DocTableComponent` | 3 colunas, 0 linhas |
| Encerramento | Assinaturas | `signature` | *(gerenciado via config)* | — |

> **Nota sobre assinaturas**: assinatura não é um `DocumentEntry` — é parte do `DocumentConfig.signature`. O bloco "Assinaturas" no editor modifica `config.signature`, não cria um entry. Isso mantém compatibilidade com o layout engine (que usa `DOC_SIGNATURE_HEIGHT` fixo).

### 2.5 Inspector: aba Documento

Mapeia diretamente para `DocumentConfig`:

| Campo UI | Propriedade | Tipo |
|----------|-------------|------|
| Orientação | `orientation` | `'portrait' \| 'landscape'` |
| Margem (px) | `margin` | `number` |
| Gap entre blocos | `componentGap` | `number` |
| Tamanho da fonte | `fontSize` | `number` |
| Qualidade PDF | `pdfQuality` | `PdfQuality` |
| Cabeçalho em todas as páginas | `header.onAllPages` | `boolean` |
| Rodapé | `footer.show` | `boolean` |
| Assinaturas | `signature.show` + `signatories[]` | — |
| Frame decorativo | `frame.show` + `frame.style` | — |

### 2.6 Inspector: aba Bloco

Cada `BlockType` tem um formulário próprio. Exemplos:

**`title`**:
- Input: Texto do título
- Toggle: Centralizado / alinhado esquerda
- Toggle: Borda inferior

**`statement`**:
- Textarea: Texto (rich text simplificado)
- Toggle: Centralizado

**`table`**:
- Lista de colunas editável (nome + largura manual opcional)
- Botão: + Adicionar coluna
- Número de linhas de exemplo (para pré-visualização)

**`section`**:
- Input: Título da seção
- Input: Subtítulo (opcional)

**`info-row`**:
- Lista de pares label/valor
- Botão: + Adicionar campo

### 2.7 Validações e Limitações de Escopo (v1)

O que **não** entra na v1 para manter escopo tratável:

- Drag-and-drop entre páginas (só reordenação na lista)
- Zoom no canvas
- Undo/redo (estado em memória, não histórico)
- Persistência no backend (salva apenas na sessão / localStorage)
- Variáveis dinâmicas `{{aluno.nome}}` (inserção manual de texto; bindings automáticos ficam para v2)
- Importar/exportar template como arquivo

---

## 3. Arquitetura

### 3.1 Posição na estrutura de pastas

```
src/
└── app/
    └── features/
        └── document-editor/                 ← nova feature
            ├── document-editor.module.ts
            ├── document-editor-routing.module.ts
            ├── document-editor.component.ts  ← componente raiz
            ├── document-editor.component.html
            ├── document-editor.component.scss
            ├── components/
            │   ├── editor-topbar/
            │   ├── block-library/
            │   ├── editor-canvas/
            │   ├── block-inspector/
            │   └── block-editor-forms/       ← um sub-componente por BlockType
            │       ├── title-editor-form/
            │       ├── statement-editor-form/
            │       ├── table-editor-form/
            │       └── ...
            ├── models/
            │   └── editor.models.ts          ← EditorBlock, BlockType, BlockDef
            └── services/
                ├── block-registry.service.ts ← mapa BlockType → componentType + form
                └── document-editor-state.service.ts ← estado reativo dos blocos
```

O módulo do editor importa `DocumentBuilderModule` (já existente) para usar `DocumentViewerComponent` e `PrintOverlayComponent` no modo preview.

### 3.2 Modelo de dados

```typescript
// editor.models.ts

type BlockType =
  | 'header'
  | 'title'
  | 'section'
  | 'statement'
  | 'info-row'
  | 'info-grid'
  | 'table';

interface EditorBlock {
  id: string;          // crypto.randomUUID()
  type: BlockType;
  label?: string;      // nome exibido no painel e no handle
  data: unknown;       // dado tipado (inferido pelo BlockDef<T>)
}

interface EditorDocument {
  config: DocumentConfig;
  headerData: DocHeaderData;
  blocks: EditorBlock[];
}

// Registro que conecta BlockType ao document-builder
interface BlockDef<T> {
  type: BlockType;
  label: string;
  icon: string;
  category: 'identification' | 'content' | 'data' | 'structure';
  componentType: Type<{ data: T }>;  // usado no DocumentEntry
  defaultData: T;
}
```

### 3.3 Serviço de estado

`DocumentEditorStateService` expõe um `BehaviorSubject<EditorDocument>` e métodos imutáveis:

```typescript
class DocumentEditorStateService {
  // Estado
  readonly document$: Observable<EditorDocument>;
  
  // Blocos
  addBlock(type: BlockType, atIndex?: number): void
  updateBlock(id: string, data: Partial<EditorBlock>): void
  removeBlock(id: string): void
  reorderBlock(id: string, toIndex: number): void
  
  // Config
  updateConfig(partial: Partial<DocumentConfig>): void
  
  // Conversão para o document-builder
  toDocumentDefinition(): { config: DocumentConfig; entries: DocumentEntry[]; headerData: DocHeaderData }
}
```

`toDocumentDefinition()` é o ponto de integração: transforma `EditorBlock[]` em `DocumentEntry[]` que o `DocumentViewerComponent` já sabe renderizar.

### 3.4 Registro de blocos

`BlockRegistryService` é um mapa imutável indexado por `BlockType`:

```typescript
const BLOCK_REGISTRY: Record<BlockType, BlockDef<unknown>> = {
  header: {
    type: 'header',
    label: 'Cabeçalho da escola',
    icon: 'domain',
    category: 'identification',
    componentType: DocHeaderComponent,
    defaultData: { /* DocHeaderData vazia */ },
  },
  title: {
    type: 'title',
    label: 'Título',
    icon: 'title',
    category: 'identification',
    componentType: DocTitleComponent,
    defaultData: { title: 'Novo título', border: false, centered: true },
  },
  // ...
};
```

### 3.5 Integração com o document-builder existente

```
EditorDocument
     │
     ├─ toDocumentDefinition()
     │        │
     │        ├─ config: DocumentConfig  ──────────────┐
     │        ├─ headerData: DocHeaderData ─────────────┤──→ DocumentViewerComponent
     │        └─ entries: DocumentEntry[] ─────────────┘
     │
     └─ Preview mode: passa para PrintOverlayComponent
                      que já contém DocumentViewerComponent
```

O document-builder **não sofre nenhuma modificação**. O editor é um produtor de `DocumentDefinition` que o viewer já consome.

### 3.6 Modo Preview

Quando o usuário clica em "Visualizar" ou "Gerar PDF":

```typescript
openPreview(): void {
  this.previewDef = this.state.toDocumentDefinition();
  this.showPreview = true;
  setTimeout(() => this.viewer?.init(), 0);
}
```

O template inclui:

```html
<app-print-overlay
  *ngIf="showPreview"
  [silent]="silentMode"
  (closeEvent)="showPreview = false"
  (printEvent)="viewer?.print()"
  (saveEvent)="viewer?.save()">
  <app-document-viewer
    #viewer
    [config]="previewDef.config"
    [entries]="previewDef.entries"
    [headerData]="previewDef.headerData">
  </app-document-viewer>
</app-print-overlay>
```

Reutiliza 100% da infraestrutura existente.

---

## 4. Comportamento da Canvas (modo Edição)

### 4.1 Renderização dos blocos

O canvas **não usa** `DocumentViewerComponent` no modo edição. Ele renderiza os blocos como uma lista simples:

```html
<!-- editor-canvas.component.html -->
<div class="editor-sheet" [ngClass]="'editor-sheet--' + config.orientation">
  <ng-container *ngFor="let block of blocks; let i = index; trackBy: trackById">
    
    <!-- Insert slot -->
    <div class="insert-slot" (click)="insertAt(i)">...</div>
    
    <!-- Block wrapper com handles e toolbar -->
    <div class="editor-block"
         [class.editor-block--selected]="selectedId === block.id"
         (click)="select(block.id)">
      
      <div class="editor-block__handle" cdkDragHandle>
        <span class="material-icons-outlined">drag_indicator</span>
      </div>
      
      <div class="editor-block__tag">{{ block.label }}</div>
      
      <div class="editor-block__toolbar">
        <!-- move up / move down / duplicate / delete -->
      </div>
      
      <!-- Preview do bloco usando o próprio component Angular -->
      <div class="editor-block__content">
        <ng-container
          [ngComponentOutlet]="getComponentType(block.type)"
          [ngComponentOutletInputs]="{ data: block.data }">
        </ng-container>
      </div>
      
    </div>
  </ng-container>
  
  <!-- Insert slot final -->
  <div class="insert-slot" (click)="insertAt(blocks.length)">...</div>
  
  <!-- Add block row -->
  <button class="add-row" (click)="openBlockPicker()">
    <span class="material-icons-outlined">add</span>
    Adicionar bloco
  </button>
</div>
```

`ngComponentOutlet` renderiza o componente Angular real (ex: `DocTitleComponent`) usando o dado atual do bloco. O usuário vê o output final enquanto edita.

**Obs sobre `contentWidth`**: o canvas passa `contentWidth` via `ngComponentOutletInputs` calculado da largura da sheet menos as margens da config, igual ao que `DocumentViewerComponent` faz.

### 4.2 Drag-and-drop para reordenação

Usa `@angular/cdk/drag-drop` (já deve estar no projeto ou é uma dep natural do Angular CDK):

```html
<div cdkDropList (cdkDropListDropped)="onDrop($event)">
  <div *ngFor="let block of blocks" cdkDrag>
    ...
  </div>
</div>
```

### 4.3 Seleção e Inspector

Ao clicar num bloco:
1. `selectedId = block.id`
2. O painel direito exibe o formulário correspondente ao `block.type`
3. Mudanças no formulário chamam `state.updateBlock(id, { data: ... })`
4. O canvas re-renderiza via `ngComponentOutlet` com o novo dado

---

## 5. Rota e Entrada na Aplicação

```typescript
// document-editor-routing.module.ts
const routes: Routes = [
  { path: '', component: DocumentEditorComponent },
  { path: ':id', component: DocumentEditorComponent },  // editar existente (v2)
];
```

Rota final: `/documentos/editor` ou `/document-builder/novo`.

Entrada a partir da tela de documentos (`documents.component.html`) com um botão "Novo documento" no banner ou toolbar.

---

## 6. Fases de Implementação

### Fase 1 — Estrutura e Canvas básico (MVP sem drag-and-drop)

**Objetivo**: Editor funcional que gera preview correto.

1. Criar `document-editor.module.ts` + rota
2. Criar `editor.models.ts` (interfaces)
3. Criar `BlockRegistryService` com todos os tipos mapeados
4. Criar `DocumentEditorStateService` com `addBlock`, `updateBlock`, `removeBlock`, `toDocumentDefinition`
5. Criar `DocumentEditorComponent` (layout 3-painéis com SCSS hardcoded)
6. Criar `EditorCanvasComponent` com lista de blocos usando `ngComponentOutlet`
7. Criar `BlockLibraryComponent` (lista de blocos por categoria, click para inserir no final)
8. Criar `BlockInspectorComponent` com aba Documento (`DocumentConfigPanelComponent` reusado) e aba Bloco (formulários)
9. Criar formulários básicos: `TitleEditorForm`, `StatementEditorForm`, `SectionEditorForm`, `InfoRowEditorForm`
10. Criar `EditorTopbarComponent` (nome, back, visualizar, gerar PDF)
11. Integrar preview: `PrintOverlayComponent` + `DocumentViewerComponent` ao clicar "Visualizar"

**Critério de aceite**: usuário consegue adicionar título + texto + tabela, ver preview paginado e baixar PDF.

### Fase 2 — Drag-and-drop e UX de edição

1. Adicionar `@angular/cdk/drag-drop` à library drag para reordenar blocos
2. Drag da biblioteca para posição específica no canvas
3. Insert slots (linha azul + botão `+` ao hover entre blocos)
4. Block toolbar (mover cima/baixo, duplicar, deletar)
5. Formulário para `TableEditorForm` (colunas editáveis + linhas de exemplo)
6. Formulário para `InfoGridEditorForm`

### Fase 3 — Persistência local e templates

1. Auto-save para `localStorage` com debounce de 2s
2. Carregar rascunho ao reabrir
3. Botão "Novo a partir de modelo" — abre seletor dos modelos existentes (`historicoEscolarModelo`, etc.) para iniciar o editor com um documento pré-populado
4. Exportar como JSON (`EditorDocument` serializado) para backup manual

### Fase 4 — Persistência no backend (futura, fora do escopo atual)

1. API `POST /api/document-templates` / `GET /api/document-templates/:id`
2. `DocumentEditorStateService` com save/load assíncrono
3. Listagem de templates salvos na tela `documents.component`

---

## 7. Decisões de Design a Confirmar

| Questão | Opção A (recomendada) | Opção B |
|---------|----------------------|---------|
| Canvas em modo edição | Flat scroll, sem paginação | Paginar em tempo real |
| Persistência v1 | localStorage (zero backend) | Sem persistência |
| Drag-and-drop | Angular CDK | Nativo HTML5 drag |
| Formulários de bloco | Sub-componentes dedicados por tipo | Formulário genérico baseado em schema |
| Variáveis dinâmicas | Texto literal (sem interpolação em v1) | Suporte a `{{var}}` na v1 |
| Rota | `/documentos/editor` | `/document-builder/editor` |

---

## 8. Dependências Externas

| Lib | Já no projeto? | Uso |
|-----|---------------|-----|
| `@angular/cdk/drag-drop` | Verificar | Reordenação de blocos |
| `crypto.randomUUID()` | Nativo (Edge/Chrome) | IDs de blocos |

---

## 9. O que não muda no document-builder

- `DocumentViewerComponent` — nenhuma mudança
- `PrintOverlayComponent` — já tem `[silent]` input
- Todos os block components (`DocTableComponent`, etc.) — nenhuma mudança
- `LayoutEngineService`, `MeasurementService`, `PrintService` — nenhuma mudança
- `DocumentConfigPanelComponent` — reutilizado na aba Documento do inspector

O editor é completamente **aditivo** — nenhum arquivo existente precisa ser modificado para implementar as Fases 1-3.
