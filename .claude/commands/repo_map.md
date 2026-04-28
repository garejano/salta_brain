# Skill: repo_map

## Descrição

Percorre `c:/projects/`, coleta metadados de cada repositório e (re)gera `repository_map.md` na raiz do `salta_brain`.

O objetivo principal do mapa é **ajudar a IA a identificar em qual repositório um card Jira deve ser implementado** — por isso cada entrada deve conter: stack tecnológica, responsabilidade funcional e palavras-chave típicas que podem aparecer em descrições de cards.

---

## Uso

```
/repo_map          → escaneia todos os repos e regenera repository_map.md
/repo_map <nome>   → atualiza apenas a entrada de um repositório específico
```

---

## Execução Passo a Passo

### 1. Listar repositórios

Usar `Glob` ou `Bash` para listar subdiretórios de `c:/projects/`. Ignorar:
- `salta_brain` (este repositório)
- Arquivos soltos (ex: `*.py`)

### 2. Para cada repositório — coletar metadados

Ler os seguintes arquivos (quando existirem):

| Arquivo | O que extrair |
|---------|---------------|
| `README.md` | Descrição, propósito, instruções de setup |
| `package.json` | `name`, `description`, scripts principais, dependências-chave |
| `**/*.csproj` (primeiro encontrado) | Nome do projeto, target framework |
| `**/*.sln` (primeiro encontrado) | Nome da solution |
| `.git/config` | URL do remote `origin` |
| Estrutura de pastas (1 nível) | Inferir arquitetura (ex: `src/`, `Controllers/`, `app/`, `pages/`) |
| `.claude/commands/` (se existir) | Listar os arquivos `.md` — são skills/comandos disponíveis naquele repo |

### 3. Inferir e documentar

Para cada repo, sintetizar:

- **Stack:** linguagem(ns) principal(is) e frameworks (ex: `.NET 6 + NHibernate`, `React + Knockout.js`, `Python`)
- **Responsabilidade:** o que o sistema faz em uma frase
- **Palavras-chave de cards:** termos que aparecem em descrições de cards Jira e apontam para este repo (ex: `Configurador`, `Boletim`, `AlocacaoProfessores`, `Filtro`)
- **Comando de build/run** (se encontrado no README ou scripts do package.json)
- **Skills disponíveis:** listar os nomes dos arquivos em `.claude/commands/` (sem extensão), ou omitir o campo se a pasta não existir

### 4. Gravar `repository_map.md`

Usar o template da **Seção "Template de Saída"**. Sobrescrever sem pedir confirmação (é sempre um snapshot gerado).

### 5. Exibir resumo

```
✔ atlas                  → atualizado
✔ estrutura-pedagogica   → atualizado
✔ portal-atlas           → atualizado
...
Total: N repositórios mapeados.
```

---

## Template de Saída — `repository_map.md`

```markdown
# Repository Map

> Gerado em: <data e hora>  
> Base: `c:/projects/`

---

## <nome-do-repositório>

**Stack:** <ex: .NET 8 · NHibernate · SQL Server>  
**Responsabilidade:** <uma frase descrevendo o que o sistema faz>  
**Palavras-chave de cards:** <termos que em cards Jira indicam este repo>  
**Remote:** <URL do git remote origin, ou "não configurado">  
**Run/Build:** `<comando>` *(se encontrado)*  
**Skills:** `skill-a`, `skill-b` *(omitir se `.claude/commands/` não existir)*

<parágrafo opcional com contexto adicional relevante para IA>

---
```

Repetir uma seção `---` por repositório, ordenados alfabeticamente.

---

## Regras

- Nunca escrever no Jira nem em outros repositórios além do `salta_brain`.
- Não incluir o próprio `salta_brain` no mapa.
- Se um repositório não tiver nenhum arquivo reconhecível, registrá-lo com `Stack: desconhecida` e `Responsabilidade: não documentada`.
- Manter linguagem técnica e objetiva — o leitor principal é uma IA tentando encontrar onde implementar um card.
