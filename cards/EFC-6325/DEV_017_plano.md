# DEV_017 — Configuração avançada do bloco de assinatura

## Contexto

O `DocSignatureComponent` tem hoje comportamento fixo: data/local sempre centralizada,
assinaturas com `justify-content: space-evenly`, espaçamento `gap: 16px`, cargo sempre visível.

A tarefa expõe essas opções via `SignatureConfig` e adiciona uma sub-seção dedicada no painel
de configuração — visível apenas quando `signature.show === true`.

---

## 1. Mudanças em `SignatureConfig` (`document-config.ts`)

```typescript
export interface SignatureConfig {
  show: boolean
  onAllPages?: boolean
  signatories?: SignatoryConfig[]
  city?: string

  // ── novas propriedades ────────────────────────────────────────────────────
  cityDateAlign?: 'left' | 'center' | 'right'  // posição do texto de data/local; padrão: 'center'
  signatoriesAlign?: 'left' | 'center' | 'right' // alinhamento do grupo de assinaturas; padrão: 'center'
  signatoriesGap?: number                         // espaço entre cada assinatura em px; padrão: 16
  showRole?: boolean                              // exibir cargo (role); padrão: true
}
```

Valores default são **idênticos ao comportamento atual** — nenhum documento existente quebra.

---

## 2. Mudanças em `DocSignatureComponent`

### 2.1 Novos `@Input()`

O componente já recebe `signatories` e `city`. Adicionar:

```typescript
@Input() cityDateAlign: 'left' | 'center' | 'right' = 'center';
@Input() signatoriesAlign: 'left' | 'center' | 'right' = 'center';
@Input() signatoriesGap: number = 16;
@Input() showRole: boolean = true;
```

### 2.2 Template (`doc-signature.component.html`)

```html
<div class="signature-block">

  <p class="city-date"
     *ngIf="cityDateLine"
     [style.text-align]="cityDateAlign">
    <b>{{ cityDateLine }}</b>
  </p>

  <div class="signature-row"
       *ngIf="signatories.length > 0"
       [style.justify-content]="justifyContent"
       [style.gap.px]="signatoriesGap">
    <div class="signature-item" *ngFor="let signatory of signatories">
      <span class="signatory-role" *ngIf="showRole">
        <b>{{ signatory.role }}</b>
      </span>
      <span class="signatory-name">{{ signatory.name }}</span>
    </div>
  </div>

</div>
```

Getter necessário para converter `signatoriesAlign` → valor CSS `justify-content`:

```typescript
get justifyContent(): string {
  const map = { left: 'flex-start', center: 'center', right: 'flex-end' };
  return map[this.signatoriesAlign] ?? 'center';
}
```

> **Por que um getter?** CSS `justify-content` usa `flex-start`/`flex-end`, não `left`/`right`.
> Manter a API pública com termos semânticos (left/center/right) é mais legível para quem
> consome `SignatureConfig`.

### 2.3 SCSS (`doc-signature.component.scss`)

Remover `justify-content: space-evenly` e `gap: 16px` do `.signature-row` — passam a ser
bindings no template. O restante não muda.

```scss
.signature-row {
  display: flex;
  padding-top: 24px;
  flex-wrap: wrap;
  /* justify-content e gap controlados via [style] binding */
}
```

---

## 3. Como o `DocumentViewerComponent` passa os inputs

Em `measureBundle()` e `distributeElements()`, o viewer já usa `reflectComponentType` +
`inputNames.has(...)` antes de chamar `ref.setInput()`. Basta adicionar as novas props:

```typescript
// Em measureBundle() — após definir inputNames:
if (inputNames.has('cityDateAlign') && config.signature?.cityDateAlign)
  ref.setInput('cityDateAlign', config.signature.cityDateAlign);
if (inputNames.has('signatoriesAlign') && config.signature?.signatoriesAlign)
  ref.setInput('signatoriesAlign', config.signature.signatoriesAlign);
if (inputNames.has('signatoriesGap') && config.signature?.signatoriesGap !== undefined)
  ref.setInput('signatoriesGap', config.signature.signatoriesGap);
if (inputNames.has('showRole') && config.signature?.showRole !== undefined)
  ref.setInput('showRole', config.signature.showRole);
```

> **Atenção:** `DocSignatureComponent` é instanciado pelo `DocumentPageComponent`, não pelo
> viewer diretamente — ver seção 4.

---

