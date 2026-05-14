# analise_melhorias.md — Melhorias possíveis no `gerador-documentos`

> Gerado em: 2026-05-07
> Baseado em: inspect.md + product.md

---

## Bibliotecas instaladas

As três bibliotecas usadas para geração de documentos não estavam no projeto e foram instaladas nesta sessão:

| Biblioteca | Versão instalada |
|---|---|
| `html-to-image` | 1.11.13 |
| `jsPDF` | 4.2.1 |
| `underscore` | 1.13.8 + `@types/underscore` |

---

## 1. html-to-image

### O que é
Converte elementos DOM em imagens (PNG, JPEG, SVG). Usado no `PrintService` para capturar cada página antes de inserir no PDF.

### Configuração atual no `PrintService`
```typescript
htmlToImage.toPng(element, {
  quality: 1.0,
  width: pageSize.x,
  height: pageSize.y,
  pixelRatio: 4,
  cacheBust: true,
  skipFonts: true
})
```

### Melhorias disponíveis na versão atual (1.11.x)

**`includeQueryParams`** — cacheBust agora pode ser feito de forma controlada sem gerar URLs aleatórias por requisição. Reduz retrabalho de rede em documentos com muitas imagens externas.

**Melhor suporte a `foreignObject` SVG** — versões anteriores tinham problemas com SVG embutido. O 1.11.x tem correções relevantes para documentos que usam ícones ou gráficos SVG.

**`fetchRequestInit`** — permite passar headers de autenticação para recursos externos carregados durante a captura, útil se o cabeçalho da escola usar imagens autenticadas.

### Recomendações para o `document-builder`

- Manter `pixelRatio: 4` para qualidade de impressão (trade-off consciente de performance)
- Manter `skipFonts: true` — evita requisições de rede para fontes durante a captura
- Avaliar trocar `cacheBust: true` por `includeQueryParams: false` para URLs de recursos estáticos
- Adicionar tratamento de erro por página: se uma página falhar na conversão, o PDF não deve silenciosamente gerar uma página em branco

---

## 2. jsPDF

### O que é
Biblioteca de geração de PDF no browser. Usada no `PrintService` para combinar as imagens de cada página em um único arquivo PDF.

### Configuração atual no `PrintService`
```typescript
new jsPDF({
  orientation: 'portrait' | 'landscape',
  unit: 'px',
  compress: false,
  format: [height, width],
  floatPrecision: 'smart'
})
```

### Mudanças na versão 4.x (breaking changes relevantes)

A versão 4.x é uma major — há mudanças de API que precisam ser verificadas antes de usar:

**`compress`** — o default mudou. Na v2, `compress: false` era explícito. Na v4, o default já é `true`. Manter `compress: false` explícito apenas se necessário para debug; em produção, `compress: true` reduz o tamanho do arquivo.

**`format` com `unit: 'px'`** — o comportamento de escala em unidades de pixel foi normalizado na v4. Testar se os tamanhos de página gerados continuam corretos para A4 portrait e landscape.

**`addImage` com `compression`** — na v4 é possível passar `compression: 'FAST'` ou `compression: 'SLOW'` por imagem, permitindo balancear qualidade vs. velocidade por página.

**`html()` method** — a v4 melhorou o método `html()` que converte HTML diretamente para PDF (sem passar por imagem). Não recomendado para substituir o fluxo atual pois perde controle de fontes e layout, mas pode ser explorado para componentes simples de texto.

### Recomendações para o `document-builder`

- Ativar `compress: true` em produção — reduz tamanho do PDF sem perda de qualidade visível
- Manter o fluxo `htmlToImage → addImage` — mais confiável que `html()` para documentos complexos
- Usar `compression: 'FAST'` no `addImage` como default; oferecer `'SLOW'` via config para documentos que exigem máxima qualidade
- Adicionar `unit: 'mm'` como alternativa a `'px'` para documentos que precisam de tamanho de página exato em papel

---

## 3. underscore

### Estado atual
Usado apenas em `ficha-individual` para algumas operações de array. A versão instalada (1.13.8) é a mais recente, mas a biblioteca como um todo é dispensável.

### Recomendação

**Remover `underscore` do `document-builder`** — todos os casos de uso no código atual podem ser substituídos por métodos nativos:

| underscore | Equivalente nativo |
|---|---|
| `_.groupBy(arr, fn)` | `arr.reduce(...)` ou `Object.groupBy()` (ES2024) |
| `_.flatten(arr)` | `arr.flat()` |
| `_.uniq(arr)` | `[...new Set(arr)]` |
| `_.sortBy(arr, fn)` | `arr.sort((a, b) => ...)` |
| `_.chunk(arr, n)` | implementação simples com `slice` |

O `document-builder` não deve ter `underscore` como dependência.

---

## 4. Melhorias no `PrintService`

Além das bibliotecas, o `PrintService` atual tem oportunidades de melhoria independentes:

### 4.1 `compress: false` → `compress: true` em produção
Arquivos PDF gerados com `compress: false` são desnecessariamente grandes. Mudar para `true` não afeta qualidade visual.

### 4.2 Geração paralela de imagens
O fluxo atual gera imagens de forma sequencial (uma página por vez). `htmlToImage` é assíncrono — páginas podem ser geradas em paralelo:

```typescript
// atual: sequencial
for (const page of pages) {
  const img = await htmlToImage.toPng(page)
  images.push(img)
}

// melhorado: paralelo
const images = await Promise.all(
  pages.map(page => htmlToImage.toPng(page, options))
)
```

Em documentos com 10+ páginas, a diferença de tempo é significativa.

### 4.3 Tratamento de erro por página
Atualmente não há tratamento de falha individual de página. Uma página que falha na conversão causa falha silenciosa ou exceção não tratada.

### 4.4 Progresso mais granular
Os campos `progressImage` e `progressPDF` existem mas não são usados consistentemente. Com geração paralela, o progresso precisa ser recalculado por promises resolvidas.

---

## 5. Melhorias no `PageControlService`

### 5.1 Eliminar `setTimeout` do layout
O serviço atual usa `setTimeout` para aguardar atualizações de DOM antes de medir componentes. Isso é frágil e não determinístico.

**Alternativa:** usar `afterNextRender` (Angular 17+) ou `MutationObserver` para detectar quando o DOM está estável antes de medir.

### 5.2 Separar medição de distribuição
Hoje o serviço mede e distribui componentes na mesma operação. Separar em duas etapas torna o `LayoutEngine` testável sem DOM.

### 5.3 Tipagem forte
`group: any` e `images: any[]` devem ser substituídos por tipos concretos. O `document-builder` deve ter tipagem completa desde o início.

---

## 6. Bug conhecido

**Typo em `doc-assinatura`:** o array de meses contém "Outrubro" no lugar de "Outubro". Corrigir no `DocSignature` do `document-builder`.

---

## Resumo de prioridades

| Melhoria | Impacto | Esforço | Prioridade |
|---|---|---|---|
| Geração paralela de imagens | Alto (performance) | Baixo | Alta |
| `compress: true` no jsPDF | Médio (tamanho do arquivo) | Mínimo | Alta |
| Remover `underscore` | Baixo (limpeza) | Baixo | Alta |
| Tratamento de erro por página | Alto (confiabilidade) | Médio | Média |
| Eliminar `setTimeout` do layout | Alto (estabilidade) | Alto | Média |
| Tipagem forte em todo o módulo | Médio (manutenção) | Alto | Baixa |
