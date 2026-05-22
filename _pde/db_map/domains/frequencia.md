# Frequência

## Conceitos principais

- Aula: registro de uma aula realizada em uma turma
- EventoFrequencia: evento de chamada associado a uma aula
- FrequenciaAluno: resposta de presença/ausência por aluno

## Fluxo

Turma → Aula → EventoFrequencia → FrequenciaAluno

## Tabelas

- **AlunoAvaliacaoPresenca** (PK: `Id`, 7 FK(s))
- **AlunoAvaliacaoPresenca_bkp** (PK: `—`, 0 FK(s))
- **AlunoAvaliacaoPresenca_bkp2** (PK: `—`, 0 FK(s))
- **AlunoFrequencia** (PK: `Id`, 4 FK(s))
- **AulaEvento** (PK: `Id`, 6 FK(s))
- **AulaEventoAnotacoes** (PK: `Id`, 4 FK(s))
- **AulaEventoConfiguracao** (PK: `Id`, 5 FK(s))
- **AulaEventoDeverDeCasa** (PK: `Id`, 4 FK(s))
- **AulaEventoPauta** (PK: `Id`, 1 FK(s))
- **AulaEventoPautaMensal** (PK: `Id`, 2 FK(s))
- **AulaEventoPautaSemanal** (PK: `Id`, 2 FK(s))
- **AulaEventoUltimaAlteracao** (PK: `Id`, 1 FK(s))
- **AulaOnline** (PK: `Id, Id`, 9 FK(s))
- **AulaOnlineAcesso** (PK: `Id`, 6 FK(s))
- **AulaOnlineAcessoPing** (PK: `Id`, 4 FK(s))
- **Aula_ComentarioComportamento** (PK: `Id`, 4 FK(s))
- **Aula_LancamentoComportamento** (PK: `Id`, 5 FK(s))
- **Chamada** (PK: `Id`, 0 FK(s))
- **DiaSemAula** (PK: `Id`, 1 FK(s))
- **DiaSemAulaMotivo** (PK: `Id`, 3 FK(s))
- **DiaSemAulaTipo** (PK: `Id`, 0 FK(s))
- **DiaSemAulaTurma** (PK: `Id`, 2 FK(s))
- **DuracaoTempoAula** (PK: `Id`, 4 FK(s))
- **FrequenciaProfessor** (PK: `Id`, 6 FK(s))
- **FrequenciaProfessorSubstituto** (PK: `Id`, 6 FK(s))
- **FuncionalidadeTipoPresenca** (PK: `Id`, 2 FK(s))
- **HistoricoHoraAulaPgto** (PK: `—`, 1 FK(s)) — Histórico das alterações da tabela ClassificacaoClassePgto. Os dados são inseridos automáticamente por meio da trigger TrgSalvarHistorico
- **HistoricoHoraAulaSegmentoPgto** (PK: `—`, 1 FK(s))
- **HoraAulaPadrao** (PK: `Id`, 4 FK(s))
- **HoraAulaPgto** (PK: `Id`, 3 FK(s)) — Associação entre o fluxo de classificação e a sua classe de pagamento. Opcionalmente, são declaradas as variáveis para compor o cálculo da folha de pagamento
- **HoraAulaSegmentoPgto** (PK: `Id`, 4 FK(s))
- **ImportacaoFrequencia** (PK: `Id`, 0 FK(s))
- **LIV_FeedbackAula** (PK: `Id`, 5 FK(s))
- **LIV_FeedbackAulaRespostas** (PK: `Id`, 2 FK(s))
- **LIV_FeedbackCadastroAulas** (PK: `Id`, 0 FK(s))
- **LIV_MaterialPlanoAula** (PK: `Id`, 1 FK(s))
- **LIV_StatusPlanoAula** (PK: `Id`, 3 FK(s))
- **LogAulaOnlineAssistida** (PK: `Id`, 1 FK(s))
- **MonitoriaMonitorPresenca** (PK: `Id`, 4 FK(s))
- **MotivoFrequenciaProfessor** (PK: `Id`, 4 FK(s))
- **MotivoFrequenciaProfessorTipoPresenca** (PK: `Id`, 6 FK(s))
- **POANaoPossuiAula** (PK: `Id`, 0 FK(s))
- **POANaoPossuiAula_Modulo** (PK: `—`, 0 FK(s))
- **PercentualFrequencia** (PK: `Id`, 3 FK(s))
- **PercentualFrequenciaLog** (PK: `Id`, 0 FK(s))
- **PeriodoLancamentoFrequenciaProfessor** (PK: `Id`, 4 FK(s))
- **RelatorioLancamentoPresencas** (PK: `Id`, 0 FK(s))
- **RelatorioPresencaEE** (PK: `Id`, 0 FK(s))
- **RelatorioPresencaEmSimulados** (PK: `Id`, 0 FK(s))
- **StatusLancamentoFrequencia** (PK: `Id`, 0 FK(s))
- **TempoAula** (PK: `Id`, 4 FK(s))
- **TipoAulaEvento** (PK: `Id`, 0 FK(s))
- **TipoAulaOnline** (PK: `Id`, 3 FK(s))
- **TipoAulaOnlineRede** (PK: `Id`, 5 FK(s))
- **TipoAulaOnlineRedeSerie** (PK: `Id`, 5 FK(s))
- **TipoChamada** (PK: `Id`, 0 FK(s))
- **TipoFrequencia** (PK: `Id`, 0 FK(s))
- **TipoHoraAula** (PK: `Id`, 0 FK(s)) — Armazenamento dos fluxos para cálculo da folha do professor
- **TipoPresenca** (PK: `Id`, 0 FK(s))
