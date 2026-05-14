# product.md — Document Builder: documento de produto

> Versão: 1.0 — 2026-05-07
> Baseado em: ideai.md + inspect.md (análise técnica do gerador-documentos atual)

---

## Visão geral

O `document-builder` é a próxima geração do `gerador-documentos`. O objetivo é manter o que funciona bem (controle de páginas, geração de PDF) e atacar os problemas estruturais que tornam difícil criar novos documentos.

A premissa central, inspirada no módulo `filtro`:

> **Um documento é apenas um arquivo de configuração bem definido.**

Assim como o `filtro` é "iniciado" com uma config e monta sua UI dinamicamente, um documento deve ser descrito por uma config e o `document-builder` monta as páginas, distribui os componentes e gera o PDF sem que o desenvolvedor precise escrever lógica de layout.

---

## Problemas que o produto resolve

| Problema atual | Como o document-builder resolve |
|---|---|
| Lógica de paginação acoplada a cada documento | Motor de layout genérico e reutilizável |
| Componentes não sabem como se dividir entre páginas | Contrato `Splittable` que componentes implementam |
| Nenhum debug de layout em produção | `DocumentDebugComponent` integrado |
| Config de documento limitada e sem tipagem | Config fortemente tipada, com defaults e validação |
| Algoritmos de layout com `setTimeout` frágil | Pipeline de layout síncrono e determinístico |
| Nomes em português misturados com inglês | Todos os componentes base em inglês |

---

## Princípios de design

Estas regras guiam todas as decisões de implementação do `document-builder`:

**1. Determinismo acima de flexibilidade**
Dimensões devem ser determinísticas sempre que possível. Antes de aceitar uma dimensão dinâmica (dependente de DOM, de conteúdo ou de CSS externo), perguntar: **"essa dimensão pode ser fixa?"** Se sim, deve ser fixa — o conteúdo se adapta ao espaço (`object-fit`, `overflow`, `text-overflow`), não o contrário.

> Exemplo: a área do logo no `DocHeaderComponent` é `60px × 60px` fixo. A imagem usa `object-fit: contain`. A altura do header é calculável sem DOM.

**2. Sem DOM, sem setTimeout**
Componentes de texto devem implementar `TextMeasurable` para ser medidos via Pretext (aritmética pura). Componentes que não podem evitar DOM devem ser a exceção documentada, não a regra.

**3. Um documento é uma config**
Toda lógica de layout fica no `LayoutEngine`. O documento declara o quê, o engine decide o onde.

---

## Conceitos centrais

### 1. Document Config

Um documento é descrito por um objeto `DocumentConfig`:

```typescript
interface DocumentConfig {
  title?: string
  orientation: 'portrait' | 'landscape'
  header?: HeaderConfig
  footer?: FooterConfig
  signature?: SignatureConfig
  frame?: FrameConfig
  debug?: boolean
}
```

Tudo que define a estrutura visual do documento está na config. O desenvolvedor não escreve HTML de layout — ele descreve o documento.

---

### 2. Splittable Components

Este é o ponto crítico do produto. Componentes que podem ter conteúdo variável (tabelas, grids, listas) **devem declarar como se dividem**.

Contrato obrigatório para componentes divisíveis:

```typescript
interface Splittable {
  // Retorna quantas linhas cabem no espaço disponível
  getRowsThatFit(availableHeight: number): number

  // Divide o componente em dois: o que cabe e o que sobra
  split(rowCount: number): { head: ComponentData; tail: ComponentData }

  // Altura de uma linha individual
  getRowHeight(): number
}
```

Com esse contrato, o motor de layout sabe exatamente como quebrar qualquer componente entre páginas sem lógica específica por documento.

---

### 3. DocumentEntry — a API pública do desenvolvedor

Esta é a interface que o desenvolvedor preenche para montar um documento. Nada mais é necessário além disso e de uma `DocumentConfig`.

```typescript
interface DocumentEntry<T = unknown> {
  data: T
  componentType: Type<{ data: T }>
  name?: string  // label opcional para o DocumentDebug
}
```

**Uso:**

```typescript
// No componente do documento — tudo que o dev precisa escrever:
entries: DocumentEntry[] = [
  { data: this.data.grades,      componentType: GradeTableComponent },
  { data: this.data.disciplines, componentType: DisciplineTableComponent },
  { data: this.data.attendance,  componentType: AttendanceComponent },
]
```

