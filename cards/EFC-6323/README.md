Esse card ja foi executado, os arquivos nessa pasta ../EFC-6323 mostram o que foi feito

repositorio: estrutura-pedagogica.

- refine esse documento
- analise a msg do QA e crie um documento para validacao.
- em caso de duvidas utilize o mcp do sql server para entender
- nao consulte nada fora do repositorio estutura-pedagogica
- preciso entender se o que foi feito nessa tarefa foi feito corretamente, ou precisa algo mais.




O QA testou o card e fez essa descricao:

Descrição do problema
Quando definimos para determinado perfil que uma escola tenha apenas a permissão de seleção de componente formativo, a escola não está conseguindo fazer a alocação. A mesma escola, com outro perfil com permissão de alocação e configuração está conseguindo fazer a alocação.

Ambiente
Ambiente: homologação

Usuário utilizado: usuário com perfil de suporte / Escola: Elite MG

Pré-condições
Escola Elite MG com permissão apenas de seleção no perfil suporte

Passos para reproduzir
Logar no sistema com um perfil de suporte

Acessar alocação de componente formativo

Filtrar pela escola Elite MG

Resultado obtido
Não é possível fazer alocação de componente formativo

Resultado esperado
Usuário deveria conseguir fazer alocações

Evidências
Usuário com perfil suporte tentando alocar componente formativo com a escola Elite MG

Captura de tela 2026-05-11 162949.png
Usuário com perfil rotinas pedagógicas (permissão de seleção e configuração)

image.png
Impacto
Um usuário que tenha perfil apenas de seleção para determinada(s) escola(s) não consegue fazer a alocação de componente formativo

Frequência
Sempre ocorre
