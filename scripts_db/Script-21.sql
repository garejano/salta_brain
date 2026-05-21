SELECT TOP 1 c.Id AS IdCiclo, e.Nome AS Etapa
FROM Ciclo c
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN EstruturaAvaliacao ea ON ea.Ciclo = c.Id
WHERE ea.Agrupamento = 11 AND ea.Rede = 60 AND ea.AnoLetivo = 2026
  AND ea.ItinerarioFormativoCiclo IS NULL AND e.Boletim = 1;



SELECT ea.Id, ifc.Nome AS CicloCF, e.Nome AS Etapa, ea.Ativo
FROM EstruturaAvaliacao ea
LEFT JOIN ItinerarioFormativoCiclo ifc ON ifc.Id = ea.ItinerarioFormativoCiclo
INNER JOIN Ciclo c ON c.Id = ea.Ciclo
INNER JOIN Etapa e ON e.Id = c.Etapa
INNER JOIN Agrupamento a ON a.Id = ea.Agrupamento
INNER JOIN Rede r ON r.Id = ea.Rede
WHERE r.Nome = 'Ábaco'
  AND a.Nome = '1ª série do EM'
  AND ea.AnoLetivo = 2026
  AND ea.Ativo = 1
ORDER BY ea.ItinerarioFormativoCiclo, e.Nome;


SELECT ea.Id, ea.Hash, e.Nome AS Etapa, ea.DataInclusao
FROM EstruturaAvaliacao ea
INNER JOIN Ciclo c ON c.Id = ea.Ciclo
INNER JOIN Etapa e ON e.Id = c.Etapa
WHERE ea.Agrupamento = 11
  AND ea.Rede = 60
  AND ea.AnoLetivo = 2026
  AND ea.ItinerarioFormativoCiclo IS NULL
  AND CAST(ea.DataInclusao AS DATE) = '2026-04-20'
  AND ea.Ativo = 1;

UPDATE EstruturaAvaliacao
SET ItinerarioFormativoCiclo = 2
WHERE Agrupamento = 11
  AND Rede = 60
  AND AnoLetivo = 2026
  AND ItinerarioFormativoCiclo IS NULL
  AND CAST(DataInclusao AS DATE) = '2026-04-20'
  AND Ativo = 1;