\[16h59]Rodrigo Alves de Souza Explicando o que tô fazendo. View vai passar a ter:



EtapaDeComponenteAnual

EtapaDeComponenteSemestral

EtapaDeComponenteTrimestral

EtapaDeComponenteBimestral

Além dos atuais EtapaDeBoletim, EtapaDiversificada, EtapaDeSimulados...

Filtrar de acordo com o escopo selecionado. Vai trazer só as Disciplinas x Colunas relacionadas.

Por enquanto as colunas automáticas vão sumir. Tenho uma reunião agora, trato isso na sequência.\[17h01]Vou criar colunas de itinerário para essas automáticas também. Vai facilitar outros processos. (boletim)

\[17h01]Ah, só fiz na ViewConfiguradorAvaliacao por enquanto... Não lembro onde é usada a outra?

\[17h03]Gustavo Arejano VIewConfiguradorAvaliacaoDisciplina

\[17h03]Rodrigo Alves de Souza Sim.

\[17h03]Mas onde é usada?

\[17h03]Chutaria que para listar as disciplinas que podem ser selecionadas para uma avaliação.

\[17h04]Gustavo Arejano no BuscaManager que monta a lista de disciplinas para usar no cadastro

\[17h04]Rodrigo Alves de Souza Ok.

\[17h05]Esse vai ser mais simples.

\[18h07]Rodrigo Alves de Souza Voltei. Seguindo...

\[18h18]Rodrigo Alves de Souza Incluso em ViewConfiguradorAvaliacaoDisciplina: IdItinerarioFormativoCiclo.

Filtrar de acordo com o escopo:



Se for escopo de boletim regular, esse campo precisa ser null (não precisa chavear se é separado ou não, a view já trata)

Se for algum escopo de componente formativo, campo precisa ser o Id do componente correspondente (imagino que fizeram um enum)

Outros escopos, nada a alterar

\[18h18]Restariam as colunas de média/total/situação/faltas, que vou tratar aqui.


Nova Msg:


Rodrigo Alves de Souza  [15h09]
Em teoria criadas as colunas de Total/Média/Situação por ItinerarioFormativoCiclo.
4 respostasGustavo Arejano  [17h55]
Cara, isso foi criado onde? ViewConfiguradorAvaliacao?
Rodrigo Alves de Souza  [18h]
SELECT EsAv.*
FROM EstruturaAvaliacao AS EsAv
INNER JOIN TipoAvaliacao AS TiAv ON TiAv.Id = EsAv.TipoAvaliacao
WHERE TiAv.AnoLetivo = 2026 AND EsAv.Ativo = 1 AND EsAv.ItinerarioFormativoCiclo IS NOT null AND (TiAv.Total = 1 OR TiAv.Media = 1 OR TiAv.Situacao = 1);Rodrigo Alves de Souza  [18h06]
Daí já deveria aparecer na view.
Gustavo Arejano  [18h09]
blz, vendo.
