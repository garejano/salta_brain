# salta_brain — Contexto do Projeto

Este repositório é o **segundo cérebro** de trabalho dentro da empresa Salta. É um workspace pessoal de conhecimento, não um projeto de software deployável.

## Sobre o usuário

Desenvolvedor full-stack na Salta. Trabalha principalmente nos repositórios listados em `repository_map.md`.

## Estrutura do repositório

```
cards/           # Um diretório por card Jira (EFC-xxx/). Criado e atualizado pelo /jira_sync.
_EFC-xxx/        # Diretórios legados com anotações manuais de cards (preservar — não sobrescrever).
_scripts/        # Scripts gerados ou sugeridos durante conversas.
_archive/        # Arquivos arquivados / histórico.
frontend-maps/   # Mapas de frontends Angular gerados pelo /scan-frontend.
                 #   changelog.md → data do último scan por repositório.
                 #   <repo>-angular-map.md → estrutura comprimida do frontend (componentes, services, rotas, NgRx).
_pde/db_map/     # Mapa do banco de dados gerado por _scripts/db_map/run_all.py.
                 #   changelog.md → data da última extração.
                 #   schema/ → tables.yaml, relations.yaml, joins.yaml
                 #   domains/ → frequencia.md, avaliacao.md, academico.md, acesso.md
                 #   diagrams/ → erd.mmd e erd-<domínio>.mmd
repository_map.md  # Guia de repositórios em c:/projects/ — usado pela IA para localizar código.
```

## Regras para a IA

- **Scripts:** sempre que sugerir ou gerar um script, salvá-lo em `_scripts/<nome_do_script>`.
- **Cards Jira:** os arquivos em `cards/EFC-xxx/` são gerados pelo `/jira_sync` a partir do Jira (fonte de verdade). Nunca escrever de volta para o Jira.
- **Pastas com underscore** (`_EFC-xxx/`): contêm anotações manuais — preservar sempre, nunca sobrescrever sem confirmação explícita.

## Repositórios de código

- Caminho base: `c:/projects/`
- Detalhes de cada repositório: `repository_map.md`
- O `repository_map.md` serve como guia para a IA identificar em qual repositório uma descrição de card Jira deve ser implementada — incluindo stack, responsabilidade e palavras-chave típicas de cada repo.

## Comandos disponíveis

| Comando | Descrição |
|---------|-----------|
| `/jira_sync` | Sincroniza cards abertos do Jira para `cards/` |
| `/repo_map` | Percorre `c:/projects/` e (re)gera `repository_map.md` |
| `/scan-frontend <path>` | Escaneia um projeto Angular com ts-morph e gera mapa em `frontend-maps/`. Atualiza `changelog.md` e `repository_map.md`. Ver `skill_scan_frontend.md` para detalhes. |

## db_map — mapa do banco para a IA

O MCP `sqlserver` permite explorar o schema ao vivo, mas é caro em tokens. O pipeline correto é:

```
Banco (ElevaPortalHomolog) → _scripts/db_map/run_all.py → _pde/db_map/ → IA
```

**Conexão:** mesmos parâmetros do MCP — lidos automaticamente de `%APPDATA%\Claude\claude_desktop_config.json`.  
Servidor: `belerofonte.eleva.local` | Banco: `ElevaPortalHomolog` | Usuário: `mcp.readonly`

**Quando usar o db_map (em vez do MCP ao vivo):**

1. Checar `_pde/db_map/changelog.md` — se a extração for < 30 dias, carregar os arquivos relevantes.
2. Para queries em um domínio: `domains/<dominio>.md` + `schema/joins.yaml`.
3. Para queries cross-domínio: `schema/tables.yaml` + `schema/relations.yaml`.
4. Usar MCP ao vivo apenas para dados dinâmicos (contagens, exemplos de valor).

**Para gerar/atualizar o db_map:**
```powershell
pip install pyodbc pyyaml   # apenas na primeira vez
cd _scripts/db_map
python run_all.py
```

## Schema do banco (ElevaPortalHomolog) — curiosidades

- **`AlunoEscola.AlunoEscola_key`** é FK para `PessoaEscolaAcesso.Id`, **não** para `Pessoa.Id`.  
  Para obter o hash do aluno: `AlunoEscola_key → PessoaEscolaAcesso.Id → PessoaEscolaAcesso.PessoaEscola → PessoaEscola.Pessoa → Pessoa.Hash`.
- **`AnoLetivo.Id`** = o próprio ano (ex: `2026`). O campo `Vigente = 1` indica o ano letivo corrente.  
  `AlunoEscola.AnoLetivo` armazena diretamente esse valor numérico (ex: `2026`).
- Tabelas sem sufixo `Id` nas FKs: `Turma.EscolaSerie`, `EscolaSerie.Escola`, `Escola.Rede`, `EscolaSerie.Serie`, `EscolaSerie.AnoLetivo` — todas são IDs diretos, sem o sufixo convencional.

## Frontend maps

Quando for ajudar com código de um frontend Angular:

1. Verificar se existe `frontend-maps/<repo>-angular-map.md`
2. Checar `frontend-maps/changelog.md` — se o mapa tiver mais de 30 dias, sugerir `/scan-frontend`
3. Carregar o mapa **antes** de explorar arquivos individuais — evita gastar contexto em leitura de diretórios
