select * from folha.ProfessorCarga pc 
inner join Turma t on t.Id = pc.Turma
inner join EscolaSerie es on es.Id = t.EscolaSerie
inner join Escola e on e.Id =  es.Escola
where e.Id = 1607;

select * from folha.ProfessorCarga pc where pc.ProfessorPerfilVigente IS NULL;


select * from Turma t;
select * from Escola e where e.Rede = 27; -- 1606
select * from Rede r where r.Nome like '%CBV%'; -- 27
-- boa viagem 1607
select * from EscolaSerie es;

select * from AnoLetivo al;

DELETE pc
FROM folha.ProfessorCarga pc
INNER JOIN Turma t ON t.Id = pc.Turma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
inner join AnoLetivo al on al.Id = es.AnoLetivo
INNER JOIN Escola e ON e.Id = es.Escola
WHERE e.Id = 1606;

UPDATE pc
SET pc.ProfessorPerfilVigente = NULL
FROM folha.ProfessorCarga pc
INNER JOIN Turma t ON t.Id = pc.Turma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN Escola e ON e.Id = es.Escola
INNER JOIN AnoLetivo al ON al.Id = es.AnoLetivo
WHERE e.Id = 1606
  AND al.Id = 2025;


sp_help 'folha.ProfessorCarga';