## 4. Como `DocSignatureComponent` é renderizado hoje

O `DocumentPageComponent` cria o bloco de assinatura **diretamente no template**:

```html
<!-- document-page.component.html (trecho provável) -->
<app-doc-signature
  *ngIf="page.showSignature"
  [signatories]="config.signature?.signatories ?? []"
  [city]="config.signature?.city ?? ''">
</app-doc-signature>
```

Isso significa que **o viewer não passa inputs ao `DocSignatureComponent`** — quem o
instancia é o `DocumentPageComponent` via template. Portanto:

- **As novas props precisam ser passadas no template do `DocumentPageComponent`**, não no viewer.
- Não há conflito com a lógica de medição: a assinatura já tem altura fixa (`DOC_SIGNATURE_HEIGHT = 120px`)
  e não implementa `TextMeasurable` nem `Splittable`.

```html
<!-- document-page.component.html — bindings a adicionar -->
<app-doc-signature
  *ngIf="page.showSignature"
  [signatories]="config.signature?.signatories ?? []"
  [city]="config.signature?.city ?? ''"
  [cityDateAlign]="config.signature?.cityDateAlign ?? 'center'"
  [signatoriesAlign]="config.signature?.signatoriesAlign ?? 'center'"
  [signatoriesGap]="config.signature?.signatoriesGap ?? 16"
  [showRole]="config.signature?.showRole ?? true">
</app-doc-signature>
```

---

## 5. `DOC_SIGNATURE_HEIGHT` — impacto do espaçamento configurável

O layout engine reserva `DOC_SIGNATURE_HEIGHT = 120px` por página com assinatura.
Com o padrão atual (gap 16px, 2 signatários) o bloco ocupa ~80px — há folga.

**Risco:** se `signatoriesGap` for muito alto (ex: 64px entre 3 signatários em
`flex-wrap: wrap`), o bloco pode ultrapassar 120px e vazar para fora da área de assinatura.

**Recomendação para esta tarefa:** não tornar `DOC_SIGNATURE_HEIGHT` dinâmico ainda. Limitar
o slider de gap a **32px máximo** no painel, o que é seguro para até 4 signatários sem quebra
de linha. Documentar o limite como comentário na constante.

---

## 6. Painel de configuração (`DocumentConfigPanelComponent`)

### 6.1 Mudanças em `document-config-panel.component.ts`

Novos getters (lêem de `this.local.signature`):

```typescript
get sigCityDateAlign(): 'left' | 'center' | 'right' {
  return this.local.signature?.cityDateAlign ?? 'center';
}
get sigAlign(): 'left' | 'center' | 'right' {
  return this.local.signature?.signatoriesAlign ?? 'center';
}
get sigGap(): number { return this.local.signature?.signatoriesGap ?? 16; }
get sigShowRole(): boolean { return this.local.signature?.showRole ?? true; }
```

Novos setters (emitem `configChange` após atualizar `local`):

```typescript
setSigCityDateAlign(value: 'left' | 'center' | 'right'): void {
  this.local = { ...this.local, signature: { ...this.local.signature!, cityDateAlign: value } };
  this.emit();
}
setSigAlign(value: 'left' | 'center' | 'right'): void {
  this.local = { ...this.local, signature: { ...this.local.signature!, signatoriesAlign: value } };
  this.emit();
}
setSigGap(event: Event): void {
  const gap = Number((event.target as HTMLInputElement).value);
  this.local = { ...this.local, signature: { ...this.local.signature!, signatoriesGap: gap } };
  this.emit();
}
setSigShowRole(show: boolean): void {
  this.local = { ...this.local, signature: { ...this.local.signature!, showRole: show } };
  this.emit();
}
```

### 6.2 Template — sub-seção dentro da seção ELEMENTOS

A sub-seção expande o bloco de `Assinaturas` existente. Fica visível apenas quando
`signatureShow === true` (já controlado pelo `*ngIf` atual).

