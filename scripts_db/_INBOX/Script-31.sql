select * from folha.MotivosSaida ms ;


select * from EscolaGerencial eg
inner join Rede r on r.Id = eg.RedeId;

select eg.Nome as "NomeEscolaGerencial", eg.DataInclusao, e.Nome as "NomeEscola",ege.AnoLetivo  from EscolaGerencialEscola ege
inner join EscolaGerencial eg on eg.Id = ege.EscolaGerencialId
inner join Escola e on e.Id = ege.EscolaId
inner join Rede r on r.Id = eg.RedeId 
where r.TipoRede = 5;

select * from Rede r;
select * from TipoRede tr; -- 5 Impulso

select * from EscolaGerencial eg ; -- 82
select * from EscolaGerencialEscola ege where ege.EscolaGerencialId  = 82;



select * from Escola e 
inner join Rede r on r.id = e.Rede where r.TipoRede = 5;
select * from Escola e where e.Id = 2431;

select * from TipoEscola te ;