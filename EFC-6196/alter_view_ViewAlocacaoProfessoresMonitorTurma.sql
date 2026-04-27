ALTER VIEW [dbo].[ViewAlocacaoProfessoresMonitorTurma] AS
WITH ProfessoresOuMonitores AS
(
 SELECT monitor.Id
      , monitor.Turma
      , monitor.Disciplina
      , monitor.Ativo
      , monitor.NaoPossuiAula
      , monitor.PessoaEscolaAcesso
      , MoEsAc.PessoaEscola
      , 1 AS Monitor
      , monitor.DataInclusao
      , monitor.UsuarioInclusao
 FROM MonitorTurmaDisciplina  AS monitor
 LEFT JOIN PessoaEscolaAcesso AS MoEsAc ON MoEsAc.Id    = monitor.PessoaEscolaAcesso
                                       AND MoEsac.Ativo = monitor.Ativo
 WHERE monitor.Ativo = 1
  AND (monitor.NaoPossuiAula = 1 OR MoEsAc.Id IS NOT null)
 UNION
 SELECT professor.Id
      , professor.Turma
      , professor.Disciplina
      , professor.Ativo
      , professor.NaoPossuiAula
      , professor.PessoaEscolaAcesso
      , PrEsAc.PessoaEscola
      , 0 AS Monitor
      , professor.DataInclusao
      , professor.UsuarioInclusao

 FROM ProfessorTurmaDisciplina AS professor
 LEFT JOIN PessoaEscolaAcesso  AS PrEsAc ON PrEsAc.Id    = professor.PessoaEscolaAcesso
                                        AND PrEsAc.Ativo = professor.Ativo
 WHERE professor.Ativo = 1
  AND (professor.NaoPossuiAula = 1 OR PrEsAc.Id IS NOT null)
)
SELECT NewId() AS Id
     , Re.Id AS IdRede
     , Re.[Hash] AS HashRede
     , Re.Nome AS NomeRede
     , EsSe.AnoLetivo AS IdAnoLetivo
     , EsSe.Agrupamento AS IdAgrupamento
     , Es.Id AS IdEscola
     , Es.[Hash] AS HashEscola
     , Es.Nome AS NomeEscola
     , Se.Id AS IdSerie
     , Se.[Hash] AS HashSerie
     , Se.Nome AS NomeSerie
     , Tu.Id AS IdTurma
     , Tu.Nome AS NomeTurma
     , Tu.PossuiClassroom
     , Tu.HerdaClassroomAnoAnterior AS TurmaHerdaClassroomAnoAnterior
     , Di.Id AS IdDisciplina
     , Di.[Hash] AS HashDisciplina
     , Di.Nome AS NomeDisciplina
     , IsNull(PeEsAc.Id, 0) AS IdPessoaEscolaAcesso
     , IsNull(Pe.Nome, '') AS NomePessoa
     , IsNull(PeEsAc.PerfilAcesso, 0) AS PerfilAcesso
     , IsNull(PrTuDi.NaoPossuiAula, 0) AS NaoPossuiAula
     , IsNull(ReSeDi.PermiteClassroom, 0) AS RedeSerieDisciplinaPermiteClassroom
     , IsNull(ReSeDi.HerdaClassroomAnoAnterior, 0) AS RedeSerieDisciplinaHerdaClassroomAnoAnterior
     , TuCl.Id AS IdTurmaClassroom
     , TuCl.ClassroomOwnerId
     , TuCl.ClassroomCourseId
     , TuCl.[Hash] AS HashTurmaClassroom
     , TuClA.[Hash] AS HashTurmaClassroomAnoAnterior
     , Us.Email
     , Lower(PeReEm.Email) AS EmailCorporativo
     , IsNull(PeReEm.PermiteClassroom, 0) AS PessoaRedeEmailPermiteClassroom
     , CASE WHEN IsNull(Tu.HerdaClassroomAnoAnterior, 0) = 0 THEN 1 --Turmas sem herança (padrão)
            WHEN IsNull(Tu.HerdaClassroomAnoAnterior, 0) = 1 AND TuCl.ClassroomCourseId IS NOT NULL THEN 1 --Turmas com herança, e já associadas
            WHEN IsNull(Tu.HerdaClassroomAnoAnterior, 0) = 1 AND TuCl.ClassroomCourseId IS NULL THEN 0 --Turmas com herança, mas NÃO associadas
       END AS ProntaParaSincronismoClassroom
     , PrTuDi.Monitor
     , PrTuDi.DataInclusao        AS DataInclusao
     , ISNULL(PeUsuario.Nome, '') AS NomeUsuarioInclusao
