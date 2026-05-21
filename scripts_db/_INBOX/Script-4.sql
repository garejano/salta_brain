SELECT vcae.Escolas, vcae.NomeTipoDivisao
FROM ViewConfiguradorAvaliacoesExportacao vcae
WHERE vcae.IdAnoLetivo = 2025
 -- vcae.IdRede = 2
 -- AND vcae.IdAnoLetivo = 2024
  AND vcae.Escolas != 'Todas as escolas';



select * from Avaliacao ea where ea.TipoDivisaoEscola != 1;
select * from TipoDivisaoEscola tde ;


select * from AlunoNota an; 

select * from AlunoEscolaDisciplina aed;