select e.Nome from Pessoa p 
join ProfessorPerfilVigente ppv on ppv.Pessoa = p.Id
join PessoaEscolaAcesso pea on pea.Id = ppv.PessoaEscolaAcesso 
join PessoaEscola pe on pe.Id = pea.PessoaEscola 
join Escola e on e.Id = pe.Escola
join Rede
where p.CPF = '06765481133';

select * from Escola e where e.Nome like '%Claras Je%';


select * from folha.ProfessorCarga pc ;


SELECT
    pc.ProfessorPerfilVigente     AS ProfessorId,
    pc.Turma                      AS TurmaId,
    pc.Disciplina                 AS DisciplinaId,
    SUM(pc.QuantidadeTempos)      AS TotalTempos
FROM folha.ProfessorCarga pc
WHERE pc.Ativo = 1
GROUP BY
    pc.ProfessorPerfilVigente,
    pc.Turma,
    pc.Disciplina;