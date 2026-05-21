select * from folha.ProfessorCarga pc where pc.Id = 5636294;

select * from folha.ProfessorCarga pc ;


select * from folha.ProfessorCargaSubstituto pcs ;


select * from Escola e where e.Hash = 'ac54f03d-613b-4781-a859-324f70ea5bed'; -- Ipiranga


select * from Escola e where e.Hash = '3e32fd72-f4c7-4679-b02b-ad9749b5f059'; -- Sao Bernardo do Campo

select * from Rede r where r.Nome = 'Elite RJ'; -- 3
select * from Rede r where r.Nome = 'CBV'; -- 27

select * from Escola e where e.Nome LIKE '%Jaque%'; 1606


select * from folha.ProfessorCarga pc ;
select * from ProfessorPerfilVigente ppv;
select * from SituacaoProfessor sp ;

SELECT 
    r.Nome  AS Rede,
    e.Nome  AS Escola,
    p.Nome  AS Professor,
    p.CPF as CPFProfessor,
    sp.Descricao,
    pc.DataSaida,
    pc.Id
FROM folha.ProfessorCarga pc
JOIN ProfessorPerfilVigente ppv ON ppv.Id = pc.ProfessorPerfilVigente
JOIN SituacaoProfessor sp ON sp.Id = ppv.SituacaoProfessor
JOIN Pessoa p ON p.Id = ppv.Pessoa
JOIN Turma t ON t.Id = pc.Turma
JOIN EscolaSerie es ON es.Id = t.EscolaSerie
JOIN AnoLetivo al ON al.Id = es.AnoLetivo
JOIN Escola e ON e.Id = es.Escola
JOIN Rede r ON r.Id = e.Rede
WHERE r.Id = 27
  AND al.Id = 2025
  AND pc.DataSaida IS NULL
  AND e.Id = 1606
GROUP BY
	pc.Id,
    p.Nome,
    p.CPF,
    sp.Descricao,
    e.Nome,
    r.Nome,
    pc.DataSaida
ORDER BY P.Nome ASC;







DELETE pc
FROM folha.ProfessorCarga pc
JOIN ProfessorPerfilVigente ppv ON ppv.Id = pc.ProfessorPerfilVigente
JOIN SituacaoProfessor sp ON sp.Id = ppv.SituacaoProfessor
JOIN Pessoa p ON p.Id = ppv.Pessoa
JOIN Turma t ON t.Id = pc.Turma
JOIN EscolaSerie es ON es.Id = t.EscolaSerie
JOIN AnoLetivo al ON al.Id = es.AnoLetivo
JOIN Escola e ON e.Id = es.Escola
JOIN Rede r ON r.Id = e.Rede
WHERE r.Id = 27
  AND al.Id = 2025
  AND pc.DataSaida IS NULL
  AND e.Id = 1606
  AND p.Nome NOT LIKE 'A%'
  AND p.Nome NOT LIKE 'B%';

DELETE pc
FROM folha.ProfessorCarga pc
JOIN ProfessorPerfilVigente ppv ON ppv.Id = pc.ProfessorPerfilVigente
JOIN SituacaoProfessor sp ON sp.Id = ppv.SituacaoProfessor
JOIN Pessoa p ON p.Id = ppv.Pessoa
JOIN Turma t ON t.Id = pc.Turma
JOIN EscolaSerie es ON es.Id = t.EscolaSerie
JOIN AnoLetivo al ON al.Id = es.AnoLetivo
JOIN Escola e ON e.Id = es.Escola
JOIN Rede r ON r.Id = e.Rede
WHERE p.CPF = '09857306411';



select * from folha.ProfessorCarga pc ;


