# Plano Técnico — EFC-6323

## Atividade

- **Chave:** EFC-6323
- **Título:** Mapear funcionalidade própria para a seleção de componentes formativos
- **Tipo:** Technology
- **Status:** Aberta

## Critérios de Aceite

Consulte `Docs/criterios-aceite-EFC-6323.md`

## Fases

### Fase 1 — Criar constante de funcionalidade de seleção _(infraestrutura)_

**Status:** pendente

**Arquivo:** `backend/EstruturaPedagogica.Domain/Entities/Base/Funcionalidade.cs`

Adicionar a linha abaixo imediatamente após a constante `Configurador_Itinerario_Formativo = 426`:

```csharp
public const int ItinerarioFormativo_Selecao = 427;
```

Esta constante é o pré-requisito para todas as fases seguintes. Mantê-la posicionada junto à constante irmã facilita a leitura.

---

### Fase 2 — Atualizar autorização do controller _(CA-01, CA-02)_

**Status:** pendente

**Arquivo:** `backend/EstruturaPedagogica.Api/Controllers/ItinerarioFormativoSelecaoController.cs`

Substituir o atributo `[RequiredAuthorization]`:

```csharp
// antes
[RequiredAuthorization(Funcionalidade.Configurador_Itinerario_Formativo)]

// depois
[RequiredAuthorization(Funcionalidade.ItinerarioFormativo_Selecao)]
```

Esta mudança separa as duas permissões: usuários com apenas a funcionalidade 426 (Configuração) não mais têm acesso à tela de seleção; apenas usuários com a funcionalidade 427 (Seleção) têm acesso. Usuários com ambas continuam acessando as duas telas (CA-04).

---

### Fase 3 — Substituir referências à funcionalidade de configuração nos services _(CA-02, CA-03)_

**Status:** pendente

**Arquivo 1:** `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/FilterItinerarioFormativoSelecaoService.cs`

Substituir todas as 6 ocorrências de `Funcionalidade.Configurador_Itinerario_Formativo` por `Funcionalidade.ItinerarioFormativo_Selecao` nos métodos:
- `GetAnosLetivos`
- `GetRedes`
- `GetEscolas`
- `GetAgrupamentos`
- `GetTurmas`
- `GetPeriodos`
- `GetAlunoParaSelecaoItinerario`

Isso garante que a filtragem de escolas passe a respeitar exclusivamente as escolas às quais o usuário tem permissão de **seleção** (CA-03), não de configuração.

**Arquivo 2:** `backend/EstruturaPedagogica.Domain.Services/ItinerarioFormativo/AlunoEscolaItinerarioFormativoSaveService.cs`

Substituir a 1 ocorrência de `FuncionalidadeEntity.Configurador_Itinerario_Formativo` por `FuncionalidadeEntity.ItinerarioFormativo_Selecao` no método `Save`.

---

### Fase 4 — Atualizar testes de integração existentes _(CA-01, CA-02, CA-03)_

**Status:** pendente

**Arquivo 1:** `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/FilterItinerarioFormativoSelecaoServiceTests.cs`

Atualizar o campo `_funcionalidadeCorreta`:

```csharp
// antes
private readonly int _funcionalidadeCorreta = FuncionalidadeEntity.Configurador_Itinerario_Formativo;

// depois
private readonly int _funcionalidadeCorreta = FuncionalidadeEntity.ItinerarioFormativo_Selecao;
```

**Arquivo 2:** `backend/EstruturaPedagogica.Test/Integration/Scenarios/ItinerarioFormativo/AlunoEscolaItinerarioFormativoSaveServiceTests.cs`

Atualizar o campo `_funcionalidadeCorreta`:

```csharp
// antes
private readonly int _funcionalidadeCorreta = FuncionalidadeEntity.Configurador_Itinerario_Formativo;

// depois
private readonly int _funcionalidadeCorreta = FuncionalidadeEntity.ItinerarioFormativo_Selecao;
```

Nenhum teste novo precisa ser criado — os cenários de acesso negado e sucesso já estão cobertos. Apenas o seed muda de id.

Após as alterações, executar:

```bash
dotnet test backend/EstruturaPedagogica.Test --filter "FullyQualifiedName~FilterItinerarioFormativoSelecaoServiceTests|FullyQualifiedName~AlunoEscolaItinerarioFormativoSaveServiceTests"
```

Todos os testes existentes devem continuar passando.
