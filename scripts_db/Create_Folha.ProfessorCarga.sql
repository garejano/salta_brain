drop table Folha.ProfessorCargaSubstituto;
drop table Folha.ProfessorCarga;

select * from Folha.ProfessorCarga pc; 

CREATE TABLE Folha.ProfessorCarga (
    Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    -- Identificador lógico
    Hash UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    -- Vínculos principais
    ProfessorPerfilVigente INT NULL,
    Turma INT NOT NULL,
    Disciplina INT NOT NULL,
    -- Carga
    QuantidadeTempos DECIMAL(10,2) NOT NULL,
    -- Vigência
    DataEntrada DATETIME2 NOT NULL,
    DataSaida DATETIME2 NULL,
    -- Motivo da saída ou alteração
    MotivoAlteracao INT NULL,
    -- Flags
    Vago BIT NOT NULL,
    SaidaTemporaria BIT NOT NULL DEFAULT 0,
    Aprovado BIT NOT NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    -- Lançamento
    PessoaLancamentoEntrada INT NOT NULL,
    DataLancamentoEntrada DATETIME2 NOT NULL,
    PessoaLancamentoSaida INT NULL,
    DataLancamentoSaida DATETIME2 NULL,
    -- Aprovação
    PessoaAprovacao INT NULL,
    DataAprovacao DATETIME2 NULL,
    -- Auditoria (StatefulEntity)
    UsuarioInclusao INT NOT NULL,
    DataInclusao DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UsuarioUltimaAlteracao INT NULL,
    DataUltimaAlteracao DATETIME2 NULL,
    UsuarioInativacao INT NULL,
    DataInativacao DATETIME2 NULL,
    -- ===============================
    -- FOREIGN KEYS
    -- ===============================
    CONSTRAINT FK_ProfessorCarga_ProfessorPerfilVigente
        FOREIGN KEY (ProfessorPerfilVigente)
        REFERENCES ProfessorPerfilVigente(Id),

    CONSTRAINT FK_ProfessorCarga_Turma
        FOREIGN KEY (Turma)
        REFERENCES Turma(Id),

    CONSTRAINT FK_ProfessorCarga_Disciplina
        FOREIGN KEY (Disciplina)
        REFERENCES Folha.Disciplina(Id),

    CONSTRAINT FK_ProfessorCarga_MotivoAlteracao
        FOREIGN KEY (MotivoAlteracao)
        REFERENCES Folha.MotivosSaida(Id),

    CONSTRAINT FK_ProfessorCarga_PessoaLancamentoEntrada
        FOREIGN KEY (PessoaLancamentoEntrada)
        REFERENCES Pessoa(Id),

    CONSTRAINT FK_ProfessorCarga_PessoaLancamentoSaida
        FOREIGN KEY (PessoaLancamentoSaida)
        REFERENCES Pessoa(Id),

    CONSTRAINT FK_ProfessorCarga_PessoaAprovacao
        FOREIGN KEY (PessoaAprovacao)
        REFERENCES Pessoa(Id),

    CONSTRAINT FK_ProfessorCarga_UsuarioInclusao
        FOREIGN KEY (UsuarioInclusao)
        REFERENCES Usuario(Id),

    CONSTRAINT FK_ProfessorCarga_UsuarioUltimaAlteracao
        FOREIGN KEY (UsuarioUltimaAlteracao)
        REFERENCES Usuario(Id),

    CONSTRAINT FK_ProfessorCarga_UsuarioInativacao
        FOREIGN KEY (UsuarioInativacao)
        REFERENCES Usuario(Id),
);
