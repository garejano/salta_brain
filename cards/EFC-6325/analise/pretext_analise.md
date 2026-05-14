# pretext_analise.md — Análise de uso da lib Pretext no `document-builder`

> Gerado em: 2026-05-07
> Ref: https://pretextjs.net/ | https://github.com/chenglou/pretext
> Contexto: avaliação da DEV_001 em tarefas.md

---

## O que é Pretext

Pretext é uma biblioteca TypeScript de **5KB (gzipado)** criada por Cheng Lou (ex-React core team, Midjourney) que calcula altura de texto e quebras de linha **sem tocar o DOM**. Ganhou 16.000 estrelas no GitHub em 24 horas após o lançamento (março/2026).

**Instalação:**
```bash
npm install @chenglou/pretext
```

**API central:**
```typescript
import { prepare, layout } from '@chenglou/pretext'

// fase 1 — executada uma vez por par (texto, fonte): 1-5ms
const prepared = await prepare('Texto do componente', '16px Nunito')

// fase 2 — aritmética pura, sem DOM: ~0.0002ms por chamada
const { height, lineCount } = layout(prepared, maxWidth, lineHeight)
```

---

## Como funciona internamente

Pretext separa a medição em três fases:

1. **Segmentação** — usa `Intl.Segmenter` para normalizar espaços e quebras conforme spec CSS. Trata CJK (quebra por caractere), bidirecional (árabe/hebraico), emoji (ZWJ sequences) e hifenização suave.

2. **Medição via Canvas** — `canvas.measureText()` mede a largura de cada segmento uma única vez e cacheia o resultado por `(segmento, fonte)`. É aqui que o navegador é consultado — apenas uma vez.

3. **Layout aritmético** — percorre os segmentos em cache, acumula largura, insere quebra de linha quando `maxWidth` é atingido. Zero DOM, zero reflow, zero `getBoundingClientRect`.

**Calibração Safari:** detecta discrepâncias de emoji via uma única medição DOM oculta e aplica fator de correção às chamadas seguintes.

---

## O problema que isso resolve no `document-builder`

### O fluxo atual de medição (gerador-documentos)

```
Renderizar TODOS os componentes na "fake page" (DOM)
        ↓
setTimeout(300ms) — esperar DOM estabilizar
        ↓
getBoundingClientRect() em cada componente
        ↓
LayoutEngine.distribute()
        ↓
Renderizar páginas reais
```

**Problemas:**
- `setTimeout` é não-determinístico — se o DOM demorar mais de 300ms, as medidas ficam erradas
- Todos os componentes precisam estar montados no DOM antes de qualquer cálculo de layout
- A "fake page" com `transform: scale(0)` é um hack que consome memória e tempo de rendering
- Impossível calcular layout em SSR ou Web Worker

### O fluxo com Pretext

```
prepare() — mede segmentos de texto via Canvas (1-5ms, uma vez)
        ↓
layout() — aritmética pura: calcula altura de cada componente (0.0002ms cada)
        ↓
LayoutEngine.distribute() — distribui entre páginas com alturas já conhecidas
        ↓
Renderizar páginas reais (DOM aparece só aqui)
```

**Ganhos:**
- Elimina o `setTimeout` e a fake page para componentes de texto
- Layout calculado **antes de qualquer renderização DOM**
- Determinístico: mesmos inputs, mesmo resultado
- Suporta execução em Web Worker (sem bloqueio do thread principal)

---

## Onde Pretext ajuda no `document-builder`

### Componentes 100% beneficiados

| Componente | Por quê | API Pretext a usar |
|---|---|---|
| `DocTitleComponent` | texto simples com fonte conhecida | `prepare` + `layout` |
| `DocTextFieldComponent` | label + valor, fonte fixa | `prepareRichInline` + `layout` |
| `DocTextComponent` | texto plano com label | `prepare` + `layout` |
| `DocLegendComponent` | lista de itens de texto | `prepare` + `layout` por item |
| `DocFooterComponent` | numeração de página (texto fixo) | altura constante, não precisa |
| `DocHeaderComponent` | ver decisão abaixo ↓ | `prepare` + `layout` para texto |

**Decisão de design — `DocHeaderComponent`:**
O logo não deve ditar a altura do cabeçalho. A área do logo deve ser **fixa** (ex: `60px × 60px`) e a imagem se ajusta dentro dela via `object-fit: contain`. Com isso, a altura total do header é:

```
altura_header = LOGO_AREA_HEIGHT (constante) + Pretext(nome_instituição, fonte, largura)
```

Totalmente determinístico, sem DOM. Quanto mais determinismo, melhor — essa decisão deve guiar o design de `DocHeaderComponent` na TAREFA 03.

### Componentes parcialmente beneficiados

| Componente | O que Pretext resolve | O que ainda precisa DOM |
|---|---|---|
| `DocSignatureComponent` | altura de cada nome/cargo (texto) | espaçamento decorativo entre linhas |
| `DocTableComponent` (TAREFA 08) | `getRowHeight()` sem DOM → `Splittable` puramente determinístico | largura de colunas se variável por conteúdo |
| `DocInfoGridComponent` | altura das células de texto | layout de grid CSS com múltiplas colunas |

### Componentes que ainda precisam de DOM

| Componente | Por quê DOM é necessário |
|---|---|
| `DocFrameComponent` | borda decorativa pura — sem texto a medir, altura determinada pelo conteúdo filho |
| Grids complexos (ex: `doc-grid-ata`) | larguras de coluna dependem de CSS `table-layout: auto` e conteúdo tabular multilinha |

---

## Impacto direto no contrato `Splittable`

Este é o ponto de maior valor prático. O `DocTableComponent` (TAREFA 08) precisa implementar:

