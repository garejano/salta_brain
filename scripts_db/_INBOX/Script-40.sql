select * from folha.MotivosSaida ms ;


UPDATE folha.MotivosSaida
set EhRetornoDeSaidaTemporaria = 0
where EhRetornoDeSaidaTemporaria IS NULL;

UPDATE folha.MotivosSaida
set EhSaidaTemporaria = 0
where EhSaidaTemporaria IS NULL;


select * from folha.ProfessorCarga pf where pf.Hash = '3c0d86fb-6a77-423b-8cc2-3acbdbe6c555';