select al.Id, e.Nome, s.Nome from Escola e 
inner join EscolaSerie es on es.Escola = e.Id
inner join Serie s on s.Id = es.Serie 
inner join AnoLetivo al on al.Id = es.AnoLetivo 
where e.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0' -- Alfa/Blumenau
and s.Hash = '81DC599D-98EB-4659-BBB1-5B6854C8192F'; -- 3ª Série Regular

select * from Escola s where s.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0';
select * from Serie s where s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387';

select * from Serie s where s.Id = 22;


select es.Serie, s.Nome,s.Hash from Escola e 
inner join EscolaSerie es on es.Escola = e.Id
inner join Serie s on s.Id = es.Serie 
where e.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0'
and s.Nome like '%3%'; -- Alfa/Blumenau
and s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387';



select * from MenuItem mi where mi.Nome like '%de Classe%';



select * from Escola e where e.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0';


select * from EscolaSerieEtapa ese where ese.EscolaSerie = 142920;



select * from Folha.ClassePagamento cp ;
ALTER TABLE Folha.ClassePagamento
DROP COLUMN PadraoRedePagamento;

ALTER TABLE Folha.RedePagamento 
ADD ZerarChapas BIT NULL;


select * from Folha.RedePagamento rp ;

UPDATE Folha.RedePagamento
SET ZerarChapas = 0;
