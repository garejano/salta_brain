# Bug — Cascata dispara com data inválida

**Detectado em:** `lancamento-frequencia/listar`
**Afeta:** qualquer filtro que tenha `FieldType.Date` com `watch_list` e/ou `min`
**Componente core:** `src/shared/filtro/filtro/filtro.component.ts`

---

## Comportamento observado

Ao abrir a tela de lançamento de frequência, o filtro executa três chamadas na seguinte ordem:

```
filter-status   ← ngOnInit do componente pai (monta statusMap local)
filter-rede     ← autostart do campo rede
filter-status   ← autostart do campo status
```

A chamada duplicada de `filter-status` é esperada e tem propósitos distintos (ver seção extra no final). O problema real está no campo de data:

**Ao digitar manualmente uma data anterior a 01/01/2018:**
1. A chamada de `filter-rede` é feita normalmente → API retorna dados (não valida mínimo)
2. O usuário seleciona uma rede
3. A chamada de `filter-escola` é feita → API retorna: **"A data informada está abaixo do mínimo."**

O filtro permitiu avançar a cascata com uma data que o backend rejeita.

---

## Diagnóstico — causa raiz (3 pontos)

### 1. `min` ausente na config do campo data

`filtro-lancamento-frequencia.ts`:
```typescript
{
  field_type: FieldType.Date,
  key: "data",
  max: new Date().toISOString().split("T")[0],
  // ← min: "2018-01-01" não existe
}
```

Sem `min`, o browser não bloqueia a seleção pelo datepicker, e o Angular não tem base para marcar o controle como inválido.

---

### 2. `requiredIsValid` verifica presença, não validade

`filtro.component.ts:211`:
```typescript
requiredIsValid(keys: string[]): boolean {
  return keys.every(k => {
    const control = this.form?.controls[k];
    return control ? control.value !== (field.value ?? null) : false;
    //                ↑ só checa se tem valor diferente do padrão
    //                  não checa control.valid
  });
}
```

Quando o usuário digita `"2017-01-01"`, o controle tem valor (diferente do padrão), então `requiredIsValid` retorna `true` e libera a chamada para `rede`.

---

### 3. `fieldUpdate` dispara watchers sem validar o campo emissor

`filtro.component.ts:184`:
```typescript
fieldUpdate(fieldUpdate: { key, value }) {
  // ...
  this.findWatchers(fieldType)
    .filter(k => this.requiredIsValid(this.requiredMap[k]))  // valida dependentes
    .forEach(k => this.components[k]?.update(...));           // não valida o próprio campo
}
```

O portão atual (`requiredIsValid`) só garante que os campos dependentes têm seus pré-requisitos preenchidos. Não há verificação de que o campo que disparou a mudança é ele mesmo válido.

Além disso, `buildFormControl` (`filtro.component.ts:221`) não adiciona validators de range para `FieldType.Date` — mesmo que `min` exista no config, `control.valid` permanece `true` ao digitar manualmente.

---

## Fluxo atual (problema)

```
Usuário digita "2017-01-01"
    ↓
valueChanges emite (sem validator de min no Angular)
    ↓
fieldUpdate({ key: "data", value: "2017-01-01" })
    ↓
valor ≠ "" → não entra no fieldReset → continua
    ↓
findWatchers(Date) → ["hashRede"]
    ↓
requiredIsValid(["data"]) → "2017-01-01" ≠ default → TRUE  ← portão falho
    ↓
components["hashRede"].update() → HTTP call com data inválida
    ↓
API de redes não valida mínimo → retorna dados normalmente
    ↓
Usuário seleciona rede → chamada de escolas → "A data informada está abaixo do mínimo."
```

---

## Melhoria sugerida — 3 camadas

### Camada 1 — Config: adicionar `min`

**Arquivo:** config de cada filtro com campo de data (ex: `filtro-lancamento-frequencia.ts`)

```typescript
{
  field_type: FieldType.Date,
  key: "data",
  min: "2018-01-01",           // ← adicionar
  max: new Date().toISOString().split("T")[0],
}
```

Habilita o bloqueio nativo do browser ao usar o datepicker. Necessário para as camadas 2 e 3 funcionarem.

---

### Camada 2 — `buildFormControl`: adicionar validator de range para datas