```html
<!-- logo abaixo do cp-sub-check "Em todas as páginas" existente -->
<ng-container *ngIf="signatureShow">

  <!-- Data e Local -->
  <div class="cp-field cp-field--sub">
    <label class="cp-field__label cp-field__label--sm">Posição da data/local</label>
    <div class="cp-segmented cp-segmented--3">
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigCityDateAlign === 'left'"
        (click)="setSigCityDateAlign('left')">
        <span class="material-icons-outlined">format_align_left</span>
      </button>
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigCityDateAlign === 'center'"
        (click)="setSigCityDateAlign('center')">
        <span class="material-icons-outlined">format_align_center</span>
      </button>
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigCityDateAlign === 'right'"
        (click)="setSigCityDateAlign('right')">
        <span class="material-icons-outlined">format_align_right</span>
      </button>
    </div>
  </div>

  <!-- Alinhamento das assinaturas -->
  <div class="cp-field cp-field--sub">
    <label class="cp-field__label cp-field__label--sm">Alinhamento das assinaturas</label>
    <div class="cp-segmented cp-segmented--3">
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigAlign === 'left'"
        (click)="setSigAlign('left')">
        <span class="material-icons-outlined">align_horizontal_left</span>
      </button>
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigAlign === 'center'"
        (click)="setSigAlign('center')">
        <span class="material-icons-outlined">align_horizontal_center</span>
      </button>
      <button type="button" class="cp-seg"
        [class.cp-seg--on]="sigAlign === 'right'"
        (click)="setSigAlign('right')">
        <span class="material-icons-outlined">align_horizontal_right</span>
      </button>
    </div>
  </div>

  <!-- Espaçamento entre assinaturas -->
  <div class="cp-field cp-field--sub">
    <div class="cp-field__row">
      <label class="cp-field__label cp-field__label--sm">Espaço entre assinaturas</label>
      <span class="cp-value-pill">{{ sigGap }} px</span>
    </div>
    <input type="range" class="cp-range" min="8" max="32" step="4"
      [value]="sigGap"
      [style.--pct]="sliderPct(sigGap, 8, 32)"
      (input)="setSigGap($event)">
    <div class="cp-range-ticks"><span>8</span><span>20</span><span>32</span></div>
  </div>

  <!-- Exibir cargo -->
  <div class="cp-sub-check">
    <button type="button" class="cp-cbx cp-cbx--sm"
      [class.cp-cbx--on]="sigShowRole"
      (click)="setSigShowRole(!sigShowRole)"
      [attr.aria-pressed]="sigShowRole">
      <span class="material-icons-outlined">check</span>
    </button>
    <span class="cp-sub-check__label">Exibir cargo</span>
  </div>

</ng-container>
```

### 6.3 CSS necessário (`document-config-panel.component.scss`)

O `cp-segmented--3` é um grid de 3 colunas (vs. 2 colunas do atual):

```scss
.cp-segmented--3 {
  grid-template-columns: 1fr 1fr 1fr;
}

.cp-field--sub {
  margin-left: 28px;
  margin-bottom: 12px;
}

.cp-field__label--sm {
  font-size: 11px;
  color: $neutral-dark1;
}
```

---

## 7. Ordem de execução

```
1. document-config.ts          — adicionar campos em SignatureConfig
2. doc-signature.component.ts  — adicionar @Input() e getter justifyContent
3. doc-signature.component.html — bindings [style.text-align], [style.justify-content], [style.gap.px], *ngIf showRole
4. doc-signature.component.scss — remover justify-content e gap fixos
5. document-page.component.html — passar novos bindings ao <app-doc-signature>
6. document-config-panel.component.ts — getters + setters
7. document-config-panel.component.html — sub-seção dentro de signatureShow
8. document-config-panel.component.scss — cp-segmented--3, cp-field--sub, cp-field__label--sm
```

---

## 8. Arquivos a modificar

| Arquivo | Tipo de mudança |
|---|---|
| `models/document-config.ts` | Adicionar campos em `SignatureConfig` |
| `components/doc-signature/doc-signature.component.ts` | Novos `@Input()` + getter `justifyContent` |
| `components/doc-signature/doc-signature.component.html` | Bindings de alinhamento e visibilidade |
| `components/doc-signature/doc-signature.component.scss` | Remover valores fixos de `gap` e `justify-content` |
| `components/document-page/document-page.component.html` | Passar novos bindings para `<app-doc-signature>` |
| `components/document-config-panel/document-config-panel.component.ts` | Getters + setters |
| `components/document-config-panel/document-config-panel.component.html` | Sub-seção de assinatura |
| `components/document-config-panel/document-config-panel.component.scss` | Variantes de classe CSS |

**Nenhum arquivo de serviço muda** — a assinatura tem altura fixa e não passa pelo pipeline
de medição do viewer. O `DOC_SIGNATURE_HEIGHT` permanece 120px.
