select * from MenuItem mi where mi.Rota like '%diario%';



select * from ItinerarioFormativo iff where iff.NomeCompleto like '%Teste 12345%';



SELECT ItFoOf.Id, ItFo.Id, ItFo.NomeComum, ItFoPr.Nome
FROM ItinerarioFormativo AS ItFo
INNER JOIN ItinerarioFormativoOferta AS ItFoOf ON ItFoOf.ItinerarioFormativo = ItFo.Id AND ItFoOf.Ativo = ItFo.Ativo
INNER JOIN ItinerarioFormativoRedeSerie AS ItFoReSe ON ItFoReSe.ItinerarioFormativo = ItFo.Id AND ItFoReSe.Ativo = ItFo.Ativo
INNER JOIN RedeSerie AS ReSe ON ReSe.Id = ItFoReSe.RedeSerie AND ReSe.Ativo = ItFo.Ativo
INNER JOIN ItinerarioFormativoPeriodo AS ItFoPr ON ItFoPr.Id = ItFoOf.ItinerarioFormativoPeriodo AND ItFoPr.Ativo = ItFo.Ativo
WHERE ReSe.Rede = 6 AND ReSe.AnoLetivo = 2026 AND ReSe.Agrupamento = 11 AND ItFo.Ativo = 1;


SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ItinerarioFormativo'
ORDER BY ORDINAL_POSITION;

ALTER TABLE ItinerarioFormativo
ALTER COLUMN NomeComum VARCHAR(255) NULL;



select * from AlunoEscola ae where ae.Hash = '59d1be0f-9b2b-486a-8e33-a5fa509ecb4d';

select  p.Nome, t.NomeComum,t.Ativo,t.EhObrigatorio   from AlunoEscolaItinerarioFormativo aeif  
inner join AlunoEscola ae on ae.AlunoEscola_key  = aeif.AlunoEscola 
inner join PessoaEscolaAcesso pea on pea.Id  = ae.AlunoEscola_key 
inner join PessoaEscola pe on pe.Id  = pea.PessoaEscola
inner join Pessoa p on p.Id  = pe.Pessoa 
inner join ItinerarioFormativo t on t.Id = aeif.ItinerarioFormativo 
where aeif.AlunoEscola = 5667173 and t.Ativo = 1
and ifp.Hash = 'bc0a8788-81a8-4e3d-a652-7f2948ca3ffb';

select * from AlunoEscolaItinerarioFormativo aeif  
where aeif.AlunoEscola = 5667173;

select * from ItinerarioFormativoRedeSerie ifrs ;
select * from ItinerarioFormativoRedeSerieDisciplina ifrs;

select * from ItinerarioFormativoCiclo ifc; 


select  
    p.Nome,
    t.NomeComum,
    t.Ativo,
    t.EhObrigatorio
from AlunoEscolaItinerarioFormativo aeif
inner join AlunoEscola ae 
    on ae.AlunoEscola_key = aeif.AlunoEscola
inner join PessoaEscolaAcesso pea 
    on pea.Id = ae.AlunoEscola_key
inner join PessoaEscola pe 
    on pe.Id = pea.PessoaEscola
inner join Pessoa p 
    on p.Id = pe.Pessoa
inner join ItinerarioFormativo t 
    on t.Id = aeif.ItinerarioFormativo
inner join ItinerarioFormativoOferta ifo on ifo.Id = aeif.ItinerarioFormativoOferta
inner join ItinerarioFormativoPeriodo ifp
    on ifp.Id = ifo.ItinerarioFormativoPeriodo
where 
    aeif.AlunoEscola = 5667173
    and t.Ativo = 1
    and ifp.Hash = 'bc0a8788-81a8-4e3d-a652-7f2948ca3ffb';