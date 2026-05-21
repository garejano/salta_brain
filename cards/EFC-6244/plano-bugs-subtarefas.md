# EFC-6244 — Plano de Correção dos Bugs (EFC-6396 a EFC-6400)

> Repositório: `estrutura-pedagogica` (Angular 20 + .NET 8)  
> Gerado em: 2026-05-20

---

## Mapa de Bugs

| Card | Área | Componente principal | Severidade |
|------|------|----------------------|------------|
| EFC-6396 | Frontend | `listar.component.ts` | Baixa |
| EFC-6397 | Frontend | `lancamento.component.ts` | Média |
| EFC-6398 | Frontend + Backend | `filtro_dias_sem_aula.ts` + deserialização JSON | Alta |
| EFC-6399 | Frontend + Backend | `formulario.component.ts` + `SalvarDiasSemAulaService` | Alta |
| EFC-6400 | Frontend (3 sub-bugs) | `modal.component.css`, `formulario.component.html`, `select-field` | Média |

---

## EFC-6396 — View padrão não respeita a resolução

### Diagnóstico

**Arquivo:** `frontend/src/app/features/lancamento-frequencia/listar/listar.component.ts`

```typescript
// linha 41
viewMode: 'table' | 'cards' = 'table';

// linha 68 — ngOnInit
this.viewMode = window.innerWidth < 768 ? 'cards' : 'table';
```

A detecção de resolução ocorre **uma única vez no `ngOnInit`**. Dois problemas:

1. Se o usuário acessa via mobile, o `window.innerWidth` é lido corretamente na carga inicial — mas ao aplicar o filtro (que pode causar re-renderização/reload do componente), o valor é lido novamente e pode divergir dependendo do ciclo de vida.
2. Não há listener de resize: ao rotacionar o dispositivo ou redimensionar a janela, o `viewMode` não é atualizado.

### Solução

Substituir o acesso direto ao `window.innerWidth` pelo `BreakpointObserver` do CDK.

`BreakpointObserver` usa `window.matchMedia` por baixo — que é uma **media query CSS nativa** — e só emite quando o threshold configurado é **cruzado** (ex.: ao passar de 767px para 768px). Isso é mais performático que `@HostListener('window:resize')`, que dispara a cada pixel enquanto o usuário arrasta a janela (requereria `debounceTime` para ser seguro). Para um toggle binário `table ↔ cards`, `BreakpointObserver` é o caminho correto.

**Arquivos a modificar:**
- `listar.component.ts`

**Mudança no `.ts`:**

```typescript
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { DestroyRef, inject } from '@angular/core';

// Remover a linha 41 (inicialização estática)
// Adicionar no constructor:
private destroyRef = inject(DestroyRef);

constructor(
  ...,
  private breakpointObserver: BreakpointObserver,
) {}

ngOnInit(): void {
  this.breakpointObserver
    .observe([Breakpoints.Handset, Breakpoints.TabletPortrait])
    .pipe(takeUntilDestroyed(this.destroyRef))
    .subscribe(state => {
      this.viewMode = state.matches ? 'cards' : 'table';
    });
  // ... resto do ngOnInit
}
```

> `BreakpointObserver` já está disponível em projetos Angular com CDK — verificar se `@angular/cdk` já está instalado no projeto (provável, pois é dependência do Material).

---

## EFC-6397 — Limpar marcações sem modal de confirmação

### Diagnóstico

**Arquivo:** `frontend/src/app/features/lancamento-frequencia/lancamento/lancamento.component.ts`

```typescript
// linha 239 — executa diretamente sem confirmação
async limparTodos(): Promise<void> {
  if (this.processandoLimpeza) { return; }
  this.processandoLimpeza = true;
  const marcados = this.alunos.filter(a => a.hashTipoFrequencia && !a.possuiJustificativa);
  // ...
}
```

O componente já possui padrão de confirmação inline para o caso de sair com pendências (`confirmarVoltarAberto`). O mesmo padrão deve ser aplicado aqui.

### Solução

**Arquivos a modificar:**
- `lancamento.component.ts`
- `lancamento.component.html`

**Mudança no `.ts`** — adicionar estado e handler:

```typescript
// Adicionar junto às propriedades de estado (após linha 65)
confirmarLimpezaAberto = false;

// Renomear o método atual para execução efetiva
private async executarLimpeza(): Promise<void> {
  if (this.processandoLimpeza) { return; }
  this.processandoLimpeza = true;
  const marcados = this.alunos.filter(a => a.hashTipoFrequencia && !a.possuiJustificativa);
  marcados.forEach(a => a.salvando = true);
  for (const aluno of marcados) {
    await this.registrarFrequenciaSync(aluno, null);
  }
  this.processandoLimpeza = false;
}

// O método público agora apenas abre o modal
limparTodos(): void {
  if (this.processandoLimpeza) { return; }
  this.confirmarLimpezaAberto = true;
}

confirmarLimpeza(): void {
  this.confirmarLimpezaAberto = false;
  this.executarLimpeza();
}

cancelarLimpeza(): void {
  this.confirmarLimpezaAberto = false;
}
```

**Mudança no `.html`** — adicionar bloco de confirmação (seguindo o padrão do `confirmarVoltarAberto` já existente):

```html
<!-- Modal de confirmação de limpeza — adicionar próximo ao modal de voltar -->
<div class="confirmacao-overlay" *ngIf="confirmarLimpezaAberto">
  <div class="confirmacao-box">
    <p>Deseja remover todas as marcações? Esta ação não pode ser desfeita.</p>
    <div class="confirmacao-acoes">
      <button class="button-secundary" (click)="cancelarLimpeza()">Cancelar</button>
      <button class="button-primary colored" (click)="confirmarLimpeza()">Confirmar</button>
    </div>
  </div>
</div>
```

> Verificar como o modal de `confirmarVoltarAberto` está estilizado no SCSS e replicar a mesma estrutura para consistência visual.

---

## EFC-6398 — Filtrar dia sem aula sem data início gera erro

### Diagnóstico

**Arquivo do filtro:** `frontend/src/app/features/dias-sem-aula/listar/filtro_dias_sem_aula.ts`

```typescript
// linha 138 — campo data início tem valor default
{
  field_type: FieldType.Date,
  key: "dataInicio",
  required: false,
  value: new Date().toISOString().substring(0, 10),  // default: data de hoje
}
```

**DTO do backend:** `DiasSemAulaFilterRequest.DataInicio` é `DateTime?` (nullable).

Quando o usuário limpa o campo de data, o componente de filtro envia a string `""` (vazia) no JSON. O deserializador `System.Text.Json` **não consegue converter `""` para `DateTime?`**, lançando uma exceção 400/500. O campo aceita `null` sem problemas — só falha com string vazia.

### Confirmação

Abrir o DevTools → Network ao reproduzir o bug. O request para `/diassemaula/get` conterá `"dataInicio": ""`.

### Solução

A correção pode ser feita no frontend, garantindo que o filtro envie `null` em vez de string vazia para campos de data opcionais.

**Opção A — No `FiltroComponent` (genérico, corrige para todos os filtros com Date):**

Localizar onde o `FiltroComponent` monta o objeto de request (método similar a `value()` ou `buildRequest()`). Para campos do tipo `FieldType.Date`, se o valor for string vazia, substituir por `null`:

```typescript
// Em filtro.component.ts ou filtro.models.ts — onde o value é construído
if (field.field_type === FieldType.Date && field.value === '') {
  field.value = null;
}
```

**Opção B — No `filtro_dias_sem_aula.ts` (localizado, sem impacto em outros filtros):**

Remover o `value` default do campo `dataInicio`:

```typescript
{
  field_type: FieldType.Date,
  key: "dataInicio",
  required: false,
  // Remover: value: new Date().toISOString().substring(0, 10),
}
```

Assim o campo inicia vazio e o filtro envia `null` (não string vazia) quando não preenchido.

> **Recomendação:** Opção A é mais segura e previne o mesmo bug em outros filtros de data. Verificar o comportamento do `FiltroComponent` para confirmar onde o value é serializado.

---

## EFC-6399 — Erro ao cadastrar dia sem aula

### Diagnóstico

**Arquivo do formulário:** `frontend/src/app/features/dias-sem-aula/formulario/formulario.component.ts`