**Contrato dos componentes de conteúdo:**
- Devem ter `@Input() data: T` — o `DocumentViewer` faz `setInput('data', entry.data)` ao instanciar dinamicamente
- Opcionalmente implementam `TextMeasurable` (medição via Pretext) e/ou `Splittable` (quebra entre páginas)
- Não precisam saber nada sobre paginação, PDF ou layout

**Fluxo interno do `DocumentViewer`:**
```
DocumentEntry[]
  ↓  ViewContainerRef.createComponent() + setInput('data', ...)
instâncias Angular criadas em container oculto
  ↓  MeasurementService (Pretext ou DOM conforme implementação)
LayoutComponent[]  ← com heights calculados
  ↓  LayoutEngine.distribute()
Page[]  → renderizar páginas reais
```

---

### 4. TextMeasurable

Interface opcional que componentes de texto implementam para permitir que sua altura seja calculada **sem DOM**, via Pretext.

```typescript
interface TextMeasurable {
  // Segmentos de texto do componente (para Pretext medir)
  getTextSegments(): Array<{ text: string; font: string }>

  // Largura máxima do conteúdo de texto em pixels (sem padding)
  getMaxWidth(): number

  // Altura de linha em pixels (valor numérico — não '1.5em')
  getLineHeight(): number

  // Constantes de padding/margin que o componente adiciona ao resultado do Pretext
  getVerticalPadding(): number
}
```

**Regra de ouro:** se um componente implementa `TextMeasurable`, sua altura é `Pretext.layout().height + getVerticalPadding()`. Nenhum DOM é tocado.

**Quem implementa:**
- `DocTitle`, `DocTextField`, `DocText`, `DocLegend` — 100% via Pretext
- `DocHeader` — logo com área fixa (`60px`), texto da instituição via Pretext
- `DocSignature` — texto dos nomes/cargos via Pretext + padding fixo

**Quem NÃO implementa (e por quê):**
- `DocFrame` — sem texto, altura determinada pelo filho
- `DocInfoGrid` — layout de grid CSS com múltiplas colunas; colunas não têm largura fixa por texto
- Grids complexos (`DocTable` com colunas de largura variável) — largura de coluna depende do conteúdo mais largo

**Limitações que `TextMeasurable` impõe ao componente:**
1. `getMaxWidth()` deve ser derivável da config (page_width - padding fixo) — não pode depender do DOM
2. Font string deve ser explícito em TypeScript: ex: `'16px Nunito'` — não pode ser `font: inherit` ou CSS variable
3. `getLineHeight()` deve ser valor numérico em pixels — não `1.5` nem `normal`
4. Padding/margin devem existir como constantes TypeScript além do CSS — risco de dessincronização se CSS mudar sem atualizar a constante
5. `prepare()` do Pretext é **async** — o `DocumentViewer` precisa aguardar `document.fonts.ready` antes de iniciar a fase de medição

---

### 4. Layout Engine

O motor de layout é um serviço independente, testável, sem dependência de DOM durante a etapa de cálculo:

```typescript
class LayoutEngine {
  // Recebe componentes com alturas conhecidas e distribui entre páginas
  distribute(components: LayoutComponent[], pageConfig: PageConfig): Page[]
}
```

**Regras do motor:**
- Cada página tem um `availableHeight` calculado a partir da config (orientação, header, footer, assinatura)
- Se um componente não cabe inteiro e implementa `Splittable`, é dividido
- Se não implementa `Splittable`, vai para a próxima página inteiro
- A última página sempre reserva espaço para assinatura (quando configurada)

---

### 4. Document Debug Component

Um componente de debug que pode ser ativado via `debug: true` na config ou via parâmetro de URL. Expõe em overlay sobre o documento:

**Informações por documento:**
- Total de páginas
- Config completa do documento

**Informações por página:**
- Número da página
- Espaço total / espaço usado / espaço livre
- Tem cabeçalho? Tem assinatura? Tem título?
- Lista de componentes na página com nome e altura

**Informações por componente:**
- Nome
- Altura em pixels
- É divisível (`Splittable`)?
- Se dividido: qual a parte (head/tail) e quantas linhas

O debug deve ser renderizado como overlay visual sobre as páginas (sidebar ou painel flutuante), não em console.

