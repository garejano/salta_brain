# Análise: `lancamento/lancar-nota` — Módulo de Notas

> Data: 2026-05-12  
> Repositório: `c:/projects/notas/frontend/`  
> Componente: `src/app/pages/lancamentos/lancar-nota/lancar-nota.component.*`

---

## 1. Problema Visual — Checkbox vs Toggle na coluna "Falta"

### Situação atual

O cabeçalho da coluna é `<th>Falta</th>` e cada linha da tabela usa um `<input type="checkbox">` nativo:

```html
<!-- lancar-nota.component.html, linha 141-148 -->
<input
  [attr.disabled]="deveDesabilitarFaltou(aluno, idx)"
  [formControlName]="'faltou_' + idx"
  class="form-control falta-input"
  type="checkbox"
  (change)="possuiFaltaComNota(aluno, idx)" />
<label [for]="'faltou_' + idx">{{ (aluno.ativo) ? 'Faltou' : 'Transferido' }}</label>
```

### O que deveria ser

O "Apenas pendentes" usa o componente `<app-checkbox-field>`, que renderiza como toggle switch (CSS `.switch` / `.slider`, verde `#28975A`). O mesmo padrão deve ser aplicado ao campo Falta/Transferido.

**Localização do componente toggle:**
- `src/core/components/checkbox-field/checkbox-field.component.ts`
- `src/core/components/checkbox-field/checkbox-field.component.html`

O componente expõe:
- `formControlName` — binding reativo
- `(eventChange)` — evento de mudança
- `[disabled]` — input herdado via `CommonComponent`

### Solução

Substituir o `<input type="checkbox">` nativo pelo `<app-checkbox-field>`:

```html
<!-- ANTES -->
<input
  [attr.disabled]="deveDesabilitarFaltou(aluno, idx)"
  [formControlName]="'faltou_' + idx"
  class="form-control falta-input"
  type="checkbox"
  (change)="possuiFaltaComNota(aluno, idx)" />
<label [for]="'faltou_' + idx">{{ (aluno.ativo) ? 'Faltou' : 'Transferido' }}</label>

<!-- DEPOIS -->
<app-checkbox-field
  [formControlName]="'faltou_' + idx"
  [disabled]="deveDesabilitarFaltou(aluno, idx) === true"
  (eventChange)="possuiFaltaComNota(aluno, idx)">
</app-checkbox-field>
<label>{{ (aluno.ativo) ? 'Faltou' : 'Transferido' }}</label>
```

> O `<label [for]="...">` precisa ser removido pois o `app-checkbox-field` gerencia seu próprio `id` interno.

---

## 2. Problema de Disabled — Inconsistência no padrão

### Situação atual

O método `deveDesabilitarFaltou()` retorna `true | null`:

```typescript
// lancar-nota.component.ts, linhas 380-384
deveDesabilitarFaltou(aluno, idx) {
  if (this.motivoDesabilitarFaltou(aluno, idx)) {
    return true;
  }
  return null;  // null remove o atributo [attr.disabled] do DOM
}
```

**Isso funciona para `<input>` nativo** via `[attr.disabled]`:  
- `true` → injeta o atributo `disabled` no elemento  
- `null` → remove o atributo (campo habilitado)

**Mas não funciona para `<app-checkbox-field>`**, que espera um `@Input() disabled: boolean` (via `CommonComponent`). Passar `null` seria interpretado como falsy, mas pode gerar comportamento inconsistente.

### Condições de desabilitação mapeadas (`motivoDesabilitarFaltou`)

| Condição | Motivo exibido |
|----------|----------------|
| `this.saving === true` | operação de salvar em andamento |
| `avaliacao.prazoEncerrado === true` | prazo encerrado |
| nota lançada em outra chamada | avaliação lançada em chamada diferente |
| avaliação com correção online (CeCor) | corrigida pela CeCor |
| avaliação sem questão discursiva | sem questão discursiva |
| `emBranco_idx === true` | entrega em branco |

### Solução

Ao trocar para `<app-checkbox-field>`, converter o retorno para boolean:

```html
[disabled]="deveDesabilitarFaltou(aluno, idx) === true"
```

Ou refatorar o método para retornar `boolean` diretamente (preferível para legibilidade):

```typescript
deveDesabilitarFaltou(aluno, idx): boolean {
  return !!this.motivoDesabilitarFaltou(aluno, idx);
}
```

> Atenção: `[attr.disabled]` ainda é usado no campo de nota (`deveDesabilitarCampoDeNota`) e no "Em branco" (`[attr.disabled]="true"`). Esses não precisam mudar — apenas o Falta/Transferido será migrado para o componente toggle.

---

## 3. Problema de Chamadas Duplicadas na API

### Situação

O método `getLancamentoSelecionado()` **cria uma nova subscrição** ao observable `lancamentoSelecionado.state` toda vez que é invocado:

```typescript
// lancar-nota.component.ts, linha 94
getLancamentoSelecionado() {
  this.lancamentoSelecionado.state   // BehaviorSubject
    .pipe(
      distinctUntilChanged(...),
      switchMap(...)
    )
    .subscribe(...)   // nova subscrição acumulada a cada chamada
}
```

Ele é chamado em dois momentos:
1. `ngOnInit()` — linha 70 (subscrição #1)
2. Dentro de `saveLancamentos()` após sucesso — linha 205 (subscrição #2, #3, #n...)

**Efeito:** cada save bem-sucedido acumula uma subscrição nova no mesmo BehaviorSubject. Como o `ngOnDestroy` não faz unsubscribe, todas permanecem ativas enquanto o componente existir. Na próxima emissão do state (ex.: se outra avaliação for selecionada), todas as subscrições disparariam em paralelo — chamadas duplicadas à API.

### Confirmação: o `ngOnDestroy` não faz cleanup

```typescript
// lancar-nota.component.ts, linhas 82-92
@HostListener('window:beforeunload', ['$event'])
ngOnDestroy(event: any) {
  // apenas lida com navegação sem salvar
  // NENHUM unsubscribe
}
```

### Solução

Armazenar a subscrição e cancelá-la antes de recriar, ou usar `Subject` com `takeUntil`:

```typescript
import { Subject, takeUntil } from 'rxjs';

private destroy$ = new Subject<void>();

ngOnInit() {
  this.lancamentoForm = new FormGroup({});
  this.getLancamentoSelecionado();
}

// RENOMEAR ngOnDestroy e remover o @HostListener (são dois hooks distintos)
ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}

getLancamentoSelecionado() {
  this.lancamentoSelecionado.state
    .pipe(
      takeUntil(this.destroy$),   // cleanup automático
      distinctUntilChanged((prev, cur) => !_.isEqual(prev, cur)),
      switchMap(...)
    )
    .subscribe(...)
}
```

**Alternativa mais simples** (sem refatorar o hook): dentro de `saveLancamentos()`, em vez de chamar `getLancamentoSelecionado()` (que cria nova subscrição), chamar diretamente o serviço e atualizar os dados:

```typescript
// após save bem-sucedido, apenas recarregar os alunos sem criar nova subscrição
this.lancamentosService.getAlunosLancamento(this.avaliacao.hash)
  .subscribe(result => {
    // repovoar o form com result.data
  });
```

> **Nota sobre `switchMap`:** O `switchMap` cancela requisições HTTP anteriores quando um novo valor chega do state, mas isso só protege contra emissões do BehaviorSubject — não contra a acumulação de subscrições pelo acúmulo de chamadas a `getLancamentoSelecionado()`.

---

## 4. Impacto da Migração Angular 20

### Achados

| Aspecto | Status |
|---------|--------|
| `standalone: false` | Componente permanece module-based — sem impacto |
| `ReactiveFormsModule` | Sem breaking changes no Angular 20 |
| `[attr.disabled]` com `null` | Comportamento correto — `null` remove o atributo |
| RxJS (`switchMap`, `forkJoin`, `distinctUntilChanged`) | Sem mudanças quebradoras |
| `FormControl` / `FormGroup` | Sem mudanças quebradoras |
| `@Inject('LancamentoSelecionado')` | Funcional — sem impacto |

**Conclusão:** Não foi identificado nenhum breaking change do Angular 20 que cause problemas diretos neste componente. Os problemas encontrados são de lógica pré-existente e de padrão visual inconsistente.

---

## 5. Plano de Solução

### Ordem de execução

**Passo 1 — Corrigir o hook `ngOnDestroy`** (impacto em memória/subscrições)

O `@HostListener('window:beforeunload')` e `ngOnDestroy` estão misturados no mesmo método. Separar:

```typescript
@HostListener('window:beforeunload', ['$event'])
onBeforeUnload(event: any) { /* lógica de navegação */ }

ngOnDestroy() {
  this.destroy$.next();
  this.destroy$.complete();
}
```

Adicionar `takeUntil(this.destroy$)` na subscrição de `getLancamentoSelecionado()`.

**Passo 2 — Corrigir chamada duplicada no save**

Em `saveLancamentos()`, remover a chamada `this.getLancamentoSelecionado()` e substituir por reload direto dos dados via serviço, sem criar nova subscrição.

**Passo 3 — Migrar Falta/Transferido para toggle**

Substituir `<input type="checkbox">` por `<app-checkbox-field>` no template. Ajustar binding de `disabled` para retornar `boolean`.

---

## Arquivos a modificar

| Arquivo | Mudanças |
|---------|----------|
| `lancar-nota.component.ts` | Separar `ngOnDestroy` do `@HostListener`, adicionar `destroy$`, corrigir `deveDesabilitarFaltou()` retorno boolean, eliminar chamada duplicada a `getLancamentoSelecionado()` no save |
| `lancar-nota.component.html` | Substituir `<input type="checkbox">` pelo `<app-checkbox-field>` na coluna Falta/Transferido |
