select * from public."Disciplina" d where d."Hash" = '1c85f5de-9aec-467f-8a2f-b1a659e194e5';
---06dce0d0-8b93-4a6b-8063-3816765a3b90

select * from public."Escola" e where e."Hash" = '29461a1f-bab1-40ec-8a6d-88489a46a70b' ;
--cf3d816e-252a-4566-bfcb-e11f7a6a19c0

select * from public."Rede" r where r."Hash" = '7c72bd11-7356-4fdc-ba16-3e8055d5879f';
--cd72b088-2fda-4600-9f08-c452e107a091

select * from public."Serie" s where s."Hash" = 'ed2d9286-2b26-4d62-9425-4a50b8fac7a1';
--4df9127c-d31e-478b-a947-04dc7cb51387

select * from public."Turma" t where t."Hash" = '68399769-3e39-4492-a7ca-8d4003c442b2';
--6479f646-f27c-4d79-abf5-9b7ec1b05d53


{ 
  "hashDisciplina": "06dce0d0-8b93-4a6b-8063-3816765a3b90",
  "hashEscola": "cf3d816e-252a-4566-bfcb-e11f7a6a19c0",
  "hashRede": "cd72b088-2fda-4600-9f08-c452e107a091",
  "hashSerie": "4df9127c-d31e-478b-a947-04dc7cb51387",
  "hashTurma": "6479f646-f27c-4d79-abf5-9b7ec1b05d53",
  "dataInicio": "2025-01-01T20:07:36.680Z",
  "dataFim": "2025-10-31T20:07:36.680Z"
}

select * from "Rede" r where r."Nome" like '%baco%';
select * from "Rede" r where r."Nome" like '%Alfa%';


select * from "DiarioClasseConfiguracao" dcc where dcc."Rede" = 25;