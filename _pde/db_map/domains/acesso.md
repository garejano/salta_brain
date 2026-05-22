# Acesso / Identidade

## Conceitos principais

- Pessoa: identidade central (contém Hash único)
- PessoaEscola: vínculo de uma Pessoa com uma Escola
- PessoaEscolaAcesso: credencial de acesso ao portal (Id referenciado por AlunoEscola_key)

## Notas de schema

- Para obter hash do aluno: AlunoEscola_key -> PessoaEscolaAcesso -> PessoaEscola -> Pessoa.Hash

## Tabelas principais (hubs)

- **LogAcessoProduto** (PK: `Id`) — 8 FK(s) de negócio
- **ProdutoPermissao** (PK: `Id`) — 7 FK(s) de negócio
- **PesquisaSatisfacaoUsuario** (PK: `Id`) — 6 FK(s) de negócio
- **ProfessorPerfilVigente** (PK: `Id`) — 6 FK(s) de negócio
- **AnamnesePessoaResposta** (PK: `Id`) — 4 FK(s) de negócio

## Todas as tabelas

- **AcessoSeesaw** (PK: `Id`, 2 FK(s) negócio)
- **AnamnesePessoa** (PK: `Id`, 2 FK(s) negócio)
- **AnamnesePessoaResposta** (PK: `Id`, 4 FK(s) negócio)
- **AnamnesePessoaRespostaOpcao** (PK: `Id`, 3 FK(s) negócio)
- **AtendimentoEspecialistaPessoa** (PK: `Id`, 1 FK(s) negócio)
- **AtendimentoPessoa** (PK: `Id`, 2 FK(s) negócio)
- **BaseDeAcessos** (PK: `Id, Id`, 0 FK(s) negócio)
- **BaseDeUsuariosParaMarketing** (PK: `Id`, 0 FK(s) negócio)
- **ConfiguracaoGlobalUsuario** (PK: `Id`, 0 FK(s) negócio)
- **ConteudoOnlinePerfil** (PK: `Id`, 2 FK(s) negócio)
- **EspecialistaPessoa** (PK: `Id`, 3 FK(s) negócio)
- **ExcecoesDeAcesso** (PK: `Id`, 4 FK(s) negócio)
- **FalhaLogin** (PK: `Id`, 0 FK(s) negócio)
- **FotoPessoa** (PK: `Id`, 2 FK(s) negócio)
- **GrupoPerguntaPerfilAcesso** (PK: `Id`, 2 FK(s) negócio)
- **LIV_ImportacaoDadosLinhasUsuario** (PK: `Id`, 2 FK(s) negócio)
- **LIV_LOG_Acessos** (PK: `Id`, 1 FK(s) negócio)
- **LIV_NotificacaoUsuario** (PK: `Id`, 1 FK(s) negócio)
- **LIV_PerfilAcessoAcaoMarketing** (PK: `Id`, 2 FK(s) negócio)
- **LIV_PerfilAcessoMaterial** (PK: `Id`, 2 FK(s) negócio)
- **LIV_PerfilAcessoNoticia** (PK: `Id`, 2 FK(s) negócio)
- **LIV_UsuarioInativo** (PK: `Escola, Usuario`, 1 FK(s) negócio)
- **LIV_UsuarioSegmento** (PK: `Id`, 1 FK(s) negócio)
- **LIV_WebinarPerfilAcesso** (PK: `Id`, 1 FK(s) negócio)
- **LogAcesso** (PK: `Id`, 0 FK(s) negócio)
- **LogAcessoPlataformaAdaptativa** (PK: `Id`, 3 FK(s) negócio)
- **LogAcessoProduto** (PK: `Id`, 8 FK(s) negócio)
- **LogAcessoResultadoBimestral** (PK: `Id`, 2 FK(s) negócio)
- **LogAcessoTipo** (PK: `Id`, 0 FK(s) negócio)
- **LogInconsistenciaImportacaoPedidoEditora** (PK: `Id`, 0 FK(s) negócio)
- **LogUpdateDadosPessoais** (PK: `Id`, 3 FK(s) negócio)
- **LogUpdateFotoPessoa** (PK: `Id`, 3 FK(s) negócio)
- **POAPessoa** (PK: `Id`, 1 FK(s) negócio)
- **POAPessoa_Modulo** (PK: `—`, 0 FK(s) negócio)
- **PerfilAcesso** (PK: `Id`, 0 FK(s) negócio)
- **PerfilAcessoFuncionalidade** (PK: `Id`, 4 FK(s) negócio)
- **PerfilAcessoFuncionalidadeSegmentoAgrupamento** (PK: `Id`, 4 FK(s) negócio)
- **PerfilAcessoTipoRede** (PK: `Id`, 2 FK(s) negócio)
- **PerfilDeAcessoDoUsuario** (PK: `Id`, 3 FK(s) negócio)
- **PermissaoCartaoCredito** (PK: `Id`, 0 FK(s) negócio)
- **PermissaoDW** (PK: `Id`, 1 FK(s) negócio)
- **PesquisaOpiniaoUsuario** (PK: `Id`, 1 FK(s) negócio)
- **PesquisaPublicoPerfilAcesso** (PK: `Id`, 1 FK(s) negócio)
- **PesquisaResultadoPerfilAcesso** (PK: `Id`, 1 FK(s) negócio)
- **PesquisaSatisfacaoUsuario** (PK: `Id`, 6 FK(s) negócio)
- **Pessoa** (PK: `Id`, 3 FK(s) negócio)
- **PessoaAprovadaConselho** (PK: `Id`, 1 FK(s) negócio)
- **PessoaDadosAlterados** (PK: `Id`, 1 FK(s) negócio)
- **PessoaDePara** (PK: `Id`, 3 FK(s) negócio)
- **PessoaDocumento** (PK: `Id`, 2 FK(s) negócio)
- **PessoaEndereco** (PK: `Id`, 0 FK(s) negócio)
- **PessoaJuridica** (PK: `Id`, 0 FK(s) negócio)
- **PessoaRedeEmail** (PK: `Id`, 2 FK(s) negócio)
- **PessoaSegmento** (PK: `Id`, 4 FK(s) negócio)
- **PessoaTelefone** (PK: `Id`, 1 FK(s) negócio)
- **ProdutoPermissao** (PK: `Id`, 7 FK(s) negócio)
- **ProfessorPerfilVigente** (PK: `Id`, 6 FK(s) negócio)
- **RedeAcesso** (PK: `Id`, 1 FK(s) negócio)
- **RelatorioAcessoFinanceiro** (PK: `IdVisualizacao`, 0 FK(s) negócio)
- **ServicoPerfilAcesso** (PK: `Id`, 2 FK(s) negócio)
- **TempLogUpdateUsuario** (PK: `—`, 0 FK(s) negócio)
- **TermosDeUsoRedePerfil** (PK: `Id`, 3 FK(s) negócio)
- **Usuario** (PK: `Id, Id`, 2 FK(s) negócio)
- **UsuarioAcesso** (PK: `Id`, 0 FK(s) negócio)
- **UsuarioAcessoGuia** (PK: `Id`, 0 FK(s) negócio)
- **UsuarioAcessoGuiaFinanceiro** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioAuthToken** (PK: `Id`, 0 FK(s) negócio)
- **UsuarioFuncionalidade** (PK: `—`, 0 FK(s) negócio)
- **UsuarioLIV** (PK: `Id`, 0 FK(s) negócio)
- **UsuarioLIVConteudoLIV** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioLinha** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioLogarComo** (PK: `Id`, 0 FK(s) negócio)
- **UsuarioProdutoDestaque** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioRede** (PK: `—`, 0 FK(s) negócio)
- **UsuarioSismat** (PK: `—`, 0 FK(s) negócio)
- **UsuarioUltimoFiltro** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioVisualizouCampanha** (PK: `Id`, 1 FK(s) negócio)
- **UsuarioVisualizouRegraPLAD** (PK: `Id`, 0 FK(s) negócio)
- **Usuario_Origem** (PK: `—`, 0 FK(s) negócio)
- **Usuario_id_origem** (PK: `—`, 0 FK(s) negócio)
- **UsuariosNotificacaoEnvioCartao** (PK: `Id`, 0 FK(s) negócio)
- **bkp_email_usuario** (PK: `—`, 0 FK(s) negócio)
- **temp_BasicAcessouUltimosMeses** (PK: `—`, 0 FK(s) negócio)

