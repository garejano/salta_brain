------Escola Gerencial
CREATE TABLE EscolaGerencial (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RedeId INT NOT NULL,
    Nome VARCHAR(200) NOT NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    Hash UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    UsuarioInclusao INT NOT NULL,
    DataInclusao DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioUltimaAlteracao INT NULL,
    DataUltimaAlteracao DATETIME NULL,
    DataInativacao DATETIME NULL
);
GO

ALTER TABLE EscolaGerencial
ADD CONSTRAINT FK_EscolaGerencial_Rede
    FOREIGN KEY (RedeId) REFERENCES Rede(Id);
GO



------Escola Gerencial Escola
CREATE TABLE EscolaGerencialEscola (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EscolaGerencialId INT NOT NULL,
    EscolaId INT NOT NULL,
    Ativo BIT NOT NULL DEFAULT 1,
    Hash UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    UsuarioInclusao INT NOT NULL,
    DataInclusao DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioUltimaAlteracao INT NULL,
    DataUltimaAlteracao DATETIME NULL,
    DataInativacao DATETIME NULL
);


ALTER TABLE EscolaGerencialEscola
ADD CONSTRAINT FK_EscolaGerencialEscola_EscolaGerencial
    FOREIGN KEY (EscolaGerencialId) REFERENCES EscolaGerencial(Id);


ALTER TABLE EscolaGerencialEscola
ADD CONSTRAINT FK_EscolaGerencialEscola_Escola
    FOREIGN KEY (EscolaId) REFERENCES Escola(Id);