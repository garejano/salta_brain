# Angular Map — estrutura-pedagogica
> Gerado em: 2026-05-21  
> Fonte: `C:\projects\estrutura-pedagogica\frontend`

## Módulos

- **AppModule** · declara: [AppComponent, ToastrElevaComponent, HomeComponent, PageNotFoundComponent] · importa: [SharedModule, BrowserModule, BrowserAnimationsModule, AppRoutingModule, CommonModule, ... +15]
- **AppRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **BoletimModule** · declara: [BoletimComponent, ProcessamentoBoletimComponent] · importa: [CommonModule, BoletimRoutingModule, SharedModule, FiltroModule]
- **BoletimRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **CargasIniciaisModule** · declara: [CargasIniciaisTabnavComponent, AlocacaoProfessoresComponent, GradeHorariaComponent, ImportarAlocacaoProfessoresComponent, FormEtapaImportacaoComponent] · importa: [SharedModule, CommonModule, CoreModule, FormsModule, FiltroModule, ... +1]
- **CargasIniciaisRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **CoreModule** · declara: [OnlyNumberDirective] · importa: [CommonModule, NgxPaginationModule, ReactiveFormsModule, NgSelectModule, FormsModule, ... +11] · exporta: [FontAwesomeModule, TranslateModule, NgxSpinnerModule, ReactiveFormsModule, ... +2]
- **DocumentBuilderModule** · importa: [CommonModule]
- **DocumentEditorModule** · declara: [DocumentEditorComponent, EditorCanvasComponent, BlockLibraryComponent, BlockInspectorComponent] · importa: [CommonModule, FormsModule, RouterModule, DragDropModule, DocumentBuilderModule] · exporta: [DocumentEditorComponent]
- **DynamicComponentsModule** · declara: [TextareaFieldComponent, TextFieldComponent, MultiSelectFieldComponent, SelectFieldComponent, NumberFieldComponent, ... +8] · importa: [CommonModule, ReactiveFormsModule, FormsModule] · exporta: [TextareaFieldComponent, TextFieldComponent, MultiSelectFieldComponent, SelectFieldComponent, ... +9]
- **EscolasGerenciaisModule** · declara: [CadastroEscolaGerencialComponent, ListarEscolaGerencialComponent, EditarEscolaGerencialComponent] · importa: [SharedModule, CommonModule, CoreModule, FormsModule, FormularioModule, ... +2]
- **EscolasGerenciaisRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **EscolasPublicasModule** · declara: [EscolasPublicasListarComponent, EscolasPublicasEditarComponent, EscolasPublicasDetalhesComponent, CadastroEscolaPublicaComponent, RemoverTurmaComponent, ... +4] · importa: [SharedModule, FormsModule, CommonModule, CoreModule, EscolasPublicasRoutingModule, ... +1]
- **EscolasPublicasRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **EtapasModule** · declara: [ListarComponent, EditarEtapasComponent] · importa: [SharedModule, FormsModule, ReactiveFormsModule, CommonModule, EtapasRoutingModule, ... +1] · exporta: [EditarEtapasComponent]
- **EtapasRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **ExemplosModule** · declara: [FormulariosComponent, FiltrosComponent, TelaBaseComponent, InfoBaseComponent, TableFilterComponent, ... +6] · importa: [CommonModule, DynamicComponentsModule, ExemplosRoutingModule, FormularioModule, FiltroModule, ... +5]
- **ExemplosRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **FichaIndividualModule** · declara: [FichaIndividualComponent] · importa: [CommonModule, DocumentBuilderModule, FichaIndividualRoutingModule]
- **FichaIndividualRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **FiltroModule** · declara: [FiltroComponent, FilterFieldWrapperComponent] · importa: [FormsModule, CommonModule, SharedModule] · exporta: [FiltroComponent]
- **FolhaModule** · declara: [ListarChecklistComponent, CargasIndevidasComponent, ProfessoresSemScComponent, DisciplinasSemTitularComponent, FolhaPreviaListarComponent, ... +25] · importa: [SharedModule, CommonModule, FolhaRoutingModule, CoreModule, FormsModule, ... +2]
- **FolhaRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **FormularioModule** · declara: [FormularioComponent] · importa: [CoreModule, CommonModule, DynamicComponentsModule] · exporta: [FormularioComponent]
- **GradeHorariaModule** · declara: [ConfiguradorTempoPadraoComponent] · importa: [SharedModule, FiltroModule, FormsModule, ReactiveFormsModule, CommonModule, ... +1]
- **GradeHorariaRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **ItinerarioFormativoModule** · declara: [ListarItinerariosComponent, EditarItinerarioComponent, SelecaoItinerarioComponent] · importa: [SharedModule, FiltroModule, FormsModule, CommonModule, CoreModule, ... +2]
- **ItinerarioFormativoRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **MovimentacaoPedagogicaModule** · declara: [AlteracaoCargaComponent, MovimentacaoTabNavigatorComponent, LancamentoEventosComponent, AlteracaoCargaDetalhesComponent, CentralMovimentacaoPedagogicaComponent, ... +4] · importa: [SharedModule, CommonModule, CoreModule, FormsModule, FiltroModule, ... +1]
- **MovimentacaoPedagogicaRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **NomeDoModuloModule** · declara: [NomeDoModuloComponent] · importa: [CommonModule, NomeDoModuloRoutingModule]
- **NomeDoModuloRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **OcorrenciaModule** · declara: [ListarOcorrenciaComponent, CadastroTipoOcorrenciaComponent] · importa: [SharedModule, CommonModule, FormsModule, CoreModule, OcorrenciaRoutingModule, ... +1]
- **OcorrenciaRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **PeriodoLetivoModule** · declara: [EditarPeriodoLetivoComponent] · importa: [SharedModule, FormsModule, ReactiveFormsModule, CommonModule, PeriodoLetivoRoutingModule, ... +1] · exporta: [EditarPeriodoLetivoComponent]
- **PeriodoLetivoRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **PortalModule** · declara: [PortalHeaderComponent, PortalMenuComponent, PortalModalComponent, LogarComoComponent, LogoEscolaComponent, ... +14] · importa: [CommonModule, FormsModule, NgbDropdownModule] · exporta: [PortalAuthComponent, PortalHeaderComponent, PortalModuloComponent, PortalBodyComponent, ... +3]
- **RelatorioModule** · declara: [DisciplinasComponent] · importa: [FiltroModule, SharedModule, CommonModule, RelatorioRoutingModule]
- **RelatorioRoutingModule** · importa: [RouterModule] · exporta: [RouterModule]
- **SemConteudoModule** · declara: [SemConteudoComponent] · importa: [CommonModule] · exporta: [SemConteudoComponent]
- **SharedModule** · declara: [ButtonComponent, IconButtonComponent, CirleIconButtonComponent, TituloPageComponent, LoadingComponent, ... +20] · importa: [CommonModule, CoreModule, FormsModule, ScrollingModule, SidePanelComponent] · exporta: [ButtonComponent, IconButtonComponent, CirleIconButtonComponent, TituloPageComponent, ... +25]

## Rotas

- `path.Home` → HomeComponent
- `path.Auth` → PortalAuthComponent
- `periodo-letivo` → periodo-letivo *(lazy)*
- `etapas` → etapas *(lazy)*
- `grade-horaria` → grade-horaria *(lazy)*
- `path.EscolaPublica.Base` → escolas-publicas *(lazy)*
- `path.Relatorio.Base` → relatorio *(lazy)*
- `path.Folha.Base` → folha *(lazy)*
- `path.EscolaGerencial.Base` → escolas-gerenciais *(lazy)*
- `exemplos` → exemplos *(lazy)*
- `path.Ocorrencia.Base` → ocorrencia *(lazy)*
- `path.MovimencataoPedagogica.Base` → movimentacao-pedagogica *(lazy)*
- `path.CargasIniciais.Base` → cargas-iniciais *(lazy)*
- `path.ItinerarioFormativo.Base` → itinerario-formativo *(lazy)*
- `path.PageNotFound` → PageNotFoundComponent
- `path.PageMaintenance` → PageNotFoundComponent
- `boletim` → boletim *(lazy)*
- `ficha-individual` → ficha-individual *(lazy)*
- `**` → ?
- `path.Boletim.Processamento` → ProcessamentoBoletimComponent

## Componentes

### app
- **AppComponent** `app-root`

### boletim
- **BoletimComponent** `app-boletim`
- **ProcessamentoBoletimComponent** `app-processamento`
  - Injeta: FiltroService, NotificationService, ProcessamentoService, Title

### button
- **ButtonComponent** `app-button`
  - @Input: label: string, classButton: string, disabled: boolean, icon: string... +4
  - @Output: clickEvent

### card-info
- **CardInfoComponent** `app-card-info`
  - @Input: title: string, message: string

### card-message
- **CardMessageComponent** `app-card-message`
  - @Input: title: string, iconClass: string, icon: string

