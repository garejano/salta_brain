

-- Filtros (substitua pelos seus valores):
-- set @HashAnoLetivo = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
-- set @HashRede      = 'yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy'; -- opcional
-- set @HashEscola    = 'zzzzzzzz-zzzz-zzzz-zzzz-zzzzzzzzzzzz'; -- opcional
set @AnoLetivoId = 2025;
set @RedeId = 6;
set @EscolaId = 2025;


-- Titular com vaga
SELECT
  e.Nome as EscolaNome,
  r.hash       AS RedeHash,
  r.nome       AS RedeNome,
  s.hash       AS SerieHash,
  s.nome       AS SerieNome,
  t.hash       AS TurmaHash,
  t.nome       AS TurmaNome,
  d.hash       AS DisciplinaHash,
  d.nome       AS DisciplinaNome,
  pc.Vago,
  pc.QuantidadeTempos 
FROM folha.ProfessorCarga pc
JOIN Turma t                 ON t.id = pc.Turma 
JOIN EscolaSerie es          ON es.id = t.EscolaSerie 
JOIN Escola e                ON e.id = es.Escola
JOIN Rede r                  ON r.id = e.Rede
JOIN Serie s                 ON s.id = es.Serie
JOIN Disciplina d            ON d.id = pc.Disciplina 
WHERE es.AnoLetivo   = 2025
  AND (pc.DataSaida  IS NULL OR pc.SaidaTemporaria   = 1)
  AND pc.ProfessorPerfilVigente IS NULL
  AND pc.Vago = 1
  AND r.Id = 6;

UNION

-- Substituto com vaga

SELECT
  r.hash       AS RedeHash,
  r.nome       AS RedeNome,
  s.hash       AS SerieHash,
  s.nome       AS SerieNome,
  t.hash       AS TurmaHash,
  t.nome       AS TurmaNome,
  d.hash       AS DisciplinaHash,
  d.nome       AS DisciplinaNome,
  ps.Vago,
  pc.QuantidadeTempos
FROM folha.ProfessorCarga pc
JOIN folha.ProfessorCargaSubstituto ps ON ps.ProfessorCarga = pc.Id
JOIN Turma t                 ON t.id = pc.Turma
JOIN EscolaSerie es          ON es.id = t.EscolaSerie
JOIN Escola e                ON e.id = es.Escola
JOIN Rede r                  ON r.id = e.Rede
JOIN Serie s                 ON s.id = es.Serie
JOIN Disciplina d            ON d.id = pc.Disciplina
WHERE es.AnoLetivo = 2025
  AND ps.DataSaida IS NULL
  AND ps.ProfessorPerfilVigente IS NULL
  AND ps.Vago = 1
  AND r.Id = 6