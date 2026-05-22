# _pde — Ambiente de Desenvolvimento Pessoal

Esta pasta contém scripts, configurações e documentação para controlar o ambiente de desenvolvimento dentro do repositório `pde_salta`.

## Ferramentas utilizadas

| Ferramenta | Papel |
|------------|-------|
| **Helix** | Editor principal |
| **WezTerm** | Terminal — controlador central do ambiente |
| **Claude CLI** | IA rodando dentro do WezTerm |

---

## Visão: WezTerm como controlador central

O objetivo é usar o WezTerm (via Lua) como orquestrador de tudo que envolve o `pde_salta` e o Claude CLI. Isso inclui:

- Abrir layouts de abas/splits específicos por repositório
- Saber quais painéis têm Claude rodando
- Acompanhar quais tarefas cada instância de Claude está executando

---

## Funcionalidades planejadas

### 1. Detecção de Claude em painéis ativos

Identificar, via WezTerm/Lua, em quais `window` / `pane` há um processo `claude` rodando.

**Abordagem sugerida:**
- Usar `wezterm.mux.all_windows()` para iterar janelas e painéis
- Verificar o processo ativo de cada painel via `pane:get_foreground_process_name()`
- Destacar visualmente painéis com Claude (ex: cor diferente na tab bar)

**Arquivo:** `_pde/wezterm/claude_detector.lua`

---

### 2. Layouts de abas por repositório

Criar uma nova aba com layout pré-definido: N splits, cada um abrindo uma pasta diferente e executando um comando específico.

**Abordagem sugerida:**
- Arquivo Lua por repositório: `_pde/layouts/<repo>.lua`
- Cada arquivo define splits, diretórios e comandos iniciais
- Comando WezTerm para carregar o layout: ex. `wezterm cli spawn --cwd ... -- lua _pde/layouts/efc-frontend.lua`

**Exemplo de estrutura de layout:**
```lua
-- _pde/layouts/efc-frontend.lua
return {
  tabs = {
    {
      name = "efc-frontend",
      splits = {
        { cwd = "c:/projects/efc-frontend", cmd = "hx ." },
        { cwd = "c:/projects/efc-frontend", cmd = "claude" },
        { cwd = "c:/projects/pde_salta",   cmd = nil },
      }
    }
  }
}
```

**Arquivo principal:** `_pde/wezterm/layouts.lua`

---

### 3. Rastreamento de tarefas por instância de Claude

Saber o que cada Claude está fazendo, sem precisar trocar de painel.

**Abordagem sugerida:**
- Cada sessão Claude salva um arquivo `_pde/tasks/<session-id>.md` com a tarefa atual
- WezTerm lê esses arquivos e exibe um resumo na tab bar ou em um painel de status
- A IA atualiza o arquivo ao iniciar/terminar uma tarefa

**Formato do arquivo de tarefa:**
```markdown
# Task
card: EFC-6322
status: in-progress
description: Implementar testes E2E para lançamento de frequência
started: 2026-05-22T10:30
```

**Arquivos:**
- `_pde/tasks/` — diretório com uma task por sessão Claude ativa
- `_pde/wezterm/task_status.lua` — lê os arquivos e renderiza na UI do WezTerm

---

## Estrutura de arquivos desta pasta

```
_pde/
  readme.md                  # Este documento
  wezterm/
    claude_detector.lua      # Detecta Claude em painéis ativos
    layouts.lua              # Carregador de layouts por repositório
    task_status.lua          # Lê tasks ativas e exibe no WezTerm
  layouts/
    <repo>.lua               # Layout específico por repositório
  tasks/
    <session-id>.md          # Tarefa atual de cada instância Claude
```

---

## Próximos passos

- [ ] Criar `claude_detector.lua` — detectar processo Claude por painel
- [ ] Criar primeiro layout Lua para o repositório mais usado
- [ ] Definir convenção de nomeação de sessões Claude para rastrear tasks
- [ ] Integrar `task_status.lua` com a tab bar do WezTerm
