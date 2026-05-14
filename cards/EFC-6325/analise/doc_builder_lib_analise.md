# Análise de bibliotecas — geração de PDF no document-builder

## Problema

O fluxo atual (`html-to-image` → PNG → `jsPDF`) produz páginas em branco em produção.
A causa raiz é o pipeline SVG da `html-to-image`:

```
DOM → clone → serializa CSS → SVG data URL → <img src="svgUrl"> → Canvas → PNG
```

Nesse pipeline, recursos externos (fontes Google, imagens) são buscados no contexto do
SVG clonado. Na primeira chamada, esses recursos não estão no cache do browser para aquele
contexto. O Canvas renderiza sem eles → página em branco.

O "double-render fix" (DEV_007) ameniza mas não elimina o problema porque em alguns
browsers o cache do contexto SVG expira entre chamadas ou não é compartilhado entre
elementos diferentes.

---

## Alternativas analisadas

### 1. CSS `@media print` + `window.print()` ✅ IMPLEMENTADO

| Critério | Avaliação |
|---|---|
| Páginas em branco | Impossível — browser renderiza nativo |
| Performance | Melhor possível — zero overhead JS |
| Fontes | Perfeito — browser usa as fontes já carregadas |
| Suporte | Universal — funciona em qualquer browser/computador |
| PDF programático (download) | ✗ — usuário usa "Salvar como PDF" no diálogo |
| Controle de nome do arquivo | ✗ — título da aba vira nome sugerido |

**Como funciona:** os componentes Angular têm `@media print` CSS que esconde a UI e
exibe apenas as páginas. O PrintService chama `window.print()`. O browser renderiza
cada página como uma folha de papel usando seu próprio mecanismo de impressão.

**Veredicto:** estratégia padrão para a ação "Imprimir". Zero risco de páginas em branco.

---

### 2. `html2canvas` + `jsPDF` ✅ IMPLEMENTADO

| Critério | Avaliação |
|---|---|
| Páginas em branco | Improvável — renderiza direto em canvas, sem pipeline SVG |
| Performance | Médio — mais lento que html-to-image mas mais confiável |
| Fontes | Bom — usa fontes do browser diretamente no canvas |
| PDF programático | ✓ — gera arquivo para download |
| Bundle size | ~500KB (maior que html-to-image ~150KB) |
| Manutenção | Ativa — v1.4.1, amplamente adotado |

**Como funciona:** percorre o DOM elemento por elemento e desenha diretamente em
`<canvas>`, sem serialização SVG. Isso elimina a causa raiz das páginas em branco.

**Veredicto:** melhor alternativa para `save()` (download de PDF) quando html-to-image falha.

---

### 3. `html-to-image` (atual) com double-render ⚠️ MANTIDO

| Critério | Avaliação |
|---|---|
| Páginas em branco | Possível (pipeline SVG) |
| Performance | Bom — rápido quando funciona |
| Double-render fix | Ameniza mas não elimina em todos os browsers |

**Veredicto:** mantido como fallback. Funciona bem em Chrome com double-render; 
problemático em Firefox e Safari ou em computadores com pouca memória.

---

### 4. Puppeteer / Headless Chrome (servidor) — NÃO IMPLEMENTADO

| Critério | Avaliação |
|---|---|
| Qualidade de render | Perfeito — usa Chrome real |
| Páginas em branco | Impossível |
| Requer backend | ✓ — não funciona no browser |
| Performance | Depende do servidor |

**Veredicto:** melhor solução a longo prazo para documentos críticos. Requer endpoint
backend. A ser considerado quando houver demanda de qualidade de impressão garantida.

---

### 5. `dom-to-image-more` — NÃO IMPLEMENTADO

Fork de `dom-to-image`. Mesmo pipeline SVG da `html-to-image`. Não resolve a causa raiz.
Descartado.

---

## Decisão de implementação

```
Ação: Imprimir  →  estratégia 'css'         (padrão — window.print())
Ação: Salvar    →  estratégia 'html2canvas'  (padrão — sem pipeline SVG)
Fallback        →  estratégia 'html-to-image' + double-render
```

A estratégia é configurável por documento via `DocumentConfig.printStrategy` e
globalmente via `ACTIVE_PRINT_STRATEGY` / `ACTIVE_SAVE_STRATEGY` no `print.service.ts`.

---

## Guia de debug de páginas em branco

```
1. Trocar para preset 'draft' (skipFonts: true, sem double-render)
   - Ainda branco → problema de DOM/visibilidade (elemento não no viewport, display:none, etc.)
   - Funciona em draft → problema de fonte/imagem externa
     ↳ 2. Trocar estratégia de save para 'html2canvas'
          - Ainda branco → uso de imagens cross-origin sem CORS headers
          - Funciona → confirma: html-to-image tem issue com pipeline SVG neste ambiente

2. Verificar se 'css' resolve o print
   - Resolve → usar css para print, html2canvas para save
   - Não resolve → problema de CSS @media print (checar se overlay está se fechando)
```

---

## Configuração

`print.service.ts` — local central de configuração:
```typescript
const ACTIVE_PRINT_STRATEGY: PrintStrategy = 'css';       // padrão para imprimir
const ACTIVE_SAVE_STRATEGY: PrintStrategy  = 'html2canvas'; // padrão para salvar
```

`DocumentConfig` — override por documento:
```typescript
const docXxx: DocumentDefinition = {
  config: {
    printStrategy: 'high',  // usa preset de alta qualidade
    // ...
  },
  // ...
}
```
