# Caso A — Sem db_map (MCP ao vivo)

## Regras deste caso

- **Proibido** ler qualquer arquivo de `_pde/db_map/`
- Explorar o schema exclusivamente via MCP `sqlserver`
- Registrar cada tool call realizada

## Processo esperado

1. Usar `list_tables` para identificar tabelas candidatas ao domínio de frequência
2. Usar `describe_table` nas tabelas candidatas para entender colunas
3. Usar `get_foreign_keys` para entender as relações
4. Compor a query com base no que foi descoberto
5. Opcional: `execute_query` para validar

## Checkpoint de registro

Ao final, anotar em `resultados.md`:
- Quantas vezes `list_tables` foi chamado
- Quantas vezes `describe_table` foi chamado
- Quantas vezes `get_foreign_keys` foi chamado
- Quantas vezes `execute_query` foi chamado
- Total de tool calls
- Estimativa de bytes recebidos (soma dos tamanhos das respostas)
- A query resultante
- Se os joins estão corretos
