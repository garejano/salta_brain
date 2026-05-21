select * from Turma t ;

select * from Etapa e;
select * from EscolaSerieEtapa ese;



select * from Rede r where r.Nome like '%Imp%';


select * from Usuario u where u.Email like '%arejano%'; --1097334


SELECT DISTINCT ua.RedeId
FROM ModuloAuth.UsuarioAcesso ua
WHERE ua.FuncionalidadeId = 90
  AND ua.UsuarioId = 1097334;