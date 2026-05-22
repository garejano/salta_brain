# Caso B — Com db_map (arquivos pré-gerados)

## Regras deste caso

- **Proibido** usar qualquer tool do MCP `sqlserver`
- Usar exclusivamente os arquivos de `_pde/db_map/`
- Registrar cada arquivo lido

## Processo esperado

1. Ler `_pde/db_map/domains/frequencia.md` para entender o domínio
2. Ler `_pde/db_map/schema/joins.yaml` para obter o caminho de join pronto
3. Se precisar de colunas específicas: ler `_pde/db_map/schema/tables.yaml`
4. Compor a query com base no contexto carregado

## Arquivos disponíveis

| Arquivo | Conteúdo |
|---------|----------|
| `_pde/db_map/domains/frequencia.md` | Conceitos, fluxo e tabelas do domínio |
| `_pde/db_map/domains/academico.md` | Contexto de Aluno, Turma, Matrícula |
| `_pde/db_map/schema/joins.yaml` | Caminhos de join detectados automaticamente |
| `_pde/db_map/schema/tables.yaml` | Todas as tabelas com PKs e colunas importantes |
| `_pde/db_map/diagrams/erd-frequencia.mmd` | Grafo visual do domínio |

## Checkpoint de registro

Ao final, anotar em `resultados.md`:
- Quais arquivos foram lidos (um por linha)
- Total de arquivos lidos
- Estimativa de bytes lidos (soma dos tamanhos)
- A query resultante
- Se os joins estão corretos
