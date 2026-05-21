SELECT
   a.AlunoEscolaId,
   p.Nome AS NomeAluno,
   a.Matricula,
   t.Id AS TurmaId,
   t.Nome AS NomeTurma,
   s.Id AS SerieId,
   s.Nome AS NomeSerie,
   d.Id AS DisciplinaId,
   d.Nome AS NomeDisciplina,
   dm.Id AS DisciplinaMaeId,
   dm.Nome AS NomeDisciplinaMae
FROM AlunoEscola a
JOIN PessoaEscolaAcesso pea ON pea.Id = a.PessoaEscolaAcessoId
JOIN Pessoa p ON p.Id = pea.PessoaId
JOIN Turma t ON t.Id = a.TurmaId
JOIN EscolaSerie es ON es.Id = t.EscolaSerieId
JOIN Serie s ON s.Id = es.SerieId
-- Disciplinas ofertadas para a série daquela escola
JOIN EscolaSerieDisciplina esd ON esd.EscolaSerieId = es.Id
JOIN Disciplina d ON d.Id = esd.DisciplinaId
JOIN Disciplina dm ON dm.Id = d.DisciplinaMaeId
WHERE t.Hash = @HashTurma
  AND d.Rede = @RedeId
  -- (Filtros adicionais conforme necessidade)
ORDER BY p.Nome, d.Nome;


select * from AlunoEscola ae;

select * from Turma t where t.Hash = '68399769-3e39-4492-a7ca-8d4003c442b2';

select * from AlunoEscola ae
inner join Turma t on t.Id = ae.Turma 
where t.Hash = '68399769-3e39-4492-a7ca-8d4003c442b2';

--
JOIN PessoaEscolaAcesso pea ON pea.Id = a.
JOIN Pessoa p ON p.Id = pea.PessoaId
JOIN Turma t ON t.Id = a.TurmaId
WHERE t.Hash = '68399769-3e39-4492-a7ca-8d4003c442b2';