### cargas-iniciais
- **AlocacaoProfessoresComponent** `app-alocacao-professores`
  - Injeta: FilterAlocacaoProfessorService, ImportacaoAlocacaoProfessoresService, RouteStateService, Router
- **CargasIniciaisTabnavComponent** `app-cargas-iniciais-navigator`
- **FormEtapaImportacaoComponent** `form-etapa-importacao`
  - @Input: etapa: Step<any>, loading: boolean
  - @Output: submitEvent
- **GradeHorariaComponent** `app-grade-horaria`
- **ImportarAlocacaoProfessoresComponent** `app-importacao`
  - Injeta: FormBuilder, ImportacaoAlocacaoProfessoresService, NotificationService, RouteStateService, Router

### checkbox
- **CheckboxFieldComponent** `app-checkbox`
  - @Input: control: FormControl | null, fieldName: string, checkboxInfo: string

### checkbox-field
- **CheckboxFieldComponent** `app-checkbox-field`
  - @Input: id: string
  - @Output: eventChange
  - Injeta: NgControl

### circle-icon-button
- **CirleIconButtonComponent** `app-circle-icon-button`
  - @Input: icon: string, disabled: boolean
  - @Output: clickEvent

### components
- **AvatarComponent** `app-avatar`
  - @Input: userId: string, userName: string, photoUrl: string | null
  - Injeta: PhotoService
- **TabPeriodoLetivoComponent** `app-tab-periodo-letivo`

### custom-radio
- **CustomRadioComponent** `app-custom-radio`
  - @Input: control: FormControl | null, options: RadioOptions[], fieldName: string, placeholder: string

### date-field
- **DateFieldComponent** `date-field`
  - @Input: control: FormControl | AbstractControl, min: string, max: string, label: string... +2
  - Injeta: DateUtilsService
- **DateFieldComponent** `app-date-field`
  - @Input: control: FormControl | null, fieldName: string, min: string, max: string

### datepicker
- **DatepickerComponent** `app-datepicker`
  - @Input: config: CalendarConfig, min: Date, max: Date, start: Date... +3
  - @Output: change
  - Injeta: DateCalendar

### daterangepicker-field
- **DateRangePickerComponent** `app-daterange-picker`
  - @Input: label: string, required: boolean, nullable: boolean, initialYear: number... +3
  - @Output: eventDateChange
  - Injeta: ElementRef, NgbCalendar, NgbDateParserFormatter, Renderer2

### doc-footer
- **DocFooterComponent** `app-doc-footer`
  - @Input: currentPage: number, totalPages: number

### doc-frame
- **DocFrameComponent** `app-doc-frame`
  - @Input: config: FrameConfig

### doc-header
- **DocHeaderComponent** `app-doc-header`
  - @Input: data: DocHeaderData

### doc-info-grid
- **DocInfoGridComponent** `app-doc-info-grid`
  - @Input: data: DocGridData

### doc-info-row
- **DocInfoRowComponent** `app-doc-info-row`
  - @Input: data: DocInfoRowData

### doc-legend
- **DocLegendComponent** `app-doc-legend`
  - @Input: label: string, items: LegendItem[], fontSize: number, contentWidth: number

### doc-presenca-info
- **DocPresencaInfoComponent** `app-doc-presenca-info`
  - @Input: data: DocPresencaInfoData

### doc-section
- **DocSectionComponent** `app-doc-section`
  - @Input: data: DocSectionData, fontSize: number, contentWidth: number

### doc-signature
- **DocSignatureComponent** `app-doc-signature`
  - @Input: signatories: SignatoryConfig[], city: string, highlight: boolean, signatoriesGap: number... +1

### doc-statement
- **DocStatementComponent** `app-doc-statement`
  - @Input: data: DocStatementData, fontSize: number, contentWidth: number

### doc-table
- **DocTableComponent** `app-doc-table`
  - @Input: data: DocTableData, fontSize: number, contentWidth: number, cellPadding: number... +1

### doc-text
- **DocTextComponent** `app-doc-text`
  - @Input: label: string, value: string, fontSize: number, contentWidth: number

### doc-text-field
- **DocTextFieldComponent** `app-doc-text-field`
  - @Input: label: string, value: string, fontSize: number, contentWidth: number

### doc-title
- **DocTitleComponent** `app-doc-title`
  - @Input: title: string, border: boolean, centered: boolean, fontSize: number... +1

### doc-wide-table
- **DocWideTableComponent** `app-doc-wide-table`
  - @Input: data: DocWideTableData, fontSize: number, contentWidth: number, cellPadding: number... +1
  - Injeta: DocumentLogService

### document-config-panel
- **DocumentConfigPanelComponent** `app-document-config-panel`
  - @Input: config: DocumentConfig
  - @Output: configChange, openInEditor

### document-debug
- **DocumentDebugComponent** `app-document-debug`
  - @Input: pages: Page[], config: DocumentConfig

### document-page
- **DocumentPageComponent** `app-document-page`
  - @Input: page: Page, config: DocumentConfig, index: number, total: number... +1
  - Injeta: ElementRef

### document-viewer
- **DocumentViewerComponent** `app-document-viewer`
  - @Input: config: DocumentConfig, entries: DocumentEntry[], headerData: DocHeaderData, documents: DocumentBundle[]
  - Injeta: ChangeDetectorRef, ComponentRef, DocumentLogService, LayoutEngineService, MeasurementService, ... +1

### dropdown-actions
- **DropdownActionsComponent** `app-dropdown-actions`
  - @Input: options: DropdownOption<any>[]
  - @Output: optionSelected
  - Injeta: ElementRef

### escolas-gerenciais
- **CadastroEscolaGerencialComponent** `app-cadastro-escola-gerencial`
  - @Output: aplicarFiltroSeForMesmaRede
  - Injeta: EscolaGerencialService, FormBuilder, NotificationService, StringUtilsService
- **EditarEscolaGerencialComponent** `app-editar-escola-gerencial`
  - @Input: escolaParaEditar: EscolaGerencialResponse, escolas: ResponseModel[]
  - @Output: atualizarLista
  - Injeta: EscolaGerencialService, FormBuilder, NotificationService, StringUtilsService
- **ListarEscolaGerencialComponent** `app-listar-escola-gerencial`
  - Injeta: EscolaGerencialService

### escolas-publicas
- **CadastroEscolaPublicaComponent** `app-cadastro-escola-publica`
  - @Input: hashAnoLetivo: string, series: BaseResponse[], turnos: BaseResponse[]
  - @Output: closeModalEvent, atualizarLista
  - Injeta: EscolasPublicasService, FormBuilder, NotificationService
- **CadastroTurmaComponent** `app-cadastro-turma`
  - @Input: escola: EscolasPublicasGetResponse, series: ResponseModel[], turnos: ResponseModel[], filtro: CadastroEscolasPublicasFilterRequest
  - @Output: atualizarLista
  - Injeta: EscolasPublicasService, FormBuilder, NotificationService
- **CadastroTurmaServicoComponent** `app-cadastro-turma-servico`
  - @Input: escola: EscolasPublicasGetResponse, series: ResponseModel[], filtro: CadastroEscolasPublicasFilterRequest
  - @Output: atualizarLista
  - Injeta: EscolasPublicasService, FormBuilder, NotificationService
- **EditarEscolaPublicaComponent** `app-editar-escola-publica`
  - @Input: escola: EscolasPublicasGetResponse
  - @Output: closeModalEvent, atualizarLista
  - Injeta: EscolasPublicasService, FormBuilder, NotificationService
- **EditarTurmaComponent** `app-editar-turma`
  - @Input: turnos: ResponseModel[], escola: EscolasPublicasGetResponse
  - @Output: closeModalEvent, atualizarLista
  - Injeta: EscolasPublicasService, FormBuilder, NotificationService
- **EscolasPublicasDetalhesComponent** `app-detalhes`
  - Injeta: EscolasPublicasService, RouteStateService, Router
- **EscolasPublicasEditarComponent** `app-editar`
- **EscolasPublicasListarComponent** `app-listar`
  - Injeta: ChangeDetectorRef, EscolasPublicasService, FileService, FiltroEscolasPublicasService, RouteStateService, ... +1
- **RemoverTurmaComponent** `app-remover-turma`
  - @Output: atualizarLista
  - Injeta: EscolasPublicasService, NotificationService

### etapas
- **EditarEtapasComponent** `app-editar-etapas`
  - @Output: atualizarLista
  - Injeta: DateUtilsService, EtapasService, FormBuilder, NotificationService
- **ListarComponent** `app-listar`
  - Injeta: ChangeDetectorRef, EtapasService, FiltroEtapasService

### exemplos
- **BlockInspectorComponent** `app-block-inspector`
  - @Input: selectedBlock: EditorBlock | null, config: DocumentConfig
  - @Output: configChange, blockDataChange, blockLabelChange
  - Injeta: ChangeDetectorRef
