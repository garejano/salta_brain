# Dicas para Devs — Claude Code

---

## 1. Mentalidade: Claude não é um chatbot

Claude Code é um agente autônomo — ele lê arquivos, executa comandos, faz alterações e resolve problemas por conta própria enquanto você acompanha e orienta.

- Descreva **o que** você quer. O Claude descobre **como** fazer.
- O fluxo ideal é: **explorar → planejar → implementar**. Separe essas fases.
- Dê critérios de verificação para que o Claude cheque o próprio trabalho (testes, saída esperada, screenshot).
- Interrompa cedo quando o Claude for na direção errada. Loops curtos de feedback produzem resultados melhores.

---

## 2. Como escrever bons prompts

### Seja específico
| Ruim | Bom |
|------|-----|
| "Corrija o bug do login" | "Adicione validação de entrada na função `login()` em `auth.ts`, cobrindo string vazia e somente espaços" |
| "Melhore esse código" | "Refatore o método `calcularDesconto()` seguindo o padrão usado em `calcularJuros()` no mesmo arquivo" |

### Dicas práticas
- Use `@caminho/do/arquivo` para referenciar arquivos diretamente sem esperar o Claude lê-los.
- Cole imagens e screenshots para mudanças de UI ou mensagens de erro.
- Para features grandes, peça ao Claude para te **entrevistar** primeiro:
  > "Me entreviste sobre [feature]. Pergunte sobre implementação, edge cases, UI e preocupações. Quando cobrir tudo, escreva uma spec em `specs/feature.md`."
- Depois da entrevista, abra uma sessão nova com o spec pronto — contexto limpo para implementação.

---

## 3. CLAUDE.md — a "constituição" do projeto

O `CLAUDE.md` é carregado automaticamente em toda sessão. É o lugar mais importante para investir tempo.

### O que colocar
- Comandos de build, test e lint do projeto
- Regras de estilo que diferem do padrão da linguagem
- Decisões arquiteturais específicas do projeto
- Convenções de branch e PR
- Gotchas e comportamentos não óbvios do sistema
- Dicionário de termos de negócio → nome no banco (ex: "Período letivo = tabela `academic_period`")

### O que NÃO colocar
- Convenções padrão da linguagem (o Claude já sabe)
- Conteúdo que muda frequentemente
- Tutoriais longos ou documentação de API (use links)
- Procedimentos de múltiplos passos (mova para Skills)
- Descrições arquivo por arquivo do código

### Hierarquia de arquivos
```
~/.claude/CLAUDE.md              ← suas preferências pessoais (todos os projetos)
./CLAUDE.md                      ← regras do time (commitar no repositório)
./CLAUDE.local.md                ← suas notas pessoais do projeto (add no .gitignore)
./src/pagamentos/CLAUDE.md       ← regras específicas da pasta (carregadas sob demanda)
```

### Regras por caminho (`.claude/rules/`)
Crie arquivos `.md` com frontmatter para carregar regras apenas quando relevante:
```markdown
---
paths:
  - "src/api/**/*.ts"
---
# Regras de API
- Todo endpoint valida o input
- Use o formato padrão de resposta de erro
```

### Dicas
- **Mantenha abaixo de 200 linhas.** Regras se perdem no ruído quando o arquivo é grande.
- Execute `/init` para gerar um `CLAUDE.md` inicial baseado no seu repositório.
- Se o Claude continua errando algo apesar da regra, o arquivo está grande demais — pode.
- Use `@README.md` para referenciar arquivos externos sem duplicar conteúdo.

---

## 4. Janela de contexto — seu recurso mais valioso

O contexto esgota rápido e a performance cai à medida que enche. Gerencie proativamente.

### Estratégias
- **`/clear`** entre tarefas não relacionadas. Use `/rename` antes para salvar a sessão.
- **`/compact`** com instrução customizada: `/compact Foque nas mudanças de código e saída dos testes`
- **`/cost`** para ver o uso atual de tokens da sessão.
- Configure a status line para exibir o uso do contexto em tempo real.

### Padrões eficientes
- Não misture tarefas não relacionadas na mesma sessão ("kitchen sink session").
- Teste incrementalmente — implemente um arquivo, teste, continue — em vez de implementar tudo de uma vez.
- Use subagentes para investigações; leituras verbosas de arquivos ficam no contexto do subagente, não no seu.
- Use `/btw` para perguntas rápidas que não precisam ficar no contexto.

