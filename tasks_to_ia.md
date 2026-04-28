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
