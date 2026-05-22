# EFC-6244 — Tarefas de Correção dos Bugs

> Referência: `plano-bugs-subtarefas.md`  
> Legenda: `[ ]` pendente · `[x]` concluído · `[-]` ignorado/won't fix

---

## EFC-6396 — View padrão não respeita resolução

- [x] Substituir `window.innerWidth` por `BreakpointObserver` em `listar.component.ts:68`
  - Importar `BreakpointObserver` de `@angular/cdk/layout`
  - Subscrever no `ngOnInit` com `takeUntilDestroyed`
  - Remover a inicialização estática `viewMode = 'table'` da linha 41

---

## EFC-6397 — Limpar marcações sem confirmação

- [x] Renomear `limparTodos()` para `executarLimpeza()` (privado) em `lancamento.component.ts`
- [x] Criar método público `limparTodos()` que apenas abre o modal (`confirmarLimpezaAberto = true`)
- [x] Criar métodos `confirmarLimpeza()` e `cancelarLimpeza()` em `lancamento.component.ts`
- [x] Adicionar bloco de confirmação inline em `lancamento.component.html` (seguir padrão do `confirmarVoltarAberto`)

---

## EFC-6398 — Filtrar sem data início gera erro

payload:
```
{"hashAnoLetivo":"ea3695ab-f17b-4905-8034-b8c2a0495c06","hashRede":"a43c39f2-91b7-4425-8921-1849090c1804","hashEscola":"ac54f03d-613b-4781-a859-324f70ea5bed","hashSerie":null,"hashTurno":null,"hashTipo":null,"dataInicio":"","pagina":1}  
```

response:

```
{
    "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
    "title": "One or more validation errors occurred.",
    "status": 400,
    "errors": {
        "$.dataInicio": [
            "The JSON value could not be converted to System.Nullable`1[System.DateTime]. Path: $.dataInicio | LineNumber: 0 | BytePositionInLine: 223."
        ]
    },
    "traceId": "00-2e671f7beb17b82dddb2166a5ca5d124-96cec938f4ffbcda-00"
}
```

 - tem que entender no backend de estrutura-pedagogica se o campo eh necessario ou como deve ser passado na request

- [x] Investigar onde o `FiltroComponent` serializa os valores de campo para o request (método `value()` ou similar)
- [x] Definir abordagem: corrigir no `FiltroComponent` (genérico) ou remover o `value` default em `filtro_dias_sem_aula.ts` (localizado)
- [x] Aplicar a correção escolhida: campos `Date` vazios devem ser enviados como `null`, não `""`

---

## EFC-6399 — Erro ao cadastrar dia sem aula

- [x] Reproduzir o bug e abrir DevTools → Network → verificar o request JSON e a mensagem de erro do response
- [x] Confirmar se `hashEscola` está presente e preenchido no request
- [x] Corrigir conforme causa identificada:
  - Se `hashEscola` é null → adicionar guarda no `start()` do `formulario.component.ts`
  - Se é erro de serialização de data → corrigir campos de data no form
  - Se é mensagem de negócio do backend não exibida → verificar tratamento do `result.message` no frontend

### Novo erro: 500 ao salvar

**Erro:** `Implicit conversion from data type datetime to bit is not allowed.`  
**Causa raiz:** Colunas `DataInicio` e `DataFim` da tabela `DiaSemAulaMotivo` foram criadas com tipo `bit` no banco, mas a entidade declara `DateTime`. O EF Core envia valores `datetime` no INSERT e o SQL Server rejeita.

**Evidência (banco):**
| Coluna | Tipo real no banco | Tipo esperado |
|--------|-------------------|---------------|
| DataInicio | `bit` NOT NULL | `datetime` NOT NULL |
| DataFim | `bit` NOT NULL | `datetime` NOT NULL |

**Fix:** executar script `_scripts/fix-diasemaula-colunas-data.sql` no banco.  
Não é possível `ALTER COLUMN bit → datetime` diretamente; o script adiciona colunas novas, remove as antigas e renomeia.

- [x] Executar `_scripts/fix-diasemaula-colunas-data.sql` no banco de desenvolvimento
- [x] Validar salvamento de novo dia sem aula após a correção
- [x] Executar script em homologação/produção

---

## EFC-6400 — Quebra de layout no formulário

- [x] **Sub-bug 1 (botão fechar invisível em mobile):** Adicionar media query em `modal.component.css` para ajustar `min-width`, `padding` e `top` do `.btn-modal-close` em telas ≤ 600px
- [x] **Sub-bug 2 (msg erro sobre label "Tipo"):** Encapsular `<single-select>` e a `<div class="msg-warn">` em um `<div>` wrapper dentro de `.row-form` em `formulario.component.html`
- [x] **Sub-bug 3 (feriado regional aparece selecionado):** Corrigir `toggleDropdown()` e `openDropdown()` em `select-field.component.ts` — inicializar `hoveredIndex` com o índice do item selecionado (ou `-1`) em vez de sempre `0`

---

## EFC-6401 — Campo de tempo de aula oculto quando há apenas um tempo

> Arquivo: `lancamento.component.ts`  
> O template `#tempoEstatico` existe e está correto. O problema é que `tempoAtual` fica `null` quando `hashAulaEvento` não corresponde a nenhum tempo em `evento.tempos`.