```typescript
getRowHeight(): number        // altura de uma linha
getRowsThatFit(available: number): number  // quantas linhas cabem
```

**Sem Pretext:** é necessário montar a tabela no DOM, medir uma linha real, então calcular.

**Com Pretext:**
```typescript
getRowHeight(): number {
  // texto da célula mais alta da linha, com a fonte da tabela
  const prepared = prepare(this.longestCellText, '10px Nunito')
  const { height } = layout(prepared, this.columnWidth, 14)
  return height + CELL_PADDING_VERTICAL
}
```

`getRowHeight()` passa a ser uma função pura, chamável antes de qualquer DOM existir. Isso torna o `Splittable` completamente determinístico e testável sem DOM.

---

## Nova interface proposta: `TextMeasurable`

Para integrar Pretext de forma estruturada no `document-builder`, propõe-se adicionar uma segunda interface opcional em `layout.models.ts`:

```typescript
export interface TextMeasurable {
  // Retorna os segmentos de texto que compõem o componente
  // Cada segmento tem seu texto e fonte CSS
  getTextSegments(): Array<{ text: string; font: string }>

  // Largura máxima do componente em pixels (sem padding)
  getMaxWidth(): number

  // Altura de linha em pixels
  getLineHeight(): number
}
```

No `LayoutEngine`, antes de recorrer à fake page DOM:

```typescript
if (isTextMeasurable(component)) {
  component.height = await measureWithPretext(component)
} else {
  component.height = await measureWithDOM(component) // fallback atual
}
```

Componentes que implementam `TextMeasurable` nunca precisam ir para o DOM para ser medidos.

---

## API completa disponível

Além de `prepare` + `layout`, Pretext oferece APIs avançadas relevantes:

| API | Uso no document-builder |
|---|---|
| `prepareRichInline([{ text, font }])` | Labels em negrito + valores normais no `DocTextField` |
| `layoutWithLines(prepared, width, lineHeight)` | Obter linhas individuais para debug no `DocumentDebug` |
| `walkLineRanges()` | Contagem de linhas sem alocação — útil no `Splittable` |
| `measureLineStats()` | Retorna `lineCount` e `maxLineWidth` — para calcular altura sem alocação |
| `letter-spacing` (suportado) | Documentos com espaçamento configurável |
| `line-height` (suportado) | Configurável por componente |

---

## Limitações que precisam ser consideradas

| Limitação | Impacto no document-builder |
|---|---|
| Fontes devem estar carregadas antes de `prepare()` | O `DocumentViewer` precisa aguardar `document.fonts.ready` antes de iniciar o layout |
| Canvas 2D obrigatório | Sem impacto — app já roda em browser |
| `Intl.Segmenter` obrigatório | Suportado em todos os browsers do `browserslist` do projeto (Chrome, Firefox, Edge, Safari modernos) |
| `white-space: pre` não suportado | Sem impacto — documentos usam `white-space: normal` |
| `system-ui` não confiável no macOS | Usar `'Nunito'` explícito (já é a fonte do projeto) |
| `font-feature-settings` não modelado | Sem impacto — projeto não usa features OpenType |

---

## Plano de integração recomendado

### Fase 1 — Fundamentação (sem breaking changes)
- Instalar `@chenglou/pretext`
- Adicionar interface `TextMeasurable` ao `layout.models.ts`
- Implementar `TextMeasurable` em `DocTextFieldComponent` e `DocTitleComponent` (mais simples)
- No `DocumentViewer`: tentar `TextMeasurable` primeiro, cair para DOM measurement se não disponível

### Fase 2 — Splittable determinístico
- Implementar `getRowHeight()` em `DocTableComponent` usando Pretext (elimina DOM measurement para linhas)
- Todos os testes do `LayoutEngine` continuam passando — o engine não muda, apenas a fonte dos heights

### Fase 3 — Eliminar fake page
- Quando todos os componentes de um documento implementarem `TextMeasurable`, a fake page pode ser removida completamente
- O `LayoutEngine` recebe alturas já calculadas, sem nenhum DOM intermediário

---

## Resumo executivo

| Aspecto | Sem Pretext | Com Pretext |
|---|---|---|
| Como medir altura de texto | fake page DOM + setTimeout | `prepare()` + `layout()` puro |
| Determinismo | frágil (timing dependente) | exato (aritmética pura) |
| `getRowHeight()` no Splittable | requer DOM montado | função pura, testável |
| Compatibilidade SSR | impossível | possível |
| Bundle adicionado | — | +5KB gzipado |
| Componentes beneficiados | — | ~80% dos componentes base |
| Componentes que ainda usam DOM | 100% | ~20% (DocFrame, grids complexos com CSS table-layout) |

**Recomendação:** adotar Pretext como interface `TextMeasurable` opcional no `document-builder`, implementando progressivamente nos componentes de texto. Não é breaking change — é uma otimização incremental que elimina o ponto mais frágil do módulo atual (o `setTimeout` de medição DOM).

---

Sources:
- [Pretext — JavaScript Text Measurement Without DOM Reflow](https://pretextjs.net/)
- [GitHub - chenglou/pretext](https://github.com/chenglou/pretext)
- [Pretext.js Bypasses DOM Layout Reflow, Enabling Advanced UX Patterns at 120 FPS — InfoQ](https://www.infoq.com/news/2026/04/pretext-js-120fps-text-layout/)
- [Pretext — Simon Willison](https://simonwillison.net/2026/Mar/29/pretext/)
- [Pretext Does What CSS Can't — HackerNoon](https://hackernoon.com/pretext-does-what-css-cant-measuring-text-before-the-dom-even-exists)
