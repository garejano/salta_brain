SELECT * from Escola e where e.Nome = 'Blumenau';


select r.NOme from ProfessorPerfilVigente ppv 
inner join Pessoa p on p.Id = ppv.Pessoa
inner join PessoaEscolaAcesso pea on pea.Id = ppv.PessoaEscolaAcesso 
inner join PessoaEscola pe on pe.Id = pea.PessoaEscola 
inner join Escola e on e.Id = pe.Escola 
inner join Rede r on r.Id = e.Rede
where p.Nome = 'Andre Lourenco de Oliveira';





select * from ItinerarioFormativo t where t.ItinerarioFormativoTipo is null;

select * from ItinerarioFormativo t;
select * from ItinerarioFormativoRedeSerie t;
select * from RedeSerie rs;

select r.Nome, iff.NomeComum  from ItinerarioFormativoRedeSerie ifrd
inner join ItinerarioFormativo iff on iff.Id = ifrd.ItinerarioFormativo
inner join RedeSerie rs on rs.Id = ifrd.RedeSerie
inner join Rede r on r.Id = rs.Rede
where rs.AnoLetivo = 2025
;



select * from MenuItem mi where mi.Nome like '%Formativo%' ;

select * from Funcionalidade f where f.Id = 426 ;
select * from Funcionalidade f;


