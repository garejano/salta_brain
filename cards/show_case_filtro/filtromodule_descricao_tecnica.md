# FiltroModule — Descrição Técnica

## O que é

`FiltroModule` é um módulo Angular que encapsula toda a lógica de filtros de tela. Em vez de cada tela construir seu próprio componente de filtro com métodos de carregamento, cascata e persistência, o desenvolvedor declara uma configuração (`FilterConfig`) e o módulo cuida de tudo: renderização, validação, cascata entre campos, chamadas de API e persistência em localStorage.

O ponto de entrada na tela é a tag `<filtro>`. Não existe HTML de filtro escrito pelo desenvolvedor — apenas essa tag e um objeto de configuração.

---

## Arquitetura

```
FilterConfig (objeto de configuração)
    ↓
FiltroComponent          ← orquestrador principal
    ↓ (para cada campo)
FilterFieldWrapperComponent  ← wrapper por campo
    ↓
componentMap[field_type]     ← componente injetado dinamicamente via ViewContainerRef
    ↓
FiltroStorageService         ← localStorage automático
FiltroFormService            ← FormGroup centralizado
FiltroApiService             ← chamadas HTTP genéricas
```

**Arquivos do módulo** (`src/shared/filtro/`):

| Arquivo | Responsabilidade |
|---------|-----------------|
| `filtro.component.ts` | Orquestrador — cria form, gerencia cascatas, emite eventos |
| `filtro.component.html` | Template do painel (botões aplicar/limpar, slot de campos) |
| `field-wrapper/field-wrapper.component.ts` | Cria e gerencia cada campo dinamicamente |
| `filtro.storage.service.ts` | Lê/escreve estado no localStorage com validação e expiração |
| `filtro.form.service.ts` | Mantém FormGroup compartilhado entre componentes |
| `filtro.api.ts` | GET/POST genérico para carregar options dos campos |
| `filtro.models.ts` | Enums `FilterType`, `FieldType` e interfaces `FilterConfig`, `FilterItemConfig` |
| `filtro.validators.ts` | Validator customizado `dependencyValidator` para campos com `dependency_list` |
| `field-update.map.ts` | Mapa que resolve qual campo atualizar dado um evento de mudança |

---

## Como configurar

### FilterConfig — nível do filtro

```typescript
interface FilterConfig {
  id: string;           // chave única no localStorage
  id_save: string;      // id do botão Aplicar
  id_clear: string;     // id do botão Limpar
  id_toggle?: string;   // id do botão fechar painel
  defaultValue: string; // valor padrão para campos vazios (geralmente "")
  filters: FilterItemConfig[];
  title?: string;
  showSearchField?: boolean;
  searchPlaceholder?: string;
}
```

### FilterItemConfig — nível do campo

```typescript
interface FilterItemConfig {
  key: string;                    // chave no FormGroup e no payload do submit
  type: FilterType;               // tipo de negócio — usado no sistema de cascatas
  field_type: FieldType;          // tipo de input (define qual componente é injetado)
  label: string;
  placeholder?: string;
  required: boolean;
  service_name?: string;          // nome do método no serviço passado via [service]
  url?: string;                   // rota para FiltroApiService (alternativa ao service_name)
  autostart?: boolean;            // carrega options automaticamente no init
  selectFirst?: boolean;          // seleciona a primeira option após carregar
  watch_list?: FilterType[];      // recarrega este campo quando qualquer item da lista muda
  dependency_list?: FilterType[]; // valida que os itens da lista estão preenchidos antes de carregar
  showSelectTag?: boolean;        // exibe tag visual após aplicar o filtro
  tagOptions?: { icon: string; label?: string }; // ícone/label da tag
  colClass?: string;              // classe Bootstrap para largura (ex: "col-md-4")
  value?: any;                    // valor inicial
  options?: any[];                // options hardcoded (obrigatório para CustomRadio)
  info?: string;                  // texto informativo ao lado do campo (Checkbox/Toggle)
}
```

---

## Tipos de campo disponíveis (FieldType)

| FieldType | Visual | Caso de uso típico |
|-----------|--------|--------------------|
| `Select` | Dropdown seleção única | AnoLetivo, Turno, Série |
| `MultiSelect` | Dropdown seleção múltipla | Redes, Escolas, Disciplinas |
| `Date` | Date picker | Data início, Data fim |
| `Text` | Input de texto livre | Nome, CPF |
| `Checkbox` | Caixa de seleção booleana | "Apenas pendentes" |
| `CustomRadio` | Botões de rádio customizados | Situação, Tipo |
| `Toggle` | Switch on/off | "Exibir desabilitados" |