- **BlockLibraryComponent** `app-block-library`
  - @Output: addBlock
  - Injeta: BlockRegistryService, CategoryGroup
- **DocumentBuilderIaGuideComponent** `app-document-builder-ia-guide`
  - Injeta: Router
- **DocumentBuilderTourComponent** `app-document-builder-tour`
- **DocumentEditorComponent** `app-document-editor`
  - Injeta: BlockRegistryService, ChangeDetectorRef, DocumentEditorStateService, DocumentImportService, Router
- **DocumentsComponent** `app-documents`
  - Injeta: BlockRegistryService, DocumentImportService, DocumentSample, DocumentoModeloSample, MultiDocumentSample, ... +1
- **EditorCanvasComponent** `app-editor-canvas`
  - @Input: blocks: EditorBlock[], config: DocumentConfig, headerData: DocHeaderData, selectedId: string | null... +1
  - @Output: selectBlock, addBlockAt, moveBlock, duplicateBlock, ... +2
  - Injeta: BlockRegistryService, ChangeDetectorRef
- **ExemplosDashboardComponent** `app-exemplos-dashboard`
- **FiltrosComponent** `app-filtros`
  - Injeta: MockFiltroApiService
- **FiltrosTourComponent** `app-filtros-tour`
  - Injeta: MockFiltroApiService
- **FormulariosComponent** `app-formularios`
  - Injeta: FormBuilder
- **InfoBaseComponent** `app-info-base`
  - Injeta: RouteStateService, Router
- **SidePanelExemploComponent** `app-side-panel-exemplo`
- **TableFilterComponent** `app-table-filter`
  - Injeta: StringUtilsService
- **TelaBaseComponent** `app-tela-base`
  - Injeta: FormBuilder, RouteStateService, Router
- **TestDocBodyComponent** `app-test-doc-body`
  - @Input: data: TestDocBodyData

### ficha-individual
- **FichaIndividualComponent** `app-ficha-individual`
  - Injeta: ChangeDetectorRef, DocHeaderData, DocumentLogService, FichaIndividualService

### field-wrapper
- **FilterFieldWrapperComponent** `app-field-wrapper`
  - @Input: filterName: string, defaultValue: string, componentType: Type<any>, control: FormControl... +4
  - Injeta: DynamicInjectorService, FiltroApiService, FiltroStorageService, LogService, NotificationService

### files-field
- **FilesFieldComponent** `app-files-field`
  - @Input: control: FormControl | null, fieldName: string, placeholder: string, multiple: boolean

### filtro
- **FiltroComponent** `filtro`
  - @Input: service: any, config: FilterConfig, loading: boolean, visible: boolean... +2
  - @Output: submit, resetList, changeFilterStatus, fieldUpdateEvent, ... +1
  - Injeta: ChangeDetectorRef, FiltroFormService, FiltroStorageService, FormBuilder, LogService

### folha
- **CadastroCargoPagamentoComponent** `app-cadastro-cargo-pagamento`
  - @Output: updateList
  - Injeta: CargosPagamentoService, NotificationService
- **CadastroClasseComponent** `app-cadastro-classe`
  - @Output: updateList
  - Injeta: ClassePagamentoService, FormBuilder, NotificationService
- **CadastroEscolaPagamentoComponent** `app-cadastro-escola-pagamento`
  - @Output: aplicarFiltroSeForMesmaRede
  - Injeta: FormBuilder, GestaoPagamentoService, NotificationService
- **CadastroEventoComponent** `app-cadastro-evento`
  - @Output: updateList
  - Injeta: FormBuilder, NotificationService, TipoEventoPagamentoService
- **CadastroHoraAulaPadraoComponent** `app-cadastro-hora-aula-padrao`
  - Injeta: HoraAulaService, NotificationService
- **CadastroSegmentoPagamentoComponent** `app-cadastro-segmento-pagamento`
  - @Output: updateList
  - Injeta: FormBuilder, NotificationService, SegmentoPagamentoService
- **CadastroSegmentoSindicalComponent** `app-cadastro-segmento-sindical`
  - @Output: updateList
  - Injeta: FormBuilder, NotificationService, SegmentoSindicalService
- **CargasIndevidasComponent** `app-cargas-indevidas`
  - @Input: lista: CargasIndevidasResponse[]
- **ConfiguracaoChapaComponent** `app-configuracao-chapa`
  - Injeta: ConfiguracaoChapaService, FileService, RouteStateService, Router, StringUtilsService
- **DisciplinasSemTitularComponent** `app-disciplinas-sem-titular`
  - @Input: lista: TurmaSemTitularResponse[]
- **EdicaoChapaComponent** `app-edicao-chapa`
  - Injeta: ConfiguracaoChapaService, FormBuilder, NotificationService, RouteStateService, Router
- **EditarEscolaPagamentoComponent** `app-editar-escola-pagamento`
  - @Input: escolaParaEditar: EscolaPagamento, escolas: ResponseModel[]
  - @Output: atualizarLista
  - Injeta: FormBuilder, GestaoPagamentoService, NotificationService
- **EditarMacroturmasComponent** `app-editar-macroturmas`
  - @Output: submit, notifyFilter
  - Injeta: ClassePagamentoService, FormBuilder, MacroTurmaService, NotificationService, RouteStateService, ... +1
- **EditarTurmaMacroturmasComponent** `app-editar-turma-macroturmas`
  - @Input: turmasDisponiveis: BaseResponse[]
  - @Output: updateList
  - Injeta: NotificationService, TurmaMacroturmaService
- **EnvioPreviaComponent** `app-envio-previa`
  - Injeta: FolhaPreviaService, FormBuilder, NotificationService
- **EnvioTesteComponent** `app-envio-teste`
  - @Output: closeModalEvent
  - Injeta: FolhaPreviaService, NotificationService
- **FolhaPreviaListarComponent** `app-listar-folha-previa`
  - Injeta: FileService, FiltroPreviaCargaService, FolhaPreviaService, NotificationService, RouteStateService, ... +1
- **GestaoTabNavigatorComponent** `app-gestao-tab-navigator`
- **HoraAulaTabNavigatorComponent** `app-hora-aula-tab-navigator`
- **InformacoesEnvioComponent** `app-informacoes-envio`
  - Injeta: NotificationService, RouteStateService, Router
- **ListarCargosPagamentoComponent** `app-listar-cargos-pagamento`
  - Injeta: CargosPagamentoService
- **ListarChecklistComponent** `app-listar-checklist`
  - Injeta: FileService, FiltroChecklistFolhaService, StringUtilsService
- **ListarClassesComponent** `app-listar-classes`
  - Injeta: ClassePagamentoService
- **ListarEscolaPagamentoComponent** `app-lista-escola-pagamento`
  - Injeta: GestaoPagamentoService
- **ListarEventosComponent** `app-listar-eventos`
  - Injeta: TipoEventoPagamentoService
- **ListarMacroturmasComponent** `app-listar-macroturmas`
  - Injeta: MacroTurmaService, RouteStateService, Router
- **ListarSegmentosPagamentoComponent** `app-listar-segmentos-pagamento`
  - Injeta: SegmentoPagamentoService
- **ListarSegmentosSindicalComponent** `app-listar-segmentos-sindical`
  - Injeta: SegmentoSindicalService
- **ListarTurmasMacroturmasComponent** `app-listar-turmas-macroturmas`
  - Injeta: MacroTurmaService, RouteStateService, Router, TurmaMacroturmaService
- **NovoEnvioPreviaComponent** `app-novo-envio-previa`
  - @Output: closeModalEvent
  - Injeta: FolhaPreviaService, FormBuilder, NotificationService, RouteStateService, Router
- **ProfessoresSemScComponent** `app-professores-sem-sc`
  - @Input: lista: ProfessorSemSCResponse[]
- **TestarEnvioComponent** `app-testar-envio`
  - Injeta: FolhaPreviaService, FormBuilder, NotificationService

### form
- **FormularioComponent** `app-formulario`
  - @Input: debugger: boolean, mock: any, defaultActions: boolean
  - @Output: cancel, submit
  - Injeta: ChangeDetectorRef, FormBuilder, Injector

### grade-horaria
- **ConfiguradorTempoPadraoComponent** `app-configurador-tempo-padrao`
  - Injeta: ConfiguradorTempoPadraoService, FormBuilder, NotificationService

### home
- **HomeComponent** `app-home`

### icon-button
- **IconButtonComponent** `app-icon-button`
  - @Input: icon: string, class: string
  - @Output: clickEvent

### input-pesquisa-header
- **InputPesquisaHeaderComponent** `input-pesquisa-header`
  - Injeta: PortalConfig

### itinerario-formativo
- **EditarItinerarioComponent** `app-editar-itinerario`
  - @Output: submit
  - Injeta: ChangeDetectorRef, FormBuilder, ItinerarioFormativoService, NotificationService
