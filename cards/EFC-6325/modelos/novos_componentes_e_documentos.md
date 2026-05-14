para entender o produto, consulte @EFC-666 em caso de duvidas

aqui a ideia e ter a documentacao dos possiveis documentos que serao criados com o document-builder

- componentizar de forma coerente para facilitar no desenvolvimento
- analise quais elementos tem coerencia entre diferentes documentos para criar componentes que podem ser compartilhados
- analisar quais componentes precisam implementar split
- criar uma nova pasta em exemplos/documents/modelos/**nome_model**
- cada arquivo ts do modelo possui a configuracao do documento, os elementos que ele tem interno e o mock dos dados necessarios para criar o documento
- na tela de exemplos dos documentos, criar uma sessao onde esses documentos modelos vao aparecer para seguir o fluxo de testar documento normalmente


Documentos escolares por setor
Secretaria Acadêmica
Histórico Escolar

Descrição:
Documento oficial que registra toda a trajetória acadêmica do aluno.

Elementos internos:

Dados do aluno
Matrícula
Série/turma
Componentes curriculares
Notas
Frequência
Carga horária
Resultado final
Assinaturas/responsáveis
QR Code/autenticação
Boletim Escolar

Descrição:
Resumo periódico do desempenho acadêmico do aluno.

Elementos internos:

Dados do aluno
Período letivo
Disciplinas
Notas
Média
Frequência
Observações pedagógicas
Parecer descritivo
Assinatura digital
Declaração de Matrícula

Descrição:
Comprova que o aluno está regularmente matriculado.

Elementos internos:

Nome do aluno
Curso/série
Turno
Ano letivo
Data de emissão
Finalidade
Dados da escola
Assinatura/autenticidade
Certificado de Conclusão

Descrição:
Comprova a conclusão de curso ou etapa escolar.

Elementos internos:

Dados do aluno
Curso/etapa
Data de conclusão
Base legal
Carga horária
Assinaturas
Numeração de registro
Ata de Resultado Final

Descrição:
Registro oficial dos resultados finais da turma.

Elementos internos:

Turma
Ano letivo
Lista de alunos
Resultado final
Frequência
Conselho de classe
Assinaturas
Ficha de Matrícula

Descrição:
Cadastro completo do aluno e responsáveis.

Elementos internos:

Dados pessoais
Documentos
Responsáveis
Endereço
Contatos
Dados médicos
Autorizações
Histórico escolar anterior
Coordenação Pedagógica
Plano de Aula

Descrição:
Planejamento detalhado de uma aula específica.

Elementos internos:

Objetivos
Conteúdo
Metodologia
Recursos
Cronograma
Avaliação
Competências
Habilidades BNCC
Plano de Ensino

Descrição:
Planejamento macro da disciplina para o período letivo.

Elementos internos:

Disciplina
Professor
Ementa
Objetivos
Conteúdos
Metodologia
Critérios de avaliação
Bibliografia
Cronograma
Relatório Pedagógico

Descrição:
Análise pedagógica sobre aluno, turma ou projeto.

Elementos internos:

Identificação
Contextualização
Desenvolvimento
Observações
Dificuldades
Intervenções
Encaminhamentos
Parecer Descritivo

Descrição:
Avaliação qualitativa do desenvolvimento do aluno.

Elementos internos:

Dados do aluno
Desenvolvimento cognitivo
Aspectos socioemocionais
Participação
Recomendações
Assinatura
Diário de Classe

Descrição:
Registro oficial das aulas e frequência.

Elementos internos:

Turma
Disciplina
Conteúdo ministrado
Frequência
Avaliações
Observações
Professor responsável
Financeiro
Boleto/Recibo Escolar

Descrição:
Documento de cobrança ou comprovação de pagamento.

Elementos internos:

Dados do responsável
Valor
Vencimento
Competência
Multa/juros
Código de barras
Histórico financeiro
Contrato de Prestação de Serviços

Descrição:
Formaliza o vínculo entre escola e responsável.

Elementos internos:

Partes envolvidas
Cláusulas
Valores
Vigência
Obrigações
Rescisão
Assinaturas
Demonstrativo Financeiro

Descrição:
Resumo financeiro de pagamentos e pendências.

Elementos internos:

Competências
Valores pagos
Pendências
Descontos
Histórico
Totais
RH
Contrato de Trabalho

Descrição:
Formaliza a contratação de colaboradores.

Elementos internos:

Dados do funcionário
Cargo
Jornada
Salário
Benefícios
Cláusulas
Assinaturas
Folha de Ponto

Descrição:
Controle de frequência dos colaboradores.

Elementos internos:

Funcionário
Datas
Horários
Banco de horas
Assinaturas
Observações
Avaliação de Desempenho

Descrição:
Análise periódica do desempenho profissional.

Elementos internos:

Critérios
Competências
Notas
Feedback
Plano de desenvolvimento
Direção / Gestão
Ata de Reunião

Descrição:
Registro formal de reuniões institucionais.

Elementos internos:

Data
Participantes
Pauta
Discussões
Deliberações
Responsáveis
Assinaturas
Projeto Político Pedagógico (PPP)

Descrição:
Documento estratégico da proposta educacional da escola.

Elementos internos:

Identidade institucional
Missão
Objetivos
Diretrizes pedagógicas
Metodologias
Avaliação
Planos de ação
Regimento Escolar

Descrição:
Conjunto de normas e regras da instituição.

Elementos internos:

Direitos e deveres
Estrutura organizacional
Normas disciplinares
Critérios avaliativos
Calendário
Procedimentos
Orientação / Psicopedagógico
Relatório de Atendimento

Descrição:
Registro de atendimentos individuais.

Elementos internos:

Dados do aluno
Motivo do atendimento
Histórico
Observações
Encaminhamentos
Responsável técnico
Plano de Acompanhamento Individual

Descrição:
Plano de suporte pedagógico/comportamental.

Elementos internos:

Objetivos
Diagnóstico
Estratégias
Cronograma
Responsáveis
Evolução
Biblioteca
Ficha de Empréstimo

Descrição:
Controle de empréstimo de materiais.

Elementos internos:

Usuário
Livro/material
Datas
Situação
Multas
Assinaturas
Tecnologia / TI
Termo de Uso de Sistemas

Descrição:
Define regras de uso dos sistemas escolares.

Elementos internos:

Usuário
Permissões
Regras
LGPD
Responsabilidades
Assinaturas
Relatório de Chamado Técnico

Descrição:
Registro de suporte técnico.

Elementos internos:

Solicitante
Problema
Prioridade
Atendimento
Solução
SLA
Comunicação Escolar
Comunicado aos Pais

Descrição:
Informativo oficial enviado às famílias.

Elementos internos:

Título
Mensagem
Datas
Responsáveis
Assinatura
Confirmação de leitura
Autorização para Evento/Viagem

Descrição:
Permissão formal dos responsáveis.

Elementos internos:

Dados do aluno
Evento
Datas
Responsável legal
Informações médicas
Assinatura
Saúde Escolar
Ficha Médica do Aluno

Descrição:
Cadastro de informações de saúde.

Elementos internos:

Tipo sanguíneo
Alergias
Medicamentos
Restrições
Contatos de emergência
Convênio
Registro de Ocorrência Médica

Descrição:
Registro de incidentes de saúde na escola.

Elementos internos:

Data/hora
Descrição
Procedimentos realizados
Responsáveis acionados
Profissional responsável
Estruturas reutilizáveis para o seu document-builder

Você provavelmente vai precisar de componentes/blocos reutilizáveis:

Blocos comuns
Cabeçalho institucional
Rodapé
Assinaturas
QR Code validação
Tabelas
Campos dinâmicos
Lista de participantes
Timeline/histórico
Parecer textual
Uploads/anexos
Carimbo/autenticação
Tipos de elementos internos
Texto simples
Rich text
Data
Número
Moeda
Checkbox
Select
Multi-select
Tabela dinâmica
Repetidores (ex: disciplinas)
Assinatura digital
Imagem
QR Code
Código de barras
Anexos



aqui eh um modelo de estrutra dos documentos, eh para ser usado com consulta do que cada documento possui de elementos e não para ser usado como guia para alterar a estrutura que já tem pronta em document-builder

<!-- ===================================================== -->
<!-- ESTRUTURA ABSTRATA BASE -->
<!-- ===================================================== -->

1. HISTÓRICO ESCOLAR
<Document type="historico-escolar">

  <Header>
    <InstitutionInfo />
    <DocumentTitle />
    <Authentication />
  </Header>

  <StudentIdentification>
    <PersonalData />
    <EnrollmentData />
    <CurrentStatus />
  </StudentIdentification>

  <AcademicTrajectory>

    <SchoolPeriod>
      <AcademicYear />
      <GradeLevel />
      <Subjects>

        <Subject>
          <Name />
          <Workload />
          <Grades />
          <Attendance />
          <FinalResult />
        </Subject>

      </Subjects>
    </SchoolPeriod>

  </AcademicTrajectory>

  <ComplementaryInformation>
    <Observations />
    <LegalBasis />
  </ComplementaryInformation>

  <Signatures>
    <Secretary />
    <Principal />
  </Signatures>

  <Footer />
</Document>
2. BOLETIM ESCOLAR
<Document type="boletim">

  <Header />

  <StudentInfo />

  <AcademicPeriod />

  <PerformanceTable>

    <SubjectRow>
      <Subject />
      <Grade1 />
      <Grade2 />
      <Average />
      <Attendance />
      <Status />
    </SubjectRow>

  </PerformanceTable>

  <BehavioralSection>
    <TeacherComments />
    <PedagogicalFeedback />
  </BehavioralSection>

  <Signatures />

</Document>
3. DECLARAÇÃO
<Document type="declaracao">

  <Header />

  <DocumentBody>

    <Statement>
      <StudentIdentification />
      <DeclarationText />
      <AcademicContext />
    </Statement>

  </DocumentBody>

  <Validation>
    <IssueDate />
    <Authentication />
  </Validation>

  <Signatures />

</Document>
4. CERTIFICADO
<Document type="certificado">

  <BackgroundVisual />

  <Header>
    <InstitutionIdentity />
  </Header>

  <MainContent>

    <Recipient />
    <CertificationText />

    <CourseInformation>
      <CourseName />
      <Workload />
      <CompletionDate />
    </CourseInformation>

  </MainContent>

  <Validation>
    <RegistryNumber />
    <LegalInformation />
  </Validation>

  <Signatures />

</Document>
5. ATA
<Document type="ata">

  <Header />

  <MeetingIdentification>
    <MeetingType />
    <Date />
    <Location />
  </MeetingIdentification>

  <Participants />

  <Agenda />

  <DiscussionTopics>

    <Topic>
      <Title />
      <Discussion />
      <Decisions />
    </Topic>

  </DiscussionTopics>

  <ClosingSection />

  <Signatures />

</Document>
6. FICHA DE MATRÍCULA
<Document type="ficha-matricula">

  <Header />

  <StudentData>
    <PersonalInformation />
    <Documents />
    <Address />
    <MedicalInfo />
  </StudentData>

  <GuardianData>
    <PrimaryGuardian />
    <SecondaryGuardian />
  </GuardianData>

  <AcademicData>
    <PreviousSchool />
    <DesiredGrade />
    <Shift />
  </AcademicData>

  <Authorizations>
    <ImageUse />
    <MedicalEmergency />
    <LGPDConsent />
  </Authorizations>

  <Attachments />

  <Signatures />

</Document>
7. PLANO DE AULA
<Document type="plano-aula">

  <Header />

  <ClassIdentification>
    <Teacher />
    <Subject />
    <Classroom />
    <Date />
  </ClassIdentification>

  <PedagogicalStructure>

    <Objectives />

    <SkillsAndCompetencies />

    <Content />

    <Methodology />

    <Resources />

    <Activities />

    <Evaluation />

  </PedagogicalStructure>

  <Observations />

</Document>
8. PLANO DE ENSINO
<Document type="plano-ensino">

  <Header />

  <DisciplineIdentification />

  <GeneralInformation>
    <Workload />
    <AcademicPeriod />
  </GeneralInformation>

  <PedagogicalPlanning>

    <Syllabus />

    <LearningObjectives />

    <CurriculumMatrix />

    <TeachingStrategies />

    <EvaluationCriteria />

    <Bibliography />

  </PedagogicalPlanning>

</Document>
9. RELATÓRIO PEDAGÓGICO
<Document type="relatorio-pedagogico">

  <Header />

  <Identification />

  <Contextualization />

  <DevelopmentAnalysis>

    <CognitiveDevelopment />

    <BehavioralDevelopment />

    <SocialDevelopment />

  </DevelopmentAnalysis>

  <Interventions />

  <Recommendations />

  <Conclusion />

  <Signatures />

</Document>
10. DIÁRIO DE CLASSE
<Document type="diario-classe">

  <Header />

  <ClassIdentification />

  <ClassSessions>

    <Session>
      <Date />
      <LessonContent />
      <AttendanceList />
      <Activities />
      <Observations />
    </Session>

  </ClassSessions>

  <EvaluationRecords />

</Document>
11. CONTRATO
<Document type="contrato">

  <Header />

  <ContractParties>
    <Institution />
    <ResponsibleParty />
  </ContractParties>

  <ContractClauses>

    <Clause>
      <Title />
      <Description />
    </Clause>

  </ContractClauses>

  <FinancialTerms />

  <LegalConditions />

  <Validity />

  <Signatures />

</Document>
12. COMUNICADO
<Document type="comunicado">

  <Header />

  <CommunicationMetadata>
    <Title />
    <TargetAudience />
    <PublicationDate />
  </CommunicationMetadata>

  <MessageBody />

  <ActionItems />

  <ResponsibleSector />

  <Signatures />

</Document>
13. AUTORIZAÇÃO
<Document type="autorizacao">

  <Header />

  <StudentIdentification />

  <EventInformation>
    <Destination />
    <Schedule />
    <ResponsibleStaff />
  </EventInformation>

  <AuthorizationText />

  <EmergencyInformation />

  <GuardianConsent />

  <Signatures />

</Document>
14. RELATÓRIO DE ATENDIMENTO
<Document type="relatorio-atendimento">

  <Header />

  <StudentIdentification />

  <AttendanceMetadata>
    <Date />
    <Professional />
    <Reason />
  </AttendanceMetadata>

  <SessionDescription />

  <Analysis />

  <Recommendations />

  <FollowUpActions />

  <Signatures />

</Document>
15. FICHA MÉDICA
<Document type="ficha-medica">

  <Header />

  <StudentIdentification />

  <HealthProfile>
    <BloodType />
    <Allergies />
    <Medications />
    <MedicalConditions />
  </HealthProfile>

  <EmergencyContacts />

  <MedicalAuthorizations />

  <Attachments />

  <Signatures />

</Document>
BLOCOS GENÉRICOS REUTILIZÁVEIS
<Header>
  <Logo />
  <InstitutionName />
  <Address />
  <Contacts />
</Header>
<Footer>
  <PageNumber />
  <GeneratedAt />
  <AuthenticationCode />
</Footer>
<Signatures>
  <Signature>
    <Role />
    <Person />
    <SignedAt />
  </Signature>
</Signatures>
<Table>
  <Columns />
  <Rows />
  <Summary />
</Table>
<DynamicList>
  <Item />
</DynamicList>
<Attachment>
  <Type />
  <File />
</Attachment>
ESTRUTURA MAIS MODERNA (RECOMENDADA)

Se você quiser um document-builder realmente escalável, o ideal é separar:

<Document>

  <Schema />
  <Data />
  <Layout />
  <Rules />
  <Renderer />

</Document>

ou:

<DocumentTemplate>

  <Blocks>

    <Block type="header" />
    <Block type="table" />
    <Block type="rich-text" />
    <Block type="signature" />

  </Blocks>

  <Bindings />

  <Conditions />

  <Styles />

</DocumentTemplate>
EXEMPLO MAIS PRÓXIMO DE UM BUILDER REAL
<DocumentTemplate name="BoletimEscolar">

  <Block id="header" type="institution-header" />

  <Block id="student-info" type="student-card">
    <Bind source="student" />
  </Block>

  <Block id="grades" type="dynamic-table">
    <Columns>
      <Column field="subject" />
      <Column field="grade" />
      <Column field="attendance" />
    </Columns>

    <Bind source="student.subjects" />
  </Block>

  <Block id="comments" type="rich-text">
    <Bind source="teacher.comments" />
  </Block>

  <Block id="signature" type="signature-group" />

</DocumentTemplate>
