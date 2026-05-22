# Resultados do Benchmark — db_map vs MCP ao vivo

Tarefa: query de frequência por turma e período — nome do aluno, data da aula, status de presença.  
Data: 2026-05-22

---

## Caso A — Sem db_map (MCP ao vivo)

### Tool calls

| Tool | Chamadas | Observação |
|------|----------|------------|
| `list_tables` | 1 | Retornou 152 KB — truncado, lido via grep |
| `describe_table` | 2 | **Ambas erraram** (bug do MCP: "Invalid column name 'dbo'") |
| `get_foreign_keys` | 3 | AulaEvento, AlunoFrequencia, AlunoFalta |
| `execute_query` | 11 | INFORMATION_SCHEMA, sys.columns, sys.foreign_keys, TOP 1 da view, sys.sql_modules |
| **Total** | **17** | |

### Volume de dados

| Origem | Tamanho estimado |
|--------|-----------------|
| `list_tables` (arquivo) | ~152 KB |
| `execute_query` × 11 | ~88 KB |
| `get_foreign_keys` × 3 | ~3 KB |
| **Total** | **~243 KB** |

### Resultado

**Caminho descoberto:** `AulaEvento.Turma` → Turma (FK confirmada). Mas a ligação `AulaEvento → aluno + presença` só existe em views com definição encriptada — tabelas base inacessíveis via introspecção.

**SQL gerado (melhor possível):**
```sql
-- Única saída viável: view (definição encriptada, join interno desconhecido)
SELECT
    NomeAluno,
    DataAula,
    NomeTipoPresenca AS status_presenca
FROM ViewChamadaPorAula
WHERE IdTurma    = @id_turma
  AND DataAula  >= @data_inicio
  AND DataAula  <= @data_fim
ORDER BY DataAula, NomeAluno
```

**Joins corretos?** Parcial — a view tem as colunas certas, mas não sabemos o join interno.  
**Observações:**
- `describe_table` não funciona (bug do driver MCP)
- 9 das 17 chamadas foram para exploração que não gerou resultado útil
- A view `ViewChamadaPorAula` foi descoberta por acidente ao listar views — não estava na rota original de investigação

---

## Caso B — Com db_map (arquivos pré-gerados)

### Arquivos lidos

| Arquivo | Tamanho | Utilidade |
|---------|---------|-----------|
| `domains/frequencia.md` | ~3 KB | Tabelas do domínio listadas ✓ — fluxo conceitual incorreto ✗ |
| `schema/joins.yaml` (grep + 2 reads) | ~11 KB lidos | Join paths encontrados mas todos via metadados (Turno, UsuarioInativacao) |
| `schema/tables.yaml` (grep) | ~1 KB | Colunas de AlunoAvaliacaoPresenca — tabela de avaliação, não aula |
| **Total** | **~15 KB** | |

### Resultado

**Caminho descoberto:** Lista de tabelas do domínio. Join paths gerados pelo BFS passam por colunas de metadados (`Turno`, `UsuarioInativacao`, `Disciplina`) — sem valor de negócio.

**SQL gerado:**
```sql
-- Não foi possível montar join confiável pelas tabelas brutas.
-- Melhor achado: mesmo que Caso A — usar ViewChamadaPorAula.
-- O db_map não forneceu caminho de join AulaEvento → Aluno → TipoPresenca.
```

**Joins corretos?** Não — db_map v1 não forneceu o caminho correto.  
**Observações:**
- O fluxo `Turma → Aula → EventoFrequencia → FrequenciaAluno` em `frequencia.md` foi hardcoded incorretamente — `EventoFrequencia` não existe como tabela
- O BFS gera caminhos por qualquer FK, inclusive `UsuarioInativacao` → `Usuario` → outras tabelas — ruído alto
- A tabela real de presença por aula é provável que esteja nas views encriptadas
- `AlunoFalta` registra faltas por `Pessoa + DataAula` (sem vínculo com `AulaEvento`)

---

## Comparativo

| Métrica | Caso A (MCP) | Caso B (db_map) | Vencedor |
|---------|-------------|----------------|----------|
| Tool calls / arquivos | 17 chamadas MCP | 4 arquivos (5 operações) | **B** (3.4× menos ops) |
| Bytes consumidos | ~243 KB | ~15 KB | **B** (16× menos dados) |
| Encontrou a view certa | Sim (`ViewChamadaPorAula`) | Não (não lista views) | **A** |
| Join path correto | Não (view encriptada) | Não (BFS com ruído) | Empate |
| SQL de negócio funcional | Parcial (usa view) | Não | **A** |
| Tempo de exploração | Alto (muitas tentativas) | Baixo (leitura direta) | **B** |

---

## Conclusão

**O db_map v1 reduz drasticamente o volume de dados e o número de operações, mas não entrega o join path correto para o domínio de frequência.**

A Caso A encontrou acidentalmente a view certa (`ViewChamadaPorAula`) durante a exploração — o db_map v1 não indexa views.

### Problemas identificados no db_map v1

| Problema | Impacto |
|---------|---------|
| `joins.yaml` gera caminhos por qualquer FK — inclui metadados (`UsuarioInativacao`, `DataInclusao`, `Turno`) | Alto — join paths inúteis para queries de negócio |
| `domains/frequencia.md` tem fluxo conceitual hardcoded incorreto | Médio — engana a IA sobre o modelo real |
| Views não são indexadas no db_map | Alto — `ViewChamadaPorAula` foi a saída mais útil do Caso A |
| `AlunoFalta` classificada em `academico` (keyword ALUNO) em vez de `frequencia` | Baixo |

### Próximas melhorias (db_map v2)

1. **Filtrar FKs de metadados no BFS** — ignorar colunas como `UsuarioInclusao`, `UsuarioUltimaAlteracao`, `UsuarioInativacao`, `DataInclusao`, `DataUltimaAlteracao` ao montar grafos de join
2. **Indexar views no db_map** — gerar `schema/views.yaml` com colunas das views principais
3. **Fluxos de domínio derivados do schema real** — não hardcoded; derivar dos join paths válidos
4. **Marcar "joins de negócio" vs "joins de auditoria"** — PKs e FKs não-auditoria como peso maior no BFS
