# salta_brain — Contexto do Projeto

Este repositório é o **segundo cérebro** de trabalho dentro da empresa Salta. É um workspace pessoal de conhecimento, não um projeto de software deployável.

## Sobre o usuário

Desenvolvedor full-stack na Salta. Trabalha principalmente nos repositórios listados em `repository_map.md`.

## Estrutura do repositório

```
cards/          # Um diretório por card Jira (EFC-xxx/). Criado e atualizado pelo /jira_sync.
_EFC-xxx/       # Diretórios legados com anotações manuais de cards (preservar — não sobrescrever).
_scripts/       # Scripts gerados ou sugeridos durante conversas.
_archive/       # Arquivos arquivados / histórico.
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
