select * from ItinerarioFormativoTipo ift ;

select * from RedeSerieDisciplina rsd ;

select * from RedeSerie rs  where rs.PossuiItinerarioFormativo = 1	;


select * from ItinerarioFormativo t ;
select * from ItinerarioFormativo
select * from ItinerarioFormativoRedeSerie ifrs 

select * from ItinerarioFormativoPeriodo ifp ;
select * from ItinerarioFormativoOferta ifo;


SELECT DISTINCT
    t.name AS Tabela,
    rt.name AS TabelaRelacionada,
    fk.name AS ForeignKey
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.tables rt ON fk.referenced_object_id = rt.object_id
WHERE t.name = 'ItinerarioFormativoPeriodo' 
   OR rt.name = 'ItinerarioFormativoPeriodo';


select * from AnoLetivo al where al.Hash = 'ea3695ab-f17b-4905-8034-b8c2a0495c06';

select * from Rede r where r.Hash = 'cd72b088-2fda-4600-9f08-c452e107a091';
select * from Serie s where s.Hash = '0a1c308a-8c8e-42de-b8a6-6a9c7eb9757d';
select * from Agrupamento a where a .Hash = '0a1c308a-8c8e-42de-b8a6-6a9c7eb9757d';