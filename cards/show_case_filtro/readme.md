Contexto: em algumas telas do frontend utilizamos um componente de filtro para 'filtrar' os dados que queremos em tela

o planejamento dessa implementacao deve viver nessa pasta ../show_case_filtro

primeiro planejar tudo e depois valido
caso tenha tuvidas, inclua no planejamento que trato na sequencia

filtro_novo: estrutura-pedagogica c:/projects/estrutura-pedagogica/frontend/src/shared/filtro

filtro_antigo: documentacao-pedagogica c:/projects/documentacao-pedagogica/frontend/src/app/filtro

em estrutura-pedagogica existe o modulo de exemplos que eh onde essa filtro-tour deve ser criado.

no modulo de estrutura-pedagogica foi criado um modulo/componente filtro_novo que facilita a construcao de filtros em tela apartir de uma configuracao
simples e dinamica, permitindo que filtro sejam criados de forma facil pelo desenvolvedor

- entender se a estrutura do modulo filtro tbm facilita para a IA implementar diferentes filtros
- entendo que uma configuracao eh mais facil de replicar do que o filtro_antigo 'manual' com varios fluxos



antes desse modulo de filtro_novo, o padrao era em cada tela construir todo um fluxo de filtro para ela, e no final cada tela tinham
uma complexidade maior so pelo filtro.

um exemplo disso esta no modulo de documentaca-pedagogica em src/app/filtro/filtro.component.ts
tecnicamente ele funciona mas com muito codigo e repeticao de codigo com fluxos dificeis de debugar manualmente
- entender se para a IA esse cenario tbm seria ruim (uma comparacao entre filtro_antigo e filtro_novo)


A ideia central eh ter uma tela em exemplos/filtros-tour que explique as novas features do filtro_novo de estrutra-pedagogica
- destacar vantagens
- visualmente eh uma landing-page de apresentacao do filtro_novo, nao precisa de enrolacao, eh mais tecnico
- de como ele pode facilitar no desenvolvimento do dev e da IA

- uma sessao da landingpage tem que ter exemplos dos filtros e suas funcionalidade e configuracaoes visuaisi
para mostrar aos devs a quantidade de coisas que podem ser feitas de forma facil
 
- tenha uma parte tecnica explicando o motivo da existencia do modulo de filtro
 - analise o codigo do modulo para entender as vantagens tecnicas, componentes dinamicos e injetados sem muito uso de template
 - o filtro_novo tbm tem localstorage que salva alguns dados entre fluxos que funciona sem dificuldade
- analise de qualidade de codigo, dificuldade de manutencao do filtro_antigo vs filtro_novo
- comparacao da dificuldade de manutencao, melhorias, extensibilidade


- entender numeros e algumas metricas do uso do filtro_novo no repositorio de estrutura-pedagogica para
mostrar que o componente novo funciona a longo prazo e em varis situacoes



