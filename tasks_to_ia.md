# Tarefas para a IA

Cole o template, preencha e cole no chat.

---

## Template

```
## T<N> — <título>

**O que fazer:** <uma frase direta — ex: "criar script SQL que...", "refatorar o componente X para...">

**Contexto:** <o que a IA precisa saber que não é óbvio — decisão, restrição, dependência>

**Pronto quando:** <critério objetivo — ex: "script roda sem erro e retorna Y linhas">
```

---

## Tarefas

## T1 — Criar skill para executar tarefas de tasks_to_ia.md

**O que fazer:** Criar a skill `/run-tasks` que lê `tasks_to_ia.md`, identifica tarefas pendentes e as executa. A skill deve refinar o texto das tarefas antes de executar (corrigir português e melhorar coerência) e gerenciar um índice sequencial (T1, T2...) nas tarefas, adicionando-o na primeira execução caso não exista.

**Pronto quando:** Skill criada em `.claude/commands/run-tasks.md`.

**Status:** concluída

---

## T2 — Melhoria na skill repo_map: detectar skills por repositório

**O que fazer:** Atualizar a skill `repo_map` para verificar se cada repositório varrido possui a pasta `.claude/commands/`. Se existir, incluir no `repository_map.md` a lista de skills disponíveis naquele repositório.

**Pronto quando:** Skill `repo_map` atualizada e `repository_map.md` refletindo as skills do `estrutura-pedagogica`.

**Status:** concluída

---


## T3 — leia o command refinar-feature do repostiorio estrutura-pedagogica e crie um command com a mesma ideia

**O que fazer:** Condiserar que o comand criado deve funcionar no meu contexto dos cards locais (nao os do jira)
e deve criar dentro dos locais um card com EFC-xx.refinamento.md

**Pronto quando:** tiver o command criado pronto para usar considerando a arquitetura desse repo salta_brain

**Status:** concluída

---

## T4 — Criar skill identificar-bug adaptada para o salta_brain

**O que fazer:** Ler o command `identificar-bug.md` do repositório `estrutura-pedagogica` e criar um command equivalente para o `salta_brain`, seguindo o mesmo padrão da T3: lê o card local em `cards/EFC-xxx/`, identifica o repositório via `repository_map.md`, explora o código no repo identificado e grava o resultado em `cards/EFC-xxx/EFC-xxx.bug-report.md`.

**Pronto quando:** Command criado em `.claude/commands/identificar-bug.md`.

**Status:** concluída

---

## T5 — Criar skill para gerar plano técnico de atuação

**O que fazer:** Com o nome de um card EFC-xxxx, a skill analisa os documentos do card em `cards/` — exigindo que o arquivo de refinamento exista para prosseguir — e gera um `EFC-xxxx.tech.md` com todos os passos necessários para executar a tarefa, levando em conta os `CLAUDE.md` dos repositórios analisados.

**Pronto quando:** Command criado em `.claude/commands/refinar-tech.md`.

**Status:** concluída



---

## T6 — Atualizar `/refinar-tech` com regras do `planejar-implementacao` do `estrutura-pedagogica`

**O que fazer:** Ler o command `planejar-implementacao.md` do repositório `estrutura-pedagogica` e incorporar ao command `/refinar-tech` do `salta_brain` as regras ou etapas que estejam faltando.

**Pronto quando:** Command atualizado em `.claude/commands/refinar-tech.md`.

**Status:** concluída


---

## T7 — Criar um command/skill

**O que fazer:** que execute o fluxo criaod para refinameto e refinamento tecnico de um card do jira e crie para esse ddos o spdd-story e depois o spdd-canvas para esse card.

**Pronto quando:** Command atualizado em `.claude/commands/spdd-refine.md`.

**Status:** concluída

---

## T8 — Criar o command `/spdd-generate`

**O que fazer:** Com base na especificação documentada em `inbox/spdd_commands.md` (seção 5), criar o command `/spdd-generate` que lê o `EFC-xxxx.spdd-canvas.md` de um card, localiza o repositório alvo, executa uma operação específica do bloco `O — Operations` no código real e marca a operação como concluída no Canvas.

**Pronto quando:** Command criado em `.claude/commands/spdd-generate.md`.

**Status:** concluída
