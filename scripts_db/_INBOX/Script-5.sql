SELECT TOP (10) *
FROM dbo.ViewConselhoDeClasse AS vcdc where vcdc.IdRede = 2 and vcdc.IdAnoLetivo = 2024 and vcdc.IdEscola = 3;

select * from Rede r where r.Nome like 'Pensi';
select * from Escola e where e.Rede = 2;



EXEC sp_helptext 'dbo.ViewConselhoDeClasse';