FROM       Rede                  AS Re
INNER JOIN Escola                AS Es     ON Es.Rede = Re.Id
INNER JOIN EscolaSerie           AS EsSe   ON EsSe.Escola = Es.Id
                                          AND EsSe.Ativo = 1
INNER JOIN Serie                 AS Se     ON Se.Id = EsSe.Serie
INNER JOIN Turma                 AS Tu     ON Tu.EscolaSerie = EsSe.Id
                                          AND Tu.PossuiAlocacaoProfessor = 1
                                          AND Tu.Ativo = 1
INNER JOIN EscolaSerieDisciplina AS EsSeDi ON EsSeDi.EscolaSerie = EsSe.Id
                                          AND EsSeDi.Ativo = 1
INNER JOIN Disciplina            AS Di     ON Di.Id = EsSeDi.Disciplina
LEFT JOIN TurmaEscolaSerieDisciplina AS TuEsSeDi ON TuEsSeDi.Turma = Tu.Id
                                                AND TuEsSeDi.EscolaSerieDisciplina = EsSeDi.Id
                                                AND TuEsSeDi.Ativo = 1
LEFT JOIN RedeSerie AS ReSe ON ReSe.Rede = Re.Id
                           AND ReSe.Serie = Se.Id
                           AND ReSe.AnoLetivo = EsSe.AnoLetivo
                           AND ReSe.Ativo = 1
LEFT JOIN RedeSerieDisciplina AS ReSeDi ON ReSeDi.RedeSerie = ReSe.Id
                                       AND ReSeDi.Disciplina = Di.DisciplinaMae
                                       AND ReSeDi.Ativo = 1
LEFT JOIN Google.TurmaClassroom AS TuCl ON TuCl.Turma = Tu.Id
                                       AND TuCl.Disciplina = Di.Id
                                       AND TuCl.Ativo = 1
LEFT JOIN Google.TurmaClassroom AS TuClA ON TuClA.Id = Tu.TurmaClassroomAnoAnterior
LEFT JOIN (
 SELECT EsSeDi.EscolaSerie
      , Di.DisciplinaMae
      , Di.Id AS Disciplina
 FROM Disciplina AS Di
 INNER JOIN EscolaSerieDisciplina AS EsSeDi ON EsSeDi.Disciplina = Di.Id
 WHERE EsSeDi.Ativo = 1
) AS Filhos ON Filhos.EscolaSerie = EsSe.Id
           AND Filhos.DisciplinaMae = Di.Id
           AND Filhos.Disciplina <> Filhos.DisciplinaMae
LEFT JOIN ProfessoresOuMonitores AS PrTuDi ON PrTuDi.Turma = Tu.Id
                                          AND PrTuDi.Disciplina = EsSeDi.Disciplina
LEFT JOIN PessoaEscolaAcesso AS PeEsAc ON PeEsAc.Id = PrTuDi.PessoaEscolaAcesso
LEFT JOIN PessoaEscola AS PeEs ON PeEs.Id = PeEsAc.PessoaEscola
LEFT JOIN Pessoa AS Pe ON Pe.Id = PeEs.Pessoa
LEFT JOIN Usuario AS Us ON Us.Pessoa = PeEs.Pessoa
                       AND Us.Ativo = 1
LEFT JOIN (
 SELECT DISTINCT Pessoa,Rede, email, PermiteClassroom
 FROM PessoaRedeEmail
 WHERE ContaEhCorporativa = 1 and Ativo = 1
) AS PeReEm ON PeReEm.Pessoa = PeEs.Pessoa
           AND PeReEm.Rede = Re.Id
LEFT JOIN Pessoa AS PeUsuario ON PeUsuario.Id = PrTuDi.UsuarioInclusao
WHERE (Re.TipoRede <> 2 OR ReSeDi.Id IS NOT null)
  AND Di.Escola IS NULL
  AND Filhos.Disciplina IS NULL
  AND (TuEsSeDi.Id IS NOT NULL OR Re.Id NOT IN (7,40,42));
