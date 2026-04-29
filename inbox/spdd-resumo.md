# Resumo: Structured-Prompt-Driven Development (SPDD)

**Fonte:** https://martinfowler.com/articles/structured-prompt-driven/  
**Publicado:** 28 Abril 2026 — Martin Fowler (autores: Wei Zhang & Jessie Jie Xia, Thoughtworks)

---

## O que é

SPDD é uma metodologia de engenharia que trata **prompts como artefatos de entrega de primeira classe** — versionados, revisados e reutilizados. Em vez de usar LLMs via chats avulsos, o SPDD cria prompts estruturados e governados que capturam requisitos, modelo de domínio, intenção de design, restrições e quebra de tarefas.

**Problema que resolve:** LLMs aumentam a velocidade individual, mas sem estrutura escalam também mal-entendidos, dificultam revisões de código e aumentam risco em produção. *"Local speed improves. But that doesn't automatically translate into system-level throughput."*

---

## O Canvas REASONS

Framework de 7 partes para construir prompts eficazes:

| Letra | Nome | O que captura |
|-------|------|---------------|
| **R** | Requirements | Definição do problema e critérios de aceite |
| **E** | Entities | Entidades de domínio e relacionamentos |
| **A** | Approach | Estratégia de solução |
| **S** | Structure | Fit no sistema, componentes, dependências |
| **O** | Operations | Passos concretos e testáveis de implementação |
| **N** | Norms | Padrões de engenharia (naming, observabilidade, etc.) |
| **S** | Safeguards | Limites inegociáveis (invariantes, segurança, performance) |

As quatro primeiras (REAS) são **abstratas** (intenção e design); O é **específico** (execução); N e S são **governança**.

---

## Workflow

1. Criar requisitos/user stories (`/spdd-story`)
2. Clarificar análise com negócio/técnica
3. Gerar contexto de análise (`/spdd-analysis`)
4. Gerar Canvas REASONS (`/spdd-reasons-canvas`)
5. Gerar código a partir do Canvas (`/spdd-generate`)
6. Gerar e refinar testes unitários (`/spdd-api-test`)
7. Ciclo de revisão e sincronização

**Regra fundamental:** *"When reality diverges, fix the prompt first — then update the code."*

### Dois tipos de mudança no código

- **Correção de lógica** (mudança de comportamento) → atualizar o prompt primeiro (`/spdd-prompt-update`), depois regenerar código
- **Refatoração** (estrutura/estilo, sem mudança de comportamento) → alterar o código diretamente, depois sincronizar de volta no Canvas (`/spdd-sync`)

---

## 3 Habilidades Essenciais

1. **Abstraction First** — desenhar relacionamentos, fronteiras e colaborações entre objetos *antes* de gerar código
2. **Alignment** — travar explicitamente intenção e restrições antes da implementação (o que vai e o que não vai ser feito)
3. **Iterative Review** — ciclos disciplinados de revisão e iteração; sem isso o time perde controle de tempo e custo

---

## Onde SPDD se encaixa

| Contexto | Adequação |
|----------|-----------|
| Entrega padronizada em escala | ★★★★★ |
| Ambientes de alta conformidade | ★★★★★ |
| Time com múltiplas pessoas + auditabilidade | ★★★★☆ |
| Refatoração cross-cutting | ★★★★☆ |
| Firefighting em produção | ★★☆☆☆ |
| Spikes exploratórios | ★★☆☆☆ |
| Scripts one-off | ★★☆☆☆ |
| Domínios mal definidos | ★☆☆☆☆ |
| Trabalho criativo/visual | ★☆☆☆☆ |

---

## Diferença em relação a Spec-Driven Development

SPDD vai além porque:
- O prompt é um **artefato vivo**, evoluído junto com o código — não um documento gerado uma vez
- Captura não só *o que* o sistema faz, mas *como*, *com quais padrões* e *com quais fronteiras*
- **Sincronização bidirecional**: mudanças em requisitos atualizam o prompt; refatorações no código sincronizam de volta a documentação
- Cria controle de equipe **repetível** em vez de uma especificação pontual

---

## ROI

**Benefícios:**
- Determinismo: specs precisas reduzem alucinações do LLM
- Rastreabilidade imediata: toda mudança linkada à intenção estruturada
- Revisões mais rápidas: código chega mais próximo dos padrões
- Evolução mais segura: fronteiras bem definidas = menor risco de mudança

**Investimentos:**
- Mudança de mentalidade para design-first
- Expertise sênior para traduzir regras de negócio em abstrações
- Setup de tooling (ferramenta open-source: `openspdd` CLI)

---

## Citação final

> *"In the AI era, software development isn't a contest of model IQ. It's a contest of engineer cognitive bandwidth – how clearly we can think, frame problems, and make decisions."*