### O que sobrevive ao compaction
- O `CLAUDE.md` é reinjetado automaticamente.
- Alterações de código e estado dos arquivos são preservados.
- Decisões e padrões importantes são resumidos.
- Instruções dadas apenas na conversa são perdidas → **coloque no `CLAUDE.md`**.

---

## 5. Skills — workflows reutilizáveis

Skills são arquivos `.md` que ensinam o Claude a executar um fluxo específico, ativados com `/`.

### Quando criar uma skill
- Qualquer coisa que você explica repetidamente para o Claude.
- Workflows que o time executa regularmente (`/refinar-historia`, `/criar-pr`, `/gerar-testes`).
- Procedimentos de múltiplos passos que seriam longos no `CLAUDE.md`.

### Estrutura
Crie `.claude/commands/nome-da-skill.md`:
```markdown
---
description: Refina uma história do Jira e gera tasks no padrão Spec Driven
---
1. Leia a história em `$ARGUMENTS` ou peça o link do Jira
2. Identifique lacunas na especificação e pergunte ao usuário
3. Gere o arquivo `specs/[nome]/spec.md` com os cenários mapeados
4. Gere `specs/[nome]/tasks.md` com as subtasks técnicas
5. Confirme se o resultado está alinhado antes de prosseguir
```

Invoque com: `/refinar-historia GE-1234`

### Skill vs. CLAUDE.md
| CLAUDE.md | Skill |
|---|---|
| Sempre carregado | Carregado só quando usado |
| Consome contexto desde o início | Não consome contexto até ser invocado |
| Regras gerais e arquitetura | Workflows e procedimentos específicos |

---

## 6. Subagentes — delegue investigações pesadas

Use subagentes para tarefas que leem muitos arquivos ou são independentes da conversa principal.

### Quando delegar
- Investigar onde uma regra de negócio está implementada (lê muitos arquivos)
- Rodar testes, processar logs, buscar documentação
- Tarefas paralelas não relacionadas
- Code review em sessão separada (sem o viés de quem escreveu o código)

### Como criar um subagente customizado
Crie `.claude/agents/revisor-seguranca.md`:
```markdown
---
name: revisor-seguranca
description: Revisa código em busca de vulnerabilidades de segurança
tools: Read, Grep, Glob
---
Você é um engenheiro de segurança sênior. Revise o código buscando:
- Injection (SQL, XSS, command injection)
- Falhas de autenticação e autorização
- Secrets expostos no código
- Validação insuficiente de entrada
```

Invoque: "Use um subagente para revisar este código em busca de problemas de segurança."

---

## 7. Modo Plan — planeje antes de executar

Ative com `Shift+Tab` ou `--permission-mode plan`.

- **Somente leitura**: o Claude explora o código sem fazer nenhuma alteração.
- Produz um plano detalhado e aguarda sua aprovação antes de implementar.
- Use `Ctrl+G` para abrir o plano no editor de texto e editar diretamente.

### Quando usar
- Mudanças em múltiplos arquivos
- Código desconhecido ou legado
- Features complexas onde a direção ainda não está clara
- Antes de refatorações grandes

---

## 8. Hooks — automação sem esforço

Hooks executam comandos automaticamente em resposta a ações do Claude.

### Casos de uso comuns
- **Formatar código** automaticamente após cada edição (Prettier, Black, dotnet format)
- **Bloquear comandos perigosos** antes de executar (`rm -rf`, `DROP TABLE`)
- **Rodar testes** automaticamente após alterações de código
- **Notificações** quando o Claude termina uma tarefa longa

### Exemplo — formatar após edição
Em `.claude/settings.json`:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$(jq -r '.tool_input.file_path')\""
          }
        ]
      }
    ]
  }
}
```

### Exemplo — bloquear deleções acidentais
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '$CLAUDE_TOOL_INPUT' | grep -q 'rm -rf' && exit 1 || exit 0"
          }
        ]
      }
    ]
  }
}
```

---

## 9. Guardrails — evite que o Claude ignore regras críticas

### Problema: Claude ignorou uma regra de negócio importante

**Solução 1 — Regras invioláveis no `CLAUDE.md`:**
```markdown
## Regras de Negócio Críticas — NUNCA violar
- Cálculos de folha SEMPRE devem incluir o campo `filial`
- Exclusões são SEMPRE lógicas (flag `ativo = false`), NUNCA físicas
- Não remova Redux — a migração será feita separadamente
```

