select * from ModuloDocumentacaoPedagogica.ConteudoDiarioClasse cdc where cdc.AnoLetivo = 2025;



SELECT
    r.Nome,
    s.Nome,
    t.Nome
FROM ModuloDocumentacaoPedagogica.ConteudoDiarioClasse cdc
INNER JOIN Turma t ON t.Hash = cdc.HashTurma
INNER JOIN EscolaSerie es ON es.Id = t.EscolaSerie
INNER JOIN Serie s ON s.Id = es.Serie 
INNER JOIN Escola e ON e.Id = es.Escola
INNER JOIN Rede r ON r.Id = e.Rede
WHERE cdc.AnoLetivo = 2025
  AND cdc.Conteudo IS NOT NULL
  AND cdc.Atividades IS NOT NULL
GROUP BY r.Nome, s.Nome, t.Nome;


select * from Rede r where r.Nome = 'Alfa'; -- 2

select * from Turma t where t.Hash = '9CB4658A-C308-481C-A4E6-9136B006C2F0'

