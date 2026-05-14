# QA — Análise do Bug Reportado — EFC-6323

> **Card:** EFC-6323 — Mapear funcionalidade própria para a seleção de componentes formativos  
> **Subtarefa:** EFC-6343 — Não é possível associar aluno a Componente Formativo com permissão de seleção  
> **Data da análise:** 2026-05-12  
> **Repositório analisado:** `estrutura-pedagogica`

---

## Descrição do bug (QA)

> Quando definimos para determinado perfil que uma escola tenha **apenas a permissão de seleção** de componente formativo, a escola não está conseguindo fazer a alocação. A mesma escola, com outro perfil com **permissão de alocação e configuração**, está conseguindo fazer a alocação.

- **Ambiente:** Homologação
- **Usuário:** perfil suporte / Escola: Elite MG
- **Pré-condição:** Escola Elite MG com permissão apenas de seleção (427) no perfil suporte
- **Frequência:** Sempre ocorre

---

## O que foi verificado

### 1. Banco de dados ✅

| Item | Resultado |
|------|-----------|
| `Funcionalidade` (Id=426) | `"Configurador de Itinerário Formativo"` — existe |
| `Funcionalidade` (Id=427) | `"Seleção de Itinerário Formativo"` — existe |
| `ModuloAuth.UsuarioAcesso` com FuncionalidadeId=427 | 76.227 registros, 2.402 usuários, `HashRede` preenchido |

A funcionalidade 427 está corretamente cadastrada e atribuída a usuários com `HashRede` e `EscolaId` preenchidos.

### 2. Backend ✅

| Arquivo | Status | Observação |
|---------|--------|------------|
| `Funcionalidade.cs` | ✅ Correto | Constante `ItinerarioFormativo_Selecao = 427` presente |
| `ItinerarioFormativoSelecaoController.cs` | ✅ Correto | `[RequiredAuthorization(427)]` em todos os endpoints |
| `FilterItinerarioFormativoSelecaoService.cs` | ✅ Correto | 7 métodos usam 427 |
| `AlunoEscolaItinerarioFormativoSaveService.cs` | ✅ Correto | Save usa `GetEscolaIdByRedeFuncionalidadeUsuarioAutenticado(hashRede, 427)` |

O backend está implementado corretamente. O save valida 427 com `HashRede`, e os dados no banco têm essa estrutura preenchida.

### 3. Frontend ❌

**`selecao-itinerario.component.ts` — `aplicarFiltro()` linha 75:**

```typescript
forkJoin({
  componentes: this.itinerarioService.getItinerarios(request),  // ← PROBLEMA
  alunos: this.selecaoItinerarioService.alunos(request),
})
```

`itinerarioService.getItinerarios` chama `POST /itinerarioformativo/itinerarios` — endpoint do `ItinerarioFormativoController`, que exige permissão **426**.

Um usuário com apenas **427** recebe 403 nessa chamada. O `handleApiError` converte em `ServiceResult { isSuccess: false }`, então `this.componentes` fica vazio e a tela não exibe nenhum componente para selecionar.

**Routing module — guards comentados:**

```typescript
// canActivate: [IsLoggedGuard, IsAllowed],
// data: { roles: [permission.ChecklistFolha] }
```

Qualquer usuário logado acessa a tela — o problema não está na entrada, mas no carregamento dos dados.

---

## Causa raiz

> O `ItinerarioFormativoSelecaoController` (protegido por 427) **não possui endpoint** para listar os itinerários disponíveis para seleção. O frontend usa o endpoint de configuração (`/itinerarioformativo/itinerarios`, protegido por 426), que bloqueia usuários com apenas 427.

Resultado: usuário acessa a tela (guards comentados), alunos carregam (via 427), mas a lista de componentes fica vazia (falha silenciosa no 403 do endpoint 426). Sem componentes, não há o que alocar.

---

## Por que o usuário com 426+427 consegue alocar

Usuário com ambas as permissões tem 426, então `GET /itinerarioformativo/itinerarios` retorna a lista de componentes normalmente. O save usa 427, que também está presente. Tudo funciona.

---

## O que precisa ser corrigido

### Fix 1 — Backend: novo endpoint no controller de seleção

**`ItinerarioFormativoSelecaoController.cs`** — adicionar:

```csharp
[HttpPost("itinerarios")]
public async Task<IActionResult> GetItinerariosFormativos(
    [FromServices] IItinerarioFormativoGetService service,
    [FromBody] ItinerarioFormativoFilterRequest request)
{
    return Result(await service.GetItinerariosFormativos(request));
}
```

> `IItinerarioFormativoGetService.GetItinerariosFormativos` não verifica permissão internamente — pode ser reutilizado sem alteração.

### Fix 2 — Frontend: trocar chamada no componente de seleção

**`selecao-itinerario.service.ts`** — adicionar:

```typescript
getItinerarios(filter: ItinerarioFormativoSelecaoFilterRequest): Observable<ServiceResult<ItinerarioFormativoResponse[]>> {
  return this.apiClient
    .post("/selecao-itinerario/itinerarios", filter)
    .pipe(catchError(this.handleApiError.handleError<any>("selecao-itinerario/itinerarios")));
}
```

**`selecao-itinerario.component.ts`** — `aplicarFiltro()`, linha 75:

```typescript
// antes
componentes: this.itinerarioService.getItinerarios(request),

// depois
componentes: this.selecaoItinerarioService.getItinerarios(request),
```

### Fix 3 (complementar) — Ativar guard de rota

**`itinerario-formativo-routing.module.ts`:**

```typescript
{
  path: path.ItinerarioFormativo.Selecao,
  component: SelecaoItinerarioComponent,
  canActivate: [IsLoggedGuard, IsAllowed],
  data: { roles: [permission.ItinerarioFormativoSelecao] } // 427
}
```

---

## Critérios de aceite — status após análise

| CA | Descrição | Status |
|----|-----------|--------|
| CA-01 | Usuário com 427 acessa tela e consegue alocar | ❌ Falha — sem componentes para selecionar |
| CA-02 | Usuário com apenas 426 não acessa seleção | ⚠️ Sem guarda de rota (comentado) — acessa a tela, mas alunos/save falham por 427 |
| CA-03 | Escolas filtradas respeitam 427 | ✅ Backend correto |
| CA-04 | Usuário com 426+427 acessa ambas | ✅ Funciona |

---

## Arquivos a modificar

```
backend/EstruturaPedagogica.Api/Controllers/ItinerarioFormativoSelecaoController.cs
frontend/src/app/features/itinerario-formativo/services/selecao-itinerario.service.ts
frontend/src/app/features/itinerario-formativo/selecao-itinerario/selecao-itinerario.component.ts
frontend/src/app/features/itinerario-formativo/itinerario-formativo-routing.module.ts
```