**Solução 2 — Dicionário de termos de domínio:**
Crie `docs/domain-glossary.md`:
```markdown
| Termo de negócio | Nome no banco     | Tabela           |
|------------------|-------------------|------------------|
| Período letivo   | academic_period   | academic_period  |
| Ano letivo       | school_year       | school_year      |
| Filial           | branch_id         | branches         |
```
Referencie no `CLAUDE.md`: *"Consulte sempre `docs/domain-glossary.md` ao mapear termos de negócio para o banco."*

**Solução 3 — TDD como guardrail automático:**
Antes de qualquer alteração em código crítico:
> "Escreva primeiro os testes que cobrem o comportamento atual de `calcularDesconto()`. Só então faça a alteração. Se os testes quebrarem, pare e me avise."

---

## 10. Gerenciar múltiplos repositórios

Para features que cruzam repositórios (GE + Pagamento Service + Barramento):

**Opção A — Workspace (pasta pai):**
Abra o VS Code na pasta pai com todos os repositórios. O Claude acessa tudo como subpastas.
```
/workspace-salta/
  CLAUDE.md              ← regras globais + mapeamento entre repos
  GE/
    CLAUDE.md            ← regras específicas do GE
  pagamento-service/
    CLAUDE.md
  barramento/
    CLAUDE.md
```

**Opção B — Instrução explícita:**
> "A implementação envolve os repos `./GE` (backend) e `./pagamento-service`. O contrato entre eles está em `./barramento/contracts/api.ts`."

**Dica:** Se o Claude "viaja" tentando se achar em workspace grande, é sinal de que faltam regras claras no `CLAUDE.md` de cada projeto. Defina explicitamente o escopo de cada um.

---

## 11. Sessões e contexto entre sessões

- Os arquivos `.md` no repositório são a "memória persistente". Sessões diferentes leem do disco, não da conversa anterior.
- `/clear` reseta a conversa mas não os arquivos — o progresso em `specs/` está sempre salvo.
- `claude --continue` retoma a sessão mais recente no diretório atual.
- `claude --resume` abre o seletor de sessões anteriores.
- Use `/rename` para nomear sessões importantes antes de fechar.

### Comandos úteis
| Comando | O que faz |
|---------|-----------|
| `/clear` | Reseta o histórico da conversa |
| `/compact` | Resume a conversa (preserva contexto) |
| `/rename` | Nomeia a sessão atual |
| `/resume` | Abre outra sessão |
| `/cost` | Mostra uso de tokens da sessão |
| `/rewind` | Restaura código para um checkpoint anterior |
| `/btw` | Pergunta rápida sem ocupar contexto |

---

## 12. Modo não-interativo — automação e CI/CD

```bash
# Execução única, sem sessão
claude -p "Corrija todos os erros de lint no projeto"

# Com ferramentas específicas permitidas
claude -p "Commit as alterações" --allowedTools "Bash(git commit *)"

# Processar uma lista de arquivos
for file in $(cat lista.txt); do
  claude -p "Migre $file para o novo padrão" --allowedTools "Edit,Bash(npm test)"
done

# Saída em JSON para scripts
claude -p "Analise este erro" --output-format json
```

---

## 13. Few-shot prompting — use exemplos como gabarito

Para que o Claude replique o padrão de histórias bem escritas do Jira:

1. Selecione 3–5 histórias de alta qualidade.
2. Salve em `docs/examples/historias-modelo.md`.
3. Na skill de refinamento, instrua:
   > *"Siga o formato e nível de detalhe dos exemplos em `docs/examples/historias-modelo.md`."*

Isso se chama **few-shot prompting** — uma das técnicas mais eficazes para padronizar output.

---

## 14. Revisão de código com Claude

Para uma revisão imparcial, **abra uma sessão nova** — assim o Claude não tem viés em relação ao código que ele mesmo escreveu.

Prompt eficaz:
> "Revise este PR buscando: edge cases não tratados, race conditions, problemas de segurança, e lugares onde o comportamento difere da spec. Explique o *porquê* de cada problema, não só aponte o que está errado."

---

## 15. Depuração eficiente

1. Compartilhe a mensagem de erro completa e os passos para reproduzir.
2. Peça ao Claude para localizar o código: *"Onde esse erro é lançado?"*
3. Peça múltiplas abordagens de correção e discuta os tradeoffs antes de implementar.
4. Após a correção: *"Verifique se a correção resolve a causa raiz e não apenas o sintoma."*
5. Escreva um teste de regressão para o bug corrigido.

