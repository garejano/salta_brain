IF Object_Id('tempdb..#PARAM') IS NOT NULL
 DROP TABLE #PARAM;
GO

-- ----------------------- --

SELECT Year(GetDate()) AS IdAnoLetivo

INTO #PARAM;

GO

-- Inscrição automática ---------------------------------------------------------- --
IF EXISTS (SELECT TOP 1 1 FROM #PARAM)
 INSERT INTO AlunoEscolaItinerarioFormativo (
  AlunoEscola,
  ItinerarioFormativoOferta,
  Ativo,
  DataInclusao)
 SELECT DISTINCT -- Sanidade
        AlEs.AlunoEscola_key,
        ItFoOf.Id,
        1, -- Ativo
        GetDate() -- DataInclusao
 FROM RedeSerie AS ReSe
 INNER JOIN ItinerarioFormativoRedeSerie AS ItFoReSe ON ItFoReSe.RedeSerie = ReSe.Id
                                                    AND ItFoReSe.Ativo     = ReSe.Ativo
 INNER JOIN ItinerarioFormativo AS ItFo ON ItFo.Id    = ItFoReSe.ItinerarioFormativo
                                       AND ItFo.Ativo = ReSe.Ativo
 INNER JOIN ItinerarioFormativoOferta AS ItFoOf ON ItFoOf.Id    = ItFo.Id
                                               AND ItFoOf.Ativo = ReSe.Ativo
 INNER JOIN Escola AS Es ON Es.Rede  = ReSe.Rede
                        AND Es.Ativo = ReSe.Ativo
 INNER JOIN EscolaSerie AS EsSe ON EsSe.Escola      = Es.Id
                               AND EsSe.Agrupamento = ReSe.Agrupamento
                               AND EsSe.Serie       = ReSe.Serie
                               AND EsSe.AnoLetivo   = ReSe.AnoLetivo
                               AND EsSe.Ativo       = ReSe.Ativo
 INNER JOIN Turma AS Tu ON Tu.EscolaSerie = EsSe.Id
                       AND Tu.Ativo       = ReSe.Ativo
 INNER JOIN AlunoEscola AS AlEs ON AlEs.Turma = Tu.Id
 LEFT JOIN AlunoEscolaItinerarioFormativo AS AlEsItFo ON AlEsItFo.AlunoEscola               = AlEs.AlunoEscola_key
                                                     AND AlEsItFo.ItinerarioFormativoOferta = ItFoOf.Id
                                                     AND AlEsItFo.Ativo                     = ReSe.Ativo
 INNER JOIN #PARAM AS p ON p.IdAnoLetivo = ReSe.AnoLetivo
 WHERE ReSe.Ativo = 1
   AND ItFo.EhObrigatorio = 1
   AND AlEsItFo.Id IS null;
GO