- **ListarItinerariosComponent** `app-listar-itinerarios`
  - Injeta: ChangeDetectorRef, FilterItinerarioService, ItinerarioFormativoService, NotificationService
- **SelecaoItinerarioComponent** `app-selecao-itinerario`
  - Injeta: FileService, FormBuilder, ItinerarioFormativoService, NotificationService, SelecaoItinerarioService, ... +1

### listbox-transfer
- **ListboxTransferComponent** `app-listbox-transfer`
  - @Input: rightLabel: string, leftLabel: string, itemSize: number, loading: boolean... +1
  - Injeta: ChangeDetectorRef, StringUtilsService

### loading
- **LoadingComponent** `app-loading`
  - @Input: mensagem: string

### logar-como
- **LogarComoComponent** `logar-como`
  - Injeta: AlertService, ModalService, PortalConfig, UsuarioService

### logo-escola
- **LogoEscolaComponent** `logo-escola`
  - Injeta: PortalConfig, UsuarioService

### menu-lateral
- **MenuLateralComponent** `menu-lateral`
  - Injeta: MenuService, UsuarioService

### minimize-pages
- **MinimizePagesComponent** `app-minimize-pages`
  - @Output: pageCountChange
  - Injeta: ChangeDetectorRef, PageOptimizerService

### modal
- **ModalComponent** `app-modal`
  - @Input: showModal: boolean, closeButton: boolean, loading: boolean, closeOnOverlay: boolean
  - @Output: closeModalEvent

### money-field
- **MoneyFieldComponent** `app-money-field`
  - @Input: control: FormControl | null, fieldName: string, placeholder: string

### movimentacao-pedagogica
- **AlteracaoCargaComponent** `app-alteracao-carga`
  - Injeta: AlteracaoCargaService, FiltroAlteracaoCargaService, RouteStateService, Router
- **AlteracaoCargaDetalhesComponent** `app-alteracao-carga-detalhes`
  - Injeta: AlteracaoCargaService, DateUtilsService, FiltroStorageService, FormBuilder, NotificationService, ... +1
- **CargaEditorComponent** `app-carga-editor`
  - @Input: fg: FormGroup, substitutos: BaseResponse[], modoSaida: ModoSaida, dataSaida: string... +2
  - Injeta: CtxAlteracaoCarga, DateUtilsService
- **CentralMovimentacaoPedagogicaComponent** `app-central-movimentacao-pedagogica`
- **InfoLancamentoEventoComponent** `app-info-lancamento-evento`
  - @Input: loading: boolean, lancamento: LancamentoEventosResponse
  - Injeta: StringUtilsService
- **InfoProfessorComponent** `app-info-professor`
  - @Input: loading: boolean, professor: AlteracaoCargaProfessorResponse
- **LancamentoEventosComponent** `app-lancamento-eventos`
  - Injeta: FiltroLancamentoEventosService, LancamentoEventosService, RouteStateService, Router
- **ModalAlteracaoCargaComponent** `app-modal-alteracao-carga`
  - @Input: show: boolean, turmasAfetadas: CargaTurmaResponse[], habilitarMsgInfoItensParciais: boolean
  - @Output: confirmaEvent, closeEvent
- **MovimentacaoTabNavigatorComponent** `app-movimentacao-tab-navigator`

### multi-select
- **MultiSelectComponent** `multi-select`
  - @Input: control: FormControl | AbstractControl, options: MultiSelectOption[], fieldName: string, placeholder: string... +4
  - @Output: eventChange
  - Injeta: MultiSelectOption

### multi-select-field
- **MultiSelectFieldComponent** `app-multi-select-field`
  - @Input: control: FormControl | null, options: MultiSelectOption[], fieldName: string, placeholder: string
  - Injeta: MultiSelectCoordinatorService, MultiSelectOption

### nome-do-modulo
- **NomeDoModuloComponent** `app-nome-do-modulo`

### number-field
- **NumberFieldComponent** `app-number-field`
  - @Input: control: FormControl | null, fieldName: string, min: number, max: number... +1

### ocorrencia
- **CadastroTipoOcorrenciaComponent** `app-cadastro-ocorrencia`
  - @Output: updateList
  - Injeta: FiltroOcorrenciaService, FormBuilder, NotificationService, OcorrenciaService
- **ListarOcorrenciaComponent** `app-listar`
  - Injeta: FileService, FiltroOcorrenciaService, NotificationService, OcorrenciaService

### page-not-found
- **PageNotFoundComponent** `app-page-not-found`
  - Injeta: PortalConfig

### paginacao
- **PaginacaoComponent** `app-paginacao`
  - @Input: wrapper: boolean, loading: boolean, current: number, total: number... +1
  - @Output: goTo
  - Injeta: FiltroSync

### periodo-letivo
- **EditarPeriodoLetivoComponent** `app-editar`
  - Injeta: ChangeDetectorRef, ConfiguradorPeriodoLetivoService, DateUtilsService, FileService, FiltroPeriodoLetivoService, ... +1

### portal-alert
- **PortalAlertComponent** `portal-alert`
  - Injeta: AlertService, ElementRef

### portal-auth
- **PortalAuthComponent** `atlas-modulo-auth`
  - Injeta: ActivatedRoute, AlertService, PortalConfig, UsuarioService

### portal-body
- **PortalBodyComponent** `portal-body`

### portal-guia
- **PortalGuiaComponent** `portal-guia`
  - Injeta: GuiaPortalService, PortalConfig, UsuarioService

### portal-header
- **PortalHeaderComponent** `portal-header`
  - @Output: onLateralMenuClick
  - Injeta: Boolean

### portal-header-progress
- **PortalHeaderProgressComponent** `portal-header-progress`
  - Injeta: ProgressService

### portal-menu
- **PortalMenuComponent** `portal-menu`
  - @Input: menuLateralVisibel: boolean
  - Injeta: ElementRef, MenuService, ModalService, UsuarioService

### portal-menu-eleva-id
- **PortalMenuElevaIdComponent** `portal-menu-eleva-id`
  - Injeta: PortalConfig, UsuarioService

### portal-menu-notificacoes
- **PortalMenuNotificacoesComponent** `portal-menu-notificacoes`
  - Injeta: NotificacaoService, PortalConfig, UsuarioService

### portal-menu-perfil
- **PortalMenuPerfilComponent** `portal-menu-perfil`
  - Injeta: MenuPerfilService, MenuService, ModalService, PortalConfig, UsuarioService

### portal-modal
- **PortalModalComponent** `portal-modal`
  - @Input: modalId: string
  - Injeta: ElementRef, ModalService

### portal-modulo
- **PortalModuloComponent** `portal-modulo`
  - Injeta: CookieService, UsuarioService

### print-overlay
- **PrintOverlayComponent** `app-print-overlay`
  - @Input: viewer: DocumentViewerComponent
  - @Output: closeEvent, printEvent, saveEvent

### radio-field
- **RadioFieldComponent** `app-radio-field`
  - @Input: control: FormControl | null, fieldName: string, options: RadioOption[], verticalField: boolean

### relatorio
- **DisciplinasComponent** `app-disciplinas`
  - Injeta: FileService, FiltroDisciplinasPorAlunoService, StringUtilsService

### salvar
- **SalvarComponent** `app-salvar`
  - @Input: loading: boolean, disabled: boolean, labels: string[], mensagemAlerta: string... +2
  - @Output: saveEvent

### search-field
- **SearchFieldComponent** `app-search-field`
  - @Input: loading: boolean, placeholder: string
  - @Output: change, search

### select-field
- **SelectFieldComponent** `single-select`
  - @Input: control: FormControl | AbstractControl, options: SelectOption[], placeholder: string, required: boolean... +4
  - @Output: onChange
  - Injeta: SelectOption
- **SelectFieldComponent** `app-select-field`
  - @Input: control: FormControl | null, options: SelectOption[], fieldName: string, placeholder: string
  - Injeta: MultiSelectCoordinatorService, SelectOption

### sem-conteudo
- **SemConteudoComponent** `app-sem-conteudo`
  - @Input: mensagem: string

### side-panel
- **SidePanelComponent** `app-side-panel`
  - @Input: show: boolean
  - @Output: closeEvent

### skeleton-box
- **SkeletonBoxComponent** `skeleton-box`

### skeleton-text
- **SkeletonTextComponent** `app-skeleton-text`
  - Injeta: ChangeDetectorRef

### step-card
- **StepCardComponent** `app-step-card`
  - @Input: steps: Record<string, Step<any>>, key: string, etapaAtual: Step<any>, loading: boolean
  - @Output: selectEvent
  - Injeta: Record

### tab-navigator
- **TabNavigatorComponent** `app-tab-navigator`
  - @Input: routes: TabNavigatorItem[], useRouter: boolean
  - @Output: routeEvent
  - Injeta: Router

### table-wrapper
- **TableWrapperComponent** `app-table-wrapper`
  - @Input: loading: boolean, loadingList: boolean, items: any[], actionLabel: string... +1
  - @Output: submitEvent