---

## 16. Armadilhas comuns e como evitar

### "Kitchen sink session"
**Problema:** Misturar tarefas não relacionadas na mesma sessão.
**Sintoma:** Claude começa a ignorar instrução antigas, contexto lento.
**Fix:** Use `/clear` + `/rename` antes de trocar de assunto.

### Loop de correção
**Problema:** Correção em cima de correção — contexto cheio de tentativas falhas.
**Fix:** Após duas correções sem sucesso, `/clear` e reescreva o prompt inicial com mais contexto.

### `CLAUDE.md` grande demais
**Problema:** Regras se perdem no ruído quando o arquivo é grande demais.
**Fix:** Mantenha abaixo de 200 linhas. Mova workflows detalhados para Skills. Use `rules/` por caminho.

### Implementar sem verificar
**Problema:** Código gerado parece correto mas tem edge cases errados.
**Fix:** Sempre forneça critérios de verificação (testes, saída esperada). Nunca aceite código sem rodar.

### Exploração infinita
**Problema:** Pediu para "investigar" sem escopo — Claude leu centenas de arquivos, contexto esgotado.
**Fix:** Escoope a investigação: *"Procure apenas em `src/pagamentos/`."* Use subagentes para exploração.

---

## 17. Atalhos de teclado essenciais

| Atalho | Ação |
|--------|------|
| `Esc` / `Ctrl+C` | Para o Claude (contexto preservado) |
| `Esc` + `Esc` | Abre menu de rewind (restaurar código) |
| `Shift+Tab` | Alterna entre modos de permissão |
| `Alt+T` | Liga/desliga o modo de raciocínio (thinking) |
| `Ctrl+O` | Modo verboso — mostra o processo de raciocínio |
| `Tab` | Autocomplete de comandos |
| `?` | Lista todos os atalhos disponíveis |

---

## 18. Estrutura de repositório recomendada para uso com IA

```
meu-projeto/
  CLAUDE.md                  ← regras do time (commitar)
  CLAUDE.local.md            ← notas pessoais (.gitignore)
  .claude/
    commands/                ← slash commands / skills
      refinar-historia.md
      criar-pr.md
      gerar-testes.md
    agents/                  ← subagentes customizados
      revisor-seguranca.md
    rules/                   ← regras por caminho
      frontend.md
      api.md
    settings.json            ← permissões e hooks do time
    settings.local.json      ← permissões pessoais (.gitignore)
  specs/                     ← arquivos spec/plan/tasks do Spec Driven
    epic-001-contratacao/
      spec.md
      plan.md
      tasks.md
  docs/
    domain-glossary.md       ← dicionário de termos de negócio
    examples/
      historias-modelo.md    ← exemplos para few-shot prompting
```

---

## 19. Configuração de permissões para reduzir prompts

Em `.claude/settings.json`:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run test)",
      "Bash(npm run build)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Edit(src/**)",
      "Edit(tests/**)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Edit(.env*)"
    ]
  }
}
```

---

## 20. Checklist de onboarding para novo projeto

- [ ] Gerar `CLAUDE.md` inicial com `/init`
- [ ] Adicionar comandos de build, test e lint ao `CLAUDE.md`
- [ ] Criar `docs/domain-glossary.md` com termos de negócio
- [ ] Criar skills para os workflows mais frequentes do time
- [ ] Configurar hook de formatação automática
- [ ] Definir permissões no `settings.json` para reduzir prompts repetitivos
- [ ] Adicionar 3–5 histórias modelo em `docs/examples/` para few-shot prompting
- [ ] Adicionar `CLAUDE.local.md` e `settings.local.json` ao `.gitignore`

---

## Referência rápida — documentação oficial

| Tema | Link |
|------|------|
| Visão geral | https://docs.anthropic.com/en/docs/claude-code/overview |
| CLAUDE.md (memória) | https://docs.anthropic.com/en/docs/claude-code/memory |
| Slash commands | https://docs.anthropic.com/en/docs/claude-code/slash-commands |
| Hooks | https://docs.anthropic.com/en/docs/claude-code/hooks |
| MCP (integrações) | https://docs.anthropic.com/en/docs/claude-code/mcp |
| Configurações | https://docs.anthropic.com/en/docs/claude-code/settings |
| Melhores práticas | https://docs.anthropic.com/en/docs/claude-code/best-practices |
| Engenharia de prompt | https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview |
