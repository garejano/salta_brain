select * from Folha.ProfessorCargaSubstituto pcs; 


CREATE TABLE Folha.ProfessorCargaSubstituto(
Id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
Hash UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
ProfessorCarga INT NOT NULL,
ProfessorPerfilVigente INT NULL,
DataEntrada DATETIME2 NOT NULL,
DataSaida DATETIME2 NULL,
MotivoAlteracao INT NULL,
Vago BIT NOT NULL,
PessoaLancamentoEntrada INT NOT NULL,
DataLancamentoEntrada DATETIME2 NOT NULL,
PessoaLancamentoSaida INT NULL,
DataLancamentoSaida DATETIME2 NULL,
Aprovado BIT NOT NULL,
PessoaAprovacao INT NULL,
DataAprovacao DATETIME2 NULL,
Ativo BIT NOT NULL DEFAULT 1,
UsuarioInclusao INT NOT NULL,
DataInclusao DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
UsuarioUltimaAlteracao INT NULL,
DataUltimaAlteracao DATETIME2 NULL,
UsuarioInativacao INT NULL,
DataInativacao DATETIME2 NULL,
CONSTRAINT FK_ProfessorCargaSubstituto_ProfessorCarga FOREIGN KEY(ProfessorCarga) REFERENCES Folha.ProfessorCarga(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_ProfessorPerfilVigente FOREIGN KEY(ProfessorPerfilVigente) REFERENCES ProfessorPerfilVigente(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_MotivoAlteracao FOREIGN KEY(MotivoAlteracao) REFERENCES Folha.MotivosSaida(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_PessoaLancamentoEntrada FOREIGN KEY(PessoaLancamentoEntrada) REFERENCES Pessoa(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_PessoaLancamentoSaida FOREIGN KEY(PessoaLancamentoSaida) REFERENCES Pessoa(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_PessoaAprovacao FOREIGN KEY(PessoaAprovacao) REFERENCES Pessoa(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_UsuarioInclusao FOREIGN KEY(UsuarioInclusao) REFERENCES Usuario(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_UsuarioUltimaAlteracao FOREIGN KEY(UsuarioUltimaAlteracao) REFERENCES Usuario(Id),
CONSTRAINT FK_ProfessorCargaSubstituto_UsuarioInativacao FOREIGN KEY(UsuarioInativacao) REFERENCES Usuario(Id),
CONSTRAINT CK_ProfessorCargaSubstituto_Ativo_Inativacao CHECK((Ativo=1 AND DataInativacao IS NULL) OR (Ativo=0 AND DataInativacao IS NOT NULL))
);

ALTER TABLE Folha.ProfessorCargaSubstituto
DROP CONSTRAINT DF__Professor__Saida__3A9A1CB7;

ALTER TABLE Folha.ProfessorCargaSubstituto
DROP COLUMN SaidaTemporaria;