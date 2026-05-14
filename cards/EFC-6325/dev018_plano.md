# DEV_018 — Plano: Feature "Minimizar Páginas"

> Status: planejamento
> Design: a ser anexado (ver `dev018_design_description.md`)

---

## Objetivo

Permitir que o usuário reduza automaticamente o número de páginas de um documento, ajustando as configurações de forma incremental e validando cada ajuste antes de continuar.

---

## Princípio de design

**Não reduzir tudo ao mínimo de uma vez.** Cada passo é atômico: aplica-se uma mudança, verifica-se o resultado, e só então passa-se para o próximo. O usuário acompanha o processo em tempo real.

---

## Arquitetura da feature

### Novos artefatos

| Artefato | Caminho | Responsabilidade |
|---|---|---|
| `PageOptimizerService` | `services/page-optimizer.service.ts` | Algoritmo de otimização — independe de DOM e de UI |
| `OptimizeDialogComponent` | `components/optimize-dialog/` | UI do processo: loading, steps, resultado |

### Artefatos alterados

| Artefato | Mudança |
|---|---|
| `PrintOverlayComponent` | Adicionar botão "Minimizar páginas" na topbar |
| `DocumentViewerComponent` | Expor `pageCount: number` como getter público |
| `document-builder.module.ts` | Declarar e exportar os novos artefatos |

---

## `PageOptimizerService`

```typescript
export interface OptimizationStep {
  id: string
  label: string           // exibido no painel de loading
  apply: (config: DocumentConfig) => DocumentConfig
}

export interface StepResult {
  step: OptimizationStep
  pagesBefore: number
  pagesAfter: number
  kept: boolean
}

export interface OptimizationResult {
  originalPages: number
  finalPages: number
  steps: StepResult[]
  appliedConfig: DocumentConfig
}
```

**Método principal:**
```typescript
async optimize(
  config: DocumentConfig,
  reload: (newConfig: DocumentConfig) => Promise<number>,  // retorna pageCount após reload
  onStepStart: (step: OptimizationStep, index: number, total: number) => void,
  onStepDone: (result: StepResult) => void
): Promise<OptimizationResult>
```

O serviço **não conhece Angular, DOM, nem ViewContainerRef** — recebe tudo por injeção de dependências (callbacks). Isso permite testes unitários puros.

---

## Steps de otimização

Organizados em fases, do menos agressivo ao mais agressivo. Cada linha é um step atômico.

### Fase 1 — Espaçamento entre componentes (sem impacto visual no conteúdo)

| Step | Mudança | Valor mínimo |
|---|---|---|
| 1.1 | `componentGap` − 2px | 0 |
| 1.2 | `componentGap` − 2px | 0 |
| 1.3 | `componentGap` − 2px | 0 |

> Gerados dinamicamente: enquanto `config.componentGap > 0`, adicionar steps de −2px.

### Fase 2 — Padding das células de tabela

| Step | Mudança | Valor mínimo |
|---|---|---|
| 2.1 | `tableCellPadding` − 1px | 1 |
| 2.2 | `tableCellPadding` − 1px | 1 |
| 2.3 | `tableCellPaddingH` − 1px | 2 |
| 2.4 | `tableCellPaddingH` − 1px | 2 |

### Fase 3 — Margens da página

| Step | Mudança | Valor mínimo |
|---|---|---|
| 3.1 | `margin` − 2px | 5 |
| 3.2 | `margin` − 2px | 5 |

### Fase 4 — Tamanho da fonte (impacto visual visível)

| Step | Mudança | Valor mínimo |
|---|---|---|
| 4.1 | `fontSize` − 1px | 8 |
| 4.2 | `fontSize` − 1px | 8 |

**Critério de parada:**
- Steps esgotados, OU
- `pageCount === 1` (não há como reduzir mais)

**Critério de manter o step:**
- Um step é mantido se `pagesAfter <= pagesBefore`. Mesmo sem reduzir páginas, mudanças de fase 1/2 são mantidas pois criam espaço para as próximas fases.
- Steps de fase 4 (fonte) só são mantidos se `pagesAfter < pagesBefore` — impacto visual não justifica sem resultado.

---

## `OptimizeDialogComponent`

### Estados

