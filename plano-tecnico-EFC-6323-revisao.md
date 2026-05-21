# Plano Técnico — EFC-6323 (Revisão de PR)

## Atividade

- **Chave:** EFC-6323 (revisão)
- **Título:** Correções apontadas na revisão de PR
- **Origem:** `Docs/revisao-pr.md`

## Critérios de Aceite

Consulte `Docs/criterios-aceite-EFC-6323.md`

## Fases

### Fase 1 — Ajustes de qualidade no backend _(infraestrutura)_

**Status:** pendente

**Arquivo 1:** `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/ItinerarioFormativoSaveService.cs`

Linha 67 — substituir `conflitos.Any()` por `conflitos.Count > 0`:

```csharp
// antes
if (conflitos.Any())

// depois
if (conflitos.Count > 0)
```

`conflitos` é uma `List<T>` materializada em memória — `Count > 0` é o padrão do projeto para coleções já carregadas.

---

**Arquivo 2:** `backend/EstruturaPedagogica.Infra/Repositories/Stateful/ItinerarioFormativoRepository.cs`

Linha 140 — o filtro `.Where(it => it.ItinerarioFormativoCiclo != null && it.ItinerarioFormativoCiclo.Hash != request.HashCiclo)` acessa a propriedade de navegação `ItinerarioFormativoCiclo` diretamente no `QueryableAtivos()`. Como a FK pode ser nula, o EF gera um LEFT JOIN implícito.

Reescrever usando a FK direta e uma subquery correlacionada para forçar comportamento de INNER JOIN:

```csharp
// antes
.Where(it => it.ItinerarioFormativoCiclo != null && it.ItinerarioFormativoCiclo.Hash != request.HashCiclo)

// depois
.Where(it => it.ItinerarioFormativoCicloId != null
          && it.ItinerarioFormativoCicloId != _context.Set<ItinerarioFormativoCiclo>()
                .Where(c => c.Hash == request.HashCiclo)
                .Select(c => (int?)c.Id)
                .FirstOrDefault())
```

Alternativa mais simples se o `Id` do ciclo estiver disponível no request: pré-buscar o `Id` e usar `it.ItinerarioFormativoCicloId != cicloId`. Avaliar qual abordagem é mais alinhada ao padrão do repositório.

---

### Fase 2 — Corrigir falso positivo de disciplinas bloqueadas na edição _(infraestrutura)_

**Status:** pendente

**Contexto:** `ItinerarioFormativoGetService.GetDisciplinas` (linha 43) chama `GetDisciplinasBloqueadasPorCiclo` sem passar `hashItinerarioExcluir`. Ao editar um componente formativo e trocar de ciclo, as próprias disciplinas do componente em edição aparecem como bloqueadas para o novo ciclo (falso positivo visual).

A correção exige alteração em três camadas:

**Arquivo 1:** `backend/EstruturaPedagogica.Domain/DTO/ItinerarioFormativo/ItinerarioFormativoFilterRequest.cs`

Adicionar propriedade opcional:

```csharp
public Guid? HashItinerario { get; set; }
```

**Arquivo 2:** `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/ItinerarioFormativoGetService.cs`

Linha 43 — passar o hash ao chamar o repositório:

```csharp
// antes
var disciplinasBloqueadas = await _itinerarioFormativoRepository.GetDisciplinasBloqueadasPorCiclo(request, redesDoUsuario);

// depois
var disciplinasBloqueadas = await _itinerarioFormativoRepository.GetDisciplinasBloqueadasPorCiclo(request, redesDoUsuario, hashItinerarioExcluir: request.HashItinerario);
```

**Arquivo 3:** `frontend/src/app/features/itinerario-formativo/editar-itinerario/editar-itinerario.component.ts`

No método `getFormulario()`, o `hash` do componente em edição já está presente. No método `atualizarDisciplinasComBloqueio()`, certificar-se de que o request enviado ao serviço Angular inclua `hashItinerario`:

```typescript
// em atualizarDisciplinasComBloqueio()
const request = this.getFormulario();
// garantir que o serviço Angular mapeie request.hash → hashItinerario no payload da API
```

Verificar se o serviço Angular (`ItinerarioFormativoService.getDisciplinas`) serializa o campo `hash` como `hashItinerario` ou se é necessário ajustar o payload enviado.

---

### Fase 3 — Ajustes no frontend _(infraestrutura)_

**Status:** pendente

**Arquivo 1:** `frontend/src/app/features/itinerario-formativo/editar-itinerario/editar-itinerario.component.ts`

**3a) Remover `cdr.detectChanges()` desnecessário no `ngOnInit` (linha 49):**

```typescript
// remover
ngOnInit(): void {
  this.cdr.detectChanges(); // ← remover esta linha
  this.formInit();
}
```

O `detectChanges()` no `complete:` do subscribe de `atualizarDisciplinasComBloqueio` (linha ~204) é suficiente.

**3b) Adicionar `takeUntilDestroyed` na subscription de `valueChanges` (linha 108):**

```typescript
// antes
this.form.get('ciclo').valueChanges.subscribe((valor) => { ... });

// depois — injetar DestroyRef no construtor e usar takeUntilDestroyed
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { DestroyRef, inject } from '@angular/core';

// no construtor:
private destroyRef = inject(DestroyRef);

// na subscription:
this.form.get('ciclo').valueChanges
  .pipe(takeUntilDestroyed(this.destroyRef))
  .subscribe((valor) => { ... });
```

