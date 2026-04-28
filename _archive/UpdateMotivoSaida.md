select * from folha.MotivosSaida ms ;

  

  

UPDATE folha.MotivosSaida

set EhRetornoDeSaidaTemporaria = 0

where EhRetornoDeSaidaTemporaria IS NULL;

  

UPDATE folha.MotivosSaida

set EhSaidaTemporaria = 0

where EhSaidaTemporaria IS NULL;