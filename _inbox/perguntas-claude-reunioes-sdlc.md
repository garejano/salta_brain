# Perguntas sobre Claude — Reuniões SDLC (15/04 e 17/04)

---

## Pergunta 1 — Skills / Rules do Claude Code vs. Conventions do Spec Driven: como conversam?

**Quem:** Jonas Sossai (Reunião 1, ~10min)
> *"No spec driven ele tem as conventions, só que eu pego o cloud code, ele tem as skills barra rule set, que também tem conventions. Como é que essas coisas conversam?"*

**Resposta:**
São conceitos complementares, não concorrentes. O Claude Code usa dois mecanismos de instrução:

- **`CLAUDE.md`** — arquivo de "constituição" do projeto. Fica na raiz (ou em subpastas) do repositório e é carregado automaticamente em toda sessão. Equivale ao arquivo `constitution.md` do Spec Kit.
- **Slash commands / skills** (pasta `.claude/commands/`) — arquivos `.md` que ensinam o Claude a executar um fluxo específico (ex: `/refinar-historia`, `/gerar-testes`). Equivalem aos comandos do Spec Kit (`/specify`, `/plan`, `/tasks`).

Quando o Spec Kit é usado no Claude Code, os arquivos de constitution e conventions do Spec Kit viram entradas no `CLAUDE.md` ou em arquivos separados que o `CLAUDE.md` referencia. Rodrigo estava correto: "são nomes diferentes para um MD que ele lê como parte do contexto".