---

## Componentes base (todos em inglês)

### Estrutura da página

| Componente | Responsabilidade |
|---|---|
| `DocumentPage` | Container de uma única página (portrait/landscape) |
| `DocumentViewer` | Orquestrador: inicializa, pagina, ativa print/save |
| `DocumentTopbar` | Barra de ações (print, save, close) |
| `DocumentLoading` | Estado de carregamento |
| `DocumentDebug` | Overlay de debug de layout |

### Conteúdo do documento

| Componente | Equivalente atual | Responsabilidade |
|---|---|---|
| `DocTitle` | `doc-title` | Título do documento |
| `DocHeader` | `doc-header` | Cabeçalho institucional |
| `DocFooter` | `doc-footer` | Rodapé com paginação |
| `DocSignature` | `doc-assinatura` | Bloco de assinaturas |
| `DocFrame` | `moldura` | Bordas decorativas |
| `DocInfoGrid` | `doc-grid-info` | Grid de informações do aluno |
| `DocTextField` | `doc-text-field` | Campo texto com label |
| `DocLegend` | `doc-legenda` | Legenda de símbolos |
| `DocText` | `doc-clean-text` | Texto simples com label |

---

## Módulo de exemplos

Deve ser criada uma rota `documents` no módulo de exemplos para testar o `document-builder`. Essa rota é o ambiente de desenvolvimento dos documentos — não serve para produção.

A rota deve listar os documentos disponíveis e permitir abrir cada um com dados mockados, facilitando desenvolvimento sem dependência de backend.

---

## Escopo do MVP

O MVP do `document-builder` deve entregar:

1. **Motor de layout** (`LayoutEngine`) funcionando com componentes simples (sem split)
2. **Contrato `Splittable`** definido e implementado em pelo menos um componente de tabela
3. **Interface `TextMeasurable`** definida e implementada nos componentes de texto elegíveis
4. **Todos os componentes base** em inglês, com dimensões fixas onde aplicável
5. **`DocumentDebug`** com as informações de página e componente
6. **Config fortemente tipada** com `DocumentConfig`
7. **Rota `documents`** no módulo de exemplos com pelo menos um documento usando o novo módulo
8. **`PrintService` mantido** — a geração de PDF via `htmlToImage` + `jsPDF` não muda no MVP

---

## Fora do escopo do MVP

- Migração dos documentos existentes (`ata-resultados-finais`, `ficha-individual`) — eles continuam usando o `gerador-documentos` atual
- Upgrade de `htmlToImage` e `jsPDF` — avaliado em `analise_melhorias.md`, executado após o MVP
- Documentos baseados puramente em config sem template HTML — possível evolução futura
- Eliminar completamente a fake page — enquanto houver componentes sem `TextMeasurable`, a fake page ainda é necessária como fallback

---

## Critérios de aceite

- [ ] Um documento pode ser criado descrevendo apenas uma `DocumentConfig` + componentes de conteúdo
- [ ] Um componente de tabela implementando `Splittable` quebra corretamente entre páginas sem lógica no documento
- [ ] `DocTitle`, `DocTextField` e `DocText` implementam `TextMeasurable` e têm altura calculada sem DOM
- [ ] `DocTableComponent.getRowHeight()` usa Pretext — sem DOM para calcular altura de linha
- [ ] `DocumentViewer.init()` aguarda `document.fonts.ready` antes de iniciar medição
- [ ] `DocumentDebug` exibe: total de páginas, espaço livre por página, componentes por página, se cada componente é `Splittable` e se usa `TextMeasurable`
- [ ] `LayoutEngine` é testável unitariamente sem dependência de DOM
- [ ] Todos os componentes base têm nomes em inglês e dimensões variáveis justificadas
- [ ] A rota `documents` funciona com dados mockados
- [ ] O typo "Outrubro" em `DocSignature` está corrigido

---

## Referência técnica

- Inspeção detalhada do módulo atual: `analise/inspect.md`
- Análise de melhorias nas bibliotecas: `analise/analise_melhorias.md`
- Análise da lib Pretext: `analise/pretext_analise.md`
- Análise das libs de geração de PDF: `analise/doc_builder_lib_analise.md`
- Tarefas de implementação e status: `tarefas.md`
- Registro de alterações: `changelog.md`
