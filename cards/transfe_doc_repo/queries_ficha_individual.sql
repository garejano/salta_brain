-- Queries para busca de dados de teste da FichaIndividual
-- Banco: ElevaPortalHomolog
-- Geradas em: 2026-05-22
--
-- SCHEMA IMPORTANTE:
--   AlunoEscola.AlunoEscola_key  -> FK para PessoaEscolaAcesso.Id (NÃO é Pessoa.Id)
--   AnoLetivo.Id                 -> o próprio ano numérico (ex: 2025, 2026)
--   AnoLetivo.Vigente = 1        -> ano letivo corrente
--   FKs sem sufixo Id: Turma.EscolaSerie, EscolaSerie.Escola, Escola.Rede, etc.
--
-- JOIN BASE (Aluno → Turma → Escola → Rede):
--   AlunoEscola ae
--   INNER JOIN PessoaEscolaAcesso pea ON pea.Id = ae.AlunoEscola_key
--   INNER JOIN PessoaEscola pe       ON pe.Id = pea.PessoaEscola
--   INNER JOIN Pessoa p              ON p.Id = pe.Pessoa
--   INNER JOIN Turma t               ON t.Id = ae.Turma
--   INNER JOIN EscolaSerie es        ON es.Id = t.EscolaSerie
--   INNER JOIN Escola e              ON e.Id = es.Escola
--   INNER JOIN Rede r                ON r.Id = e.Rede


-- ===========================================================================
-- 1. Alunos matriculados em um ano letivo específico
-- ===========================================================================
SELECT TOP 10
    p.Hash AS HashUsuario,
    p.Nome AS NomeAluno,
    t.Hash AS HashTurma,
    t.Nome AS NomeTurma,
    r.Hash AS HashRede,
    r.Nome AS NomeRede,
    e.Nome AS NomeEscola
FROM dbo.AlunoEscola ae
INNER JOIN dbo.PessoaEscolaAcesso pea ON pea.Id = ae.AlunoEscola_key
INNER JOIN dbo.PessoaEscola pe ON pe.Id = pea.PessoaEscola
INNER JOIN dbo.Pessoa p ON p.Id = pe.Pessoa
INNER JOIN dbo.Turma t ON t.Id = ae.Turma
INNER JOIN dbo.EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN dbo.Escola e ON e.Id = es.Escola
INNER JOIN dbo.Rede r ON r.Id = e.Rede
WHERE ae.Status = 'Matriculado'
  AND ae.AnoLetivo = 2025   -- trocar pelo ano desejado
  AND t.Ativo = 1
ORDER BY r.Nome, e.Nome, t.Nome;


-- ===========================================================================
-- 2. Alunos com status específico (Aprovado, Reprovado, Em recuperação)
--    No homolog: Aprovado e Reprovado só existem em AnoLetivo = 2022
-- ===========================================================================
SELECT TOP 10
    p.Hash AS HashUsuario,
    p.Nome AS NomeAluno,
    t.Hash AS HashTurma,
    t.Nome AS NomeTurma,
    r.Hash AS HashRede,
    r.Nome AS NomeRede,
    e.Nome AS NomeEscola,
    ae.Status,
    ae.AnoLetivo
FROM dbo.AlunoEscola ae
INNER JOIN dbo.PessoaEscolaAcesso pea ON pea.Id = ae.AlunoEscola_key
INNER JOIN dbo.PessoaEscola pe ON pe.Id = pea.PessoaEscola
INNER JOIN dbo.Pessoa p ON p.Id = pe.Pessoa
INNER JOIN dbo.Turma t ON t.Id = ae.Turma
INNER JOIN dbo.EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN dbo.Escola e ON e.Id = es.Escola
INNER JOIN dbo.Rede r ON r.Id = e.Rede
WHERE ae.Status IN ('Aprovado', 'Reprovado', 'Em recuperação')
  -- AND ae.AnoLetivo = 2022
ORDER BY ae.Status, r.Nome, e.Nome;


-- ===========================================================================
-- 3. Distribuição de Status por AnoLetivo (auditoria)
-- ===========================================================================
SELECT ae.AnoLetivo, ae.Status, COUNT(*) AS Qtd
FROM dbo.AlunoEscola ae
GROUP BY ae.AnoLetivo, ae.Status
ORDER BY ae.AnoLetivo DESC, Qtd DESC;


