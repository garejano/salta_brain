# Plano de Migração — FichaIndividual → Document-Builder

**Data:** 2026-05-15  
**Repositório destino:** `estrutura-pedagogica` (frontend)  
**Builder de referência:** `estrutura-pedagogica/frontend/src/shared/document-builder/`  
**Cards relacionados:** EFC-6292 (transfer endpoints), EFC-6325 (document-builder)

> **Objetivo:** Criar a FichaIndividual em `estrutura-pedagogica` usando o `document-builder`.  
> O document-builder **permanece** em `estrutura-pedagogica` — não é compartilhado.  
> O frontend da FichaIndividual **sai** de `documentacao-pedagogica` e passa a viver em `estrutura-pedagogica`.  
> Esta migração serve de **template** para os demais documentos de `documentacao-pedagogica` que serão migrados posteriormente.

---

## 1. Situação Atual

### Onde vive o documento hoje (`documentacao-pedagogica`)

| Camada | Arquivo |
|--------|---------|
| Controller | `backend/.../Controllers/FichaIndividualController.cs` |
| Service | `backend/.../FichaIndividual/FichaIndividualGetService.cs` |
| Repository | `backend/.../Repositories/Notas/FichaIndividualRepository.cs` |
| Componente principal | `frontend/.../ficha-individual/ficha-individual.component.ts` |
| Serviço HTTP | `frontend/.../ficha-individual-impressao.service.ts` |
| Geração de PDF | `frontend/.../print.service.ts` (html-to-image + jsPDF próprio) |
| Controle de página | `frontend/.../page-control.service.ts` (paginação manual) |

### Problema da implementação atual

- Paginação manual e frágil via `page-control.service.ts`
- PDF gerado com `print.service.ts` local — reinventa o que o document-builder já faz
- `DocumentViewerComponent` e `DocumentPageComponent` customizados localmente
- Difícil manter: qualquer mudança de layout requer ajustar a paginação manual

### Estrutura dos dados (backend — não muda)

```typescript
// Request
FichaIndividualGetRequest {
  hashRede: Guid
  hashUsuario?: Guid          // aluno
  hashAnoLetivo?: Guid
  hashSerie?: Guid
  hashTurma?: Guid
  ativo: boolean
  dataMatricula?: DateTime
}

// Response
FichaIndividualGetResponse {
  escopoRegular: FichaIndividualEscopoGetResponse
  escopoDiversificado: FichaIndividualEscopoGetResponse
  escopoItinerarioSemestral: FichaIndividualEscopoGetResponse
  escopoDependencia: FichaIndividualEscopoGetResponse
  percentualFrequencia: string
  cargaHoraria: string
  resultadoFinal: string        // "Aprovado", "Cursando", etc.
  observacoesAluno: string
  legenda: Array<{ sigla: string, descricao: string }>
}

// Cada escopo:
FichaIndividualEscopoGetResponse {
  nomeComponente: string
  etapas: Array<{ hash, descricao, colunas }>   // colunas = avaliações dentro da etapa
  disciplinas: Array<{
    nomeDisciplina: string
    hashDisciplina: Guid
    notas: Array<nota por coluna>
    cargaHoraria: string
    areaConhecimento: string
    ehEnriquecimentoCurricular: boolean
  }>
}
```

---

## 2. Estado Alvo

### Onde o documento vai viver (`estrutura-pedagogica`)

```
estrutura-pedagogica/frontend/src/app/features/ficha-individual/
  ├── ficha-individual.component.ts       (componente pai — orquestra entries + viewer)
  ├── ficha-individual.component.html
  ├── ficha-individual.module.ts
  ├── services/
  │   └── ficha-individual.service.ts     (métodos de chamada HTTP — dados mockados)
  └── components/
      └── ficha-individual-wide-table/
          ├── ficha-individual-wide-table.component.ts   (grade de notas — ColumnSplittable)
          └── ficha-individual-wide-table.component.html
```

O `document-builder` já existe em `estrutura-pedagogica/frontend/src/shared/document-builder/` e é importado normalmente.

### Arquitetura alvo

```
FichaIndividualComponent
  ├─ Chama FichaIndividualService.get() → dados mockados
  ├─ Transforma FichaIndividualGetResponse em DocumentEntry[]
  │    ├─ DocSectionComponent        (título de cada escopo)
  │    ├─ FichaIndividualWideTableComponent  (grade notas — ColumnSplittable)
  │    ├─ DocLegendComponent         (legenda de siglas)
  │    └─ DocTextFieldComponent      (frequência, resultado final, observações)
  └─ Passa ao <app-document-viewer [entries] [config] [headerData]>
       → LayoutEngine distribui entre páginas automaticamente
       → PrintService gera PDF
```

### Dados mockados

O `FichaIndividualService` terá os métodos reais (`get()`, `getResumida()`) mas retornando dados mockados via `of(mockData)`. O mock deve cobrir:
- Pelo menos 2 escopos preenchidos (regular + diversificado)
- Grade grande: ~15 disciplinas × 3 etapas com 2-3 avaliações cada (para validar quebra de colunas)
- Legenda com 2-3 entradas
- Frequência, resultado final e observações preenchidos

---

## 3. Componentes a Criar

### 3.1 `FichaIndividualWideTableComponent` ⭐ (mais crítico)

A grade de notas é uma tabela com colunas variáveis:
- **Colunas fixas (esquerda):** disciplina, área de conhecimento, carga horária
- **Colunas variáveis:** etapa 1 → avaliações internas + média, etapa 2 → ..., resultado final

Deve implementar `ColumnSplittable` para que o LayoutEngine quebre automaticamente quando as colunas não cabem em uma página.