### text-field
- **TextFieldComponent** `text-field`
  - @Input: control: FormControl | null, fieldName: string, placeholder: string

### textarea-field
- **TextareaFieldComponent** `app-textarea-field`
  - @Input: control: FormControl | null, fieldName: string, placeholder: string, maxLengthValue: number

### time-field
- **TimeFieldComponent** `app-time-field`
  - @Input: control: FormControl | null, fieldName: string, min: string, max: string

### titulo-page
- **TituloPageComponent** `app-titulo-page`
  - @Input: title: string, subtitle: string
  - Injeta: Title

### titulo-tela
- **TituloTelaComponent** `app-titulo-tela`
  - @Input: titulo: string
  - @Output: emtVoltar

### toastr-eleva
- **ToastrElevaComponent** `app-toastr-eleva`

### toggle
- **ToggleFieldComponent** `app-toggle`
  - @Input: control: FormControl | null, fieldName: string, toggleInfo: string

### toggle-buttons
- **ToggleButtonsComponent** `app-toggle-buttons`
  - @Input: options: ToggleOption[], selected: string | null
  - @Output: change

### tooltip
- **TooltipComponent** `app-tooltip`
  - @Input: text: string

### turno-radio-select
- **TurnoRadioSelectComponent** `app-turno-radio-select`
  - @Input: selecionado: string, loading: boolean, turnos: ResponseModel[]
  - @Output: select

### user-validation
- **UserValidationComponent** `app-user-validation`
  - @Output: ExpirationEvent
  - Injeta: AutenticacaoService, UsuarioService

## Services

### boletim
- **FiltroService** (root)
  - Injeta: HandleApiError, ProcessamentoBoletimApiClient
  - Métodos: anosLetivos, redes, escolas, agrupamentos
- **ProcessamentoService** (root)
  - Injeta: HandleApiError, ProcessamentoBoletimApiClient
  - Métodos: getProcessamento, enfileirar

### cache-service
- **CachingInterceptor** (none)
  - Injeta: HttpCacheService
  - Métodos: intercept, if, tap
- **HttpCacheService** (root)
  - Métodos: get, set, has, clear

### cargas-iniciais
- **CargasIniciaisService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getStatusEscolasInvalidas
- **FilterAlocacaoProfessorService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes
- **ImportacaoAlocacaoProfessoresService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getImportacoes, upload, updateImportacao, getStatusImportacao

### click-outside
- **ClickOutsideService** (root)
  - Métodos: register, unregister

### components
- **PhotoService** (root)
  - Injeta: UsuarioService
  - Métodos: getPhotoUrl, if, if, if, if, if, ... +1

### datepicker
- **DateCalendar** (root)
  - Métodos: config, for, for, buildMonths, for, nextMonth, ... +2

### daterangepicker-field
- **I18n** (none)
  - Injeta: I18n
  - Métodos: getWeekdayShortName, getMonthShortName, getMonthFullName, getWeekdayLabel, getDayAriaLabel

### dynamic-components
- **DynamicInjectorService** (root)
  - Injeta: Injector

### escolas-gerenciais
- **EscolaGerencialService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, getEscolas, getEscolasGerencial, save, update

### escolas-publicas
- **EscolasPublicasService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getEscolas, getSeries, getTurnos, getTurmas, disableTurmas, createTurmas, ... +2
- **FiltroEscolasPublicasService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, series

### etapas
- **EtapasService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: get, save
- **FiltroEtapasService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, series, etapas

### exemplos
- **BlockRegistryService** (root)
  - Métodos: get, getAll, getByCategory, getBlockTypeByComponent, if, canImport, ... +1
- **DocumentEditorStateService** (none)
  - Injeta: BlockRegistryService
  - Métodos: setName, addBlock, updateBlockData, updateBlockLabel, removeBlock, moveBlock, ... +2
- **DocumentImportService** (root)
  - Injeta: EditorDocument
  - Métodos: stage, takePending
- **MockFiltroApiService** (root)
  - Métodos: anosLetivos, redes, escolas, series, turmas, disciplinas, ... +2

### ficha-individual
- **FichaIndividualService** (root)
  - Métodos: get, getResumida

### filtro
- **FiltroApiService** (root)
  - Injeta: ApiClient, HandleApiError, NotificationService
  - Métodos: tap, fakeGet, getOptions
- **FiltroFormService** (root)
  - Injeta: Record
  - Métodos: hasForm, save, if, if, get, onFilterChanges, ... +1
- **FiltroStorageService** (root)
  - Métodos: register, if, loadFieldData, clear, hasLoggedUser, getLoggedUser

### folha
- **CargosPagamentoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getCargosPagamento, getCargosDisponiveis, save
- **ClassePagamentoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: redes, getClassesParaValidacao, getClassesPagamento, saveNovoclassePagamento
- **ConfiguracaoChapaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, meses, redes, professores, getProfessores, getQuantidadePaginas, ... +2
- **FiltroChecklistFolhaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, meses, tiposRede, redes, escolas, getPendencias, ... +1
- **FiltroPreviaCargaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, meses
- **FolhaPreviaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getRedes, getQuantidadePublico, enviar, getTextoPrevia, getCelularTeste, testarEnvio, ... +2
- **GestaoPagamentoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, verificarNomeEscola, getEscolasDePagamento, getEscolas, save, ... +1
- **HoraAulaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redesDePagamento, getPadrao, savePadrao
- **MacroTurmaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: tipoEventosFilter, segmentosFilter, segmentosSindicalFilter, anoLetivos, redes, tipoEventos, ... +2
- **SegmentoPagamentoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: redes, getSegmentosParaValidacao, getSegmentosPagamento, saveNovoSegmentoPagamento
- **SegmentoSindicalService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: redes, getSegmentosSindical, saveNovoSegmentoSindical, getSegmentosParaValidacao
- **TipoEventoPagamentoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: redes, getTipoEvento, getTiposDePagamento, save
- **TurmaMacroturmaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getTurmasParaMacroTurma, saveTurmaMacroTurma

### grade-horaria
- **ConfiguradorTempoPadraoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, series, turnos, get, ... +1

### interceptor
- **HttpRequestInterceptor** (none)
  - Injeta: ProgressService, UsuarioService
  - Métodos: intercept, if

### itinerario-formativo
- **FilterItinerarioService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, agrupamentos, ciclos
- **ItinerarioFormativoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getItinerarios, getDisciplinas, getCiclo, getTipos, getPeriodos, save, ... +1
- **SelecaoItinerarioService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, agrupamentos, turmas, periodos, ... +2

### movimentacao-pedagogica
- **AlteracaoCargaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: get, getProfessoresSubstitutos, getMotivosSaida, getProfessorCarga, update
- **FiltroAlteracaoCargaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, periodos, series, professores
- **FiltroLancamentoEventosService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, periodos, series, perfis
- **LancamentoEventosService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: get

### multi-select
- **MultiSelectCoordinatorService** (root)
  - Métodos: register, open, if

### ocorrencia
- **FiltroOcorrenciaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, series, getOcorrencias, export
- **OcorrenciaService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: save, saveStatus

### periodo-letivo
- **ConfiguradorPeriodoLetivoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: get, save, export
- **FiltroPeriodoLetivoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, series

### regional
- **RegionalService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getPaises, getEstados, getMunicipios

### relatorio
- **FiltroDisciplinasPorAlunoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: anosLetivos, redes, escolas, segmentos, series, turmas, ... +2

### route-guard
- **IsAllowed** (root)
  - Injeta: Router, UsuarioService
  - Métodos: canActivate, if
- **IsDesktopGuard** (root)
  - Injeta: Router
  - Métodos: canActivate, if
- **IsLoggedGuard** (root)
  - Injeta: Router, UsuarioService
  - Métodos: canActivate
- **IsMaintenance** (root)
  - Injeta: Router
  - Métodos: canActivate, if, if
- **IsMobileGuard** (root)
  - Injeta: Router
  - Métodos: canActivate, if

### route-state
- **RouteStateService** (root)
  - Injeta: Record
  - Métodos: if, set, if, isExpired, has, if, ... +1

### services
- **AlertService** (root)
  - Métodos: showSuccess, showAlert, showError, setAlertComponent, if
- **ApiClient** (root)
  - Injeta: HttpClient
  - Métodos: get, getBlob, post, put, getFilterBlob, delete
- **AutenticacaoService** (root)
  - Injeta: ApiClient, HandleApiError
  - Métodos: getPerfil, possuiAcesso
- **CookieService** (root)
  - Injeta: Document
  - Métodos: addToDOM
- **DateUtilsService** (root)
  - Injeta: DatePipe
  - Métodos: formatDateTime, formatDate, dateFromIso, toISOString, dateWithTime, addDays, ... +2
- **DocumentLogService** (root)
  - Injeta: DocLogEvent
  - Métodos: enable, disable, clear, logLayoutStart, logWideTableMeasure, logLayoutPlace, ... +2
