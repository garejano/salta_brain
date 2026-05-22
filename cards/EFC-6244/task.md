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