- [x] Em `lancamento.component.ts`, localizar o bloco de inicialização de `tempoAtual` (~linha 109)
- [x] Adicionar fallback logo após: se `!this.tempoAtual && this.temposDisponiveis.length === 1`, atribuir `tempoAtual = temposDisponiveis[0]` e `controlTempo.setValue(tempoAtual.hash)`
- [x] Testar: Rede Ábaco, Escola Sumaré, Turma Infantil 2 A - T → "Lançar" → campo de tempo aparece como texto estático

---

## EFC-6402 — Layout mobile inconsistente na listagem de alunos

> Resolução de teste: 412×915 (S25 FE). Comportamento intermitente — às vezes correto, às vezes não.

- [x] Reproduzir com logs em mobile (601x911): BreakpointObserver emite sincronamente, `viewMode` já é `'cards'` antes do primeiro render — timing não é o problema
- [x] Aplicar inicialização defensiva: `viewMode = window.matchMedia('(max-width: 767px)').matches ? 'cards' : 'table'` em vez de `'table'` hard-coded
- [x] **Bug está no CSS/template.** Inspecionar no DevTools (412x915) com `viewMode='cards'` ativo e identificar qual elemento causa overflow ou layout quebrado (suspeito: `min-width` fixo ou `flex` sem `wrap` no card de evento em `listar.component.html`)


  Guia de análise — logs EFC-6402

  ┌─────────────────────────────┬──────────────────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
  │             Log             │             Momento              │                                              O que revela                                               │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [1] constructor             │ Classe instanciada               │ Viewport real + se matchMedia já detectaria mobile                                                      │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [2] ngOnInit início         │ Antes de qualquer subscição      │ viewMode ainda é 'table' (valor inicial hard-coded)                                                     │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [3]                         │ Chamada ao .observe()            │ Linha imediatamente antes da subscription                                                               │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [4] BreakpointObserver emit │ Dentro do callback               │ Se aparece entre [3] e [5] → emitiu síncrono ✅. Se aparece depois de [5] ou [6] → emitiu assíncrono ⚠️ │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [5] após subscribe          │ Imediatamente após .subscribe()  │ Se viewMode ainda é 'table' aqui em mobile → confirma problema de timing                                │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [6] ngOnInit fim            │ Fim do ngOnInit                  │ Estado final antes do primeiro render                                                                   │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [7] aplicarFiltro           │ Botão "Filtrar" clicado          │ Verifica se viewMode foi atualizado antes do usuário interagir                                          │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [8] getEventos início       │ Requisição HTTP disparada        │                                                                                                         │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [9] getEventos resposta     │ Dados chegaram + lista renderiza │ viewMode no momento em que os eventos aparecem na tela                                                  │
  ├─────────────────────────────┼──────────────────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────┤
  │ [10] abrirLancamento        │ Clique em "Lançar" numa turma    │ Estado imediatamente antes de navegar                                                                   │
  └─────────────────────────────┴──────────────────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  Cenário saudável (mobile): [4] aparece entre [3] e [5], e viewMode já é 'cards' no [5].

  Cenário com bug: [4] aparece depois de [5]/[6], ou não aparece antes de [9] — o template renderizou com viewMode = 'table' e o CDK só corrigiu depois.