- **EventTagService** (root)
  - Métodos: click, if
- **FileService** (root)
  - Injeta: ApiClient
  - Métodos: downloadFile, downloadSheet
- **FiltroSync** (root)
- **FotoPortalService** (root)
  - Injeta: ApiClient
  - Métodos: downloadFile
- **FuncionalidadeAcessadaService** (root)
  - Injeta: HttpClient
- **GuiaPortalService** (root)
  - Injeta: HttpClient, PortalConfig
  - Métodos: getGuia, updateUsuarioDispensouGuia, updateUsuarioVisualizouGuia
- **HandleApiError** (root)
  - Injeta: NotificationService, TranslateService, UsuarioService
  - Métodos: if, for, if, if, if, if
- **LayoutEngineService** (root)
  - Injeta: DocumentLogService
  - Métodos: distribute, for, if, if, if, if, ... +2
- **LogService** (root)
  - Injeta: LogLevel
  - Métodos: log, if, if, debug, info, warn, ... +1
- **MeasurementService** (root)
  - Métodos: measure, for
- **MenuPerfilService** (root)
  - Injeta: UsuarioService
  - Métodos: update
- **MenuService** (root)
  - Injeta: FuncionalidadeAcessadaService, HttpClient, ModalService, PortalConfig, ... +1
  - Métodos: clear, get, if, if, if, if, ... +2
- **ModalService** (root)
  - Injeta: IModal
  - Métodos: add, remove, open, close
- **NotificacaoService** (root)
  - Injeta: HttpClient, PortalConfig
  - Métodos: get
- **NotificationService** (root)
  - Injeta: ToastrService
  - Métodos: showSuccess, showError, showInfo, showWarning, showLongTimeInfo
- **PageOptimizerService** (root)
  - Métodos: buildSteps, while, while, while, while, while, ... +2
- **PrintService** (root)
  - Métodos: if, if, for, if, if, for
- **ProcessamentoBoletimApiClient** (root)
- **ProgressService** (root)
  - Injeta: PortalHeaderProgressComponent
  - Métodos: complete, if, for, show, if, for, ... +1
- **SelectService** (root)
- **StateGuardService** (none)
  - Métodos: guardState
- **StringUtilsService** (root)
  - Métodos: normalize, isNumeric, onlyNumbers, formatCNPJ, formatFormCNPJ, if, ... +2
- **User** (root)
  - Injeta: ApiClient
  - Métodos: getUserName
- **UsuarioService** (root)
  - Injeta: HttpClient, PortalConfig, Router
  - Métodos: logoff, logoffElevaId, logarComo, alternarPerfisDeAcessoDoUsuario, irParaLogin, alternarPessoasEscolaAcesso, ... +2

## Models

