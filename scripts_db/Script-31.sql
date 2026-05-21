select top 10 * from AlunoEscola ae where ae.Matricula = '23313977';

select * from Pessoa p where p.Id = 3575058;


SELECT TOP 5
    t.Id          AS TurmaId,
    t.Nome        AS NomeTurma,
    tturno.Id     AS TurnoTurmaId,
    tturno.Nome   AS TurnoTurma,
    ae.Id         AS AulaEventoId,
    ae.DataInicio,
    aeturno.Id    AS TurnoEventoId,
    aeturno.Nome  AS TurnoEvento,
    e.Nome        AS Escola,
    r.Nome        AS Rede
FROM dbo.AulaEvento ae
JOIN dbo.Turno      aeturno ON aeturno.Id = ae.Turno
JOIN dbo.Turma      t       ON t.Id       = ae.Turma       AND t.Ativo  = 1
JOIN dbo.Turno      tturno  ON tturno.Id  = t.Turno
JOIN dbo.EscolaSerie escser ON escser.Id  = t.EscolaSerie
JOIN dbo.Escola     e       ON e.Id       = escser.Escola  AND e.Ativo  = 1
JOIN dbo.Rede       r       ON r.Id       = e.Rede         AND r.Ativo  = 1
WHERE ae.Ativo          = 1
  AND ae.PossuiFrequencia = 1
  AND ae.Turno           <> t.Turno        -- turno do evento ≠ turno da turma
  AND ae.DataInicio      >= '2026-01-01'
ORDER BY ae.DataInicio DESC;
