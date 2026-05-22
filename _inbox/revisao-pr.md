# Revisão de PR — master → EFC-6323
_Gerado em: 2026-05-11_

---

## Conformidade com o Spec

| Critério | Implementado | Testado | Observação |
|---|---|---|---|
| CA-01 — Usuários com permissão de seleção conseguem acessar a tela e associar alunos | Sim | Sim | `ItinerarioFormativoSelecaoController` e `AlunoEscolaItinerarioFormativoSaveService` passaram a usar `ItinerarioFormativo_Selecao` (427). Testes em `AlunoEscolaItinerarioFormativoSaveServiceTests` e `FilterItinerarioFormativoSelecaoServiceTests` refletem a nova funcionalidade. |
| CA-02 — Usuário apenas com permissão de configuração não acessa a tela de seleção | Sim | Parcial | O controller passa a exigir `ItinerarioFormativo_Selecao`, separando as duas permissões. Não há teste de integração explícito que valide o cenário de acesso negado com somente `Configurador_Itinerario_Formativo` ativo para a rota de seleção. |
| CA-03 — Filtragem de escolas respeita apenas permissão de seleção | Sim | Sim | Todos os métodos de `FilterItinerarioFormativoSelecaoService` migraram para `ItinerarioFormativo_Selecao`. Testes atualizados com `_funcionalidadeCorreta = ItinerarioFormativo_Selecao`. |
| CA-04 — Um mesmo usuário pode ter ambas as permissões simultaneamente | Sim | Não | A separação das constantes de funcionalidade (`426` e `427`) permite acumulação de permissões no modelo de dados. Não há teste que provisione o mesmo usuário com as duas permissões e valide o acesso às duas rotas. |

---

## Backend

### `ItinerarioFormativoSaveService.cs`

- **Linha 50** — `Any()` vs `Count` em listas em memória: `conflitos.Any()` (linha 67) é usado sobre uma `List<T>` já materializada em memória. Substituir por `conflitos.Count > 0` conforme padrão do projeto.

- **Linha 50** — Permissão inconsistente no `GetDisciplinasBloqueadasPorCiclo` dentro de `Save`: o serviço usa `GetRedeIdByFuncionalidadeUsuarioAutenticado(Funcionalidade.Configurador_Itinerario_Formativo)` para buscar as redes. Isso é correto para o fluxo de configuração, mas a dependência implícita do configurador ter acesso às redes relevantes não está documentada. Verificar se é comportamento intencional e, se sim, adicionar comentário.

### `ItinerarioFormativoRepository.cs`

- **Linhas 202–203** — Navegação via propriedade de navegação nullable em `GetDisciplinasBloqueadasPorCiclo`: o filtro `.Where(it => it.ItinerarioFormativoCiclo != null && it.ItinerarioFormativoCiclo.Hash != request.HashCiclo)` acessa a propriedade de navegação `ItinerarioFormativoCiclo` diretamente no `QueryableAtivos()`. Como a FK pode ser nula (left join implícito no EF), recomenda-se reescrever com subquery via `_context.Set<ItinerarioFormativoCiclo>()` para garantir inner join explícito, ou documentar por que o comportamento atual é aceitável.

### `ItinerarioFormativoGetService.cs`

- **Linha 43** — Chamada a `GetDisciplinasBloqueadasPorCiclo` sem `hashItinerarioExcluir`: ao editar um itinerário existente, `GetDisciplinas` não passa o hash do itinerário atual para exclusão. Isso pode fazer com que disciplinas do próprio itinerário em edição apareçam como bloqueadas (falso positivo visual). Verificar se é comportamento desejado; se não, o serviço deve receber e repassar o hash do item em edição.

### `ItinerarioFormativoSaveServiceTests.cs`

- **Cobertura** — ausência de teste de cenário de bloqueio de ciclo cruzado na variação de **edição** (update): os testes cobrem criação de novo CF, mas não validam o bloqueio ao **editar** um CF existente passando `Hash` preenchido, para garantir que `hashItinerarioExcluir` funciona corretamente e não produz falso positivo.

---

## Frontend

### `editar-itinerario.component.ts`

- **Linha 108** — Subscription em `valueChanges` sem unsubscribe: `this.form.get('ciclo').valueChanges.subscribe(...)` registrado em `setFormulario()` sem `takeUntil` / `takeUntilDestroyed` e sem guardar a subscription. Potencial vazamento de memória se o componente for destruído e recriado. Sugestão: usar `takeUntilDestroyed(this.destroyRef)` ou fazer `unsubscribe()` no `ngOnDestroy`.

- **Linha 49** — `cdr.detectChanges()` desnecessário no `ngOnInit`: chamada antes de qualquer inicialização relevante. O `detectChanges` no `complete:` do subscribe (linha 204) é suficiente. Sugestão: remover a chamada na linha 49.

### `listar-itinerarios.component.ts`

- **Linha 127** — `console.error(error)` no callback de erro: chama `console.error` além do `notificationService.showError(...)`. O `HandleApiError` já trata os erros HTTP. Sugestão: remover o `console.error(error)`.

- **Linhas 116–123 e 194–197** — Lógica de mapeamento de disciplinas bloqueadas duplicada: a construção do `Set` de bloqueadas e o mapeamento de `disciplinas` com `locked` estão duplicados em `listar-itinerarios.component.ts` e `editar-itinerario.component.ts`. Sugestão: extrair para um método utilitário como `mapDisciplinasComBloqueio(disciplinas, bloqueadas): MultiSelectOption[]` para evitar divergência futura.

---

## Avaliação Geral

O PR entrega com clareza o objetivo central: separar a permissão de seleção (`ItinerarioFormativo_Selecao = 427`) da permissão de configuração (`Configurador_Itinerario_Formativo = 426`), garantindo que o acesso às rotas e a filtragem de escolas respeitem a permissão correta. A implementação é cirúrgica e bem estruturada.

Pontos que merecem atenção antes do merge:

1. **Bloqueante potencial** — navegação via propriedade de navegação nullable em `GetDisciplinasBloqueadasPorCiclo` pode gerar left join implícito no SQL, ferindo o padrão de repositório do projeto.
2. **Melhoria de qualidade** — `conflitos.Any()` deve ser `conflitos.Count > 0` (coleção em memória).
3. **Vazamento de memória** — subscription em `valueChanges` no frontend sem unsubscribe/takeUntil.
4. **Cobertura parcial** — CA-02 e CA-04 sem teste de integração para acesso negado e permissões cumulativas; ausência de teste de bloqueio de ciclo cruzado no fluxo de edição.
5. **Duplicação de lógica** no frontend (mapeamento de disciplinas bloqueadas em dois componentes).
