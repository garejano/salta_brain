select * from TwilioRemetente tr;
select * from TwilioRemetenteRede trr;

select * from Usuario u where u.Email like '%arejano%';

select * from Rede r where r.Nome like '%xima%'; -- ID 67
select * from Rede r where r.Nome like '%Antares%'; -- ID 66
select * from Rede r where r.Nome like '%Lato%'; -- AM-ID 53, AC-ID 58, PA-ID-68

-- Remetente
--Maxima -- Prod.ID 67
insert into TwilioRemetente (Hash,Telefone,Ativo,UsuarioInclusao,DataInclusao,Nome) values (NEWID(),'2123915541',1,1097334,GETDATE(),'MAXIMA'); -- id 31
--Antares -- Prod.Id 66
insert into TwilioRemetente (Hash,Telefone,Ativo,UsuarioInclusao,DataInclusao,Nome) values (NEWID(),'8523981264',1,1097334,GETDATE(),'ANTARES'); -- id 32

-- Vinculo Rede -> Remetente
insert into TwilioRemetenteRede (Hash,TwilioRemetente,Rede,Ativo,UsuarioInclusao,DataInclusao) values(NEWID(),31,67,1,1097334,GETDATE());
insert into TwilioRemetenteRede (Hash,TwilioRemetente,Rede,Ativo,UsuarioInclusao,DataInclusao) values(NEWID(),32,66,1,1097334,GETDATE());
insert into TwilioRemetenteRede (Hash,TwilioRemetente,Rede,Ativo,UsuarioInclusao,DataInclusao) values(NEWID(),15,68,1,1097334,GETDATE());