1. **Idle** — botão "Minimizar páginas" visível na topbar do `PrintOverlayComponent`
2. **Running** — modal aberto, lista de steps animada, viewer atualizando ao fundo
3. **Done (success)** — modal mostra resumo: "Reduzido de N para M páginas"
4. **Done (no gain)** — modal mostra: "Não foi possível reduzir mais com as configurações atuais"

### Interface do modal (Running)

```
╔══════════════════════════════════════════╗
║  Minimizando páginas...                  ║
║                                          ║
║  ✅ Removendo espaçamento entre           ║
║     componentes  7 → 5 pág.             ║
║  ✅ Reduzindo padding das células        ║
║     5 → 5 pág. (mantido)                ║
║  ⏳ Testando: Reduzindo margens...       ║
║     ████████░░░░░░░░░░  3/7             ║
║                                          ║
║  ○ Reduzindo tamanho da fonte            ║
║                                          ║
╚══════════════════════════════════════════╝
```

### Interface do modal (Done)

```
╔══════════════════════════════════════════╗
║  ✅ Minimização concluída                 ║
║                                          ║
║  7 páginas → 4 páginas                   ║
║                                          ║
║  Ajustes aplicados:                      ║
║  • Espaçamento entre componentes: 8→0px  ║
║  • Padding das células: 4→2px            ║
║  • Margem da página: 10→6px              ║
║                                          ║
║  [Desfazer]              [Fechar]        ║
╚══════════════════════════════════════════╝
```

### Botão "Desfazer"
Restaura o `config` original e faz `viewer.reload()`. Sem necessidade de histórico complexo — o `config` original é salvo no início da otimização.

---

## Integração com `DocumentViewerComponent`

Adicionar getter público:
```typescript
get pageCount(): number {
  return this.pages.length
}
```

O `PrintOverlayComponent` passa ao `OptimizeDialogComponent`:
- Referência ao viewer (`@ViewChild`)
- Config atual
- Callback `reload(newConfig) → Promise<number>` que chama `viewer.reload(newConfig)` e resolve com `viewer.pageCount`

---

## Fluxo completo

```
Usuário clica "Minimizar páginas"
  ↓
OptimizeDialogComponent.open(config, reloadFn)
  ↓
PageOptimizerService.optimize(config, reloadFn, onStepStart, onStepDone)
  ↓
  Para cada step:
    1. onStepStart() → UI mostra "⏳ Testando: <label>..."
    2. newConfig = step.apply(currentConfig)
    3. pagesAfter = await reloadFn(newConfig)  ← viewer rerenderiza ao vivo
    4. onStepDone(result) → UI atualiza lista
    5. Se mantido: currentConfig = newConfig
  ↓
OptimizationResult retornado
  ↓
UI muda para estado "Done"
  ↓
Config aplicado ao documento fica ativo até usuário fechar ou desfazer
```

---

## Testes unitários (`page-optimizer.service.spec.ts`)

- `optimize()` sem nenhuma redução possível → `finalPages === originalPages`
- `optimize()` com componentGap=8 → 3 steps tentados, 2 mantidos
- Step de fase 4 (fontSize) revertido se não reduz páginas
- `onStepStart` chamado na ordem correta
- `onStepDone` emite `kept: false` quando step revertido
- `appliedConfig` final reflete apenas steps mantidos

---

## Critério de aceite

- [ ] Botão "Minimizar páginas" no `PrintOverlayComponent`
- [ ] Otimização é incremental — cada step aplica uma mudança atômica
- [ ] Viewer atualiza ao vivo durante a otimização (usuário vê páginas mudando)
- [ ] Loading mostra label de cada step com resultado (✅ / ⏳ / ○)
- [ ] Steps de fase 4 (fonte) só mantidos se reduziram páginas
- [ ] Botão "Desfazer" restaura config original
- [ ] `PageOptimizerService` é testável sem Angular (sem DOM, sem DI)
- [ ] Testes unitários passam

---

## Pendências antes da implementação

1. **Design visual** — aguardando mockup do Claude Design (ver `dev018_design_description.md`)
2. **`DocumentViewerComponent.reload(newConfig)`** — verificar se já aceita novo config por parâmetro ou se é necessário ajuste