Cada `FieldType` corresponde a um componente Angular mapeado em `componentMap`. O `FilterFieldWrapperComponent` instancia o componente correto via `ViewContainerRef.createComponent()`.

---

## Tipos de negócio (FilterType)

`FilterType` é um enum com os domínios de negócio conhecidos pelo sistema (ex: `AnoLetivo`, `Rede`, `Escola`, `Serie`, `Professor`, `Disciplina`, etc. — 48+ valores). Ele serve exclusivamente para o sistema de cascatas identificar qual campo disparou uma mudança e quais campos precisam reagir. Não tem relação com o visual.

---

## Como funciona a cascata

Definida via `watch_list` e `dependency_list` na configuração de cada campo.

**`watch_list: [FilterType.AnoLetivo]`**
Quando o campo de tipo `AnoLetivo` muda de valor, este campo recebe um evento de atualização e recarrega suas options chamando `service_name` com o valor atual do form como argumento.

**`dependency_list: [FilterType.Rede]`**
O campo só carrega options se todos os campos em `dependency_list` estiverem preenchidos. O validator `dependencyValidator` aplica essa regra no FormControl — o campo fica inválido enquanto a dependência não for satisfeita.

**Exemplo de cascata com 3 níveis:**
```
AnoLetivo (autostart, selectFirst)
    → muda → Rede recarrega (watch_list: [AnoLetivo])
                 → muda → Escola recarrega (watch_list: [Rede], dependency_list: [Rede])
```

A cascata é resolvida por `FiltroComponent.findWatchers(changedFieldType)` — varre todos os campos procurando quem tem `watch_list` contendo o tipo que mudou, e dispara `FilterFieldWrapperComponent.update()` em cada um.

---

## Como usar na tela

### 1. Importar o módulo

```typescript
// módulo da tela
import { FiltroModule } from 'src/shared/filtro/filtro.module';

@NgModule({ imports: [FiltroModule] })
```

### 2. Criar a configuração

```typescript
// filtro_minha_tela.config.ts (ao lado do componente)
export const minhaTelaCfg: FilterConfig = {
  id: 'filtro_minha_tela',
  id_save: 'filtro_minha_tela_save',
  id_clear: 'filtro_minha_tela_clear',
  defaultValue: '',
  filters: [
    {
      field_type: FieldType.Select,
      service_name: 'anosLetivos',
      autostart: true,
      selectFirst: true,
      required: true,
      label: 'Ano Letivo',
      key: 'hashAnoLetivo',
      type: FilterType.AnoLetivo,
    },
    {
      field_type: FieldType.MultiSelect,
      service_name: 'redes',
      required: false,
      label: 'Rede',
      key: 'hashRede',
      type: FilterType.Rede,
      watch_list: [FilterType.AnoLetivo],
      dependency_list: [FilterType.AnoLetivo],
    },
  ],
};
```

### 3. Usar no template

```html
<filtro
  [service]="meuService"
  [config]="filtroConfig"
  [visible]="true"
  [loading]="loading"
  (submit)="onFiltroSubmit($event)">
</filtro>
```

### 4. Receber o resultado

```typescript
filtroConfig = minhaTelaCfg;

constructor(public meuService: MeuService) {}

onFiltroSubmit(params: any) {
  // params = { hashAnoLetivo: "abc", hashRede: ["def", "ghi"], pagina: 1 }
  this.carregarDados(params);
}
```

O serviço passado via `[service]` deve ter métodos com os nomes usados em `service_name` de cada campo. O FiltroModule chama `service[service_name](formData)` e espera um Observable com `{ data: any[] }`.

---

## Inputs e Outputs do componente

| Input | Tipo | Descrição |
|-------|------|-----------|
| `[config]` | `FilterConfig` | Configuração do filtro (obrigatório) |
| `[service]` | `any` | Serviço com métodos de API dos campos |
| `[visible]` | `boolean` | Controla se o painel está aberto |
| `[loading]` | `boolean` | Estado de loading externo |
| `[disabled]` | `boolean` | Desabilita o filtro inteiro |
| `[debugMode]` | `boolean` | Loga eventos no console |