## Views disponíveis

- **AcessoUsuarioPorDia** — colunas: `UsuarioId`, `Email`, `PessoaId`, `PessoaNome`, `Sexo`, `Matricula`, `AnoLetivo`, `TurmaId`, `TurmaNome`, `EscolaId`, `EscolaNome`, `RedeId`, `RedeNome`, `ContrataApoioPedagogico`, `DataAcesso`
- **PerfilAcesso** — colunas: `HashProduto`, `Hash`, `Nome`, `EhPerfilProfessor`, `EhPerfilResponsavel`, `EhPerfilAluno`, `Ativo`, `DataInclusao`, `DataUltimaAlteracao`, `DataInativacao`
- **PerfilAcessoFuncionalidade** — colunas: `Hash`, `HashProduto`, `HashFuncionalidade`, `HashPerfilAcesso`, `TodasAsRedes`, `HashRede`, `TodasAsEscolas`, `HashEscola`, `Ativo`, `DataInclusao`, `DataUltimaAlteracao`, `DataInativacao`
- **Usuario** — colunas: `Hash`, `IdProduto`, `HashProduto`, `IdUsuario`, `HashUsuario`, `Nome`, `CPF`, `Email`, `ElevaIdUserToken`, `Ativo`
- **UsuarioAcesso** — colunas: `UsuarioId`, `FuncionalidadeId`, `HashRede`, `RedeId`, `HashEscola`, `EscolaId`, `PossuiAcessoProfessor`, `PossuiAcessoMonitor`, `PossuiAcessoCoordenacao`
- **UsuarioAleatorio** — colunas: `Id`
- **UsuarioProfessor** — colunas: `Hash`, `Nome`, `Ativo`, `DataInclusao`, `DataUltimaAlteracao`, `DataInativacao`
- **UsuarioResponsavel** — colunas: `Hash`, `Nome`, `Ativo`, `DataInclusao`, `DataUltimaAlteracao`, `DataInativacao`
- **UsuariosAtivosSaltaId** — colunas: `Id`, `Nome`, `CPF`, `Email`, `Matricula`, `ElevaId`, `ElevaIdUserName`, `EhAluno`, `EhResponsavel`, `EhProfessor`, `EhMonitor`, `EhColaborador`
- **VIEW_USUARIO** — colunas: `Email`
- **ViewAcessoGuiaPortal** — colunas: `Id`, `IdUsuario`, `NomeGuia`, `LinkArquivo`, `VisualizouGuia`, `DispensouGuia`
- **ViewAcessosPontue** — colunas: `Id`, `NomePessoa`, `HashUsuario`, `NomePerfilAcesso`, `HashPerfilAcesso`, `NomeEscola`, `CnpjEscola`, `NomeTurma`, `HashTurma`, `Matricula`, `CPF`, `Email`, `HashEscola`
- **ViewAcessosPortalETL** — colunas: `AnoAcesso`, `Mes`, `RedeId`, `Rede`, `EscolaId`, `Escola`, `SerieId`, `Serie`, `TurmaId`, `Turma`, `Matricula`, `Aluno`, `FuncionalidadeId`, `Funcionalidade`, `AnoLetivo`, `Qtd de Acessos`
- **ViewFotoPessoa** — colunas: `Id`, `IdPessoa`, `CodPessoa`, `IdAnoLetivo`, `FotoURL`
- **ViewFotoPessoaBase64** — colunas: `Id`, `IdPessoa`, `HashPessoa`, `IdFotoPessoa`, `IdAnoLetivo`, `FotoPessoa`
- **ViewInformacaoSaidaDadosUsuariosAgentes** — colunas: `IdPessoaEscolaAcesso`, `HashRede`, `HashEscola`, `HashPessoa`, `Nome`, `Telefone`, `Rg`, `Cpf`, `Sexo`, `HashUsuario`, `Email`, `AcessoExclusivoGoogle`, `AcessoExclusivoElevaId`, `PessoaUltimaAlteracaoData`, `UsuarioUltimaAlteracaoData`
- **ViewLogAcesso** — colunas: `IdRede`, `NomeRede`, `IdEscola`, `NomeEscola`, `IdPerfilAcesso`, `NomePerfilAcesso`, `IdPessoa`, `NomePessoa`, `Email`, `IdProduto`, `NomeProduto`, `Id`, `DataAcesso`
- **ViewLogAcessoPerfil** — colunas: `Id`, `IdUsuario`, `DataAcesso`, `Origem`, `Token`, `Ativo`, `EhLogarComo`, `IdUsuarioLogarComo`, `IPAddress`, `HashUsuario`, `IdPessoa`, `HashPessoa`, `NomePessoa`, `IdRede`, `HashRede`, `NomeRede`, `IdPerfilAcesso`, `HashPerfilAcesso`, `NomePerfilAcesso`, `EhPerfilFuncionario`
- **ViewPOAPessoaModulo** — colunas: `Id`, `POAPeriodo`, `Pessoa`, `TokenAcesso`, `UsuarioInclusao`, `DataInclusao`, `UsuarioInativacao`, `DataInativacao`, `Ativo`, `Foto`, `Hash`
- **ViewPerfilAcessoSegmento** — colunas: `Id`, `IdPessoaEscolaAcesso`, `IdPerfilAcesso`, `PerfilAcesso`, `IdFuncionalidade`, `Funcionalidade`, `IdSegmento`, `Segmento`, `HashSegmento`, `IdRede`, `HashRede`, `IdEscola`, `HashEscola`
- **ViewPessoaSegmentoEmailCorporativo** — colunas: `Id`, `IdSegmento`, `IdEscola`, `IdAnoLetivo`, `EmailCorporativo`
- **ViewPossuiUsuarioPessoaRedeEmail** — colunas: `Id`, `IdPessoa`, `IdUsuario`, `IdRede`, `Email`
- **ViewServicoPerfilAcesso** — colunas: `Id`, `PerfilAcesso`, `ChamadoOtrsTipo`, `ChamadoOtrsTipoPai`, `NomeChamadoOtrsTipo`, `ServicoOtrsId`, `ChamadoOtrsFila`, `ChamadoOtrsSLA`
- **ViewUsuarioAcesso** — colunas: `Id`, `IdUsuario`, `HashUsuario`, `IdPessoa`, `HashPessoa`, `IdPessoaEscola`, `HashPessoaEscola`, `IdPessoaEscolaAcesso`, `HashPessoaEscolaAcesso`, `NomePessoa`, `IdMarca`, `HashMarca`, `NomeMarca`, `IdRede`, `HashRede`, `NomeRede`, `NomeIntelped`, `RedePropria`, `TipoRede`, `IdEscola`, `HashEscola`, `NomeEscola`, `IdEscolaMae`, `HashEscolaMae`, `NomeEscolaMae`, `EhCentralDaRede`, `CnpjEscola`, `AcessoBoletoNF`, `IdPerfilAcesso`, `HashPerfilAcesso`, `NomePerfilAcesso`, `EhPerfilFuncionario`, `Email`, `Matricula`, `CPF`, `Token`
- **ViewUsuarioAcessoPlurall** — colunas: `IdRede`, `NomeRede`, `IdPessoa`, `NomePessoa`, `CPF`, `IdUsuario`, `Email`, `IdEscola`, `NomeEscola`, `CnpjEscola`, `IdPerfilAcesso`, `NomePerfilAcesso`, `IdSegmento`, `NomeSegmento`, `Cargo`
- **ViewUsuarioAcesso_backup** — colunas: `Id`, `IdUsuario`, `HashUsuario`, `IdPessoa`, `HashPessoa`, `IdPessoaEscola`, `HashPessoaEscola`, `IdPessoaEscolaAcesso`, `HashPessoaEscolaAcesso`, `NomePessoa`, `IdRede`, `HashRede`, `NomeRede`, `RedePropria`, `TipoRede`, `IdEscola`, `HashEscola`, `NomeEscola`, `EhCentralDaRede`, `CnpjEscola`, `AcessoBoletoNF`, `IdPerfilAcesso`, `HashPerfilAcesso`, `NomePerfilAcesso`, `EhPerfilFuncionario`, `Email`, `Token`
- **ViewUsuarioLIV** — colunas: `Id`, `IdUsuario`, `IdPessoaEscolaAcesso`, `IdPessoaEscola`, `IdPessoa`, `NomePessoa`, `IdRede`, `NomeRede`, `RedePropria`, `IdEscola`, `NomeEscola`, `IdPerfilAcesso`, `NomePerfilAcesso`, `EhPerfilFuncionario`
- **ViewUsuarioLogin** — colunas: `Id`, `IdUsuario`, `Nome`, `Email`, `CPF`, `Matricula`, `Senha`, `AcessoExclusivoGoogle`, `AcessoExclusivoElevaId`
- **ViewUsuarioRemocaoClassroom** — colunas: `Id`, `IdPessoa`, `NomePessoa`, `IdRede`, `IdEscola`, `IdAnoLetivo`, `IdTurma`, `NomeTurma`, `IdCourse`, `ClassroomOwnerId`, `PossuiTurmaClassroom`, `IdTurmaClassroom`, `IdDisciplina`, `TurmaClassroomPessoaEscolaAcessoId`, `PossuiTurmaClassroomPessoaEscolaAcesso`, `UserProfileId`, `EmailSincronizado`
- **ViewUsuariosAcessoMangaHighColeguium** — colunas: `IdUsuario`, `IdEscolaMangaHigh`, `IdTurmaMangaHigh`, `LoginMangaHigh`, `SenhaMangaHigh`, `NomeUsuario`, `SobrenomeUsuario`

