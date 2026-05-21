select v.CicloTotalEtapa, v.CicloMediaEtapa from ViewConfiguradorAvaliacao v;


select top 5 * from ItinerarioFormativoCiclo ifc;


select top 20 * from ViewConfiguradorAvaliacaoDisciplina v;


SELECT EsAv.*
FROM EstruturaAvaliacao AS EsAv
INNER JOIN TipoAvaliacao AS TiAv ON TiAv.Id = EsAv.TipoAvaliacao
WHERE TiAv.AnoLetivo = 2026 AND EsAv.Ativo = 1 AND EsAv.ItinerarioFormativoCiclo IS NOT null AND (TiAv.Total = 1 OR TiAv.Media = 1 OR TiAv.Situacao = 1);



select top 10 * from ViewConfiguradorAvaliacoesExportacao vcae ;





SELECT TOP 5
    IdItinerarioFormativoCiclo,
    NomeEtapa,
    NomeCiclo,
    NomeAgrupamento
FROM ViewConfiguradorAvaliacoesExportacao
WHERE IdItinerarioFormativoCiclo IS NOT NULL
ORDER BY IdItinerarioFormativoCiclo;


select top 8 *
FROM ViewConfiguradorAvaliacoesExportacao;
