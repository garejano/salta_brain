select *
from "EscolaAnoLetivo" eal 
inner join "AnoLetivo" al on al."Id" = eal."AnoLetivo"
where eal."CNPJ" like '%22.613.895/0012-25%';

select *
from "EscolaAnoLetivo" eal 
inner join "AnoLetivo" al on al."Id" = eal."AnoLetivo"
where eal."CNPJ" like '%09.159.156/0002-75%';

select *
from "EscolaAnoLetivo" eal 
inner join "AnoLetivo" al on al."Id" = eal."AnoLetivo"
where eal."NomeOficial" like '%Vila da Penha%';

select * from "AnoLetivo" al where al."Id" in (2,17,4,8,22,133);



id alterado: 1320
Endereco: Avenida Padre Roser, 74
CEP: 21220-560