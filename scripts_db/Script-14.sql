select * from MenuItem mi where mi.Nome like '%Formativo';
select * from MenuItem mi where mi.Nome like '%Escola%';

select * from Funcionalidade f where f.Id in (425,426);
select * from Funcionalidade f where f.Produto = 171;

/estrutura-pedagogica/itinerario-formativo/listar

select * from ItinerarioFormativoRedeSerie ifrs ;
select * from ItinerarioFormativoRedeSerieDisciplina ifrsd ;


SELECT
    it.Id                           AS ItinerarioId,
    al.Id as AnoLetivo,
    it.NomeComum                    AS ItinerarioNome,
    --t.Nome                          AS Tipo,
    --c.Nome                          AS Ciclo,
    --dsc.Hash                        AS HashDisciplina,
    --dsc.Nome                        AS DescricaoDisciplina
    it.EhObrigatorio
FROM ItinerarioFormativo it
INNER JOIN ItinerarioFormativoRedeSerie irs
    ON irs.ItinerarioFormativo = it.Id
    AND irs.DataInativacao IS NULL
INNER JOIN RedeSerie rs
    ON rs.Id = irs.RedeSerie
INNER JOIN AnoLetivo al
    ON al.Id = rs.AnoLetivo
    --AND al.Hash = 'ea3695ab-f17b-4905-8034-b8c2a0495c06'
INNER JOIN Rede r
    ON r.Id = rs.Rede
    --AND r.Hash = '281c9abf-3a98-479b-beb6-fd2fa3f0b828'
INNER JOIN Agrupamento ag
    ON ag.Id = rs.Agrupamento
    AND ag.Hash = '281c9abf-3a98-479b-beb6-fd2fa3f0b828';
 


SELECT
    it.Id                           AS ItinerarioId,
    it.NomeComum                    AS ItinerarioNome,
    t.Nome                          AS Tipo,
    c.Nome                          AS Ciclo,
    it.EhObrigatorio,
    dsc.Hash                        AS HashDisciplina,
    dsc.Nome                        AS DescricaoDisciplina
FROM ItinerarioFormativo it
INNER JOIN ItinerarioFormativoRedeSerie irs
    ON irs.ItinerarioFormativo = it.Id
    AND irs.DataInativacao IS NULL
INNER JOIN RedeSerie rs
    ON rs.Id = irs.RedeSerie
INNER JOIN AnoLetivo al
    ON al.Id = rs.AnoLetivo
    --AND al.Hash = "ea3695ab-f17b-4905-8034-b8c2a0495c06"
INNER JOIN Rede r
    ON r.Id = rs.Rede
    --AND r.Hash = "281c9abf-3a98-479b-beb6-fd2fa3f0b828"
INNER JOIN Agrupamento ag
    ON ag.Id = rs.Agrupamento
    --AND ag.Hash = "281c9abf-3a98-479b-beb6-fd2fa3f0b828"
INNER JOIN ItinerarioFormativoRedeSerieDisciplina ifrsd
    ON ifrsd.ItinerarioFormativoRedeSerie = irs.Id
    AND ifrsd.DataInativacao IS NULL
INNER JOIN Disciplina dsc
    ON dsc.Id = ifrsd.Disciplina
INNER JOIN ItinerarioFormativoTipo t
    ON t.Id = it.ItinerarioFormativoTipo
INNER JOIN ItinerarioFormativoCiclo c
    ON c.Id = it.ItinerarioFormativoCiclo
WHERE
    rs.Rede IN (2,3,4,5,6,7,9);