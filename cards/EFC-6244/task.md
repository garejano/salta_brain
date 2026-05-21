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
