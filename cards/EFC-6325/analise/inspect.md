# inspect.md — Fotografia atual de `gerador-documentos`

> Documento gerado em: 2026-05-07
> Propósito: análise técnica do estado atual do módulo antes da criação do `document-builder`

---

## 1. Estrutura de diretórios

```
gerador-documentos/
├── EFC-666/                          ← pasta do projeto
├── doc-assinatura/
├── doc-clean-text/
├── doc-footer/
├── doc-grid-info/
├── doc-header/
├── doc-legenda/
├── doc-text-field/
├── doc-title/
├── document-loading/
├── document-page/
├── document-select/
│   └── ano-select/
├── document-settings/
├── document-topbar/
├── document-viewer/
│   └── services/
│       ├── page-control.service.ts
│       ├── page.service.ts
│       ├── print.service.ts
│       └── print.service.spec.ts
├── exemplos/
│   ├── ata-resultados-finais/
│   │   ├── doc-grid-ata/
│   │   └── models/
│   └── ficha-individual/
│       ├── ficha-individual/
│       ├── doc-ficha-individual/
│       ├── doc-ficha-individual-resumido/
│       ├── doc-ficha-individual-legenda/
│       ├── doc-ficha-individual-frequencia/
│       ├── doc-grid-conteudos-ficha-individual/
│       ├── models/
│       └── services/
├── moldura/
└── models.ts
```

---

## 2. Models e tipos (`models.ts`)

### Interfaces

```typescript
ConfigDocumento {
  assinaturaEmTodasAsFolhas: boolean
  mostrarCabecalho: boolean
  tituloDocumento?: string
}

GridInfo {
  // dados do aluno: nome, matrícula, série, segmento,
  // RG, dataNascimento, naturalidade, filiação1, filiação2,
  // flags opcionais de exibição
}

PageControlComponentModel {
  name: string
  group: any                // QueryList do Angular
  index: number
  height: number
  lastComponent?: boolean
}
```

### Enums / Types

```typescript
enum PageLayout { Portrait, Landscape }
type DocumentSettings { fontSize, pageLayout }
```

**Observação:** `group: any` e ausência de tipagem forte em vários lugares são pontos de melhoria relevantes.

---

## 3. Serviços principais

### 3.1 `PageControlService`

**Responsabilidade:** controlar a distribuição de componentes entre páginas.

**Propriedades-chave:**

| Propriedade | Tipo | Descrição |
|---|---|---|
| `defaultContainerSize` | number | Espaço disponível por página |
| `fullPageSize` | number | Altura total da página |
| `pages` | PageControl[] | Array de páginas com componentes |
| `fakePage` | DocumentPageComponent | Página invisível usada para medir |
| `config` | ConfigDocumento | Configuração do documento |
| `tamanhoAssinatura` | number (160) | Altura reservada para assinatura |
| `tamanhoMinimoFree` | number (30) | Espaço mínimo restante por página |

**Fluxo principal:**
1. `init()` — cria a `fakePage` (invisible, scale=0) como template de medição
2. `adicionarComponente()` — insere componente na página atual; cria nova página se o componente não couber
3. `montarPaginas()` — re-mede todos os componentes e redistribui entre páginas

**Padrão "Fake Page":** uma página com `transform: scale(0)` permanece no DOM para medir dimensões reais sem ser visível. Essa é a estratégia central de layout.

---

### 3.2 `PageControl` (page.service.ts)

**Responsabilidade:** representa uma única página do documento.

| Propriedade | Descrição |
|---|---|
| `id` | identificador único |
| `counter` | número da página (1-based) |
| `fake` | flag de página de medição |
| `showHeader / showAssinatura / showTitle` | flags de exibição |
| `components` | componentes na página |
| `freeSpace` | espaço vertical disponível |

**Método `addComponent()`:** adiciona componente se couber e subtrai do `freeSpace`.

---

### 3.3 `PrintService`

**Responsabilidade:** converter páginas HTML em imagens e gerar PDF.

**Dependências externas:**
- `html-to-image` — DOM → PNG
- `jsPDF` — construção do PDF

**Configuração de imagem (htmlToImage.toPng):**
```typescript
{
  quality: 1.0,
  pixelRatio: 4,      // alta qualidade, custo de performance
  cacheBust: true,
  skipFonts: true     // evita requisições de rede para fontes
}
```

**Configuração de PDF (jsPDF):**
```typescript
{
  orientation: 'portrait' | 'landscape',
  unit: 'px',
  compress: false,    // arquivos maiores, melhor para debug
  floatPrecision: 'smart'
}
```

**Fluxo:**
```
print/save()
  → getImagesFromHTML()   [DOM → PNG via htmlToImage]
  → getPdfFromImages()    [PNG → jsPDF]
  → printPDF() ou save()  [dialog de impressão ou download]
```

**Estado de progresso:**
- `progressImage: number` — avanço da geração de imagens
- `progressPDF: number` — avanço da criação do PDF
- `finishImages / finishPDF: boolean` — flags de conclusão

---

## 4. Componentes de UI

### 4.1 Componentes de conteúdo do documento

| Componente | Responsabilidade |
|---|---|
| `doc-header` | Cabeçalho com logo e dados da escola |
| `doc-footer` | Rodapé com numeração de páginas |
| `doc-title` | Título do documento |
| `doc-grid-info` | Grid de informações do aluno |
| `doc-text-field` | Campo de texto com label em container bordado |
| `doc-legenda` | Legenda / chave de símbolos |
| `doc-clean-text` | Texto simples com label |
| `doc-assinatura` | Bloco de assinaturas |