Referência direta: `estrutura-pedagogica/frontend/src/shared/document-builder/components/doc-wide-table/`

### 3.2 `FichaIndividualComponent`

Monta os `DocumentEntry[]` a partir do response mockado:

```typescript
buildEntries(data: FichaIndividualGetResponse): DocumentEntry[] {
  const entries: DocumentEntry[] = [];

  for (const escopo of [data.escopoRegular, data.escopoDiversificado, ...]) {
    if (!escopo?.disciplinas?.length) continue;
    entries.push({ componentType: DocSectionComponent, data: { title: escopo.nomeComponente } });
    entries.push({ componentType: FichaIndividualWideTableComponent, data: { escopo, config } });
  }

  entries.push({ componentType: DocLegendComponent, data: { items: data.legenda } });
  entries.push({ componentType: DocTextFieldComponent, data: { label: 'Frequência', value: data.percentualFrequencia } });
  entries.push({ componentType: DocTextFieldComponent, data: { label: 'Resultado Final', value: data.resultadoFinal } });

  return entries;
}
```

`DocumentConfig`:
```typescript
config: DocumentConfig = {
  orientation: 'landscape',    // grade de notas é larga
  header: { show: true, onAllPages: true },
  footer: { show: true },
  signature: { show: true },
  componentGap: 12,
}
```

### 3.3 `FichaIndividualService`

```typescript
@Injectable({ providedIn: 'root' })
export class FichaIndividualService {

  // Método real — dados mockados via of()
  get(request: FichaIndividualGetRequest): Observable<FichaIndividualGetResponse> {
    return of(FICHA_INDIVIDUAL_MOCK);
  }

  getResumida(request: FichaIndividualGetRequest): Observable<FichaIndividualGetResponse> {
    return of(FICHA_INDIVIDUAL_RESUMIDA_MOCK);
  }
}
```

---

## 4. Passo a Passo da Migração

### Fase 1 — Análise e preparação

- [ ] Ler `DocWideTableComponent` completo — entender interface `ColumnSplittable`
- [ ] Ler `layout-engine.service.ts` — entender como `distribute` trata `ColumnSplittable`
- [ ] Ver exemplos em `estrutura-pedagogica/frontend/src/app/features/exemplos/documents/` — identificar o mais próximo de uma wide table com dados reais
- [ ] Mapear variações de configuração que afetam o layout:
  - `agruparPorAreaConhecimento` (boolean)
  - `exibirUmaCasaDecimal` (boolean)
  - versão resumida vs. completa

### Fase 2 — Criar mock e service

- [ ] Criar `ficha-individual-mock.ts` com dados realistas (grade grande)
- [ ] Criar `FichaIndividualService` com `get()` e `getResumida()` retornando o mock

### Fase 3 — Criar `FichaIndividualWideTableComponent`

- [ ] Criar componente em `features/ficha-individual/components/ficha-individual-wide-table/`
- [ ] Implementar `ColumnSplittable`
- [ ] Definir colunas fixas (disciplina, área, carga horária) e variáveis (etapas → avaliações)
- [ ] Aplicar estilos visuais equivalentes ao layout atual em `documentacao-pedagogica`
- [ ] Testar quebra de colunas com grade grande

### Fase 4 — Criar `FichaIndividualComponent`

- [ ] Criar módulo e componente pai em `features/ficha-individual/`
- [ ] Implementar `buildEntries()` para montar `DocumentEntry[]` por escopo
- [ ] Configurar `DocumentConfig` (landscape, header em todas as páginas, footer, signature)
- [ ] Configurar `DocHeaderData` com dados mockados da rede/escola
- [ ] Usar `<app-document-viewer>` no template
- [ ] Adicionar rota em `estrutura-pedagogica`

### Fase 5 — Testes e validação

- [ ] Versão completa: múltiplos escopos, grade grande → validar quebra de colunas
- [ ] Versão resumida: estrutura diferente
- [ ] Agrupamento por área de conhecimento
- [ ] Imprimir e salvar PDF

---

## 5. Pontos de Atenção

| Risco | Mitigação |
|-------|-----------|
| Grade com N colunas variáveis (etapas + avaliações internas) | `ColumnSplittable` já resolve — ver `DocWideTableComponent` como referência |
| Configurações da rede afetam layout (casas decimais, agrupamento) | Passar configurações como `@Input` ao `FichaIndividualWideTableComponent` |
| Versão resumida tem estrutura diferente | `buildEntries()` separado por modo; mesmo componente de tabela |

---

## 6. Padrão para Migração dos Demais Documentos

Após a FichaIndividual, o mesmo processo se aplica aos outros documentos de `documentacao-pedagogica`:

1. **Identificar** o componente atual e seu mecanismo de geração de PDF
2. **Mapear** os dados (request/response do backend — não muda)
3. **Criar** componentes com `TextMeasurable`, `Splittable` ou `ColumnSplittable` conforme a grade
4. **Criar** service com dados mockados
5. **Montar** `DocumentEntry[]` + `DocumentConfig` + `DocHeaderData`
6. **Substituir** template pelo `<app-document-viewer>`
7. **Remover** implementação antiga de `documentacao-pedagogica`

---

## 7. Referências

- `estrutura-pedagogica/frontend/src/shared/document-builder/README.md` — guia do builder
- `estrutura-pedagogica/frontend/src/app/features/exemplos/documents/` — exemplos implementados
- `estrutura-pedagogica/frontend/src/shared/document-builder/components/doc-wide-table/` — referência de ColumnSplittable
- `documentacao-pedagogica/frontend/src/app/ficha-individual/` — implementação atual a ser substituída