```typescript
// linha 57 — hashEscola pode ser null/undefined
private initForm(item?: DiasSemAulaGetResponse): void {
  this.form = this.fb.group({
    hashEscola: [this.filterRequest.hashEscola ?? null],
    // ...
  });
}
```

**DTO do backend:** `DiasSemAulaSaveRequest.HashEscola` é `Guid` (não nullable).

```csharp
// SalvarDiasSemAulaService.cs linha 31
if (request.HashEscola == default) { result.AddError("Escola não informada."); }
```

Se `hashEscola` for `null` no JSON, o deserializador o converte para `Guid.Empty` (`default`), acionando a validação.

**Hipótese secundária:** O erro pode estar em outra validação do backend. Para confirmar a causa exata:

1. Abrir DevTools → Network ao clicar em "Confirmar"
2. Verificar o request JSON (confirmar que `hashEscola` está preenchido)
3. Verificar o response body com a mensagem de erro específica

### Solução por hipótese

**Hipótese A — `hashEscola` está null no request:**

Investigar se existe algum cenário de uso em que o filtro aplicado não possui escola selecionada (ex.: usuário com visão multi-escola ou erro de estado do filtro). Se confirmado:

```typescript
// formulario.component.ts — adicionar guarda no start()
start(filterRequest: DiasSemAulaFilterRequest, ...): void {
  if (!filterRequest.hashEscola) {
    this.notificationService.showError("Selecione uma escola no filtro antes de cadastrar.");
    return;
  }
  // ...
}
```

**Hipótese B — Erro de data/serialização (mesmo problema do EFC-6398):**

Se o campo `dataInicio` ou `dataFim` estiver sendo enviado como string vazia para o save (improvável pois há `Validators.required`), corrigir o form control para nunca enviar `""`.

**Hipótese C — Conflito de descrição ou turma:**

O backend verifica duplicidade de descrição e conflito de turmas por período. Pode ser que as mensagens de negócio estejam chegando mas não sendo exibidas corretamente. Verificar se `result?.message` é exibido na UI quando `result.isSuccess === false`.

---

## EFC-6400 — Quebra de layout no formulário de cadastro

Este card agrupa **três sub-bugs** distintos.

---

### Sub-bug 1 — Botão fechar não visível em mobile

**Arquivo:** `frontend/src/shared/components/modal/modal.component.css`

```css
/* Botão posicionado fora do viewport em telas menores */
.btn-modal-close {
  position: absolute;
  top: -50px;  /* ← Fica acima do modal, invisível se não há espaço */
  right: 0px;
}

.modal-eleva {
  min-width: 480px;  /* ← Muito largo para mobile */
}
```

**Solução:** Adicionar responsividade ao `modal.component.css`:

```css
@media (max-width: 600px) {
  .modal-eleva {
    min-width: 90vw;
    max-width: 95vw;
    padding: 16px;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    max-height: 90vh;
    overflow-y: auto;
  }

  .btn-modal-close {
    top: -44px;  /* ajustar conforme o espaço disponível acima do modal */
  }
}
```

> **Atenção:** O `modal.component` é compartilhado (`src/shared`). Qualquer alteração impacta todos os modais do sistema. Testar o comportamento em desktop antes de fazer deploy.

---

### Sub-bug 2 — Mensagem "Campo obrigatório" aparece sobre o label "Tipo"

**Arquivo:** `frontend/src/app/features/dias-sem-aula/formulario/formulario.component.html`

```html
<!-- Problema: msg-warn está como irmão dentro do flex .row-form -->
<div class="row-form">
    <single-select [label]="'Tipo'" ...></single-select>
    <div class="msg-warn" *ngIf="...">Campo obrigatório.</div>  <!-- aparece AO LADO -->
</div>
```

O `.row-form` usa `display: flex` (`formulario.component.scss` linha 14), então a `msg-warn` aparece na mesma linha que o `single-select`, sobrepondo o label do próximo campo.

**Solução:** Encapsular o select e sua mensagem em um wrapper `div`:

```html
<div class="row-form">
    <div>
        <single-select
            [label]="'Tipo'"
            [placeholder]="'Selecione'"
            [options]="tiposParaCadastro"
            [control]="form.get('hashTipo')"
            [required]="true"
            [forceDisabled]="edicao"
            (onChange)="onTipoChange($event?.hash)"
        ></single-select>
        <div
            class="msg-warn"
            *ngIf="form.get('hashTipo')?.hasError('required') && form.get('hashTipo')?.touched"
        >
            Campo obrigatório.
        </div>
    </div>
</div>
```

O `div` wrapper receberá `flex: 1` via `> *` do `.row-form`, e a mensagem de erro ficará abaixo do select.

---

### Sub-bug 3 — "Feriado regional" aparece cinza/selecionado ao reabrir dropdown

**Arquivo:** `frontend/src/shared/components/select-field/select-field.component.ts`

**Causa raiz:** O `toggleDropdown()` inicializa `hoveredIndex = 0` ao abrir o dropdown. Se "Feriado Regional" for o item de índice 0 na lista e o usuário tiver selecionado "Outros", ao reabrir o dropdown o primeiro item (Feriado Regional) recebe a classe `option-hovered` — que tem a mesma cor de fundo (`#e5e7eb`) que `option-selected`. Visualmente parece estar selecionado.

**Solução — inicializar `hoveredIndex` com o item atualmente selecionado:**

```typescript
// Em select-field.component.ts — método toggleDropdown()
toggleDropdown(): void {
  if (this.isDropdownOpen) {
    this.closeDropdown();
    return;
  }
  this.isDropdownOpen = true;
  // Em vez de: this.hoveredIndex = 0;
  // Usar o índice do item selecionado, ou -1 se nenhum
  this.hoveredIndex = this.selectedItem
    ? this.filteredOptions.findIndex(o => o.hash === this.selectedItem.hash)
    : -1;
  this.updateFilteredOptions();
}
```

**Solução alternativa — diferenciar os estilos `option-selected` e `option-hovered`:**

```scss
// select-field.component.scss
.option-item {
  &.option-selected {
    background-color: #dbeafe;  // azul claro — distingue de hover
    font-weight: 600;
  }

  &.option-hovered {
    background-color: #e5e7eb;  // cinza — apenas hover
  }
}
```

> A solução de inicializar `hoveredIndex` com o índice do item selecionado é mais correta semanticamente. A alternativa de cor é uma melhoria de UX, mas não elimina a confusão se ambas as classes puderem coexistir.

---

## Ordem de Implementação Sugerida

| Prioridade | Card | Justificativa |
|-----------|------|---------------|
| 1 | EFC-6398 | Erro funcional que impede uso do filtro. Fix de 1 linha. |
| 2 | EFC-6399 | Erro funcional que impede cadastro. Requer investigação inicial via DevTools. |
| 3 | EFC-6397 | Funcionalidade que executa ação destrutiva sem confirmação. |
| 4 | EFC-6400 | Três sub-bugs de UI, todos localizados. |
| 5 | EFC-6396 | Comportamento incorreto de UX em mobile. |

---

## Checklist de Testes Após Correção

- [ ] **EFC-6396:** Acessar listagem de frequência em viewport < 768px → view deve ser "Cards". Acessar em desktop → "Tabela". Rotacionar dispositivo → view atualiza.
- [ ] **EFC-6397:** Clicar em "Limpar marcações" → modal de confirmação aparece. Clicar "Cancelar" → marcações preservadas. Clicar "Confirmar" → marcações removidas.
- [ ] **EFC-6398:** Na aba "Dias sem aula", limpar o campo "Data início" do filtro e aplicar → resultado retorna sem erro.
- [ ] **EFC-6399:** Preencher todos os campos do formulário e clicar "Confirmar" → dia sem aula criado com sucesso.
- [ ] **EFC-6400-1:** Abrir o formulário de cadastro em resolução mobile → botão "X" de fechar é visível.
- [ ] **EFC-6400-2:** Selecionar um tipo e depois limpar → mensagem "Campo obrigatório" aparece abaixo do select, não ao lado do label.
- [ ] **EFC-6400-3:** Selecionar "Outros" como tipo, fechar dropdown, reabrir → apenas "Outros" aparece destacado; "Feriado Regional" não aparece cinza.