### 4.2 Componentes de infra do viewer

| Componente | Responsabilidade |
|---|---|
| `document-viewer` | Orquestrador principal (print, save, preview) |
| `document-page` | Container de uma única página |
| `document-topbar` | Barra de ações (imprimir, salvar, fechar) |
| `document-loading` | Spinner de carregamento |
| `document-settings` | Botão toggle de configurações |
| `moldura` | Bordas decorativas da página |
| `ano-select` | Seletor de ano letivo |

---

## 5. Exemplos existentes

### 5.1 Ata de Resultados Finais

- Exibe matriz de alunos × disciplinas com notas
- Quebra de página automática por aluno e por disciplina
- Legendas de status especiais (transferido, falecido, progressão parcial, etc.)
- Configurações: exibir código INEP, RA digital, carga horária, frequência

**Algoritmo de layout:**
1. Divide disciplinas em grupos que caibam horizontalmente (mínimo 23 colunas)
2. Calcula linhas de alunos que cabem verticalmente
3. Gera grids quebrando alunos e disciplinas entre páginas
4. Adiciona legendas ao final

---

### 5.2 Ficha Individual

- Registro completo do aluno: notas, conteúdos, frequência
- Suporta múltiplos escopos: Regular, Diversificado, Itinerário Semestral, Dependência
- Agrupamento por Área do Conhecimento
- Versão resumida (resumido)

**Algoritmo de layout:**
1. Agrupa disciplinas por Área do Conhecimento
2. Divide áreas por página via `divisaoAreasPorPagina()`
3. Calcula máximo de disciplinas por página
4. Adiciona frequência, legenda, observações e assinatura ao final

---

## 6. Dimensões e layout

| Item | Valor |
|---|---|
| Página portrait | 210mm × 297mm (A4) |
| Página landscape | 297mm × 210mm (A4) |
| Padding da página | 10px |
| Altura da assinatura | 160px (fixo) |
| Espaço mínimo livre | 30px |
| Margem superior (preview) | 50px |

**Moldura (bordas decorativas):**
- Azul: 2px solid `#2D7CBE`
- Dourada: gradiente `#B39B5D → #D6B56D`
- Cinza: gradiente `#C3C7D1 → #D0D0D0`
- Padding interno: 16px

---

## 7. Padrões arquiteturais identificados

### 7.1 Clonagem de componentes
O sistema usa `@ViewChildren` para obter instâncias, mede os elementos DOM e os clona para containers de página:
```typescript
const clone = elemento.hostElement.nativeElement.cloneNode(true);
this.container.nativeElement.appendChild(clone);
```

### 7.2 QueryList para rastreamento dinâmico
Componentes são rastreados via `QueryList` do Angular para medição e clonagem:
```typescript
@ViewChildren(DocGridAtaComponent) gridsAta: QueryList<DocGridAtaComponent>;
```

### 7.3 Timeouts para sincronização de DOM
Há uso de `setTimeout()` para aguardar re-renders antes de medir componentes — frágil e difícil de debugar.

### 7.4 Configuração via objeto simples
Documentos aceitam `ConfigDocumento` para controlar comportamento, mas o modelo é limitado e não cobre casos complexos.

---

## 8. Problemas e dívidas técnicas identificadas

| # | Problema | Impacto |
|---|---|---|
| 1 | Tipagem fraca (`any` em `group`, `images[]`, etc.) | Manutenção difícil |
| 2 | Uso de `underscore.js` em vez de métodos nativos | Dependência desnecessária |
| 3 | `setTimeout` para sincronização de layout | Flaky, não determinístico |
| 4 | Ausência de componente de debug | Dificulta diagnóstico de problemas de paginação |
| 5 | `compress: false` no jsPDF | PDFs grandes desnecessariamente |
| 6 | Typo "Outrubro" em `doc-assinatura` | Bug visual em documentos |
| 7 | Algoritmos de layout acoplados ao componente | Difícil testar e reusar |
| 8 | Ausência de validação de config de entrada | Erros silenciosos em runtime |
| 9 | Nenhum mecanismo para componentes declararem como se dividem | Quebra de tabelas entre páginas é manual e específica por documento |
| 10 | Cobertura de testes mínima | Apenas `spec.ts` vazios ou básicos |

---

## 9. Fluxo de dados completo

```
Ação do usuário (Imprimir / Salvar)
         ↓
DocumentViewerComponent.print() / save()
         ↓
PageControlService.montarPaginas()
   [mede componentes via fakePage, distribui entre páginas]
         ↓
PrintService.getImagesFromHTML()
   [htmlToImage.toPng() por página]
         ↓
PrintService.getPdfFromImages()
   [jsPDF.addImage() por página]
         ↓
printPDF() → dialog do navegador
save()     → download do arquivo
```

---

## 10. Dependências externas relevantes

| Biblioteca | Uso |
|---|---|
| `html-to-image` | Conversão DOM → PNG |
| `jsPDF` | Geração do PDF |
| `underscore` | Utilitários (apenas em ficha-individual) |
| `ngx-toastr` | Notificações de erro/sucesso |

> **Nota:** as versões exatas de `html-to-image` e `jsPDF` devem ser verificadas no `package.json` para avaliar possíveis upgrades de performance (ver `analise_melhorias.md`).
