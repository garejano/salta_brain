-- Criar uma tabela temporária para armazenar as escolas do TipoRede 5
CREATE TABLE #temp_escolas_tipo5 (
    EscolaId INT,
    Nome VARCHAR(200),
    RedeId INT
);

INSERT INTO #temp_escolas_tipo5 (EscolaId, Nome, RedeId)
SELECT e.Id as EscolaId, e.Nome, r.Id as RedeId
FROM Escola e
INNER JOIN Rede r ON r.Id = e.Rede
WHERE r.TipoRede = 5;

select * from EscolaGerencial eg ;

-- Inserir nas EscolaGerencial
INSERT INTO EscolaGerencial (RedeId, Nome, Ativo, Hash, UsuarioInclusao, DataInclusao)
SELECT 
    RedeId,
    Nome,
    1 as Ativo,
    NEWID() as Hash,
    1097334 as UsuarioInclusao,
    GETDATE() as DataInclusao
FROM #temp_escolas_tipo5;

-- Criar uma tabela temporária para mapear as novas EscolaGerencial criadas
CREATE TABLE #temp_escola_gerencial_nova (
    EscolaGerencialId INT,
    EscolaId INT,
    RedeId INT
);

INSERT INTO #temp_escola_gerencial_nova (EscolaGerencialId, EscolaId, RedeId)
SELECT eg.Id as EscolaGerencialId, te.EscolaId, te.RedeId
FROM EscolaGerencial eg
INNER JOIN #temp_escolas_tipo5 te ON te.Nome COLLATE SQL_Latin1_General_CP1_CI_AS = eg.Nome 
    AND te.RedeId = eg.RedeId
WHERE eg.UsuarioInclusao = 1097334;

-- Inserir nas EscolaGerencialEscola
INSERT INTO EscolaGerencialEscola (EscolaGerencialId, EscolaId, AnoLetivo, Ativo, Hash, UsuarioInclusao, DataInclusao)
SELECT 
    EscolaGerencialId,
    EscolaId,
    YEAR(GETDATE()) as AnoLetivo,
    1 as Ativo,
    NEWID() as Hash,
    1097334 as UsuarioInclusao,
    GETDATE() as DataInclusao
FROM #temp_escola_gerencial_nova;

-- Limpar tabelas temporárias
DROP TABLE #temp_escolas_tipo5;
DROP TABLE #temp_escola_gerencial_nova;


