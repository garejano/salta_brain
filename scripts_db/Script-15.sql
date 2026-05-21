select * from Importacoes.AlocacaoProfessoresStatus aps ;
select * from Importacoes.AlocacaoProfessores ap where ap.Hash = '49316f35-9916-4afe-a5e2-f1ae661f31c6';



23

select * from Importacoes.AlocacaoProfessoresLinha apl where apl.ImportacaoAlocacaoProfessores = 23;

delete from Importacoes.AlocacaoProfessoresLinha ;
delete from Importacoes.AlocacaoProfessores ;


select * from Importacoes.AlocacaoProfessores alp;
select * from Importacoes.AlocacaoProfessoresLinha alpl;

select * from Importacoes.AlocacaoProfessoresEtapa alp;

select * from Importacoes.AlocacaoProfessoresLinha apl where apl.EscolaValida = 0;
select * from Importacoes.AlocacaoProfessoresLinha apl where apl.EscolaValida = 0; 



update Importacoes.AlocacaoProfessoresLinha set EscolaValida = 0;


select * from AlunoEscolaItinerarioFormativo aeif;

select * from ItinerarioFormativo iff where iff.NomeCompleto = 'tggggggggggggg';

select e.Hash,e.Nome  from Escola e ;