select 
	r.Nome as "Rede",
	e.Nome as "Escola",
	s.Nome as "Serie",
	t.Nome as "Turma",
	d.Nome as "Disciplina",
	p.Nome as "Professor",
	p.CPF as "CPF",
	pc.QuantidadeTempos,
	pc.DataEntrada,
	pc.DataSaida 
from folha.ProfessorCarga pc 
inner join ProfessorPerfilVigente pfv on pfv.Id = pc.ProfessorPerfilVigente 
inner join Pessoa p on p.Id = pfv.Pessoa 
inner join Turma t on t.Id = pc.Turma 
inner join EscolaSerie es on es.Id = t.EscolaSerie 
inner join Serie s on s.Id = es.Serie 
inner join Escola e on e.Id = es.Escola 
inner join Rede r on r.Id = e.Rede 
inner join Disciplina d on d.Id = pc.Disciplina 
where es.AnoLetivo = 2025;