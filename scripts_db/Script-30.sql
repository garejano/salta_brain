select top 10 * from ModuloAuth.UsuarioAcesso ua;

select * from Escola e where e.Id = 4;


SELECT u.Id, u.Email, 'Coordenador (A)' AS Papel
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Usuario u ON u.Id = ua.UsuarioId
WHERE ua.FuncionalidadeId = 101
  AND ua.EscolaId = 2
  AND EXISTS (
      SELECT 1 FROM ModuloAuth.UsuarioAcesso
      WHERE UsuarioId        = ua.UsuarioId
        AND EscolaId         = ua.EscolaId
        AND FuncionalidadeId = 68
  );




SELECT
    e.Id,
    e.Nome  AS Escola,
    r.Nome  AS Rede,
    COUNT(DISTINCT ua.UsuarioId) AS Usuarios
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Escola e ON e.Id = ua.EscolaId
JOIN dbo.Rede   r ON r.Id = e.Rede
WHERE ua.FuncionalidadeId = 101
  AND e.Ativo = 1
GROUP BY e.Id, e.Nome, r.Nome
ORDER BY Usuarios DESC;



select * from Pessoa p where p.Nome = 'CLALOREM IPSUM DOLORS';


select * from Funcionalidade f where f.Id in (101,68);