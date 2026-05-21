-- Agrupamento = Serie

select top 20 * from Agrupamento agp;

select top 20 
	AnoLetivo,
	r.Nome as Rede,
	agp.Nome as NomeAgrupamento,
	TipoArredondamento,
	agp.PossuiAvaliacoes,
	eac.PossuiItinerarioFormativo,
	eac.PossuiItinerarioFormativoSeparadoNoBoletim,
	eac.ItinerarioFormativoPossuiSituacao,
	agp.PossuiAvaliacoes
from EstruturaAvaliacaoConfiguracao eac 
inner join Agrupamento agp on agp.Id = eac.Agrupamento  
inner join Rede r on r.Id = eac.Rede
where eac.Rede = 60;

select top 2
*	
from EstruturaAvaliacaoConfiguracao eac 
inner join Agrupamento agp on agp.Id = eac.Agrupamento  
where eac.Rede = 60;



select * from Rede r where r.Nome like '%baco%'; -- 60

SELECT TOP 20
    NomePessoa
    , NomeDisciplina
    , NomeTurma
    , NaoPossuiAula
    , CONVERT(varchar(10), DataInclusao, 103) AS DataInicioAlocacao
    , NomeUsuarioInclusao
    , CASE
        WHEN NaoPossuiAula = 1        THEN 'Não possui aula'
        WHEN IdPessoaEscolaAcesso = 0 THEN 'Não informado'
        ELSE 'Alocado'
      END AS Situacao
FROM ViewAlocacaoProfessoresMonitorTurma
ORDER BY DataInclusao DESC;


select * from AnoLetivo al;

select * from ItinerarioFormativo t ;




select 
Id,Nome,Anual,Ordem
From ItinerarioFormativoCiclo
Order By Ordem;


