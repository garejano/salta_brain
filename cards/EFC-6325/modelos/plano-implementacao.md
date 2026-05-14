# Plano de Implementação — EFC-666: Modelos de Documentos

## Objetivo

Criar modelos de documentos escolares usando o `document-builder`, organizados em arquivos de configuração por tipo de documento, com blocos genéricos reutilizáveis e integração na tela de exemplos.

---

## Arquitetura

O `document-builder` (`src/shared/document-builder/`) é a arquitetura adotada. Cada documento é definido por um array de `DocumentEntry`, onde cada entrada especifica:
- `componentType` — o componente Angular que renderiza o bloco
- `data` — dados tipados para aquele componente
- `name` — label para o painel de debug

O `DocumentViewerComponent` orquestra medição (Pretext ou DOM), distribuição em páginas e renderização. Componentes que implementam `TextMeasurable` são medidos sem DOM (mais rápido e determinístico); os demais são medidos por DOM.

---

## Blocos existentes (não alterar)

| Seletor | Componente | Tipo medição | Uso |
|---|---|---|---|
| `app-doc-title` | `DocTitleComponent` | TextMeasurable | Título principal do documento |
| `app-doc-header` | `DocHeaderComponent` | fixo (80px) | Cabeçalho institucional (logo, endereço) |
| `app-doc-footer` | `DocFooterComponent` | fixo (18px) | Rodapé com numeração de página |
| `app-doc-signature` | `DocSignatureComponent` | fixo (120px) | Bloco de assinaturas |
| `app-doc-info-grid` | `DocInfoGridComponent` | DOM | Grid de dados do aluno (2 colunas) |
| `app-doc-text-field` | `DocTextFieldComponent` | TextMeasurable | Campo com borda e label flutuante |
| `app-doc-text` | `DocTextComponent` | TextMeasurable | Texto simples com label |
| `app-doc-legend` | `DocLegendComponent` | TextMeasurable | Legenda de símbolos |
| `app-doc-table` | `DocTableComponent` | Splittable | Tabela com quebra automática entre páginas |
| `app-doc-presenca-info` | `DocPresencaInfoComponent` | DOM | Cabeçalho de lista de presença |

---

## Blocos reutilizáveis criados (EFC-666)

Criados em `src/shared/document-builder/components/` e registrados em `DocumentBuilderModule`.

### `app-doc-section` — `DocSectionComponent`

Cabeçalho de seção dentro do documento. Separa visualmente blocos de conteúdo relacionados.

- **Input:** `data: DocSectionData` → `{ title: string; subtitle?: string }`
- **Medição:** TextMeasurable — título de 1 linha (bold 11px Nunito)
- **Uso:** início de cada seção lógica (Identificação, Trajetória, Participantes, etc.)

```typescript
{ componentType: DocSectionComponent, data: { title: 'Identificação do Aluno' } }
```

### `app-doc-info-row` — `DocInfoRowComponent`

Linha horizontal de campos compactos `Label: Valor`. Usado para identificação de aluno, dados de reunião, datas de emissão etc.

- **Input:** `data: DocInfoRowData` → `{ fields: Array<{ label: string; value: string }> }`
- **Medição:** DOM — flex-wrap para múltiplos campos
- **Uso:** dados de identificação que não precisam de borda nem campo separado por linha

```typescript
{ componentType: DocInfoRowComponent, data: { fields: [
  { label: 'Aluno(a)', value: 'Maria Silva' },
  { label: 'RA', value: '2024001' },
  { label: 'Turma', value: '9º Ano A' },
]}}
```

### `app-doc-statement` — `DocStatementComponent`

Parágrafo de texto formal para declarações, certificações, observações e pareceres.

- **Input:** `data: DocStatementData` → `{ text: string; centered?: boolean }`
- **Medição:** TextMeasurable — texto justificado, quebra automática (10px Nunito)
- **Uso:** corpo de declarações, certificados, relatórios, comunicados

```typescript
{ componentType: DocStatementComponent, data: {
  text: 'Declaramos para os devidos fins que o(a) aluno(a) ...',
}}
```

---

## Modelos de documentos criados

Os modelos estão em `src/app/features/exemplos/documents/modelos/`. Cada arquivo exporta uma constante compatível com `DocumentDefinition` (`config`, `headerData`, `entries`) e um DocumentoModelo com metadados.

Dados de escola mock compartilhados em `modelos/mock-escola.ts`.

| Arquivo | Documento | Orientação | Componentes usados |
|---|---|---|---|
| `historico-escolar/` | Histórico Escolar | landscape | section, info-row, table, statement |
| `boletim-escolar/` | Boletim Escolar | portrait | section, info-row, table, statement |
| `declaracao-matricula/` | Declaração de Matrícula | portrait | section, info-row, statement |
| `certificado-conclusao/` | Certificado de Conclusão | portrait | section, info-row, statement |
| `ata-reuniao/` | Ata de Reunião | portrait | section, info-row, table, statement |
| `plano-aula/` | Plano de Aula | portrait | section, info-row, statement |
| `relatorio-pedagogico/` | Relatório Pedagógico | portrait | section, info-row, statement |
| `comunicado/` | Comunicado aos Pais | portrait | section, info-row, statement |

---

## Integração na tela de exemplos

`documents.component.ts` importa os 8 modelos e os expõe em `modeloSamples`. O template `documents.component.html` renderiza uma segunda grade com cabeçalho "Modelos de Documentos Escolares".

---

## Como adicionar um novo modelo

1. Crie pasta em `modelos/<nome-kebab>/`
2. Crie `<nome>.modelo.ts` exportando `const <nomeModelo>: DocumentoModelo`
3. Use os dados do `mock-escola.ts` como base e customize
4. Importe em `documents.component.ts` e adicione em `modeloSamples`

## Como adicionar um novo bloco genérico

1. Crie a pasta em `src/shared/document-builder/components/<nome>/`
2. Crie `.component.ts`, `.component.html`, `.component.scss`
3. Se o bloco tem texto simples: implemente `TextMeasurable`
4. Se o bloco tem linhas de tabela: implemente `Splittable`
5. Registre em `document-builder.module.ts` (declarations + exports)
6. Adicione a interface de dados em `models/document-config.ts`
7. Documente aqui neste arquivo

---

## Decisões de design

- **Blocos genéricos vs. componentes por documento:** optou-se por blocos genéricos (`section`, `info-row`, `statement`, `table`) que compõem qualquer documento sem criar um componente Angular por tipo. Isso mantém o `DocumentBuilderModule` enxuto.
- **TextMeasurable vs. DOM:** `doc-section` e `doc-statement` implementam `TextMeasurable` por serem texto simples (determinístico). `doc-info-row` usa DOM porque o flex-wrap depende da largura real do container.
- **Modelos como arquivos `.ts`:** cada modelo é um arquivo TypeScript puro com mock data, sem componente Angular separado. Isso facilita a evolução para dados reais (basta trocar o mock pelo retorno da API).