**Documentação:**
- [CLAUDE.md — Project memory](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Slash commands (custom)](https://docs.anthropic.com/en/docs/claude-code/slash-commands)

---

## Pergunta 2 — Por que o Claude encontra mais problemas a cada pedido de revisão?

**Quem:** Jonas Sossai (Reunião 2, ~40min)
> *"Eu pedi para o Claude corrigir, ele achou 3 problemas. Pedi de novo, achou mais 2. Na terceira vez não achou mais nada. Isso me passa desconfiança. Até quantas vezes tenho que pedir?"*

**Resposta:**
Esse comportamento é esperado e tem dois motivos:

1. **Natureza probabilística dos LLMs:** O Claude não "varre" o código de forma determinística como um linter. Cada execução é uma nova amostragem — ele pode focar em aspectos diferentes a cada chamada. Não é bug; é característica do modelo.

2. **Janela de atenção ("attention"):** Em arquivos longos, a atenção do modelo é distribuída. Numa primeira passagem ele pode não "notar" algo que nota na segunda, quando o contexto está mais focado naquele trecho.

**Como mitigar:**
- Use **testes automatizados** como "memória objetiva" — se o teste quebrar, o Claude sabe que algo foi alterado incorretamente.
- Instrua o Claude a fazer revisão estruturada: "revise seguindo este checklist: [lista]". Isso força cobertura sistemática.
- Use o padrão TDD citado pelo Felipe: "escreva os testes primeiro, depois implemente" — os testes servem como verificador determinístico.
- Múltiplos passes são normais em **code review humano** também — o equivalente é abrir o PR e revisar depois de dormir.

**Documentação:**
- [Reduce hallucinations — best practices](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations)

---

## Pergunta 3 — Janela de contexto: cada etapa do Spec Kit tem sua própria janela?

**Quem:** Stephan (Reunião 2, ~45min)
> *"Você não tem problema de janela de contexto? Esse negócio é separado, cada parte tem sua janela de contexto independente. Como é que tá isso?"*

**Resposta:**
Sim — e o Leandro explicou o mecanismo corretamente. Cada comando do Spec Kit (`/specify`, `/plan`, `/tasks`, `/implement`) **lê arquivos do disco** em vez de depender da memória da sessão. Isso resolve o problema de janela de contexto de forma elegante:

- `/specify` → escreve `spec.md`
- `/plan` → lê `spec.md` + `constitution.md` → escreve `plan.md`
- `/tasks` → lê `plan.md` → escreve `tasks.md`
- `/implement` → lê `tasks.md` + `plan.md`

**Cada comando pode ser rodado em sessão nova** porque a "memória" está nos arquivos, não na conversa. O contexto passa por arquivos intermediários — isso é intencional no design do Spec Kit e equivale ao padrão de "memory files" do Claude Code.

**Documentação:**
- [Claude Code memory (files as memory)](https://docs.anthropic.com/en/docs/claude-code/memory)
- [Context window — como funciona](https://docs.anthropic.com/en/docs/about-claude/models/overview)

---

## Pergunta 4 — Sessões independentes: posso rodar os comandos do Spec Kit em sessões diferentes?

**Quem:** Iuri (Reunião 2, ~45min)
> *"Você tá rodando ele sempre na mesma sessão?"*

**Resposta:**
Sim, você **pode** rodar em sessões diferentes. Como explicado acima, o Spec Kit salva o estado em arquivos `.md` no repositório. Ao abrir uma nova sessão do Claude Code no mesmo repositório, o `CLAUDE.md` e os arquivos de spec/plan/tasks são carregados automaticamente — a sessão "herda" o estado anterior pelos arquivos.

**Boas práticas:**
- Mantenha o `CLAUDE.md` com as regras do projeto para garantir consistência entre sessões.
- Use `--continue` ou `/resume` para retomar uma sessão existente se quiser continuar um fluxo em andamento.

**Documentação:**
- [Claude Code sessions](https://docs.anthropic.com/en/docs/claude-code/overview)

---

## Pergunta 5 — Como organizar os arquivos MD quando crescem infinitamente?

**Quem:** Jonas Sossai (Reunião 2, ~50min)
> *"Imagina isso crescendo no infinito. Qual a melhor forma de organizar? Por features, épicos, card Jira?"*

**Resposta:**
Não há uma resposta definitiva da Anthropic para estrutura de projeto — isso é decisão de time. Mas as práticas emergentes mais adotadas são:

**Estrutura recomendada por feature/épico:**
```
.claude/
  CLAUDE.md              ← regras globais do projeto
  commands/              ← slash commands / skills
specs/
  epic-001-contratacao/
    spec.md
    plan.md
    tasks.md
  epic-002-frequencia/
    spec.md
    ...
```

**Princípio:** Um arquivo por nível de abstração (spec, plan, tasks), organizado por épico ou feature. O `CLAUDE.md` referencia os arquivos relevantes para o contexto atual.

**Documentação:**
- [Project structure — Claude Code](https://docs.anthropic.com/en/docs/claude-code/settings)

---

## Pergunta 6 — Como o Claude lida com features que atravessam múltiplos repositórios?

**Quem:** Jonas Sossai (Reunião 2, ~50min)
> *"Você tá falando de um repositório. Imagina uma feature que passa por GE, Pagamento Service, Barramento. Como fica?"*

**Resposta:**
O Claude Code lida com múltiplos repositórios de duas formas:

**Opção A — Workspace (pasta pai):**
Abra o VS Code apontando para a pasta pai que contém todos os repositórios. O Claude terá acesso a todos como subpastas. O `CLAUDE.md` na raiz define regras globais; cada repositório pode ter seu próprio `CLAUDE.md` com regras específicas (herança hierárquica).

```
/workspace-salta/
  CLAUDE.md              ← regras globais + mapeamento de repos
  GE/
    CLAUDE.md            ← regras específicas do GE
  pagamento-service/
    CLAUDE.md
  barramento/
    CLAUDE.md
```

**Opção B — Instrução explícita no prompt:**
Diga ao Claude: *"A implementação envolve os repositórios GE (pasta `./GE`) e Pagamento Service (pasta `./pagamento-service`). O contrato entre eles está em `./barramento/contracts/`."*

**Limitação real:** O Stephan relatou que em workspace com N projetos, quando a história é ambígua sobre qual projeto pertence, o Claude "viaja" e gasta tokens tentando se achar. A solução é ter **regras bem definidas no `CLAUDE.md`** de cada projeto, indicando quando ele deve e não deve agir.

**Documentação:**
- [CLAUDE.md — hierarchical loading](https://docs.anthropic.com/en/docs/claude-code/memory#how-claude-decides-what-to-read)

---

## Pergunta 7 — Usar histórias anteriores do Jira como "gabarito" para o Spec Driven faz sentido?

**Quem:** Jonas Sossai (Reunião 2, ~35min)
> *"O Stefan centralizou as melhores histórias do Jira dos últimos meses como gabarito. Vocês acham que faz sentido o Spec Driven se inspirar nisso para criar tarefas?"*

**Resposta:**
Sim, faz todo sentido — é uma das formas mais eficazes de usar o Claude. Chama-se **few-shot prompting**: você fornece exemplos de alta qualidade para que o modelo replique o padrão.

**Como implementar:**
1. Selecione 3–5 histórias bem escritas do Jira.
2. Adicione-as como exemplos no `CLAUDE.md` ou num arquivo `examples/good-stories.md`.
3. Na skill de refinamento, instrua: *"Siga o formato e nível de detalhe dos exemplos em `examples/good-stories.md`."*

O Stephan mencionou que o time já tinha histórias bem detalhadas desde setembro — isso foi o que fez o "extract de memória" funcionar tão bem. Quem não tiver esse histórico, pode criar artificialmente com 5–10 exemplos manuais de alta qualidade.

**Documentação:**
- [Prompt engineering — few-shot examples](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/use-examples)

---

## Pergunta 8 — Como evitar que o Claude ignore regras de negócio críticas (guardrails)?

**Quem:** Antonio Carlos (Reunião 2, ~55min)
> *"A IA ignorou cálculos imutáveis e fez um novo, tirando o campo filial do cálculo. Tem como programar a IA para ter guardrails nesses casos?"*

**Resposta:**
Sim — existem três mecanismos complementares:

**1. CLAUDE.md com regras invioláveis (mais importante):**
```markdown
## Regras de Negócio Críticas — NUNCA violar
- Cálculos de folha de pagamento SEMPRE devem incluir o campo `filial`
- Exclusões são SEMPRE lógicas (flag `ativo = false`), NUNCA físicas
- O campo `periodo_letivo` no banco corresponde à tabela `academic_period`, não `school_year`
```

**2. Dicionário de termos (problema do Iuri — academic vs. school_year):**
Crie um arquivo `domain-glossary.md`:
```markdown
| Termo de negócio     | Nome no banco    | Tabela           |
|----------------------|------------------|------------------|
| Período letivo       | academic_period  | academic_period  |
| Ano letivo           | school_year      | school_year      |
```
E referencie no `CLAUDE.md`: *"Consulte sempre `domain-glossary.md` antes de mapear termos de negócio para o banco."*

**3. Testes como guardrail automático (solução do Felipe):**
Antes de qualquer alteração em código crítico, peça ao Claude: *"Escreva primeiro os testes que cobrem os cálculos atuais de [X]. Só então faça a alteração."* Se os testes quebrarem, o Claude sabe que violou algo.

**Documentação:**
- [Reduce hallucinations — grounding](https://docs.anthropic.com/en/docs/test-and-evaluate/strengthen-guardrails/reduce-hallucinations)
- [CLAUDE.md best practices](https://docs.anthropic.com/en/docs/claude-code/memory)

---

## Resumo

| # | Pergunta | Reunião | Resposta resumida |
|---|---|---|---|
| 1 | Skills/Rules Claude Code vs. Conventions Spec Driven | 15/04 | São equivalentes — todos viram MD lido como contexto |
| 2 | Por que Claude acha mais bugs a cada revisão? | 17/04 | Natureza probabilística; use testes como guardrail determinístico |
| 3 | Janela de contexto entre etapas do Spec Kit | 17/04 | Cada etapa lê do disco — janela não é problema |
| 4 | Posso rodar comandos em sessões diferentes? | 17/04 | Sim — o estado fica nos arquivos MD |
| 5 | Como organizar MDs crescentes? | 17/04 | Estrutura por épico/feature com CLAUDE.md hierárquico |
| 6 | Features com múltiplos repositórios | 17/04 | Workspace (pasta pai) + CLAUDE.md por repositório |
| 7 | Usar histórias do Jira como gabarito? | 17/04 | Sim — few-shot prompting; adicionar exemplos no CLAUDE.md |
| 8 | Guardrails para regras de negócio críticas | 17/04 | CLAUDE.md com regras invioláveis + glossário de termos + TDD |