-- ===========================================================================
-- 4. Turmas com maior número de disciplinas (para teste de grade grande)
--    Usa ProfessorTurmaDisciplina — muito mais rápido que AlunoNota
-- ===========================================================================
SELECT TOP 15
    t.Hash AS HashTurma,
    t.Nome AS NomeTurma,
    r.Hash AS HashRede,
    r.Nome AS NomeRede,
    e.Nome AS NomeEscola,
    COUNT(DISTINCT ptd.Disciplina) AS QtdDisciplinas
FROM dbo.ProfessorTurmaDisciplina ptd
INNER JOIN dbo.Turma t ON t.Id = ptd.Turma
INNER JOIN dbo.EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN dbo.Escola e ON e.Id = es.Escola
INNER JOIN dbo.Rede r ON r.Id = e.Rede
WHERE ptd.Ativo = 1
  AND es.AnoLetivo = 2025   -- trocar pelo ano desejado
GROUP BY t.Hash, t.Nome, r.Hash, r.Nome, e.Nome
HAVING COUNT(DISTINCT ptd.Disciplina) >= 12
ORDER BY QtdDisciplinas DESC;


-- ===========================================================================
-- 5. Alunos de uma turma específica (usar após encontrar a turma no item 4)
-- ===========================================================================
SELECT TOP 10
    p.Hash AS HashUsuario,
    p.Nome AS NomeAluno,
    t.Hash AS HashTurma,
    t.Nome AS NomeTurma,
    r.Hash AS HashRede,
    r.Nome AS NomeRede,
    e.Nome AS NomeEscola
FROM dbo.AlunoEscola ae
INNER JOIN dbo.PessoaEscolaAcesso pea ON pea.Id = ae.AlunoEscola_key
INNER JOIN dbo.PessoaEscola pe ON pe.Id = pea.PessoaEscola
INNER JOIN dbo.Pessoa p ON p.Id = pe.Pessoa
INNER JOIN dbo.Turma t ON t.Id = ae.Turma
INNER JOIN dbo.EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN dbo.Escola e ON e.Id = es.Escola
INNER JOIN dbo.Rede r ON r.Id = e.Rede
WHERE t.Hash = 'EF5AAF35-A83E-4C4D-853A-B9D14BC6DF90'  -- substituir pelo HashTurma desejado
ORDER BY p.Nome;


-- ===========================================================================
-- 6. Alunos com observações preenchidas no histórico
-- ===========================================================================
SELECT TOP 10
    p.Hash AS HashUsuario,
    p.Nome AS NomeAluno,
    t.Hash AS HashTurma,
    t.Nome AS NomeTurma,
    r.Hash AS HashRede,
    r.Nome AS NomeRede,
    e.Nome AS NomeEscola,
    hh.Observacao AS ObservacoesAluno
FROM dbo.HisHistorico hh
INNER JOIN dbo.Pessoa p ON p.Id = hh.Pessoa
INNER JOIN dbo.PessoaEscola pe ON pe.Pessoa = p.Id
INNER JOIN dbo.PessoaEscolaAcesso pea ON pea.PessoaEscola = pe.Id
INNER JOIN dbo.AlunoEscola ae ON ae.AlunoEscola_key = pea.Id
INNER JOIN dbo.Turma t ON t.Id = ae.Turma
INNER JOIN dbo.EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN dbo.Escola e ON e.Id = es.Escola
INNER JOIN dbo.Rede r ON r.Id = e.Rede
WHERE hh.Observacao IS NOT NULL
  AND LEN(TRIM(hh.Observacao)) > 10
  AND ae.AnoLetivo = 2025   -- trocar pelo ano desejado
ORDER BY LEN(hh.Observacao) DESC;


-- ===========================================================================
-- 7. Valores de HisResultadoFinal (referência)
-- ===========================================================================
SELECT Id, Nome, Apelido FROM dbo.HisResultadoFinal ORDER BY Id;
-- 1=Apto, 2=Aprovado, 3=Reprovado, 4=Em Curso, 5=Cursando,
-- 6=Aprovado com Progressão Parcial, 8=Transferido, 9=Reprovado por falta, 10=Aprovação por Conselho


-- ===========================================================================
-- 8. Verificar configurações de rede para FichaIndividual
--    (DeveAgruparPorAreaDoConhecimento, NotasComUmaCasaDecimal NÃO existem em Rede)
--    Investigar em qual tabela essas configs estão armazenadas
-- ===========================================================================
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN ('Rede', 'EscolaConfiguracao', 'DocumentoPedagogicoRede')
  AND COLUMN_NAME LIKE '%Ficha%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
