-- Para refazer a carga se necessário:
DELETE FROM Folha.ProfessorCarga;

INSERT INTO Folha.ProfessorCarga (
 ProfessorPerfilVigente,
 Turma,
 Disciplina,
 QuantidadeTempos,
 DataEntrada,
 DataSaida,
 MotivoAlteracao,
 Vago,
 PessoaLancamentoEntrada,
 DataLancamentoEntrada,
 PessoaLancamentoSaida,
 DataLancamentoSaida,
 Aprovado,
 PessoaAprovacao,
 DataAprovacao,
 Ativo,
 UsuarioInclusao,
 DataInclusao,
 UsuarioUltimaAlteracao,
 DataUltimaAlteracao
)
SELECT x.ProfessorPerfilVigente,
       x.Turma,
       x.Disciplina,
       x.QuantidadeTempos,
       x.DataEntrada,
       x.DataSaida,
       x.MotivoAlteracao,
       x.Vago,
       x.PessoaLancamentoEntrada,
       x.DataLancamentoEntrada,
       x.PessoaLancamentoSaida,
       x.DataLancamentoSaida,
       x.Aprovado,
       x.PessoaAprovacao,
       x.DataAprovacao,
       x.Ativo,
       x.UsuarioInclusao,
       x.DataInclusao,
       x.UsuarioUltimaAlteracao,
       x.DataUltimaAlteracao
FROM (
 SELECT rel.ProfessorPerfilVigente,
        rel.Turma,
        rel.DisciplinaFolha AS Disciplina,
        rel.QuantidadeTempos,
        rel.DataEntrada,
        rel.DataSaida,
        rel.MotivoAlteracao,
        CASE WHEN rel.ProfessorPerfilVigente IS null THEN 1 ELSE 0 END AS Vago,
        UE.Pessoa AS PessoaLancamentoEntrada,
        rel.DataInclusaoEntrada AS DataLancamentoEntrada,
        US.Pessoa AS PessoaLancamentoSaida,
        rel.DataInclusaoSaida AS DataLancamentoSaida,
        1 AS Aprovado,
        UE.Pessoa AS PessoaAprovacao,
        rel.DataInclusaoEntrada AS DataAprovacao,
        1 AS Ativo,
        UE.Id AS UsuarioInclusao,
        rel.DataInclusaoEntrada AS DataInclusao,
        US.Id AS UsuarioUltimaAlteracao,
        rel.DataInclusaoSaida AS DataUltimaAlteracao,
        -- Não pegar lançamentos repetidos, devido ao congelamento mensal do relatório
        row_number() OVER(PARTITION BY rel.Turma, rel.DisciplinaFolha, rel.ProfessorPerfilVigente, rel.DataEntrada
                           ORDER BY rel.Id DESC
                          ) AS Ordem
 FROM rel.FolhaProfessorPorPeriodo AS rel
 INNER JOIN Folha.Disciplina AS FDi ON FDi.Id = rel.DisciplinaFolha -- Join para garantir que a disciplina ainda existe, pois a tabela de relatório não tem FK
 INNER JOIN Usuario AS UE ON UE.Id = rel.UsuarioInclusaoEntrada
 LEFT JOIN Usuario AS US ON US.Id = rel.UsuarioInclusaoSaida
) AS x
WHERE x.Ordem = 1;