Aplicar o mesmo padrão à subscription de `periodo.valueChanges` (linha ~115) se ainda não tiver unsubscribe.

---

**Arquivo 2:** `frontend/src/app/features/itinerario-formativo/listar-itinerarios/listar-itinerarios.component.ts`

**3c) Remover `console.error(error)` (linha ~127):**

```typescript
// antes
error: (error: any) => {
  this.notificationService.showError('Erro ao buscar dados.');
  console.error(error); // ← remover
},

// depois
error: () => {
  this.notificationService.showError('Erro ao buscar dados.');
},
```

**3d) Extrair lógica duplicada de mapeamento de disciplinas bloqueadas:**

A lógica de construir o `Set` de disciplinas bloqueadas e mapear com `locked` está duplicada em `listar-itinerarios.component.ts` (~linha 116) e `editar-itinerario.component.ts` (~linha 191). Criar uma função utilitária:

```typescript
// em um arquivo utilitário compartilhado (ex.: itinerario-formativo.utils.ts):
export function mapDisciplinasComBloqueio(
  disciplinas: MultiSelectOption[],
  bloqueadas: ResponseModel[]
): MultiSelectOption[] {
  const hashsBloqueados = new Set(bloqueadas?.map(d => d.hash) ?? []);
  return disciplinas.map(d => ({ ...d, locked: hashsBloqueados.has(d.hash) }));
}
```

Substituir os dois blocos duplicados pela chamada à função.

---

### Fase 4 — Cobertura de testes _(CA-02, CA-04)_

**Status:** concluída

**Arquivo 1:** `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/FilterItinerarioFormativoSelecaoServiceTests.cs`

Adicionar dois cenários novos ao método `GetAnosLetivos` (ou equivalente de alto nível):

**CA-02** — Usuário com apenas funcionalidade de configuração não tem acesso:
```csharp
[Fact]
public async Task GetAnosLetivos_DeveRetornarSemAcesso_QuandoUsuarioPossuiApenasPermissaoDeConfiguracao()
{
    // Arrange: criar UsuarioAcesso com Configurador_Itinerario_Formativo (426) em vez de ItinerarioFormativo_Selecao (427)
    var rede = await GerarRede();
    var escola = await GerarEscola(rede);
    await GerarUsuarioAcesso(_usuarioId, FuncionalidadeEntity.Configurador_Itinerario_Formativo,
        rede.Id, rede.Hash, escola.Id, escola.Hash);
    var service = serviceProvider.GetService<IFilterItinerarioFormativoSelecaoService>();

    // Act
    var result = await service.GetAnosLetivos();

    // Assert
    Assert.False(result.IsSuccess);
    Assert.Contains(DefaultMessages.SemAcesso, result.Errors);
}
```

**CA-04** — Usuário com ambas as permissões consegue acessar:
```csharp
[Fact]
public async Task GetAnosLetivos_DeveRetornarSucesso_QuandoUsuarioPossuiAmbas_Permissoes()
{
    // Arrange: criar UsuarioAcesso com 426 E 427 para o mesmo usuário/escola
    var anoLetivo = await GerarAnoLetivo(DateTime.Now.Year);
    var rede = await GerarRede();
    var escola = await GerarEscola(rede);
    await GerarUsuarioAcesso(_usuarioId, FuncionalidadeEntity.Configurador_Itinerario_Formativo,
        rede.Id, rede.Hash, escola.Id, escola.Hash);
    await GerarUsuarioAcesso(_usuarioId, FuncionalidadeEntity.ItinerarioFormativo_Selecao,
        rede.Id, rede.Hash, escola.Id, escola.Hash);
    var service = serviceProvider.GetService<IFilterItinerarioFormativoSelecaoService>();

    // Act
    var result = await service.GetAnosLetivos();

    // Assert
    Assert.True(result.IsSuccess);
}
```

---

**Arquivo 2:** `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/ItinerarioFormativoServiceTests.cs`

Adicionar cenário de edição com ciclo cruzado, verificando que `hashItinerarioExcluir` impede falso positivo:

```csharp
[Fact]
public async Task Save_NaoDeveBloquear_DisciplinaDoProprioComponente_AoEditar_ComMesmoCiclo()
{
    // Arrange: criar dados base (rede, escola, anoLetivo, cicloA, disciplina D, etc.)
    // Criar CF existente com cicloA e disciplina D
    // Montar request de edição: mesmo hash do CF, mesmo cicloA, mesma disciplina D

    // Act: chamar Save com request.Hash preenchido

    // Assert: result.IsSuccess == true (disciplina D não foi bloqueada porque o CF
    //          em edição foi excluído da busca via hashItinerarioExcluir)
}
```

Ao final das alterações, executar:

```bash
dotnet test backend/EstruturaPedagogica.Test --filter "FullyQualifiedName~FilterItinerarioFormativoSelecaoServiceTests|FullyQualifiedName~AlunoEscolaItinerarioFormativoSaveServiceTests|FullyQualifiedName~ItinerarioFormativoServiceTests"
```
