select * from EscolaSerie es where es.Id = 142920;

select * from Serie s where s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387'; --ID: 15 -- 3ª Série Regular
select * from Serie s where s.Id = 15;
select * from Escola e where e.Id = 768;


select * from EscolaSerieEtapa ese where ese.EscolaSerie = 142920;
select * from EscolaSerie es where es.Serie = 15 and es.Escola = 768 and es.AnoLetivo = 2025;


select * from EscolaSerie es
inner join Escola e on e.Id = es.Escola 
inner join AnoLetivo al on al.Id = es.AnoLetivo
inner join Serie s on s.Id = es.Serie 
where e.Hash = '0fbda349-1174-4f68-b1dd-a7731bfed39c';
--and s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387'
and al.Hash = '6e730b17-81f4-4486-91b5-e9db0bbcb5d5';


select * from EscolaSerie e where e.Hash = '0fbda349-1174-4f68-b1dd-a7731bfed39c';


select * from EscolaSerieEtapa ese where ese.EscolaSerie  = 142912;
select * from EscolaSerie s where s.Hash = '0fbda349-1174-4f68-b1dd-a7731bfed39c';
select * from EscolaSerie s where s.Id = 197;


select * from Serie s where s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387';
select * from Escola s where s.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0';

select * from Turma t ;


select * from EscolaSerie es 
inner join Escola e on e.Id = es.Escola
inner join Serie s on s.Id = es.Serie 
--where s.Hash = '4df9127c-d31e-478b-a947-04dc7cb51387'
where e.Hash = 'cf3d816e-252a-4566-bfcb-e11f7a6a19c0'
and es.AnoLetivo = 2025;


select * from Turma t where t.Hash = '6479f646-f27c-4d79-abf5-9b7ec1b05d53';







select * from EscolaSerieEtapa ese 
inner join EscolaSerie es on es.Id = ese.EscolaSerie 
where ese.EscolaSerie = 142918
and es.AnoLetivo = 2025; -- id 8855

--2025-02-02 00:00:00.000
select * from EscolaSerieEtapa ese where ese.id = 8855;

select * from Etapa e where e.Id = 2986;



select * from EscolaSerie	Etapa ese where ese.EscolaSerie = 148752;


select e.Nome, es.NomeExibicao as "EscolaSerie", es.AnoLetivo, et.Nome, ese.DataInicio, ese.DataTermino from EscolaSerieEtapa ese
inner join EscolaSerie es on es.Id = ese.EscolaSerie
inner join Escola e on e.Id = es.Escola
inner join Etapa et on et.Id = ese.Etapa
where es.Id= 148752;

select * from EscolaSerieEtapa ese where ese.EscolaSerie  = 148752;



select * from Turma t where t.Hash = '5ebb7b1d-6b60-440b-85e1-53e2bd08c6c2';
select * from AlunoEscola ae where ae.Turma = 256147;


select * from Turma t where t.Hash = '6479f646-f27c-4d79-abf5-9b7ec1b05d53';
select * from AlunoEscola ae where ae.Turma = 246480;

select * from AlunoEscola ae where ae.Matricula = '25449293';

select * from TipoSaidaAluno tsa ;








