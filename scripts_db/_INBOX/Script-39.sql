select * from Rede r where r.Nome = 'Alfa'; -- 6
select * from Escola e where e.Rede = 6 and e.Nome = 'Campinas'; -- 1967

select * from folha.ProfessorCarga pc
inner join ProfessorPerfilVigente ppv on ppv.Id = pc.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = ppv.Pessoa
inner join Turma t on t.Id = pc.Turma
inner join EscolaSerie es on es.Id = t.EscolaSerie
inner join Escola e on e.Id =  es.Escola
where e.Id = 1967;


select * from PerfilAcesso pa ;

select 
    r.Nome as Rede,
    e.Nome as Escola,
    s.Nome as Serie,
    t.Nome as Turma,
    d.Nome as Disciplina,
    p.Nome as Professor,
    STUFF(STUFF(STUFF(RIGHT('00000000000' + p.CPF, 11), 4, 0, '.'), 8, 0, '.'), 12, 0, '-') AS CPF,
    SUM(pc.QuantidadeTempos) AS TotalTempos,
    --pc.QuantidadeTempos,
    MIN(pc.DataEntrada) AS DataEntrada,
    MAX(pc.DataSaida) AS DataSaida
from folha.ProfessorCarga pc 
inner join ProfessorPerfilVigente pfv on pfv.Id = pc.ProfessorPerfilVigente
inner join Pessoa p on p.Id = pfv.Pessoa
inner join Turma t on t.Id = pc.Turma 
inner join EscolaSerie es on es.Id = t.EscolaSerie
inner join Serie s on s.Id = es.Serie
inner join Escola e on e.Id = es.Escola 
inner join Rede r on r.Id = e.Rede
inner join Disciplina d on d.Id = pc.Disciplina
where es.AnoLetivo = 2025
--and pfv.Hash = 'c33d3a24-ca6d-4617-8bb7-1487ea198f97'
group by
    r.Nome,
    e.Nome,
    s.Nome,
    t.Nome,
    d.Nome,
    d.Id,
    p.Nome,
    p.CPF;