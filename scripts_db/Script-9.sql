select * from Escola e where e.Nome like '%Idesa%'


select
	p.Nome,
	t.Nome,
	d.Nome,
	pf.QuantidadeTempos,
	pf.DataSaida,
	pf.MotivoAlteracao,
	pf.SaidaTemporaria 
from folha.ProfessorCarga pf
inner join ProfessorPerfilVigente ppv on ppv.Id = pf.ProfessorPerfilVigente 	
inner join Pessoa p on p.Id = ppv.Pessoa
inner join Turma t on t.Id = pf.Turma
inner join Disciplina d on d.Id = pf.Disciplina
where p.CPF  = '00951652230';

select * from Escola e where e.Nome like '%Carlos Prates%'



select * from ProfessorPerfilVigente ppv where ppv.Id = 10;
select * from folha.ProfessorCarga pc where pc.Id = 10 ;
select * from Pessoa p;


UPDATE Folha.ProfessorCarga SET MotivoAlteracao = null WHERE DataSaida IS null AND MotivoAlteracao IS NOT null;
UPDATE Folha.ProfessorCargaSubstituto SET MotivoAlteracao = null WHERE DataSaida IS null AND MotivoAlteracao IS NOT null;



select * from folha.MotivosSaida ms ;


ALTER TABLE folha.MotivosSaida
ADD ehNovoProfessor BIT NOT NULL
    CONSTRAINT DF_MotivosSaida_ehProfessorNovo DEFAULT 0;


UPDATE folha.MotivosSaida
SET Ativo = 0
WHERE ehRetornoDeSaidaTemporaria = 1;

select * from folha.MotivosSaida;

insert into folha.MotivosSaida  
	(Descricao,Hash,Ativo,DataInclusao,UsuarioInclusao,EhMotivoPorTurma,EhMotivoPorProfessor,
	SelecionavelPeloUsuario
	)
values ('Retorno de licença/afastamento',NEWID(),1,GETDATE(),1097334,0,0,1);





select * from folha.ProfessorCarga pc;
select * from folha.ProfessorTotalTempos ptt ;