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
