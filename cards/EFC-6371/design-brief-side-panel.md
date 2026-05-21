# Design Brief — Componente `app-side-panel`

## O que preciso

Gerar um template HTML/CSS para o componente `app-side-panel` usando o design system da empresa.

---

## O que é o componente

Um **painel lateral** (drawer) que desliza a partir da borda direita da tela para exibir detalhes de um registro sem navegar para outra página. É uma alternativa ao modal para conteúdo que precisa de mais espaço vertical.

---

## Comportamento

- Abre deslizando da direita para dentro (`translateX(100%)` → `translateX(0)`)
- Fecha ao clicar no botão "×" interno **ou** ao clicar no overlay (área escura à esquerda)
- Scroll interno quando o conteúdo ultrapassar a altura da tela
- Um overlay semitransparente cobre o restante da tela enquanto o painel está aberto

---

## Layout esperado

```
┌─────────────────────────────┬─────────────────┐
│                             │   SIDE PANEL    │
│   overlay semitransparente  │                 │
│   (cobre o restante da      │  [×]            │
│    tela)                    │                 │
│                             │  conteúdo via   │
│                             │  ng-content     │
│                             │                 │
│                             │  (scroll se     │
│                             │   necessário)   │
└─────────────────────────────┴─────────────────┘
```

- **Largura do painel:** ~480px (fixo)
- **Altura:** 100vh (altura total da tela)
- **Posição:** fixed, right: 0, top: 0
- **Overlay:** cobre 100vw × 100vh, opacity ~0.5, cor escura

---

## Regras de negócio e critérios de aceite

Extraídos do card EFC-6371. O design deve suportar todos esses casos:

**CA-01 — Componente independente**
O painel é standalone — a lógica de abrir, fechar e o layout vivem nele. O componente pai apenas diz se está aberto ou fechado.

**CA-02 — Controle de visibilidade pelo pai**
O painel recebe um `@Input() show` (boolean) para controlar se está visível. Ao fechar, emite um evento para o pai reagir. O design precisa contemplar o estado **fechado** (painel fora da tela) e o estado **aberto** (painel visível + overlay).

**CA-03 — Dois pontos de fechamento**
O usuário pode fechar de duas formas:
- Clicando no botão "×" dentro do painel
- Clicando no overlay semitransparente à esquerda do painel

Ambas as áreas precisam ser visualmente distinguíveis e acessíveis.

**CA-04 — Posicionamento e scroll**
- O painel ocupa **toda a altura lateral direita** da tela (100vh)
- Quando o conteúdo for maior que a tela, o scroll acontece **dentro do painel** — a página por baixo não rola
- O overlay cobre o restante da tela e impede interação com o conteúdo de fundo enquanto o painel está aberto

**CA-05 — Conteúdo projetado (ng-content)**
O painel não tem conteúdo próprio — ele é um container. O conteúdo real (título, campos, abas, botões de ação) é sempre injetado pelo componente que usa o painel.

A referência visual do card mostra um exemplo típico de uso:
- Cabeçalho com título e possivelmente abas internas
- Seções de campos de detalhe
- Botões de ação no rodapé (ex: Salvar, Cancelar)

O design do template deve prever essas áreas como **slots de conteúdo**, não como parte fixa do componente.

---

## Estrutura HTML mínima

```html
<!-- wrapper que encapsula tudo quando o painel está aberto -->
<div class="side-panel">
  <!-- botão fechar no canto superior direito do painel -->
  <button class="btn-side-panel-close">×</button>

  <!-- área de conteúdo projetado (ng-content) -->
  <div class="side-panel-body">
    <!-- conteúdo do consumidor entra aqui -->
  </div>
</div>

<!-- overlay clicável -->
<div class="overlay"></div>
```

---

## Referência visual

O componente segue o mesmo padrão visual do `app-modal` já existente no sistema:
- Fundo branco (`#fff`), bordas arredondadas no lado esquerdo
- Botão "×" posicionado no canto superior direito do painel
- Overlay com `background: #0f0f10`, opacidade ~0.5
- Animação suave de entrada (0.25s)
- Sombra lateral: `box-shadow: -4px 0 24px rgba(0,0,0,0.12)`

---

## O que quero receber

1. **CSS completo** do componente (classes: `.side-panel`, `.overlay`, `.btn-side-panel-close`)
2. O CSS deve usar as variáveis/tokens do design system da empresa onde aplicável (cores, tipografia, border-radius, sombras)
3. Animação de entrada e saída
4. Estado responsivo: em telas menores que 480px o painel deve ocupar 100vw
