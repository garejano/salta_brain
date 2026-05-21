
-- Criar um script que execute este processo:

-- Preciso pegar uma lista de escolas onde a rede pertence ao TipoRede 5
-- Criar uma EscolaGerencial para cada escola que retornar com o mesmo nome da escola e vinculado a rede da escola.
-- UsuarioInclusao deve ser: 1097334
-- DataInclusao deve ser a data atual no formato dos modelos.
-- Demais campos de Alteracao e Inativacao devem ficar em branco.
-- Para Cada EscolaGerencial criada, preciso criar tbm EscolaGerencialEscola, vinculado a escola e a escolaGerencial criada.


select e.Nome, r.Id from Escola e
inner join Rede r on r.Id = e.Rede
where r.TipoRede = 5;


-- seque o modelo de EscolaGerencial
select * from EscolaGerencial eg ;
--Id|RedeId|Nome               |Ativo|Hash                                |UsuarioInclusao|DataInclusao           |UsuarioUltimaAlteracao|DataUltimaAlteracao|DataInativacao|UsuarioInativacao|
----+------+-------------------+-----+------------------------------------+---------------+-----------------------+----------------------+-------------------+--------------+-----------------+
-- 1|     6|Escola Gerencial 1 |    1|C6623244-1D39-4CA2-9392-77E316A1241C|              1|2025-11-26 16:04:12.913|                      |                   |              |                 |


-- seque o modelo de EscolaGerencialEscola
select * from EscolaGerencialEscola ege;
--Id|EscolaGerencialId|EscolaId|AnoLetivo|Ativo|Hash                                |UsuarioInclusao|DataInclusao           |UsuarioUltimaAlteracao|DataUltimaAlteracao|DataInativacao|UsuarioInativacao|
----+-----------------+--------+---------+-----+------------------------------------+---------------+-----------------------+----------------------+-------------------+--------------+-----------------+
-- 1|                1|      16|     2025|    1|20505E3F-4FE9-4FFE-9C24-53C831EBF3DB|              1|2025-11-26 16:04:12.920|                      |                   |              |                 |


-- qualquer duvida, pergunte.