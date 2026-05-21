select * from Rede r where r.Nome = 'Anglo Alante GO'; -- ID = 62


select 
 al.Id as AnoLetivo,
 --t.Nome as NomeTurma,
 --s.Nome as NomeSerie,
 --e.Nome as NomeEscola,
 r.Nome as NomeRede,
 --pc.QuantidadeTempos ,
 pc.Vago
from folha.ProfessorCarga pc 
inner join Turma t on t.Id = pc.Turma
inner join EscolaSerie es on es.Id = t.EscolaSerie 
inner join Serie s on s.Id = es.Serie 
inner join AnoLetivo al on al.Id = es.AnoLetivo 
inner join Escola e on e.Id = es.Escola 
inner join Rede r on r.Id = e.Rede
where pc.Vago = 0 
and al.Id = 2025;

SELECT
    r.Nome AS NomeRede
FROM folha.ProfessorCarga pc
INNER JOIN Turma t       ON t.Id = pc.Turma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN Serie s      ON s.Id = es.Serie
INNER JOIN AnoLetivo al ON al.Id = es.AnoLetivo
INNER JOIN Escola e    ON e.Id = es.Escola
INNER JOIN Rede r      ON r.Id = e.Rede
WHERE pc.Vago = 0
  AND al.Id = 2025
GROUP BY r.Nome;

select * from folha.ProfessorCarga pc;
select * from AnoLetivo al;
select * from EscolaSerie es;

SELECT
    r.Nome AS NomeRede,
    COUNT(*) AS QuantidadeVagas
FROM folha.ProfessorCarga pc
INNER JOIN Turma t        ON t.Id = pc.Turma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN Serie s       ON s.Id = es.Serie
INNER JOIN AnoLetivo al  ON al.Id = es.AnoLetivo
INNER JOIN Escola e     ON e.Id = es.Escola
INNER JOIN Rede r       ON r.Id = e.Rede
WHERE pc.Vago = 1
  AND al.Id = 2025
GROUP BY r.Nome
ORDER BY r.Nome;


SELECT
    r.Nome AS NomeRede,
    COUNT(*) AS QuantidadeVagos,
    SUM(pc.QuantidadeTempos) AS TotalTemposVagos
FROM folha.ProfessorCarga pc
INNER JOIN Turma t         ON t.Id = pc.Turma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN Serie s        ON s.Id = es.Serie
INNER JOIN AnoLetivo al   ON al.Id = es.AnoLetivo
INNER JOIN Escola e      ON e.Id = es.Escola
INNER JOIN Rede r        ON r.Id = e.Rede
WHERE pc.Vago = 1
  AND pc.Ativo = 1
  AND pc.DataSaida IS NULL
  AND al.Id = 2025
GROUP BY r.Nome
ORDER BY r.Nome;
