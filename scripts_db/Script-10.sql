select 
	p.Nome,
	ptt.TotalTemposTitular,
	ptt.TotalTemposLicenca,
	ptt.TotalTemposSubstituto
from Folha.ProfessorTotalTempos ptt 
inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = ppv.Pessoa 
where ptt.TotalTemposTitular > 0 or ptt.TotalTemposLicenca  > 0 or ptt.TotalTemposSubstituto  > 0;


select 
    p.Nome  as NomePessoa,
    e.Nome  as NomeEscola,
    r.Nome  as NomeRede,
    ptt.TotalTemposLicenca,
    ptt.TotalTemposSubstituto,
    ptt.TotalTemposTitular
from Folha.ProfessorTotalTempos ptt 
inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = ppv.Pessoa 
inner join Escola e on e.Id = ptt.Escola
inner join Rede r on r.Id = e.Rede
where 
(
       ptt.TotalTemposTitular   > 0
    or ptt.TotalTemposLicenca   > 0
    or ptt.TotalTemposSubstituto > 0
)
and r.Id = 52;



select * from Rede r where r.Nome = 'Motivo';

select 
	p.Nome,
	ptt.AnoLetivo ,
	ptt.TotalTemposTitular,
	ptt.TotalTemposLicenca,
	ptt.TotalTemposSubstituto
from Folha.ProfessorTotalTempos ptt 
inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = ppv.Pessoa 
where ppv.Hash = '34bac5b9-78da-41d9-8962-6114321eeb62';

select * from Folha.ProfessorTotalTempos ptt where ptt.ProfessorPerfilVigente IS NULL;

select 
    p.Nome,
    ppv.Id as "ProfessorPerfilVitente",
    ptt.Escola ,
    ppv.Hash as ProfessorPerfilVigenteHash,
    ptt.AnoLetivo,
    sum(ptt.TotalTemposTitular)     as TotalTemposTitular,
    sum(ptt.TotalTemposLicenca)     as TotalTemposLicenca,
    sum(ptt.TotalTemposSubstituto)  as TotalTemposSubstituto
from Folha.ProfessorTotalTempos ptt 
inner join ProfessorPerfilVigente ppv 
    on ppv.Id = ptt.ProfessorPerfilVigente 
inner join Pessoa p 
    on p.Id = ppv.Pessoa 
where ppv.Hash = '34bac5b9-78da-41d9-8962-6114321eeb62'
group by 
    p.Nome,
	ppv.Id,
    ppv.Hash,
    ptt.Escola,
    ptt.AnoLetivo
order by 
    ptt.AnoLetivo;


select * from Folha.ProfessorTotalTempos ptt ;


SELECT [t].[Hash], [t].[Descricao]
FROM (
    SELECT DISTINCT [r].[Hash], [r].[Nome] AS [Descricao]
    FROM [Folha].[ProfessorTotalTempos] AS [p]
    INNER JOIN [Escola] AS [e] ON [p].[Escola] = [e].[Id]
    INNER JOIN [Rede] AS [r] ON [e].[Rede] = [r].[Id]
    INNER JOIN [AnoLetivo] AS [a] ON [p].[AnoLetivo] = [a].[Id]
    WHERE [p].Ativo = 1
) AS [t]
ORDER BY [t].[Descricao];



select * from Folha.ProfessorCarga pc 
inner join ProfessorPerfilVigente ppv on ppv.Id = pc.ProfessorPerfilVigente 
where ppv.Hash = '34bac5b9-78da-41d9-8962-6114321eeb62';

select * from ProfessorPerfilVigente ppv ;

select * from SituacaoProfessor sp ;




SELECT 
    fk.name,
    OBJECT_NAME(fk.parent_object_id) AS Tabela,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS Coluna,
    OBJECT_NAME(fk.referenced_object_id) AS TabelaRef
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc 
  ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ProfessorTotalTempos';

SELECT ptt.Id, ptt.Escola
FROM Folha.ProfessorTotalTempos ptt
LEFT JOIN Escola e ON e.Id = ptt.Escola
WHERE e.Id IS NULL;


293
select 
    p.Nome  as NomePessoa,
    e.Nome  as NomeEscola,
    r.Nome  as NomeRede,
    sum(ptt.TotalTemposTitular)    as TotalTemposTitular,
    sum(ptt.TotalTemposLicenca)    as TotalTemposLicenca,
    sum(ptt.TotalTemposSubstituto) as TotalTemposSubstituto
from Folha.ProfessorTotalTempos ptt 
inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = ppv.Pessoa 
inner join Escola e on e.Id = ptt.Escola
inner join Rede r on r.Id = e.Rede
where 
(
       ptt.TotalTemposTitular    > 0
    or ptt.TotalTemposLicenca    > 0
    or ptt.TotalTemposSubstituto > 0
)
and r.Id = 52
group by
    p.Nome,
    e.Nome,
    r.Nome
order by
    p.Nome,
    e.Nome;


select * from Folha.ProfessorTotalTempos ptt inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente where ppv.Hash = '3369cda7-7de7-45c7-8d5a-0006fa4025f4';
select * from Folha.ProfessorCarga ptt inner join ProfessorPerfilVigente ppv on ppv.Id = ptt.ProfessorPerfilVigente where ppv.Hash = '3369cda7-7de7-45c7-8d5a-0006fa4025f4';



select * from Folha.MotivosSaida ms ;