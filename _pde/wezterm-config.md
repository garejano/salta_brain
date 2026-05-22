# WezTerm — Documentação da Configuração

**Arquivo:** `C:\Users\gustavo.arejano\.wezterm.lua`

---

## Visão geral

| Item | Valor |
|------|-------|
| Plugin externo | `lib.wezterm` (chrisgve/lib.wezterm) |
| Leader key | `Ctrl+A` (timeout 1s) |
| CWD padrão | `c:/projects` |
| Font size | 10 |
| Tab bar | Habilitada, no topo, estilo simples (não fancy) |
| Window decorations | Apenas resize (sem barra de título OS) |
| Status update | 1000ms |

---

## Caminhos configurados

```lua
paths = {
  projects    = "c:/projects/",
  note_config = "c:/Users/gustavo.arejano",
  config      = "c:/Users/arejano",
}
```

---

## Temas disponíveis (lista `themes`)

| Índice | Tema |
|--------|------|
| 1 (ativo) | `nil` — tema padrão do WezTerm |
| 2 | Gruvbox light, medium (base16) |
| 3 | Catppuccin Mocha |
| 4 | Catppuccin Frappe |
| 5 | Catppuccin Macchiato |
| 6 | Catppuccin Latte |
| 7 | Batman |

Para trocar: `config.color_scheme = themes[N]`

---

## Cores da tab bar

Todas as variantes de `custom_colors` usam `#282864` (azul escuro). Há uma variante comentada com cores mais vibrantes (roxo/laranja/vermelho).

```lua
tab_bar.background      = "#282864"
active_tab.bg           = "#000" / fg "#FFF"
inactive_tab.bg         = "#282864" / fg "#FFF"
```

---

## Atalhos de teclado

### Navegação entre painéis

| Atalho | Ação |
|--------|------|
| `Ctrl+H` | Mover foco para o painel Esquerdo |
| `Ctrl+L` | Mover foco para o painel Direito |
| `Ctrl+K` | Mover foco para o painel Acima |
| `Ctrl+J` | Mover foco para o painel Abaixo |
| `Ctrl+Alt+H` | Redimensionar painel para a esquerda (-10) |
| `Ctrl+Alt+J` | Redimensionar painel para baixo (+10) |
| `Ctrl+Alt+K` | Redimensionar painel para cima (+10) |
| `Ctrl+Alt+L` | Redimensionar painel para a direita (+10) |

### Navegação entre abas

| Atalho | Ação |
|--------|------|
| `Ctrl+[` | Aba anterior |
| `Ctrl+]` | Próxima aba |
| `Leader+H` | Aba anterior |
| `Leader+L` | Próxima aba |
| `Leader+T` | Tab Navigator (fuzzy) |
| `Alt+1..9` | Ir para aba N |
| `Ctrl+Alt+L` | Mover aba para direita |

### Workspaces

| Atalho | Ação |
|--------|------|
| `Leader+W` | Launcher fuzzy de workspaces |

### Splits

| Atalho | Ação |
|--------|------|
| `Leader+\|` (pipe) | Split horizontal |
| `Leader+%` | Split vertical |
| `Ctrl+Shift+Q` | Fechar painel atual (com confirmação) |

### Layouts / Comandos especiais

| Atalho | Ação |
|--------|------|
| `Ctrl+Shift+I` | `SpawnIDE` — abre Superfile (esq) + Helix (dir) |
| `Ctrl+Shift+H` | Layout: Superfile + Helix (70%) + terminal embaixo |
| `Ctrl+Shift+R` | Split vertical abrindo `estrutura-pedagogica` com `npm run dev` |
| `Ctrl+Shift+D` | Foca painel esquerdo/baixo e executa `run.bat` |
| `Ctrl+Shift+B` | Foca painel esquerdo/baixo e executa `zig build run` |
| `Ctrl+Shift+K` | Split direito (80%) — uso geral, parcialmente comentado |
| `Ctrl+Shift+Y` | Chama `send_to_helix` com `c:/projects/teste.txt` (WIP) |
| `Alt+F` | Toggle fullscreen |

---

## Evento: `SpawnIDE`

Acionado por `Ctrl+Shift+I`. Cria layout:

```
[ Superfile (spf) ]  |  [ Helix (hx) ]
```

Salva o `pane_id` do Helix em `~/.helix_pane_id` para integração futura com o Superfile.

---

## Status bar

### Esquerda (`update_left_status`)

Mostra o **modo atual**:
- `N` = Normal (cor `#282864`)
- `L` = Leader ativo (cor `#282864`)

### Direita (`update_right_status`)

Exibe três blocos:
1. **Processo** — nome do processo em foreground do painel ativo (`get_foreground_process_name`)
2. **CWD** — diretório atual (ícone de pasta)
3. **Data** — `DD.MM.YYYY` (calculada na inicialização, não atualiza ao longo do dia)

> **Nota:** `date_string` é calculado em tempo de load do arquivo, não em tempo de render. Reiniciar o WezTerm atualiza a data.

---

## Startup (`gui-startup`)

Ao iniciar, abre automaticamente as seguintes abas:

| Título | CWD | Observação |
|--------|-----|------------|
| `code` | `DBeaverData/.../Scripts` | Scripts SQL do DBeaver |
| `code` | `c:/projects` | Diretório geral de projetos |
| `config` | `c:/Users/arejano` | Arquivos de configuração |
| `doc-ped` | `c:/projects/documentacao-pedagogica/frontend` | — |
| `portal` | `c:/projects/portal-atlas` | — |
| `estr-ped` | `c:/projects/estrutura-pedagogica/frontend` | — |
| `claude` | `c:/projects/pde_salta` | Sessão Claude CLI |

A janela inicia maximizada.

---

## Pontos para evolução

- `send_to_helix` é chamada em `Ctrl+Shift+Y` mas **não está definida** no arquivo — provavelmente está no plugin `lib.wezterm` ou é código removido.
- `date_string` não atualiza ao longo do dia — considerar mover para dentro de `update_right_status` usando `wezterm.strftime`.
- A função `teste()` está vazia — pode ser removida.
- O campo `config.launch_menu` tem apenas uma entrada ("Conectar ao servidor" com `hx`) — pode ser expandida com atalhos para projetos.
- `pane_tracker.helix_panes` está declarado mas nunca usado — base para rastreamento futuro de painéis.
