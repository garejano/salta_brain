Analise as mudanças de código da feature `$ARGUMENTS` e produza um documento de registro de mudanças detalhado.

## Passos de execução

### 1. Identifique os commits da feature

Se `$ARGUMENTS` for um ID de tarefa (ex.: `EFC-5976`):
```
git log --oneline --grep="$ARGUMENTS"
```

Se for um nome de branch (ex.: `feature/EFC-5976`):
```
git log <branch> --not main --oneline
```

Se nenhum argumento for passado, use o branch atual em relação ao branch base:
```
git log HEAD --not main --oneline
```

Liste todos os commits relevantes com data, hash curto e mensagem.

### 2. Para cada commit, colete as mudanças

```
git show <hash> --stat
git show <hash> -- <arquivo>   # para o diff de cada arquivo listado
```

Para mudanças ainda não commitadas (staged ou unstaged):
```
git diff HEAD
git diff --cached
```

### 3. Analise e escreva o documento

Produza o documento com a seguinte estrutura:

---

**Cabeçalho:** `# <FEATURE_ID> — Registro de Mudanças de Código`

Inclua uma frase resumindo o objetivo da feature.

---

**Tabela de commits:**

| Data | Hash | Descrição |
|---|---|---|
| YYYY-MM-DD | `hash` | Descrição |

---

**Seção por arquivo** (uma seção `###` por arquivo):

Para cada arquivo:
- Link clicável: `[caminho/arquivo.cs](caminho/arquivo.cs)`
- Commit(s) que o alteraram
- **Trecho adicionado/alterado** em bloco de código (antes/depois quando relevante; apenas o novo quando for adição pura)
- **Motivo:** parágrafo explicando *por que* a mudança foi necessária — o que havia de errado ou ausente antes, qual problema técnico existia, e como o trecho resolve

Agrupe arquivos de infraestrutura simples (entidades, NHibernate mappings, interfaces de repositório) quando o motivo for idêntico para todos.

Para arquivos com múltiplas iterações em commits diferentes, documente cada mudança em ordem cronológica com `#### Mudança N — descrição (hash)`.

---

**Tabela de bugs corrigidos** (seção `## Resumo dos bugs corrigidos`):

| # | Sintoma observado | Causa raiz | Arquivo(s) corrigido(s) | Commit |
|---|---|---|---|---|

Inclua apenas mudanças do tipo correção. Cada linha deve ter:
- **Sintoma:** o que o usuário via de errado (ex.: "Grid CF sempre vazio")
- **Causa raiz:** o motivo técnico preciso (ex.: "`ViewConfiguradorAvaliacao` retorna `HashDisciplina=null` para estruturas CF")
- **Arquivo(s):** arquivo(s) onde a correção foi aplicada
- **Commit:** hash do commit que corrigiu

---

### 4. Salve o documento

Salve como `<FEATURE_ID>_mudancas.md` no mesmo diretório onde os demais arquivos da feature estão armazenados, ou no diretório atual se não houver um padrão claro.

---

## Regras de qualidade

- **Priorize o MOTIVO sobre o O QUÊ.** O nome do arquivo e o diff já mostram o que mudou; o documento deve responder *por que* aquela mudança era necessária.
- Para bugs: descreva o sintoma observado, a causa raiz técnica, e como o trecho corrigido elimina a causa.
- Para novas funcionalidades: descreva o que estava faltando na arquitetura existente e como a adição se encaixa.
- Use blocos `csharp`, `javascript`, `html`, etc. para trechos de código.
- Use links clicáveis `[arquivo.cs](caminho/arquivo.cs#Lnn)` apontando para linhas específicas quando relevante.
- Não documente mudanças de formatação ou whitespace sem impacto funcional.
- Se um arquivo aparece em múltiplos commits com propósitos diferentes, trate cada mudança separadamente.
- Consulte mensagens de commit e comentários no código como fonte de contexto para inferir o motivo quando não for evidente pelo diff.
