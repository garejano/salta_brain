# Plano: Página `filtros-tour` no módulo de Exemplos

## Objetivo

Criar a página `/exemplos/filtros-tour` em `estrutura-pedagogica` — uma landing page técnica que apresenta o `filtro_novo` para desenvolvedores e para a IA, destacando vantagens sobre o `filtro_antigo` com exemplos visuais interativos.

---

## Contexto do módulo de exemplos

- **Caminho**: `c:/projects/estrutura-pedagogica/frontend/src/app/features/exemplos/`
- **Rota lazy-loaded**: `/exemplos/filtros-tour`
- **Condição de rota**: só carrega com `environment.useExempleModule = true`
- **Padrão de navegação**: cards clicáveis no `ExemplosDashboardComponent`
- **Referência visual**: `document-builder-tour` (slides com tour) e `document-builder-ia-guide` (13 slides técnicos)

---

## Arquivos a criar

```
exemplos/
└── filtros-tour/
    ├── filtros-tour.component.ts
    ├── filtros-tour.component.html
    ├── filtros-tour.component.scss
    └── exemplos/
        ├── exemplo-cascata/
        │   ├── exemplo-cascata.component.ts
        │   └── exemplo-cascata.component.html
        ├── exemplo-tipos-campo/
        │   ├── exemplo-tipos-campo.component.ts
        │   └── exemplo-tipos-campo.component.html
        └── exemplo-storage/
            ├── exemplo-storage.component.ts
            └── exemplo-storage.component.html
```

---

## Arquivos a modificar

| Arquivo | Mudança |
|---------|---------|
| `exemplos-routing.module.ts` | Adicionar rota `filtros-tour` |
| `exemplos.module.ts` | Declarar `FiltrosTourComponent` e sub-componentes |
| `exemplos-dashboard.component.html` | Adicionar card de navegação para `filtros-tour` |
| `exemplos-dashboard.component.ts` | Adicionar objeto de card na lista |

---

## Estrutura da página: seções

### Seção 1 — Hero / Introdução

**Propósito**: contextualizar o problema e a solução de forma imediata.

Conteúdo:
- Título: `filtro_novo — O módulo de filtros de estrutura-pedagogica`
- Subtítulo curto explicando o que é (configuração por JSON, sem boilerplate)
- Dois números de impacto visíveis:
  - `42 arquivos` utilizam o módulo hoje
  - `~600 linhas economizadas` por tela (comparativo com filtro_antigo)
- Link direto para `/exemplos/filtros` (exemplos interativos já existentes)

---

### Seção 2 — O problema: `filtro_antigo`

**Propósito**: mostrar concretamente a dor que o módulo resolve.

Conteúdo:
- Título: "Antes do módulo: o padrão manual"
- Tabela de custo do `filtro_antigo` (real, baseado na análise):

| Métrica | `filtro_antigo` |
|---------|----------------|
| Linhas de código | 657 linhas |
| Para | 5 dropdowns em cascata |
| Padrão `getXXX()` duplicado | 4× (~37 linhas cada) |
| Padrão `selecionaXXX()` duplicado | 5× |
| Subscriptions sem `unsubscribe` | 2 (memory leak) |
| Tipagem `any` | 15+ usos |
| Reúso em outras telas | 0 (hardcoded) |

- Snippet de código mostrando o padrão repetido: `getAnosLetivos()` vs `getRedes()` lado a lado
- Highlight visual: "Cada tela nova = reescrever tudo do zero"

---

### Seção 3 — A solução: `filtro_novo`

**Propósito**: apresentar a arquitetura e o modelo mental correto.

Conteúdo:
- Título: "Com o módulo: configuração por JSON"
- Diagrama de fluxo do ciclo de vida (texto/ASCII em cards):

```
FilterConfig (JSON)
    ↓
FiltroComponent (orquestrador)
    ↓
FilterFieldWrapperComponent (para cada campo)
    ↓
componentMap[field_type] → Componente dinâmico injetado
    ↓
DynamicInjectorService → providers do campo
    ↓
FiltroStorageService → localStorage automático
```

- Comparativo de código: implementar o mesmo filtro (AnoLetivo → Rede → Escola) nos dois estilos
  - `filtro_antigo`: mostrar ~100 linhas necessárias
  - `filtro_novo`: mostrar a config JSON equivalente (~25 linhas)

- Destaque das 4 vantagens principais:
  1. **Configuração declarativa** — JSON define tudo, sem template HTML
  2. **Cascatas automáticas** — `watch_list` + `dependency_list` sem código manual
  3. **localStorage integrado** — persistência com validação de usuário e expiração sem código adicional
  4. **12 tipos de campo prontos** — select, multiselect, date, text, checkbox, toggle, money, file, radio, textarea, number, time

---

### Seção 4 — Exemplos interativos

**Propósito**: mostrar visualmente o que é possível construir — é a seção mais importante para o desenvolvedor.

Cada exemplo é um sub-componente renderizado na página com seu código de configuração exibido ao lado.

#### Exemplo 4.1 — Cascata simples (AnoLetivo → Rede → Escola)
- Filtro funcional renderizado
- Config JSON colapsável ao lado
- Explicação de `watch_list` e `dependency_list`
- Usa `filtro_exemplo.config.ts` já existente como base

#### Exemplo 4.2 — Todos os tipos de campo
- Filtro com um campo de cada `FieldType` disponível
- Grid visual mostrando cada campo com seu tipo
- Config JSON correspondente

#### Exemplo 4.3 — localStorage em ação
- Filtro com `id` configurado
- Instrução: "Aplique o filtro, navegue para outra rota e volte"
- Indicador visual mostrando o que foi restaurado do storage
- Explicação da estrutura `FilterStorage` (expiração, validação de usuário)

#### Exemplo 4.4 — Tags visuais (`showSelectTag`)
- Filtro com campos configurados com `showSelectTag: true` e `tagOptions`
- Mostra como tags aparecem após aplicar o filtro
- Config JSON mostrando `tagOptions.icon` e `tagOptions.label`

---

### Seção 5 — Referência de configuração

**Propósito**: guia rápido de consulta para o desenvolvedor (e para a IA).

Conteúdo:
- Tabela completa de `FilterConfig`:

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `id` | `string` | ✅ | ID único do filtro (usado no storage) |
| `id_save` | `string` | ✅ | ID do botão Aplicar |
| `id_clear` | `string` | ✅ | ID do botão Limpar |
| `id_toggle` | `string` | ❌ | ID do botão fechar painel |
| `defaultValue` | `string` | ✅ | Valor padrão vazio (geralmente `""`) |
| `filters` | `FilterItemConfig[]` | ✅ | Array de campos |
| `title` | `string` | ❌ | Título do painel |
| `showSearchField` | `boolean` | ❌ | Exibe campo de busca livre |
| `searchPlaceholder` | `string` | ❌ | Placeholder da busca |

- Tabela completa de `FilterItemConfig`:

| Propriedade | Tipo | Obrigatório | Descrição |
|-------------|------|-------------|-----------|
| `key` | `string` | ✅ | Chave no FormGroup |
| `type` | `FilterType` | ✅ | Tipo de negócio (48 disponíveis) |
| `field_type` | `FieldType` | ✅ | Tipo de input (12 disponíveis) |
| `label` | `string` | ✅ | Label do campo |
| `placeholder` | `string` | ✅ | Placeholder |
| `required` | `boolean` | ✅ | Campo obrigatório? |
| `url` | `string` | ❌ | Chave para FiltroApiService |
| `service_name` | `string` | ❌ | Método de serviço customizado |
| `autostart` | `boolean` | ❌ | Carrega opções no init |
| `selectFirst` | `boolean` | ❌ | Seleciona primeira opção |
| `watch_list` | `FilterType[]` | ❌ | Observa mudanças nesses campos |
| `dependency_list` | `FilterType[]` | ❌ | Requer esses campos preenchidos |
| `showSelectTag` | `boolean` | ❌ | Exibe tag após aplicar |
| `tagOptions` | `FieldTagOptions` | ❌ | `{ icon, label }` da tag |
| `colClass` | `string` | ❌ | Classe Bootstrap (ex: `"col-md-4"`) |
| `value` | `any` | ❌ | Valor inicial do campo |
| `options` | `any[]` | ❌ | Opções hardcoded (para radio/checkbox) |

- Tabela de `FieldType` com visual de cada componente:

| FieldType | Visual | Uso típico |
|-----------|--------|-----------|
| `select` | Dropdown único | AnoLetivo, Turno |
| `multiselect` | Dropdown múltiplo | Redes, Escolas |
| `text` | Input de texto | Nome, CPF |
| `date` | Date picker | Data início/fim |
| `checkbox` | Toggle booleano | "Apenas pendentes" |
| `customradio` | Botões de rádio | Opções exclusivas |
| `toggle` | Switch on/off | Habilitar/desabilitar |
| `number` | Input numérico | Quantidade |
| `textarea` | Texto multilinha | Observações |
| `time` | Time picker | Horário |
| `money` | Input de moeda | Valores |
| `file` | Upload | Documentos |

---

### Seção 6 — Adoção no repositório

**Propósito**: provar que o módulo funciona em escala, em produção.

Conteúdo:
- Destaque visual: `42 arquivos` utilizam o módulo
  - `14 módulos` importam `FiltroModule`
  - `28 componentes` usam `FiltroComponent` diretamente
- Lista dos domínios que utilizam (agrupados por área):
  - **Folha**: folha.module, gestão-pagamento (7 componentes), previa-carga, hora-aula
  - **Pedagógico**: boletim, periodo-letivo, ocorrencia, grade-horaria, etapas
  - **Escolas**: escolas-gerenciais, escolas-publicas, cargas-iniciais
  - **Outros**: relatorio, movimentacao-pedagogica, itinerario-formativo (3)
- Mensagem: "Cada um desses filtros foi implementado com uma config JSON — sem código duplicado"

---

### Seção 7 — Guia para a IA

**Propósito**: documentar explicitamente como a IA deve implementar um filtro novo.

Conteúdo (em formato de passos numerados):

**Passo 1 — Identificar os campos necessários**
```
Pergunte: quais dados o filtro precisa capturar?
→ Mapeie cada dado para um FieldType disponível
→ Identifique dependências (qual campo depende de qual?)
```

**Passo 2 — Criar o arquivo de configuração**
```
filtro_[nome_tela].config.ts
→ Defina FilterConfig com id único
→ Liste FilterItemConfig[] com key, type, field_type, label
→ Configure watch_list e dependency_list para cascatas
```

**Passo 3 — Importar FiltroModule**
```typescript
// no módulo da tela
import { FiltroModule } from 'src/shared/filtro/filtro.module';

@NgModule({
  imports: [FiltroModule]
})
```

**Passo 4 — Usar no template**
```html
<filtro
  #filtro
  [config]="filterConfig"
  [loading]="loading"
  (submit)="onFiltroSubmit($event)"
></filtro>
```

**Passo 5 — Receber resultado**
```typescript
onFiltroSubmit(params: any) {
  // params = { hashAnoLetivo: "...", hashRedes: [...], ... }
  this.carregarDados(params);
}
```

- Nota sobre `FilterType`: ao adicionar um tipo de negócio novo, adicionar ao enum em `filtro.models.ts`
- Nota sobre API: se a URL não existe no `FiltroApiService`, passar `service_name` apontando para método de serviço do componente pai

---

## Integração no Dashboard

### Card a adicionar em `exemplos-dashboard.component`

```typescript
{
  icon: 'filter_alt',
  iconColor: 'teal',
  title: 'Filtros Tour',
  description: 'Showcase completo do módulo filtro_novo — arquitetura, exemplos interativos, comparativo com o padrão antigo e guia de implementação.',
  chips: ['filtro_novo', 'configuração', 'localStorage', 'cascata'],
  route: 'filtros-tour',
}
```

---

## Rota a adicionar em `exemplos-routing.module.ts`

```typescript
{ path: 'filtros-tour', component: FiltrosTourComponent },
```

---

## Estilo visual

Seguir o padrão visual do `document-builder-tour`:
- Fundo branco, seções com padding generoso
- Cards com `border-radius: 12px`, `box-shadow: $shadow-md`
- Destaques de código com fundo `#1e1e1e` (dark), fonte monospace
- Grid 3 colunas → 2 → 1 em breakpoints 1080px e 720px
- Cores por seção: teal para comparação, amber para exemplos, indigo para referência
- Badges/chips coloridos para `FieldType` e `FilterType`

---

## Dúvidas / pontos a validar

1. **`filtro_exemplo.api.ts`** — existe um mock de API no módulo exemplos. Os exemplos interativos da seção 4 devem usar esse mock ou criar um novo? Verificar se ele já tem as URLs necessárias.
todos podem usar os mesmo mocks que os exmplos usam, pode criar mock caso necessario para exemplificar a feature

2. **FilterType** — para os exemplos da seção 4.2 (todos os tipos de campo), será necessário adicionar novos `FilterType` no enum ou reutilizar existentes como placeholder?
Use os que ja existe

3. **Profundidade da seção 7** — o guia para a IA deve incluir o passo de adicionar `FilterType` novo ao enum? Ou assumir que os 48 existentes cobrem os casos?
- aqui seria bom desmontrar como esse filtro_novo eh benefico para o desenvolvimento com IA, se consome menos tokens, se consegue gerar output mais deterministico

4. **localStorage visível** — na seção 4.3, a instrução "navegue e volte" requer que o usuário tenha a rota configurada. Seria melhor mostrar o storage via um inspetor visual na própria tela (ler e exibir o `localStorage['filtro_exemplo_storage']`)?
nao precisa ir e voltar em tela, so uma sessao explicando o storage e quais dados ele gera e quais vantagens e oportunidades que isso abre para o desenvolvimento
