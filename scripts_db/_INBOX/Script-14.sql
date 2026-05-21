-- request feito por doc-ped/diario para ficha individual
{
  dataInicio: "2025-02-02T03:00:00.000Z",
  dataTermino: "2025-11-12T03:00:00.000Z",
  exibirNomeProfessor: false,
  hashAnoLetivo: "e55e2569-481e-4335-a2ee-1302b5fc60bd",
  hashDisciplina: "5a4c966a-6edd-42dd-ac73-7b16c1dd2fc3",
  hashEscola: "29461a1f-bab1-40ec-8a6d-88489a46a70b",
  hashRede: "7c72bd11-7356-4fdc-ba16-3e8055d5879f",
  hashSerie: "ed2d9286-2b26-4d62-9425-4a50b8fac7a1",
  hashTurma: "68399769-3e39-4492-a7ca-8d4003c442b2",
  nomeEtapa: ""
}


select * from "AnoLetivo" t where t."Hash" = 'e55e2569-481e-4335-a2ee-1302b5fc60bd';
select * from "Disciplina" t where t."Hash" = '5a4c966a-6edd-42dd-ac73-7b16c1dd2fc3';
select * from "Escola" t where t."Hash" = '29461a1f-bab1-40ec-8a6d-88489a46a70b';
select * from "Rede" t where t."Hash" = '7c72bd11-7356-4fdc-ba16-3e8055d5879f';
select * from "Serie" t where t."Hash" = 'ed2d9286-2b26-4d62-9425-4a50b8fac7a1';
select * from "Turma" t where t."Hash" = '68399769-3e39-4492-a7ca-8d4003c442b2';

-- request para o notas usando hashOrigem
{
  "hashOrigemAnoLetivo": "6e730b17-81f4-4486-91b5-e9db0bbcb5d5",
  "hashOrigemDisciplina": "33ff820f-81ca-4517-b118-1abdb93f58c0",
  "hashOrigemEscola": "cf3d816e-252a-4566-bfcb-e11f7a6a19c0",
  "hashOrigemRede": "cd72b088-2fda-4600-9f08-c452e107a091",
  "hashOrigemSerie": "4df9127c-d31e-478b-a947-04dc7cb51387",
  "hashOrigemTurma": "6479f646-f27c-4d79-abf5-9b7ec1b05d53",
  "dataInicio": "2025-01-01T20:07:36.680Z",
  "dataTermino": "2025-10-31T20:07:36.680Z"
}


select * from "Serie" s where s."Hash" = 'ed2d9286-2b26-4d62-9425-4a50b8fac7a1';

select * from "EscolaSerie" es where es."HashOrigem" = '0fbda349-1174-4f68-b1dd-a7731bfed39c';

select * from "Serie" s where s."Hash" = 'ed2d9286-2b26-4d62-9425-4a50b8fac7a1';

select * from "Turma" t where t."Hash" = '68399769-3e39-4492-a7ca-8d4003c442b2';


select * from "Turma" t where t."HashOrigem" = '5ebb7b1d-6b60-440b-85e1-53e2bd08c6c2'; -- 30291
select * from "Turma" t where t."Hash" = '68399769-3e39-4492-a7ca-8d4003c442b2'; -- 31669




select * from "Aluno" a where a."Turma" = 31669;

select * from "Aluno" a where a."RA" = '25449293';