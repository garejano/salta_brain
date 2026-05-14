# DEV_018 — Descrição para Claude Design

## Feature: Minimizar Páginas

---

## Contexto do produto

O document-builder é uma ferramenta que gera documentos institucionais (listas de presença, boletins, históricos) em PDF. Uma das principais preocupações das escolas é economizar papel — quanto menos páginas, melhor.

A tela principal já possui um painel lateral de configurações com sliders e toggles que permitem ao usuário ajustar manualmente espaçamentos, fontes e margens. O botão **"Minimizar páginas"** automatiza esse processo: testa configurações progressivamente e aplica apenas o que reduz o número de páginas.

---

## O que precisa ser projetado

### 1. Botão na topbar do overlay de impressão

A topbar atual tem:
- [←] Voltar | Título do documento | [⚙ Configurações] [🖨 Imprimir] [💾 Salvar PDF]

Adicionar o botão **"Minimizar páginas"** entre as ações. Sugestão de ícone: compressão / setas apontando para cima (↑↓ páginas diminuindo) ou símbolo de folhas empilhadas.

### 2. Modal / painel de progresso (estado "Executando")

Aparece ao clicar "Minimizar páginas". O documento continua visível ao fundo — o modal é sobreposto e o usuário pode ver as páginas mudando em tempo real enquanto a ferramenta testa cada ajuste.

**Componentes do modal:**
- Título: "Minimizando páginas..."
- Indicador do progresso atual: barra de progresso + texto "passo 3 de 7"
- **Lista de steps** — itens mostram estado:
  - `✅` step aplicado, com resultado (ex: "7 → 5 páginas")
  - `○` step mantido sem redução de páginas, mas sem prejuízo (ex: "5 → 5 páginas (mantido)")
  - `⏳` step atual — animado, pulsando suavemente
  - `○` steps futuros — cor neutra, aguardando

- Os steps são agrupados em fases:
  - **Fase 1: Espaçamento** — remover gap entre componentes
  - **Fase 2: Células da tabela** — reduzir padding das células
  - **Fase 3: Margens** — reduzir margens da página
  - **Fase 4: Fonte** — reduzir tamanho da fonte *(aviso: impacto visual)*

**Comportamento visual:**
- O modal deve ter largura fixa (~360px), alinhado ao lado direito da tela (onde fica o painel de configurações)
- Fundo semi-translúcido com blur suave (backdrop)
- Cada step novo entra com animação slide-down suave
- O step atual tem destaque visual (fundo levemente colorido, ícone pulsante)

### 3. Modal de resultado (estado "Concluído — com redução")

Após todos os steps terminarem e páginas foram reduzidas:

**Componentes:**
- Ícone de sucesso grande (✅ ou similar)
- Destaque numérico: **"7 páginas → 4 páginas"** — fonte grande, contrastante
- Lista resumida dos ajustes aplicados:
  - Espaçamento entre componentes: 8px → 0px
  - Padding das células: 4px → 2px
  - Margem da página: 10px → 6px
- Dois botões:
  - **[Desfazer]** — secundário, texto, restaura configuração original
  - **[Fechar]** — primário, fecha o modal e mantém os ajustes

### 4. Modal de resultado (estado "Concluído — sem redução")

Quando nenhum step reduziu páginas:

**Componentes:**
- Ícone neutro/informativo
- Mensagem: **"Não foi possível reduzir mais"**
- Subtexto: "Todas as configurações já estão no mínimo possível para este documento."
- Um botão: **[Fechar]**

---

## Paleta e tom visual

- **Cores:** seguir o design system existente da ferramenta (azul institucional `#1565C0` para ações primárias, fundo claro/branco, texto escuro)
- **Estado de progresso:** usar cor de destaque suave (azul claro) para o step ativo
- **Estado de sucesso:** verde `#2E7D32`
- **Estado neutro/mantido:** cinza médio
- **Aviso da Fase 4 (fonte):** amarelo/âmbar `#F57C00` — indicar que esta fase tem impacto visual

---

## Comportamento adicional

- O documento continua **visível e atualizado** durante a otimização. O usuário deve ter a sensação de "ver a máquina trabalhando" — as páginas vão sumindo enquanto o processo ocorre.
- O modal **não bloqueia o scroll** do documento
- Enquanto o processo roda, os botões "Imprimir" e "Salvar PDF" ficam desabilitados
- Se o usuário fechar o modal durante a execução (botão X), a otimização para e o config atual é mantido (não reverte automaticamente)

---

## Referência de layout (ASCII)

### Modal — Running

```
                          ┌─────────────────────────────────────┐
                          │ ↕ Minimizando páginas...             │
                          │                                      │
                          │ ████████████████░░░░░  3 / 7        │
                          │                                      │
                          │ FASE 1 — Espaçamento                │
                          │ ✅ Gap entre componentes  7 → 5 pág. │
                          │ ✅ Gap entre componentes  5 → 5 pág. │
                          │                                      │
                          │ FASE 2 — Células da tabela           │
                          │ ⏳ Testando padding vertical...      │
                          │                                      │
                          │ FASE 3 — Margens                    │
                          │ ○ Margens da página                  │
                          │ ○ Margens da página                  │
                          │                                      │
                          │ FASE 4 — Fonte ⚠ impacto visual     │
                          │ ○ Tamanho da fonte                   │
                          └─────────────────────────────────────┘
```

### Modal — Done (com redução)

```
                          ┌─────────────────────────────────────┐
                          │       ✅ Minimização concluída        │
                          │                                      │
                          │         7 pág → 4 pág               │
                          │                                      │
                          │ Ajustes aplicados:                   │
                          │ • Gap entre componentes: 8 → 0px     │
                          │ • Padding das células: 4 → 2px       │
                          │ • Margem da página: 10 → 6px         │
                          │                                      │
                          │    [Desfazer]        [Fechar]        │
                          └─────────────────────────────────────┘
```

### Modal — Done (sem redução)

```
                          ┌─────────────────────────────────────┐
                          │       ℹ Nenhuma redução possível     │
                          │                                      │
                          │  Todas as configurações já estão no  │
                          │  mínimo para este documento.         │
                          │                                      │
                          │              [Fechar]                │
                          └─────────────────────────────────────┘
```
