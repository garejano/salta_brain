# Tarefa do Benchmark

> Mesma tarefa executada nos dois casos (A e B).

## Pergunta

**Escreva uma query SQL que, dado um `id_turma` e um intervalo de datas (`@data_inicio`, `@data_fim`), retorne:**

| Coluna esperada | Descrição |
|----------------|-----------|
| nome_aluno | Nome completo do aluno |
| data_aula | Data em que a aula ocorreu |
| status_presenca | Se o aluno estava presente ou ausente |

## Critérios de qualidade

- [ ] Join correto entre as tabelas de frequência
- [ ] Caminho correto até o nome do aluno (sem confundir FKs)
- [ ] Filtro por turma e período aplicado
- [ ] Nomes de tabela e coluna batendo com o schema real

## Métricas coletadas por caso

| Métrica | Descrição |
|---------|-----------|
| tool_calls | Número de chamadas de ferramentas (MCP ou Read) |
| bytes_lidos | Total estimado de bytes recebidos nas respostas |
| sql_correto | Sim / Não / Parcial |
| joins_corretos | Sim / Não / Parcial |
| observacoes | Erros, ajustes, incertezas durante o processo |