**Arquivo:** `src/shared/filtro/filtro/filtro.component.ts` — método `buildFormControl`

```typescript
buildFormControl(field: FilterItemConfig) {
  const validators = [];
  if (field.required) validators.push(Validators.required);
  if (field.dependency_list?.length) validators.push(dependencyValidator(...));

  // novo: validator de min/max para FieldType.Date
  if (field.field_type === FieldType.Date) {
    if (field.min) {
      validators.push(control =>
        control.value && control.value < field.min ? { dateMin: true } : null
      );
    }
    if (field.max) {
      validators.push(control =>
        control.value && control.value > field.max ? { dateMax: true } : null
      );
    }
  }

  this.form.addControl(field.key, new FormControl(..., validators));
}
```

Com isso, ao digitar "2017-01-01", `control.valid` será `false` — o Angular passa a reconhecer a data como inválida.

---

### Camada 3 — `fieldUpdate`: checar validade do campo emissor antes de disparar watchers

**Arquivo:** `src/shared/filtro/filtro/filtro.component.ts` — método `fieldUpdate`

```typescript
fieldUpdate(fieldUpdate: { key: string, value: any }) {
  this.notifyParent$.next(fieldUpdate);

  if (
    fieldUpdate.value === this.config.defaultValue ||
    fieldUpdate.value === null ||
    ((typeof fieldUpdate.value === 'string' || Array.isArray(fieldUpdate.value))
      && fieldUpdate.value.length === 0)
  ) {
    this.fieldReset(fieldUpdate);
    return;
  }

  const field = this.config?.filters.find(i => i.key === fieldUpdate.key);
  if (!field) return;

  // novo: se o campo que mudou for inválido, reseta dependentes e para
  const control = this.form?.controls[fieldUpdate.key];
  if (control && !control.valid) {
    this.fieldReset(fieldUpdate);
    return;
  }

  const fieldType = field.type;
  this.findWatchers(fieldType)
    .filter(k => this.requiredIsValid(this.requiredMap[k]))
    .forEach(k => this.components[k]?.update(fieldType, null));
}
```

---

## Fluxo com as 3 camadas aplicadas

```
Usuário digita "2017-01-01"
    ↓
valueChanges emite
    ↓
fieldUpdate({ key: "data", value: "2017-01-01" })
    ↓
valor ≠ "" → não entra no fieldReset
    ↓
control.valid === false  ← camada 2 detectou data < min
    ↓
fieldReset(data) → reseta rede, escola, série, turma  ← camada 3
return  ← nenhuma chamada HTTP disparada
```

```
Usuário digita "2024-05-20" (válida)
    ↓
control.valid === true
    ↓
findWatchers(Date) → ["hashRede"]
    ↓
components["hashRede"].update() → HTTP call normal
```

---

## Arquivos a modificar

| Arquivo | Mudança |
|---------|---------|
| Config do filtro da tela (ex: `filtro-lancamento-frequencia.ts`) | Adicionar `min: "2018-01-01"` no campo data |
| `src/shared/filtro/filtro/filtro.component.ts` — `buildFormControl` | Adicionar validators de `dateMin`/`dateMax` para `FieldType.Date` |
| `src/shared/filtro/filtro/filtro.component.ts` — `fieldUpdate` | Checar `control.valid` antes de disparar watchers |

As mudanças em `filtro.component.ts` são genéricas — beneficiam qualquer filtro que use `FieldType.Date` com `min`/`max`, não apenas lançamento de frequência.

---

## Extra — Por que `filter-status` é chamado duas vezes no init

Não é bug, são dois propósitos distintos:

| Chamada | Origem | Propósito |
|---------|--------|-----------|
| 1ª | `listar.component.ts:69` — `ngOnInit` do componente pai | Monta o `statusMap` local para renderizar badges e labels na lista de eventos |
| 2ª | `filtro-lancamento-frequencia.ts:105` — `autostart: true` no campo status | O `FiltroComponent` carrega as options do dropdown de status dentro do painel de filtro |

A ordem `filter-status → filter-rede → filter-status` acontece porque o `ngOnInit` do pai executa antes do filho (`FiltroComponent`) ser inicializado. Quando o filho sobe, itera os campos em ordem de array: `rede` (índice 1) com `autostart` dispara primeiro, depois `status` (índice 5).
