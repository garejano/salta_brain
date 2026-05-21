select * from Funcionalidade f where f.Nome like '%Bolet%'; -- 92
select * from Usuario u where u.email like '%arejano%'; -- 1097334


select * from ModuloAuth.UsuarioAcesso where UsuarioId = 1097334 and FuncionalidadeId = 92;