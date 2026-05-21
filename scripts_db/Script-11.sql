select
*
from folha.ProfessorCarga pc;

select * from 

select * from Folha.Disciplina d ;



select * from folha.ProfessorCarga pc
where pc.Hash = '648922a4-cd06-4670-8ef6-4a9cc0575a4b';


select * from ProfessorPerfilVigente ppv where ppv.Hash = 'cad3f4d7-2547-4aab-9eef-1bbbd5f93040';
select * from Pessoa p where p.Id = 4629482;


select * from Pessoa p where p.CPF = '05269278411';

select * from FOlha.MotivosSaida ms ;

ALTER TABLE Folha.MotivosSaida
ADD EhDesligamentoProfessor BIT NOT NULL
    CONSTRAINT DF_MotivosSaida_EhDesligamentoProfessor DEFAULT (0);


update folha.MotivosSaida set EhDesligamentoProfessor = 1 where Id = 1;