resultado do log:


Navigated to https://localhost/estrutura-pedagogica/lancamento-frequencia/listar
debug_node.mjs:18315 Angular is running in development mode.
listar.component.ts:70 [EFC-6402][1] constructor — viewport: 835x721 — matchMedia(max-width:767px): false
listar.component.ts:74 [EFC-6402][2] ngOnInit início — viewMode: 'table' — viewport: 835x721
listar.component.ts:77 [EFC-6402][3] BreakpointObserver.observe() sendo subscrito...
listar.component.ts:84 [EFC-6402][4] BreakpointObserver emit — matches: false — viewMode: 'table' → 'table' — viewport: 835x721 — t: 1779470673191
listar.component.ts:87 [EFC-6402][5] ngOnInit após subscribe — viewMode: 'table' — (BreakpointObserver emitiu síncronamente? viewMode mudou?)
listar.component.ts:97 [EFC-6402][6] ngOnInit fim — viewMode final: 'table'
content_script_bundle.js:1 Attempting handshake with backend Fri May 22 2026 14:24:33 GMT-0300 (Horário Padrão de Brasília)
listar.component.ts:105 [EFC-6402][7] aplicarFiltro() — viewMode: 'table' — viewport: 1168x721
listar.component.ts:115 [EFC-6402][8] getEventos() início — viewMode: 'table'
menu.service.ts:70  POST https://localhost/ped/Integracoes_ApiMenu/GetMenu 400 (Bad Request)
scheduleTask @ /estrutura-pedagogica/polyfills.js:2175
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:2213
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
(anonymous) @ /estrutura-pedagogica/vendor.js:26581
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
get @ /estrutura-pedagogica/main.js:31011
load @ /estrutura-pedagogica/main.js:29859
(anonymous) @ /estrutura-pedagogica/main.js:29868
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29867
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
menu.service.ts:70 ERROR HttpErrorResponse {headers: HttpHeaders, status: 400, statusText: 'OK', url: 'https://localhost/ped/Integracoes_ApiMenu/GetMenu', ok: false, …}
handleError @ /estrutura-pedagogica/vendor.js:70198
(anonymous) @ /estrutura-pedagogica/vendor.js:62680
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
(anonymous) @ /estrutura-pedagogica/vendor.js:62673
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:2873
errorContext @ /estrutura-pedagogica/vendor.js:6570
next @ /estrutura-pedagogica/vendor.js:2866
emit @ /estrutura-pedagogica/vendor.js:39863
(anonymous) @ /estrutura-pedagogica/vendor.js:40361
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
onHandleError @ /estrutura-pedagogica/vendor.js:40361
handleError @ /estrutura-pedagogica/polyfills.js:443
runTask @ /estrutura-pedagogica/polyfills.js:239
invokeTask @ /estrutura-pedagogica/polyfills.js:545
ZoneTask.invoke @ /estrutura-pedagogica/polyfills.js:534
data.args.<computed> @ /estrutura-pedagogica/polyfills.js:1793
setTimeout
scheduleTask @ /estrutura-pedagogica/polyfills.js:1795
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:1854
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
setTimeout @ /estrutura-pedagogica/vendor.js:6228
reportUnhandledError @ /estrutura-pedagogica/vendor.js:6941
handleUnhandledError @ /estrutura-pedagogica/vendor.js:3157
error @ /estrutura-pedagogica/vendor.js:3110
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
init @ /estrutura-pedagogica/vendor.js:4022
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4291
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
source.subscribe._a @ /estrutura-pedagogica/vendor.js:5351
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
onLoad @ /estrutura-pedagogica/vendor.js:26477
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
invokeTask @ /estrutura-pedagogica/polyfills.js:545
invokeTask @ /estrutura-pedagogica/polyfills.js:1163
globalCallback @ /estrutura-pedagogica/polyfills.js:1204
globalZoneAwareCallback @ /estrutura-pedagogica/polyfills.js:1224
Zone - XMLHttpRequest.addEventListener:load
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleEventTask @ /estrutura-pedagogica/polyfills.js:305
(anonymous) @ /estrutura-pedagogica/polyfills.js:1517
(anonymous) @ /estrutura-pedagogica/vendor.js:26567
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
get @ /estrutura-pedagogica/main.js:31011
load @ /estrutura-pedagogica/main.js:29859
(anonymous) @ /estrutura-pedagogica/main.js:29868
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29867
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
portal-menu-notificacoes.component.ts:32  POST https://localhost/ped/Notificacao/GetNotificacoes 400 (Bad Request)
scheduleTask @ /estrutura-pedagogica/polyfills.js:2175
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:2213
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
(anonymous) @ /estrutura-pedagogica/vendor.js:26581
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/main.js:29285
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29283
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
menu.service.ts:81  GET https://localhost/ped/Integracoes_ApiMenu/GetVersaoMenu 400 (Bad Request)
scheduleTask @ /estrutura-pedagogica/polyfills.js:2175
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:2213
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
(anonymous) @ /estrutura-pedagogica/vendor.js:26581
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
get @ /estrutura-pedagogica/main.js:31019
load @ /estrutura-pedagogica/main.js:29859
(anonymous) @ /estrutura-pedagogica/main.js:29868
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29867
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
portal-menu-notificacoes.component.ts:32 ERROR HttpErrorResponse {headers: HttpHeaders, status: 400, statusText: 'OK', url: 'https://localhost/ped/Notificacao/GetNotificacoes', ok: false, …}
handleError @ /estrutura-pedagogica/vendor.js:70198
(anonymous) @ /estrutura-pedagogica/vendor.js:62680
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
(anonymous) @ /estrutura-pedagogica/vendor.js:62673
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:2873
errorContext @ /estrutura-pedagogica/vendor.js:6570
next @ /estrutura-pedagogica/vendor.js:2866
emit @ /estrutura-pedagogica/vendor.js:39863
(anonymous) @ /estrutura-pedagogica/vendor.js:40361
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
onHandleError @ /estrutura-pedagogica/vendor.js:40361
handleError @ /estrutura-pedagogica/polyfills.js:443
runTask @ /estrutura-pedagogica/polyfills.js:239
invokeTask @ /estrutura-pedagogica/polyfills.js:545
ZoneTask.invoke @ /estrutura-pedagogica/polyfills.js:534
data.args.<computed> @ /estrutura-pedagogica/polyfills.js:1793
setTimeout
scheduleTask @ /estrutura-pedagogica/polyfills.js:1795
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:1854
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
setTimeout @ /estrutura-pedagogica/vendor.js:6228
reportUnhandledError @ /estrutura-pedagogica/vendor.js:6941
handleUnhandledError @ /estrutura-pedagogica/vendor.js:3157
error @ /estrutura-pedagogica/vendor.js:3110
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
init @ /estrutura-pedagogica/vendor.js:4022
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4291
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
source.subscribe._a @ /estrutura-pedagogica/vendor.js:5351
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
onLoad @ /estrutura-pedagogica/vendor.js:26477
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
invokeTask @ /estrutura-pedagogica/polyfills.js:545
invokeTask @ /estrutura-pedagogica/polyfills.js:1163
globalCallback @ /estrutura-pedagogica/polyfills.js:1204
globalZoneAwareCallback @ /estrutura-pedagogica/polyfills.js:1224
Zone - XMLHttpRequest.addEventListener:load
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleEventTask @ /estrutura-pedagogica/polyfills.js:305
(anonymous) @ /estrutura-pedagogica/polyfills.js:1517
(anonymous) @ /estrutura-pedagogica/vendor.js:26567
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/main.js:29285
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29283
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
menu.service.ts:81 ERROR HttpErrorResponse {headers: HttpHeaders, status: 400, statusText: 'OK', url: 'https://localhost/ped/Integracoes_ApiMenu/GetVersaoMenu', ok: false, …}
handleError @ /estrutura-pedagogica/vendor.js:70198
(anonymous) @ /estrutura-pedagogica/vendor.js:62680
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
(anonymous) @ /estrutura-pedagogica/vendor.js:62673
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:2873
errorContext @ /estrutura-pedagogica/vendor.js:6570
next @ /estrutura-pedagogica/vendor.js:2866
emit @ /estrutura-pedagogica/vendor.js:39863
(anonymous) @ /estrutura-pedagogica/vendor.js:40361
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
runOutsideAngular @ /estrutura-pedagogica/vendor.js:40223
onHandleError @ /estrutura-pedagogica/vendor.js:40361
handleError @ /estrutura-pedagogica/polyfills.js:443
runTask @ /estrutura-pedagogica/polyfills.js:239
invokeTask @ /estrutura-pedagogica/polyfills.js:545
ZoneTask.invoke @ /estrutura-pedagogica/polyfills.js:534
data.args.<computed> @ /estrutura-pedagogica/polyfills.js:1793
setTimeout
scheduleTask @ /estrutura-pedagogica/polyfills.js:1795
scheduleTask @ /estrutura-pedagogica/polyfills.js:455
onScheduleTask @ /estrutura-pedagogica/vendor.js:39988
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMacroTask @ /estrutura-pedagogica/polyfills.js:302
scheduleMacroTaskWithCurrentZone @ /estrutura-pedagogica/polyfills.js:759
(anonymous) @ /estrutura-pedagogica/polyfills.js:1854
proto.<computed> @ /estrutura-pedagogica/polyfills.js:1062
setTimeout @ /estrutura-pedagogica/vendor.js:6228
reportUnhandledError @ /estrutura-pedagogica/vendor.js:6941
handleUnhandledError @ /estrutura-pedagogica/vendor.js:3157
error @ /estrutura-pedagogica/vendor.js:3110
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
init @ /estrutura-pedagogica/vendor.js:4022
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4291
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
source.subscribe._a @ /estrutura-pedagogica/vendor.js:5351
OperatorSubscriber._error @ /estrutura-pedagogica/vendor.js:4160
error @ /estrutura-pedagogica/vendor.js:3043
_error @ /estrutura-pedagogica/vendor.js:3066
error @ /estrutura-pedagogica/vendor.js:3043
onLoad @ /estrutura-pedagogica/vendor.js:26477
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
invokeTask @ /estrutura-pedagogica/polyfills.js:545
invokeTask @ /estrutura-pedagogica/polyfills.js:1163
globalCallback @ /estrutura-pedagogica/polyfills.js:1204
globalZoneAwareCallback @ /estrutura-pedagogica/polyfills.js:1224
Zone - XMLHttpRequest.addEventListener:load
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleEventTask @ /estrutura-pedagogica/polyfills.js:305
(anonymous) @ /estrutura-pedagogica/polyfills.js:1517
(anonymous) @ /estrutura-pedagogica/vendor.js:26567
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
source.subscribe.isComplete @ /estrutura-pedagogica/vendor.js:5203
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5199
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5338
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4286
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4580
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
doInnerSub @ /estrutura-pedagogica/vendor.js:4765
outerNext @ /estrutura-pedagogica/vendor.js:4760
OperatorSubscriber._next @ /estrutura-pedagogica/vendor.js:4153
next @ /estrutura-pedagogica/vendor.js:3035
(anonymous) @ /estrutura-pedagogica/vendor.js:3829
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
mergeInternals @ /estrutura-pedagogica/vendor.js:4793
(anonymous) @ /estrutura-pedagogica/vendor.js:4830
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4559
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:4688
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
get @ /estrutura-pedagogica/main.js:31019
load @ /estrutura-pedagogica/main.js:29859
(anonymous) @ /estrutura-pedagogica/main.js:29868
next @ /estrutura-pedagogica/vendor.js:3093
_next @ /estrutura-pedagogica/vendor.js:3062
next @ /estrutura-pedagogica/vendor.js:3035
_subscribe @ /estrutura-pedagogica/vendor.js:2563
_trySubscribe @ /estrutura-pedagogica/vendor.js:2664
_trySubscribe @ /estrutura-pedagogica/vendor.js:2917
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
_subscribe @ /estrutura-pedagogica/vendor.js:2689
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
(anonymous) @ /estrutura-pedagogica/vendor.js:5304
(anonymous) @ /estrutura-pedagogica/vendor.js:6846
(anonymous) @ /estrutura-pedagogica/vendor.js:2658
errorContext @ /estrutura-pedagogica/vendor.js:6570
subscribe @ /estrutura-pedagogica/vendor.js:2653
ngOnInit @ /estrutura-pedagogica/main.js:29867
callHookInternal @ /estrutura-pedagogica/vendor.js:33510
callHook @ /estrutura-pedagogica/vendor.js:33534
callHooks @ /estrutura-pedagogica/vendor.js:33494
executeInitAndCheckHooks @ /estrutura-pedagogica/vendor.js:33449
refreshView @ /estrutura-pedagogica/vendor.js:42469
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewIfAttached @ /estrutura-pedagogica/vendor.js:42629
detectChangesInComponent @ /estrutura-pedagogica/vendor.js:42617
detectChangesInChildComponents @ /estrutura-pedagogica/vendor.js:42691
refreshView @ /estrutura-pedagogica/vendor.js:42508
detectChangesInView @ /estrutura-pedagogica/vendor.js:42667
detectChangesInViewWhileDirty @ /estrutura-pedagogica/vendor.js:42372
detectChangesInternal @ /estrutura-pedagogica/vendor.js:42361
synchronizeOnce @ /estrutura-pedagogica/vendor.js:52786
synchronize @ /estrutura-pedagogica/vendor.js:52746
tickImpl @ /estrutura-pedagogica/vendor.js:52718
_tick @ /estrutura-pedagogica/vendor.js:52707
tick @ /estrutura-pedagogica/vendor.js:52696
_loadComponent @ /estrutura-pedagogica/vendor.js:52865
(anonymous) @ /estrutura-pedagogica/vendor.js:52673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrapImpl @ /estrutura-pedagogica/vendor.js:52640
bootstrap @ /estrutura-pedagogica/vendor.js:52636
(anonymous) @ /estrutura-pedagogica/vendor.js:28722
_moduleDoBootstrap @ /estrutura-pedagogica/vendor.js:28722
(anonymous) @ /estrutura-pedagogica/vendor.js:28701
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
(anonymous) @ /estrutura-pedagogica/vendor.js:39993
onInvokeTask @ /estrutura-pedagogica/vendor.js:39993
invokeTask @ /estrutura-pedagogica/polyfills.js:465
onInvokeTask @ /estrutura-pedagogica/vendor.js:40316
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Zone - Promise.then
onScheduleTask @ /estrutura-pedagogica/vendor.js:39987
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
onScheduleTask @ /estrutura-pedagogica/polyfills.js:339
scheduleTask @ /estrutura-pedagogica/polyfills.js:451
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
(anonymous) @ /estrutura-pedagogica/vendor.js:28678
_callAndReportToErrorHandler @ /estrutura-pedagogica/vendor.js:28732
(anonymous) @ /estrutura-pedagogica/vendor.js:28673
invoke @ /estrutura-pedagogica/polyfills.js:440
onInvoke @ /estrutura-pedagogica/vendor.js:40327
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
run @ /estrutura-pedagogica/vendor.js:40179
bootstrap @ /estrutura-pedagogica/vendor.js:28635
bootstrapModuleFactory @ /estrutura-pedagogica/vendor.js:28791
(anonymous) @ /estrutura-pedagogica/vendor.js:28816
invoke @ /estrutura-pedagogica/polyfills.js:440
run @ /estrutura-pedagogica/polyfills.js:184
(anonymous) @ /estrutura-pedagogica/polyfills.js:2501
invokeTask @ /estrutura-pedagogica/polyfills.js:465
runTask @ /estrutura-pedagogica/polyfills.js:237
drainMicroTaskQueue @ /estrutura-pedagogica/polyfills.js:638
Promise.then
nativeScheduleMicroTask @ /estrutura-pedagogica/polyfills.js:615
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:625
scheduleTask @ /estrutura-pedagogica/polyfills.js:457
scheduleTask @ /estrutura-pedagogica/polyfills.js:280
scheduleMicroTask @ /estrutura-pedagogica/polyfills.js:299
scheduleResolveOrReject @ /estrutura-pedagogica/polyfills.js:2491
then @ /estrutura-pedagogica/polyfills.js:2693
bootstrapModule @ /estrutura-pedagogica/vendor.js:28816
84429 @ /estrutura-pedagogica/main.js:28049
__webpack_require__ @ /estrutura-pedagogica/runtime.js:29
__webpack_exec__ @ /estrutura-pedagogica/main.js:42191
(anonymous) @ /estrutura-pedagogica/main.js:42192
__webpack_require__.O @ /estrutura-pedagogica/runtime.js:63
(anonymous) @ /estrutura-pedagogica/main.js:42193
webpackJsonpCallback @ /estrutura-pedagogica/runtime.js:286
(anonymous) @ /estrutura-pedagogica/main.js:2Understand this error
listar.component.ts:124 [EFC-6402][9] getEventos() resposta — 36 eventos — viewMode: 'table' — viewport: 1841x911
listar.component.ts:84 [EFC-6402][4] BreakpointObserver emit — matches: true — viewMode: 'table' → 'cards' — viewport: 757x911 — t: 1779470786349
Navigated to https://localhost/estrutura-pedagogica/lancamento-frequencia/listar
debug_node.mjs:18315 Angular is running in development mode.
listar.component.ts:70 [EFC-6402][1] constructor — viewport: 601x911 — matchMedia(max-width:767px): true
listar.component.ts:74 [EFC-6402][2] ngOnInit início — viewMode: 'table' — viewport: 601x911
listar.component.ts:77 [EFC-6402][3] BreakpointObserver.observe() sendo subscrito...
listar.component.ts:84 [EFC-6402][4] BreakpointObserver emit — matches: true — viewMode: 'table' → 'cards' — viewport: 601x911 — t: 1779470795035
listar.component.ts:87 [EFC-6402][5] ngOnInit após subscribe — viewMode: 'cards' — (BreakpointObserver emitiu síncronamente? viewMode mudou?)
listar.component.ts:97 [EFC-6402][6] ngOnInit fim — viewMode final: 'cards'
content_script_bundle.js:1 Attempting handshake with backend Fri May 22 2026 14:26:35 GMT-0300 (Horário Padrão de Brasília)
listar.component.ts:105 [EFC-6402][7] aplicarFiltro() — viewMode: 'cards' — viewport: 601x911
listar.component.ts:115 [EFC-6402][8] getEventos() início — viewMode: 'cards'
listar.component.ts:124 [EFC-6402][9] getEventos() resposta — 36 eventos — viewMode: 'cards' — viewport: 601x911
---

## EFC-6403 — Dias sem aula ausentes na exportação de período letivo

> 3 arquivos a modificar. Ver detalhes em `plano-bugs-subtarefas.md`.

**Backend:**
- [x] `ConfiguradorPeriodoLetivoExport.cs` — adicionar `public List<string> DiasSemAula { get; set; } = [];`
- [x] `ConfiguracaoPeriodoLetivoRepository.cs:GetResponseParaExport()` — popular `DiasSemAula` via `x.EscolaSerie.AnoLetivo.DiaSemAulaMotivos` filtrando por `Ativo && (TodasAsEscolas || EscolaId == EscolaSerie.EscolaId)`
- [x] `ExportarConfiguracaoService.cs` — adicionar coluna `"Dias sem aula"` na lista `colunas`
- [x] `ExportarConfiguracaoService.cs:FormatarParaDataTable()` — propagar `DiasSemAula = config?.DiasSemAula ?? []`
- [x] `ExportarConfiguracaoService.cs:dataTable.Rows.Add()` — adicionar `string.Join(" | ", item.DiasSemAula)` como último argumento
- [x] Testar: exportar com escola que tem dias sem aula → coluna aparece preenchida; escola sem dias → coluna vazia
