SELECT
    r.Nome                    AS Rede,
    e.Nome                    AS Escola,
    se.Nome                   AS Serie,
    t.Nome                    AS Turma,
    d.Nome                    AS Disciplina,
    p.Nome                    AS Professor,
    p.CPF                     AS CPF,
    ROUND(SUM(pc.QuantidadeTempos), 2) AS QuantidadeTempos,
    pc.DataEntrada,
    pc.DataSaida
FROM folha.ProfessorCarga pc
INNER JOIN ProfessorPerfilVigente ppv
    ON ppv.Id = pc.ProfessorPerfilVigente
INNER JOIN Pessoa p
    ON p.Id = ppv.Pessoa
INNER JOIN Turma t
    ON t.Id = pc.Turma
INNER JOIN EscolaSerie es
    ON es.Id = t.EscolaSerie
INNER JOIN Serie se
    ON se.Id = es.Serie
INNER JOIN Escola e
    ON e.Id = es.Escola
INNER JOIN Rede r
    ON r.Id = e.Rede
INNER JOIN Disciplina d
    ON d.Id = pc.Disciplina
WHERE pc.Ativo = 1
  AND (pc.DataSaida IS NULL OR pc.SaidaTemporaria = 1)
GROUP BY
    r.Nome,
    e.Nome,
    se.Nome,
    t.Nome,
    d.Nome,
    p.Nome,
    p.CPF,
    pc.DataEntrada,
    pc.DataSaida
ORDER BY
    r.Nome,
    e.Nome,
    se.Nome,
    t.Nome,
    d.Nome,
    p.Nome;