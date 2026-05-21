# EFC-5967 — Plano de Implementação: `useStorage` no Filtro

## Contexto

O componente de filtro (`shared/filtro`) faz cache das listas de opções de cada campo (`optionsData`) no `localStorage`. No primeiro loading, se o filtro já foi aplicado antes, o `field-wrapper` recupera as opções do cache em vez de chamar a API. O problema é que alguns campos (ex: listas que mudam com frequência ou dependem de contexto do servidor) precisam sempre buscar dados frescos, sem depender do cache local. A solução é adicionar um flag `useStorage` na configuração de cada campo, com default `true` para manter o comportamento atual.

---

## Escopo

Dois arquivos apenas:

| Arquivo | Mudança |
|---------|---------|
| `frontend/src/shared/filtro/filtro.models.ts` | Adicionar `useStorage?: boolean` em `FilterItemConfig` |
| `frontend/src/shared/filtro/field-wrapper/field-wrapper.component.ts` | Respeitar `useStorage` em `init()`, `getOptions()` e `customGet()` |

Nenhum arquivo de configuração existente precisa ser alterado — `useStorage` omitido = `true` (comportamento atual preservado).

---

## Mudanças

### 1. `filtro.models.ts` — Adicionar campo na interface

```typescript
export interface FilterItemConfig {
  // ...campos existentes...
  useStorage?: boolean;  // default: true — false = nunca usa localStorage para opções
  // ...
}
```

### 2. `field-wrapper.component.ts` — Três pontos de toque

**`init(saved)` — não recuperar do cache quando `useStorage: false`:**

```typescript
async init(saved: FilterStorage<any>): Promise<void> {
  if (this.config.field_type === FieldType.MultiSelect || this.config.field_type === FieldType.Select) {
    const useStorage = this.config.useStorage !== false;
    if (saved.aplicado && useStorage) {
      await this.recoveryFromStorage(saved);
    } else if (this.config.autostart || !this.config.watch_list?.length) {
      await this.getOptions();
    }
  } else {
    // ... sem mudança
  }
}
```

**`getOptions()` — não salvar no cache quando `useStorage: false`:**

```typescript
try {
  const options = await firstValueFrom(this.service.fakeGet(this.config.url, request));
  this.updateOptions(options.data);
  if (this.config.useStorage !== false) {
    this.updateOptionsOnStorage(options.data);
  }
} catch { ... }
```

**`customGet()` — mesmo controle para o modo legado:**

```typescript
next: (result: any) => {
  this.updateOptions(result.data);
  if (this.config.useStorage !== false) {
    this.updateOptionsOnStorage(result.data);
  }
}
```

---

## Exemplo de uso (após implementação)

```typescript
// Em qualquer filtro_*.ts
{
  field_type: FieldType.Select,
  type: FilterType.Rede,
  useStorage: false,   // <-- sempre busca da API, nunca do cache
  autostart: true,
  // ...
}
```

---

## Verificação

1. Abrir qualquer tela com filtro que usa Select (ex: Escolas Públicas)
2. Aplicar o filtro → navegar para detalhe → voltar
3. **Com `useStorage: true` (padrão):** campo recupera opções do localStorage (sem regressão)
4. Setar `useStorage: false` em um campo → repetir → confirmar que a API é chamada no loading mesmo com `saved.aplicado = true`
5. Confirmar no DevTools > Application > LocalStorage que `optionsData` do campo com `useStorage: false` **não** é atualizado
