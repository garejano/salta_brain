# Skill: run-tasks

## Descrição

Lê `tasks_to_ia.md`, identifica tarefas pendentes e as executa uma a uma.
A cada execução, refina o texto da tarefa (coerência, português) antes de rodar.

---

## Uso

```
/run-tasks          → executa todas as tarefas pendentes
/run-tasks T3       → executa apenas a tarefa com índice T3
```

---

## Execução Passo a Passo

### 1. Ler `tasks_to_ia.md`

Usar `Read` para carregar o arquivo.

### 2. Indexar tarefas (primeira execução ou se faltar índice)

- Verificar se os headings de tarefa seguem o padrão `## T1 — <título>`.
- Se **não** seguirem, renomear todos os headings adicionando o índice sequencial: `T1`, `T2`, `T3`...
- Gravar o arquivo com os índices adicionados antes de prosseguir.

### 3. Identificar tarefas pendentes

Uma tarefa está **pendente** se não contiver a linha `**Status:** concluída`.
Uma tarefa está **concluída** se contiver `**Status:** concluída` — ignorar.

### 4. Para cada tarefa pendente (em ordem)

1. **Refinar o texto** — corrigir português, melhorar coerência, sem alterar a intenção original.
2. **Atualizar o arquivo** — gravar a versão refinada da tarefa em `tasks_to_ia.md`.
3. **Marcar como em andamento** — adicionar/atualizar `**Status:** em andamento` na tarefa e gravar.
4. **Executar** — realizar o trabalho descrito em "O que fazer".
5. **Marcar como concluída** — substituir o status por `**Status:** concluída` e gravar.

### 5. Exibir resumo

```
✔ T1 — <título> → concluída
✔ T2 — <título> → concluída
─ T3 — <título> → pulada (já concluída)

Total: N executadas, M puladas.
```

---

## Regras

- Nunca alterar a seção `## Template` nem o cabeçalho do arquivo.
- Ao refinar, corrigir apenas erros de escrita — não reinterpretar a tarefa.
- Se uma tarefa for ambígua, perguntar ao usuário antes de executar.
- Se `/run-tasks <índice>` for chamado com um índice inexistente, avisar e parar.
