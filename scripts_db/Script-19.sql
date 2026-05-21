
-- 1. Coluna na tabela principal
ALTER TABLE dbo.EstruturaAvaliacao
    ADD ItinerarioFormativoCiclo INT NULL;

-- 2. FK na tabela principal
ALTER TABLE dbo.EstruturaAvaliacao
    ADD CONSTRAINT [FK_EstruturaAvaliacao.ItinerarioFormativoCiclo]
    FOREIGN KEY (ItinerarioFormativoCiclo)
    REFERENCES dbo.ItinerarioFormativoCiclo (Id);

-- 3. Coluna na tabela de auditoria (espelha estrutura da principal, sem FK)
ALTER TABLE LogAlteracoes.EstruturaAvaliacao
    ADD ItinerarioFormativoCiclo INT NULL;
```

SELECT
    r.Nome                                              AS Rede,
    a.Nome                                              AS Agrupamento,
    al.Id                                               AS AnoLetivo,
    ifc.Id                                              AS IdCiclo,
    ifc.Nome                                            AS NomeCiclo,
    COUNT(DISTINCT ifrs.Id)                             AS QtdItinerariosComCiclo,
    COUNT(DISTINCT ea.Id)                               AS QtdEstruturasConfiguradas,
    CASE WHEN COUNT(DISTINCT ea.Id) > 0
         THEN 'Sim' ELSE 'Não — grid vazio'
    END                                                 AS TeriaResultadosNoGrid
FROM EstruturaAvaliacaoConfiguracao eac
INNER JOIN Agrupamento                  a    ON a.Id   = eac.Agrupamento
INNER JOIN Rede                         r    ON r.Id   = eac.Rede
INNER JOIN AnoLetivo                    al   ON al.Id  = eac.AnoLetivo
INNER JOIN RedeSerie                    rs   ON rs.Agrupamento = eac.Agrupamento
                                            AND rs.AnoLetivo   = eac.AnoLetivo
                                            AND rs.Rede        = eac.Rede
                                            AND rs.Ativo       = 1
INNER JOIN ItinerarioFormativoRedeSerie ifrs ON ifrs.RedeSerie = rs.Id
                                            AND ifrs.Ativo     = 1
INNER JOIN ItinerarioFormativo          iff  ON iff.Id = ifrs.ItinerarioFormativo
                                            AND iff.Ativo = 1
INNER JOIN ItinerarioFormativoCiclo     ifc  ON ifc.Id = iff.ItinerarioFormativoCiclo
LEFT  JOIN EstruturaAvaliacao           ea   ON ea.Agrupamento           = eac.Agrupamento
                                            AND ea.Rede                  = eac.Rede
                                            AND ea.AnoLetivo             = eac.AnoLetivo
                                            AND ea.ItinerarioFormativoCiclo = ifc.Id
                                            AND ea.Ativo                 = 1
WHERE eac.PossuiItinerarioFormativoSeparadoNoBoletim = 1
  AND eac.Ativo = 1
GROUP BY r.Nome, a.Nome, al.Id, ifc.Id, ifc.Nome
ORDER BY r.Nome, a.Nome, al.Id DESC, ifc.Id