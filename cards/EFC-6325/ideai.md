esse documento nao pode ser alterado, ele eh a fotografia da ideia inicial.

pasta onde todos os documentos MD criados devem ir: EFC-666

para estruturarmos o projeto, precisa ser criado
inspect.md - esse documento deve conter a analise da foto atual de 'gerador-documentos'
product.md - esse documento eh a ideia.md refinada (um documento de produto do novo module)
tarefas.md - onde eu como dev vou colocar as tarefas para serem executar pela ia.
changelog.md onde a IA sempre registra o que foi feito e por qual motivo
analise_melhorias.md - onde a IA vai descrever as melgorias possiveis no codigo atual de gerador-documentos
implement_plan.md - sempre qie a IA ler uma tarefa, vai ser criado aqui um plano da tarefa





### Inicio - Ideia base
esse componente 'gerador-documentos' esta sendo usado em outro repositorio. ele foi movido pra estrutura-pedagogica pois sera usado para outros documentos
e antes vamos tentar melhorar ele

componentes que implementar um 'documento' usando gerador-documentos estao em gerador-documentos/exemplos


a ideia fazer algumar analises e melhoria

a ideia inicial do componente eh ter uma forma "facil" de gerar documentos para impressao ou pdf

features atuais:
page-control.service foi idealizado para controlar a quantidade de paginas e quais componentes estao dentro de cada pagina
print.service foi idealizado para cuidar apenas da parte de impressao e geracao de pdf com htmlToImage e jsPDF


features esperadas:





Analise de possiveis melhorias:
- entender se as ultimas versoes de htmlTOImage e jsPDF tem melhorias de performance que podem ser incluidas em print.service



objetivos:
document-builder deve ter os componentes base (title,assinatura,moldura e etc) todos componentes devem ser nomeados em ingles
document-builder deve ser criado pensando de forma "generica e agnostica" com responsabilidades bem separadas

no modulo filtro que fica em shared/filtro foi pensando com componentes injetaveis, para ter dinamismo e nao usar templates.
um filtro sempre eh "iniciado" com uma config de filtro, como objetivo de facilitar a criacao de filtros.
o document-builder deveria ser pensado usando a mesma tecnica, com objetivo final "um documento eh apenas um arquivo de configuracao bem definido"

analisar em detalhes como criar uma configuracao para o document-builder que facilite o desenvolvimento de documentos


pontos criticos:
um documento pode conter uma tabela, uma tabela pode ter N linhas, isso significa que a tabela precisa "quebrar" entre paginas
componentes criados para ser usado no document-builder tem que ter alguma forma de saber como e quando se dividir (isso eh um ponto crucial)
outro ponto inegociavel: a "estrutura" do documento precisa ser de facil "debbug" page-control.service tem issa ideia.
e isso pode ser melhorado o maximo possivel.
deve ser criado um componente de document-debug que exponha todas as configuracoes e detalhes de um documento, quantas paginas, qual componente esta em cada pagina,
- se o componente divide
- se pagina tem assinatura
- se pagina tem cabecalho
- quantidade de tamanho sobrando em cada pagina
- o maximo de detalhes possivel pensando em tudo que ja existe no gerador de documentos atual.

Primeiros passos:
criar um novo modulo document-builder que sera onde ficara a criacao do modulo que implementar a nova versao de gerador-documentos
- o module deve ter um README.md proprio que sera atualizado no final com as funcionalidades do module
deve ser criado no module de exempos uma nova tela 'documents' para termos uma rota onde testar os documentos
