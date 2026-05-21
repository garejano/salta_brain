CREATE TABLE Importacoes.AlocacaoProfessores (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    [Hash] UNIQUEIDENTIFIER,
    RedeId INT NOT NULL,
    AnoLetivoId INT NOT NULL,
    NomeArquivo VARCHAR(255) NOT NULL,
    ImportacaoAlocacaoProfessoresStatusId INT NOT NULL,
    QuantidadeLinhasEnviadas INT NOT NULL,
    QuantidadeLinhasImportadas INT NOT NULL,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_AlocacaoProfessores_Rede
        FOREIGN KEY (RedeId)
        REFERENCES Rede (Id),
    CONSTRAINT FK_AlocacaoProfessores_AnoLetivo
        FOREIGN KEY (AnoLetivoId)
        REFERENCES AnoLetivo (Id)   
);

select * from Importacoes.AlocacaoProfessores ap ;


CREATE TABLE Importacoes.AlocacaoProfessoresStatus (
    Id INT PRIMARY KEY,
    [Hash] UNIQUEIDENTIFIER,
    Nome VARCHAR(100) NOT NULL
);

INSERT INTO Importacoes.AlocacaoProfessoresStatus (Id, Hash, Nome) VALUES
(1, NEWID(), 'ValidandoEscolas'),
(2, NEWID(), 'ValidandoTurmas'),
(3,NEWID(), 'ValidandoTurmasComCarga'),
(4,NEWID(), 'ValidandoDisciplinas'),
(5,NEWID(), 'ValidandoProfessores'),
(6,NEWID(), 'RealizandoImportacao'),
(7,NEWID(), 'ImportacaoConcluida');


CREATE TABLE Importacoes.AlocacaoProfessoresLinha (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    [Hash] UNIQUEIDENTIFIER,
    ImportacaoAlocacaoProfessoresId INT NOT NULL,
    -- Escola
    EscolaValida BIT NOT NULL,
    NomeEscola VARCHAR(255),
    EscolaId INT NULL,
    -- Turma
    TurmaValida BIT NOT NULL,
    NomeTurma VARCHAR(255),
    TurmaId INT NULL,
    -- Disciplina
    DisciplinaValida BIT NOT NULL,
    NomeDisciplina VARCHAR(255),
    DisciplinaId INT NULL,
    -- Professor
    ProfessorValido BIT NOT NULL,
    NomeProfessor VARCHAR(255),
    CPF VARCHAR(14),
    ProfessorPerfilVigenteId INT NULL,
    -- Regras de negócio
    TurmaJaPossuiCargaInicial BIT NOT NULL,
    NaoRealizarImportacao BIT NOT NULL,
    DataCriacao DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_AlocacaoProfessoresLinha_Importacao
        FOREIGN KEY (ImportacaoAlocacaoProfessoresId)
        REFERENCES Importacoes.AlocacaoProfessores (Id),
    CONSTRAINT FK_AlocacaoProfessoresLinha_Escola
        FOREIGN KEY (EscolaId)
        REFERENCES Escola (Id),
    CONSTRAINT FK_AlocacaoProfessoresLinha_Turma
        FOREIGN KEY (TurmaId)
        REFERENCES Turma (Id),
    CONSTRAINT FK_AlocacaoProfessoresLinha_Disciplina
        FOREIGN KEY (DisciplinaId)
        REFERENCES Disciplina (Id),
    CONSTRAINT FK_AlocacaoProfessoresLinha_ProfessorPerfil
        FOREIGN KEY (ProfessorPerfilVigenteId)
        REFERENCES ProfessorPerfilVigente (Id)
);


