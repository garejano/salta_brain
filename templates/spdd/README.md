# Templates SPDD

Baseado em: https://martinfowler.com/articles/structured-prompt-driven/

## O que é SPDD

**Structured-Prompt-Driven Development** trata prompts como artefatos de entrega — versionados, revisados e reutilizados. O objetivo é transformar assistência de IA de produtividade individual em capacidade organizacional.

**Regra fundamental:** quando a realidade diverge da intenção, corrija o prompt primeiro — depois atualize o código.

---

## Workflow e Templates

```
1. story.md          → Quebrar o requisito em user stories (INVEST)
2. analysis.md       → Extrair conceitos de domínio, riscos e direção estratégica
3. reasons-canvas.md → Gerar o blueprint executável (artefato principal)
4. [gerar código]    → Seguir o Canvas estritamente, sem improvisar
5. [gerar testes]    → Cobertura alinhada às Operations do Canvas
6. [revisar]         → Correção de lógica: atualizar Canvas → regenerar código
                       Refatoração: alterar código → sincronizar Canvas
```

---

## Quando usar SPDD

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

---

## Arquivos nesta pasta

| Arquivo | Etapa | Descrição |
|---------|-------|-----------|
| `story.md` | 1 | Template de user stories INVEST |
| `analysis.md` | 2 | Template de análise de domínio |
| `reasons-canvas.md` | 3 | Canvas REASONS — artefato principal |