- **AcessoUsuarioModel** (interface): IdPerfilDeAcessoDoUsuario: number | null, IdPessoaEscolaAcesso: number | null, IdSegmento: number | null, Nome: string, EscolaHash: string | null, ... +3
- **AlocacaoProfessorProcessamentos** (interface): hash: string, dataEnvio: string, usuario: string, qtTurmasProfessoresDisciplinas: number, status: StatusEtapa
- **AlocacaoProfessorStatusRequest** (interface): hash: string, etapaParaAtualizar: number
- **AlocacaoProfessorUploadRequest** (interface): hashAnoLetivo: string, hashRede: string, file: File, fileName: string
- **AlteracaoCargaFormValue** (interface): motivoAlteracaoCarga: string, ehSaidaTemporaria: boolean, ehRetornoDeSaidaTemporaria: boolean, dataEntrada: string, dataNovoProfessor: string, ... +3
- **AlteracaoCargaProfessorResponse** (interface): hash: string, nome: string, cpf: string, situacao: string, situacaoId: SituacaoProfessorEnum, ... +3
- **AlteracaoCargaRouteData** (interface): filter: MovimentacaoPedagogicaFilterRequest, tagData: FieldTagOptions[], professor: AlteracaoCargaProfessorResponse, substitutos: BaseResponse[], motivos: MotivoSaidaResponse[]
- **AlunoComponentResponse** (interface): obrigatorio: boolean, hashItinerario: string, hashPeriodo: string, descricao: string
- **AlunoSelecaoItinerarioResponse** (interface): hashAluno: string, nome: string, ra: string, turma: string, hashTurma: string, ... +3
- **ArquivoModel** (interface): NomeGuia: string | null, LinkArquivo: string | null
- **BaseField** (interface): type: string, value: string | number | string[], name: string, label: string, placeholder: string
- **BaseResponse** (interface)
- **BlockDef** (interface): type: BlockType, label: string, icon: string, componentType: Type<unknown>, defaultData: unknown
- **CadastroEScolasPublicasTurmaResponse** (interface): hash: string, nomeTurma: string, nomeTurno: string, hashTurno: string, novoCadastro: boolean
- **CadastroEscolasPublicasDisableRequest** (interface): hashEscolaSerie: string, hashTurno: string
- **CadastroEscolasPublicasFilterRequest** (interface): hashRede: string, hashEscola: string[], hashAnoLetivo: string, hashSerie: string[], pagina: number, ... +3
- **CadastroEscolasPublicasRequest** (interface): hashAnoLetivo: string, hashEscola: string, nomeEscola: string, codigoInep: string, manterSequencia: boolean, ... +1
- **CadastroEscolasPublicasSerieResponse** (interface)
- **CadastroEscolasPublicasTurmaRequest** (interface): hashEscola: string, hashSerie: string, hashTurno: string, quantidadeTurmas: number, siglaUrania: string
- **CadastroEscolasPublicasUpdateRequest** (interface): hashEscola: string, nomeEscola: string, codigoInep: string
- **CadastroEscolasPublicasUpdateTurmasRequest** (interface)
- **CadastroOcorrenciasGetResponse** (interface): hash: string, hashRede: string, hashAnoLetivo: string, nomeRede: string, series: BaseResponse[], ... +3
- **CadastroTurmaForm** (interface)
- **CalendarConfig** (interface)
- **CalendarStruct** (interface)
- **CargaEscolaResponse** (interface): hashEscola: string, nome: string, tempos: ProfessorTotalTempos, dataEntrada: string, professoresSubstitutos: ProfessorSubstitutoResponse[], ... +3
- **CargaParaUpdate** (interface): HashCarga: string, HashProfessorSubstituto: string, DataEntrada: Date
- **CargaTurmaResponse** (interface): hashCarga: string, hashTurma: string, hashEscola: string, turma: string, escola: string, ... +3
- **CargasIndevidasResponse** (interface): rede: string, professor: string, cpf: string, situacao: string, qtdTemposRegulares: string
- **CargoPagamentoRequest** (interface): hash: string, cargos: BaseResponse[]
- **CargosPagamentoFilterRequest** (interface): hashRede: string[], pagina: number
- **CargosPagamentoResponse** (interface): hash: string, nome: string, cargos: BaseResponse[]
- **CellPaddingConfigurable** (interface)
- **ChapaFilterRequest** (interface): hashAnoLetivo: string, mes: number, hashRede: string[], hashPessoa: string, apenasPendente: boolean, ... +2
- **ChapaResponse** (interface): hash: string, hashChapa: string, numeroChapa: string, hashEscolaGerencial: string | null, hashTipo: string | null, ... +3
- **ChapasOutrosCargosResponse** (interface): numeroChapa: string, cargo: string
- **ChecklistFolhaFilterRequest** (interface): hashAnoLetivo: string, mes: number, hashTipoRede: string, hashRedes: string[], hashEscolas: string[], ... +1
- **ClassePagamentoFilterRequest** (interface): hashRede: string[], pagina: number
- **ClassePagamentoResponse** (interface): hash: string, hashRede: string, nomeRede: string, nomeClasse: string
- **ClassePagamentoSaveRequest** (interface): hash: string, hashRede: string, nomeClasse: string, padraoRedePagamento: boolean
- **ClassesDePagamentoPorRedeResponse** (interface): hash: string, nome: string, hashRede: string
- **ColumnConfig** (interface): header: string, avatar: boolean, highlight: boolean, key: string, multValues: boolean, ... +3
- **ColumnMultValues** (interface): key: string, highlight: boolean
- **ColumnSplittable** (interface)
- **ConfiguradorEtapaFilterRequest** (interface): hashRede: string, hashEscola: string[], hashAnoLetivo: string, hashSerie: string[], apenasPendentes: boolean
- **ConfiguradorEtapaGetResponse** (interface)
- **ConfiguradorEtapaSaveRequest** (interface): hashEtapa: string, hashEscolaSerie: string
- **ConfiguradorPeriodoLetivoFilterRequest** (interface): hashRede: string, hashEscola: string[], hashAnoLetivo: string, hashSerie: string[], apenasPendentes: boolean
- **ConfiguradorPeriodoLetivoGetResponse** (interface): hashEscolaSerie: string, nomeEscola: string, nomeSerie: string, dataInicioAno: Date, dataFimAno: Date, ... +3
- **ConfiguradorProfessorChapaEscolaRequest** (interface): hashAnoLetivo: string, mes: number, hashRede: string, hashPessoa: string
- **ConfiguradorTempoPadraoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashEscola: string[], hashSerie: string[], hashTurno: string, ... +1
- **ConfiguradorTempoPadraoGetResponse** (interface): hashEscolaSerie: string, hashTurno: string, nomeRede: string, nomeEscola: string, nomeSerie: string, ... +3
- **ConfiguradorTempoPadraoSaveRequest** (interface): hashEscolaSerie: string[], hashTurno: string, quantidadeTempos: number, duracaoTempoEmMinutos: string, horaInicioAula: string, ... +3
- **ConsultaProcessamentoBoletimRequest** (interface): HashAnoLetivo: string, HashRede: string[], HashEscola: string[], HashAgrupamento: string[], hashProcessamentoBoletim: string[]
- **ConsultaProcessamentoBoletimResponse** (interface): hash: string, nomeRede: string, nomeEscola: string, nomeAgrupamento: string, nomeSerie: string, ... +3
- **CtxAlteracaoCarga** (interface): modo: ModoSaida, temDataSaida: boolean, temMotivo: boolean, ehProfessorVago: boolean, podeSelecionarSubstituto: boolean, ... +1
- **DataTableConfig** (interface): customButtomLabel: boolean, buttonColumnLabel: string, columns: ColumnConfig[], textLimit: number, buttonLabel: string, ... +3
- **DataTableFilter** (interface): text: string, pending: boolean
- **DateSelect** (interface)
- **DayCustomColor** (interface)
- **DayStruct** (interface): day_label: string
- **DiaAulaInfo** (interface)
- **DisabledDay** (interface)
- **DisciplinasPorAlunoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashEscolas: string[], hashSegmentos: string[], hashSeries: string[], ... +3
- **DocumentDefinition** (interface): config: DocumentConfig, headerData: DocHeaderData, entries: DocumentEntry[]
- **DocumentoModelo** (interface): label: string, description: string, fileName: string, config: DocumentConfig, headerData: typeof MOCK_ESCOLA_HEADER, ... +1
- **EditorBlock** (interface): id: string, type: BlockType, label: string, data: unknown
- **EditorDocument** (interface): name: string, config: DocumentConfig, headerData: DocHeaderData, blocks: EditorBlock[]
- **ElevaIdModel** (interface)
- **EnvioPreviaCargaFilterRequest** (interface): hashAnoLetivo: string, mes: number, hashStatus: string, hashRedes: string[], pagina: number
- **EnvioPreviaRelatorioRequest** (interface): hashEnvios: string[]
- **EscolaChapaResponse** (interface): quantidadeTempos: number
- **EscolaGerencialFilterRequest** (interface): hashAnoLetivo: string, hashRede: string[], pagina: number
- **EscolaGerencialResponse** (interface)
- **EscolaGerencialSaveRequest** (interface): hashRede: string, nomeEscolaGerencial: string, hashsEscolas: string[], cnpj: string
- **EscolaGerencialUpdateRequest** (interface): hashEscolaGerencial: string, nomeEscolaGerencial: string, hashsEscolas: string[], cnpj: string
- **EscolaPagamentoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string[], pagina: number
- **EscolaPagamentoSaveRequest** (interface): HashRedePagamento: string, NomeEscolaPagamento: string, HashsEscolas: string[]
- **EscolaPagamentoUpdateRequest** (interface): hashEscolaPagamento: string, nomeEscolaPagamento: string, hashsEscolas: string[]
- **EscolasPublicasGetResponse** (interface)
- **EstadoResponse** (interface): hashEstado: string, siglaEstado: string, nomeEstado: string
- **FichaIndividualAlunoContexto** (interface)
- **FichaIndividualAreaDoConhecimento** (interface)
- **FichaIndividualColunaGetResponse** (interface)
- **FichaIndividualConfiguracaoEscola** (interface)
- **FichaIndividualConfiguracaoRede** (interface)
- **FichaIndividualDisciplinaGetResponse** (interface)
- **FichaIndividualEscopoGetResponse** (interface)
- **FichaIndividualEtapaGetResponse** (interface)
- **FichaIndividualGetRequest** (interface)
- **FichaIndividualGetResponse** (interface)
- **FichaIndividualLegendaGetResponse** (interface)
- **FichaIndividualNotaResponse** (interface)
- **FieldTagOptions** (interface): label: string, icon: string, selectDescription: string[], selectString: string
- **FilterConfig** (interface): id: string, id_toggle: string, id_save: string, id_clear: string, defaultValue: string, ... +3
- **FilterData** (interface): hash: string, descricao: string
- **FilterEtapasResponseData** (interface): data: ResponseModel[], error: any[], isSuccess: boolean, message: string
- **FilterField** (interface): control: FormControl, options: any[]
- **FilterItemConfig** (interface): url: string, value: any, autostart: boolean, selectFirst: boolean, required: boolean, ... +3
- **FilterResponseData** (interface): data: ResponseModel[], error: any[], message: string
- **FormDataDTO** (interface): hash: string | null, anoLetivo: string, redePagamento: string, descricao: string, pontos: number, ... +3
- **GridPreviaMock** (interface)
- **GuiaPortalModel** (interface): isualizado: boolean, Dispensado: boolean
- **HoraAulaFiltroRequest** (interface): hashAnoLetivo: string, hashRedePagamento: string, apenasPendentes: boolean
- **HoraAulaItemResponse** (interface): hashEscolaPagamento: string, nomeEscolaPagamento: string, hashSegmentoPagamento: string, nomeSegmentoPagamento: string, hashClassePagamento: string, ... +2
- **HoraAulaItemSaveRequest** (interface): hashEscolaPagamento: string, hashSegmentoPagamento: string, hashClassePagamento: string, valor: number | null
- **HoraAulaSaveRequest** (interface): hashAnoLetivo: string, hashRedePagamento: string, itens: HoraAulaItemSaveRequest[]
- **IConfirmModel** (interface): message: string, textOk: string, textCancel: string, title: string, description: string
- **IElevaIdToken** (interface): AccessToken: string, AccessTokenExpiration: Date
- **IExceptionCommonError** (interface): type: EnumValidationErrorType, message: string
- **IExceptionFormError** (interface): type: EnumValidationErrorType, messages: IExceptionFormErrorMessage[]
- **IExceptionFormErrorMessage** (interface): property: string, error: string
- **IExceptionImportError** (interface): type: EnumValidationErrorType, messages: IExceptionImportErrorMessage[]
- **IExceptionImportErrorMessage** (interface): linha: string, propriedade: string, valor: any, descricao: string
- **IGroupOptionField** (interface): groupLabel: string, groupOptions: IOptionField[] | IRadioOptionField[]
- **INgOptionField** (interface): hash: string, descricao: string
- **IOptionField** (interface): id: any, name: string
- **IPagingParams** (interface): page: number, limit: number
- **IRadioOptionField** (interface): value: any, label: string
- **ISelectOptions** (interface): value: string, label: string
- **IUser** (interface): Nome: string, Matricula: string
- **IdStringResponse** (interface): id: number, texto: string
- **ImportacaoAlocacaoProfessoresFilterRequest** (interface): hashAnoLetivo: string, hashRede: string[], pagina: number
- **ImportacaoAlocacaoProfessoresResponse** (interface): hash: string, dataInclusao: Date, usuarioInclusao: string, quantidadeLinhasEnviadas: number, status: string, ... +1
- **ItemValidacao** (interface): hash: string, descricaoInvalida: string, hashValido: string, ignorarLinhaImportacao: boolean
- **ItinerarioFormativoDisciplinaResponse** (interface): disciplinas: BaseResponse[], disciplinasFormacaoBasica: BaseResponse[]
- **ItinerarioFormativoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashAgrupamento: string, hashCiclo: string, pagina: number
- **ItinerarioFormativoResponse** (interface): hash: string, descricao: string, nomeTipo: string, hashTipo: string, nomeCiclo: string, ... +3
- **ItinerarioFormativoSaveRequest** (interface): hashAnoLetivo: string, hashRede: string, hashAgrupamento: string, hash: string, nome: string, ... +3
- **ItinerarioFormativoSelecaoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashEscola: string, hashAgrupamento: string, hashTurma: string[], ... +3
- **LancamentoEventosFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashEscola: string, hashPeriodo: string, hashProfessor: string, ... +2
- **LancamentoEventosResponse** (interface): hashPessoaEscolaAcesso: string, nomeProfessor: string, cpf: string, nomePerfilAcesso: string, hashPerfilAcesso: string, ... +3
- **LancamentoEventosRouteData** (interface): filter: LancamentoEventosFilterRequest, tagData: FieldTagOptions[], lancamento: LancamentoEventosResponse
- **LayoutComponent** (interface)
- **LayoutNewPageEvent** (interface): pageIndex: number
- **LayoutPlaceEvent** (interface): pageIndex: number, component: string, height_px: number, freeSpaceBefore_px: number, freeSpaceAfter_px: number
- **LayoutSignatureEvent** (interface): pageIndex: number, freeSpaceAvailable_px: number, signatureHeight_px: number
- **LayoutSplitEvent** (interface): pageIndex: number, component: string, freeSpaceAvailable_px: number, rowsThatFit: number, headHeight_px: number, ... +1
- **LayoutStartEvent** (interface): componentCount: number, firstPageHeight_px: number, otherPageHeight_px: number, signatureHeight_px: number, signatureOnAllPages: boolean
- **MacroTurmaConfiguracaoFilterRequest** (interface): hashAnoLetivo: string, hashRede: string[], hashTipoEvento: string[], hashSegmentoPagamento: string[], hashSegmentosindical: string[], ... +2
- **MacroTurmaConfiguracaoResponse** (interface): hash: string, hashRede: string, nomeRede: string, nomeMacroTurma: string, urania: string, ... +3
- **MacroTurmaConfiguracaoSaveRequest** (interface): hash: string, hashRedePagamento: string, hashSegmentoPagamento: string, hashSegmentoSindical: string, hashTipoEvento: string, ... +2
- **MesResponse** (interface): mes: string, descricao: string
- **MonthStruct** (interface): first_day: number, last_day: number, week_start: number, week_start_label: string, month: number, ... +2
- **MotivoSaidaResponse** (interface): hash: string, descricao: string, selecionavelPeloUsuario: boolean, todasAsRedes: boolean, ehSaidaTemporaria: boolean, ... +3
- **MovimentacaoPedagogicaFilterRequest** (interface): hashAnoLetivo: string, hashRede: string, hashEscola: string, hashPeriodo: string, hashProfessor: string, ... +1
- **MultiSelectField** (interface): value: string[]
- **MunicipioResponse** (interface): hashEstado: string, siglaEstado: string, nomeEstado: string, hashMunicipio: string, nomeMunicipio: string, ... +1
- **NovaPreviaCargaRequest** (interface): hashRedes: string[], excecaoEscolas: string[]
- **NumberField** (interface): value: number | string, min: number, max: number
- **OcorrenciaFilterRequest** (interface): hashAnoLetivo: string, hashRede: string[], hashSerie: string[], apenasOcorrenciasSemSerieAssociada: boolean, pagina: number
- **Page** (interface)
- **Paginacao** (interface)
- **PaisResponse** (interface): hashPais: string, possuiEstados: boolean, nomePais: string
- **PendenciasChecklistFolhaResponse** (interface): totalTurmasSemTitulares: number, totalProfessoresSemSC: number, totalCargasIndevidas: number, turmasSemTitulares: TurmaSemTitularResponse[], professoresSemSCR: TurmaSemTitularResponse[], ... +1
- **PeriodDisabled** (interface)
- **PreviaCargaPublicoPorRede** (interface): rede: string, publico: number, excecoes: string[]
- **ProfessorCargaEscolaTurmaResponse** (interface): dataMinimaSaidaTurma: string, dataMinimaSaidaEscola: string, dataInicioPeriodoCompetencia: string, dataFimPeriodoCompetencia: string, hashProfessorPerfilVigente: string, ... +3
- **ProfessorCargaRequest** (interface): hash: string, hashAnoLetivo: string, hashRede: string
- **ProfessorCargaUpdateRequest** (interface): HashProfessor: string, HashMotivoSaida: string, DataSaida: Date, CargaParaUpdates: CargaParaUpdate[]
- **ProfessorClassePagamentoSaveRequest** (interface): hashAnoLetivo: string, hashRede: string, hashPessoa: string, mes: number, hashClassePagamento: string
- **ProfessorSemSCResponse** (interface): rede: string, professor: string, cpf: string, mesInicial: string, chapa: boolean, ... +1
- **ProfessorSituacaoResponse** (interface): ehTerceiro: boolean, emAtividade: boolean, desligado: boolean
- **ProfessorSubstitutoRequest** (interface): hashRede: string, hashProfessorAtual: string
- **ProfessorSubstitutoResponse** (interface): hash: string, descricao: string, ehTitular: boolean
- **ProfessorTotalTempos** (interface): total: number, titular: number, licenca: number, substituto: number
- **ProfessoresChapaResponse** (interface): hashRede: string, nomeRede: string, hashPessoa: string, nomePessoa: string, hashClassePagamento: string, ... +3
- **RenderElementLog** (interface): name: string, calculated_px: number, actual_px: number, diff_px: number
- **RenderMeasureEvent** (interface): pageIndex: number, pageContentHeight_px: number, componentGap_px: number, elements: RenderElementLog[], totalCalculated_px: number, ... +2
- **ResumoProfessor** (interface): vago: boolean, nome: string, cpf: string, hash: string
- **SegmentoPagamentoFilterRequest** (interface): hashRede: string[], pagina: number
- **SegmentoPagamentoResponse** (interface): hash: string, hashRede: string, nomeRede: string, nomeSegmento: string, sigla: string
- **SegmentoPagamentoSaveRequest** (interface): hash: string, hashRede: string, nomeSegmento: string, sigla: string, nomeRede: string
- **SegmentoSindicalFilterRequest** (interface): hashRede: string[], pagina: number
- **SegmentoSindicalResponse** (interface): hash: string, hashRede: string, nomeRede: string, nome: string, sigla: string
- **SegmentoSindicalSaveRequest** (interface): hash: string | null, hashRede: string, nome: string, sigla: string
- **SegmentosDePagamentoPorRedeResponse** (interface): hash: string, nome: string, sigla: string, hashRede: string
- **SegmentosSindicalPorRedeResponse** (interface): hash: string, nome: string, sigla: string, hashRede: string
- **SelecaoItinerarioSaveRequest** (interface): hashRede: string, hashTurma: string[], hashAluno: string, hashPeriodo: string, hashComponente: string[]
- **SelectField** (interface): value: string
- **SplitResult** (interface)
- **Splittable** (interface)
- **StatusImportacaoResponse** (interface): fileName: string, hash: string
- **TesteEnvioRequest** (interface): hashRede: string
- **TextField** (interface): value: string
- **TextMeasurable** (interface)
- **TextareaField** (interface): value: string, max: number, min: number
- **TipoDivisaoChapaResponse** (interface): selecaoUnica: boolean, permiteOutraChapaParaMesmaEscola: boolean
- **TipoEventoPagamentoFilterRequest** (interface): hashRede: string[], pagina: number
- **TipoEventoPagamentoResponse** (interface): hash: string, nomeTipoEvento: string, siglaTipoPagamento: string, hashTipoPagamento: string, hashEventoReserva: string, ... +3
- **TipoEventoPagamentoSaveRequest** (interface): hash: string, nome: string, hashTipoPagamento: string, hashEventoReserva: string
- **TipoOcorrenciaSaveRequest** (interface): hash: string, hashAnoLetivo: string, hashRede: string, descricao: string, pontos: number, ... +2
- **TipoOcorrenciaStatusRequest** (interface): hash: string, ativo: boolean
- **TipoPagamentoResponse** (interface): hash: string, nome: string, sigla: string, possuiReserva: boolean, podeSerReserva: boolean
- **TurmaMacroTurmaConfiguracaoResponse** (interface): hashTurma: string, nomeRede: string, nomeEscola: string, nomeTurma: string
- **TurmaMacroTurmaSaveRequest** (interface): hashMacroTurmaConfiguracao: string, turmasParaAdicionar: string[], turmasParaRemover: string[]
- **TurmaSemTitularResponse** (interface): rede: string, escola: string, serie: string, turmaId: number, turma: string, ... +3
- **TurmaUpdate** (interface): segmentoDeServico: boolean, novoCadastro: boolean, hashTurno: string, hashTurma: string, nomeTurma: string, ... +1
- **TwilioFilaEnvioResponse** (interface): previaCargaHash: string, anoLetivo: number, mes: number, nomeRede: string, hashRede: string, ... +3
- **TwilioTemplateTextResponse** (interface): texto: string
- **UpdateImportacaoRequest** (interface): hash: string
- **UsuarioAutenticadoModel** (interface): PossuiUsuarioAutenticado: boolean, AcessosUsuario: AcessoUsuarioModel[], ElevaId: ElevaIdModel, Email: string, Id: number, ... +3
- **WideTableGroupLog** (interface): groupIndex: number
- **WideTableMeasureEvent** (interface): name: string, pageContentWidth_px: number, totalRows: number, columnGroupCount: number, rowHeights_px: number[], ... +2

## URLs de ambiente

- `api`
- `https://localhost/estrutura-pedagogica/api`

---
*178 componentes · 90 services · 41 módulos · 226 models · 20 rotas*