| Output | Tipo | Descrição |
|--------|------|-----------|
| `(submit)` | `any` | Emite o valor do form quando "Aplicar" é clicado |
| `(resetList)` | `any` | Emite quando o filtro é limpo |
| `(fieldUpdateEvent)` | `{ key, value }` | Emite a cada mudança de campo |
| `(searchSubmit)` | `string` | Emite o valor da busca livre |
| `(changeFilterStatus)` | `void` | Emite ao abrir/fechar o painel |

**Métodos públicos** (acessíveis via `@ViewChild`):

```typescript
filtro.value()              // FormGroup.value atual
filtro.counter()            // quantidade de campos preenchidos
filtro.filtroValido()       // form é válido para submit?
filtro.reset()              // limpa o form e o storage
filtro.atualizarPagina(n)   // atualiza pagina sem resetar o filtro
filtro.fieldOptions(key)    // options carregadas de um campo específico
filtro.getTagsData()        // dados para renderizar as tags visuais
```

---

## Persistência em localStorage

O `FiltroStorageService` salva automaticamente o estado completo do filtro em `localStorage` com a chave `filtro_<config.id>`.

**Estrutura salva:**

```typescript
interface FilterStorage {
  version: number;
  usuario: string;            // hash do usuário autenticado
  dataCriacao: string;
  ultimaAtualizacao: string;
  validate: string;           // data de expiração (10 dias após criação)
  disableds: Record<string, boolean>;
  formData: T;                // valores atuais do form
  aplicado: boolean;
  dirty: boolean;
  optionsData: Record<string, any[]>; // options carregadas — evita nova chamada de API
  pagina: number;
}
```

**Validação ao recuperar:**
- Verifica se o hash do usuário autenticado bate com `storage.usuario`
- Verifica se `new Date(storage.validate) > new Date()` (expiração de 10 dias)
- Se inválido, descarta o storage e inicia do zero

---

## Exemplo de configuração real (produção)

Cascata com 6 níveis, tags visuais e layout customizado — do módulo `exemplos/filtros`:

```typescript
{
  id: 'filtro_macroturma',
  defaultValue: '',
  showSearchField: true,
  filters: [
    { field_type: FieldType.Select,      key: 'hashAnoLetivo', type: FilterType.AnoLetivo,
      autostart: true, selectFirst: true, required: true,
      showSelectTag: true, tagOptions: { icon: 'calendar_today' } },

    { field_type: FieldType.MultiSelect, key: 'hashRede',      type: FilterType.Rede,
      watch_list: [FilterType.AnoLetivo], dependency_list: [FilterType.AnoLetivo],
      showSelectTag: true, tagOptions: { icon: 'school' } },

    { field_type: FieldType.Select,      key: 'hashEscola',    type: FilterType.Escola,
      watch_list: [FilterType.Rede], dependency_list: [FilterType.Rede],
      colClass: 'col-12 col-md-6' },

    { field_type: FieldType.Select,      key: 'hashSerie',     type: FilterType.Serie,
      watch_list: [FilterType.Escola], dependency_list: [FilterType.Escola] },

    { field_type: FieldType.Select,      key: 'hashDisciplina', type: FilterType.Disciplina,
      watch_list: [FilterType.Serie], dependency_list: [FilterType.Serie] },

    { field_type: FieldType.Select,      key: 'hashProfessor', type: FilterType.Professor,
      watch_list: [FilterType.Serie], dependency_list: [FilterType.Serie],
      colClass: 'col-12 col-lg-9 col-md-4', tagOptions: { icon: 'person' } },
  ]
}
```

---

## Adoção no repositório

O módulo está em uso em **42 arquivos** distribuídos em **14 módulos** do repositório `estrutura-pedagogica`:

- **Folha**: gestão-pagamento (7 componentes), previa-carga, hora-aula
- **Pedagógico**: boletim, periodo-letivo, ocorrencia, grade-horaria, etapas
- **Escolas**: escolas-gerenciais, escolas-publicas, cargas-iniciais
- **Outros**: relatorio, movimentacao-pedagogica (2), itinerario-formativo (3)

Cada um desses filtros foi implementado como um arquivo de configuração `FilterConfig` — sem código imperativo de filtro duplicado entre telas.
