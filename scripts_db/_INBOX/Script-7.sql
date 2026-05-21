select 
	r.Nome as "Rede",
	e.Nome as "Escola",
	s.Nome as "Serie",
	p.Nome as "NomePessoa",
	p.Id as "IdPessoa",
	t.Nome as "Turma",
	d.Nome as "Disciplina",
	d.Hash as "HashDisciplina"
from AlunoEscolaDisciplina aed
inner join Disciplina d on aed.Disciplina = d.Id
inner join AlunoEscola ae on ae.AlunoEscola_key  = aed.AlunoEscola
inner join Turma t on t.Id = ae.Turma 
inner join PessoaEscolaAcesso pea on pea.id = ae.AlunoEscola_key
inner join PessoaEscola pe on pe.Id = pea.PessoaEscola 
inner join Pessoa p on p.Id = pe.Pessoa 
inner join Escola e on e.Id = pe.Escola
inner join EscolaSerie es on e.Id = es.Escola
inner join Serie s on s.Id = es.Serie 
inner join Rede r on e.Rede = r.Id
where t.Hash = '6479f646-f27c-4d79-abf5-9b7ec1b05d53'
and ae.AnoLetivo = 2025
and d.Hash = '06dce0d0-8b93-4a6b-8063-3816765a3b90'
group by 
    r.Nome,
    e.Nome,
    s.Nome,
    p.Nome,
    p.Id,
    t.Nome,
    d.Nome,
    d.Hash;

select * from Turma t;
select * from AlunoEscolaDisciplina aed;
select * from AlunoEscola ae;
select * from PessoaEscolaAcesso pea;
select * from PessoaEscola pe;


select * from rel.RelatorioAlunoNota ran where ran.IdAnoLetivo = 2025 and ran.IdRede = 6 and ran.IdDisciplinaMae = 399;

select * from rel.RelatorioAlunoNota ran where ran.IdDisciplina = 535;
select * from rel.RelatorioAlunoNota ran where ran.HashDisciplinaMae  = '06dce0d0-8b93-4a6b-8063-3816765a3b90';

select * from Disciplina d where d.Hash = '06dce0d0-8b93-4a6b-8063-3816765a3b90';

--06dce0d0-8b93-4a6b-8063-3816765a3b90
select * from Avaliacao a where a.Id = 844125;
select * from AvaliacaoEscola ae ;
select * from AvaliacaoDisciplina ad ;
select * from ViewAvaliacao va ;


select * from Rede r where r.Hash = 'cd72b088-2fda-4600-9f08-c452e107a091';

select * from AlunoAva
select * from AvaliacaoDisciplina ad ;


select r.Nome as "NomeRede", e.Nome as "NomeEscola", d.Nome, d2.Nome from Disciplina d 
inner join Disciplina d2 on d2.Id = d.DisciplinaMae
inner join Rede r on r.Id = d.Rede
left join Escola e on e.Rede = d.Id
where d.DisciplinaMae = 199;


select * from EscolaSerieEtapa ese;


select * from Disciplina d;


select * from Escola e;


select * from Turma t;

select * from EscolaSerieEtapa ese;
inner join Serie s on s.Id = es.Serie where s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387';


select * from EscolaSerie es
inner join Escola e on e.Id = es.Escola 
inner join Serie s on s.Id = es.Serie
where e.Hash = '0b69b6c9-6992-46a7-b771-36a3e3251e7c'
and s.Hash ='4df9127c-d31e-478b-a947-04dc7cb51387';

{ 
  "hashDisciplina": "4cbd49ce-79d5-4989-ad36-81eb047c032a",
  "hashEscola": "0b69b6c9-6992-46a7-b771-36a3e3251e7c",
  "hashRede": "4dfbc7b4-e1a2-469e-aa1d-c51260e92d2d",
  "hashSerie": "4df9127c-d31e-478b-a947-04dc7cb51387",
  "hashTurma": "44c6705b-271c-43cc-9263-265596420939",
  "dataInicio": "2025-02-01T03:00:00.000Z",
  "dataTermino": "2025-11-04T03:00:00.000Z",
}

select e.Id from Escola e where e.Hash = '0b69b6c9-6992-46a7-b771-36a3e3251e7c';
select * from rel.RelatorioAlunoNota ran where ran.IdEtapa in (2660, 2598) and
ran.IdEscola = 6;



--etapas 14464, 14423
-- disciplina mae: 201
--turma 242223
-- rede 2
-- serie 15
-- anoLetivo 2025

-- total de avaliacao: 1334



select * from rel.RelatorioAlunoNota ran where ran.IdTurma = 242223 and ran.IdDisciplinaMae = 201;
select * from rel.RelatorioAlunoNota ran 
where 
	ran.IdAnoLetivo = 2025
	and	(ran.IdTurma = 242223 or ran.EhDependencia = 1)
	and ran.IdDisciplinaMae = 201
	and ran.IdRede = 2
	and ran.IdSerie = 15
	and ran.EtapaDeBoletim = 1
	and ran.VisivelNoBoletim  = 1;