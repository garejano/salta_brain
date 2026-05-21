select * from folha.MotivosSaida ms ;


ALTER TABLE Folha.ProfessorCarga
ALTER COLUMN SaidaTemporaria BIT NULL;

ALTER TABLE Folha.ProfessorCarga
ALTER COLUMN SaidaTemporaria BIT NOT NULL;

ALTER TABLE Folha.MotivosSaida
ADD 
    EhSaidaTemporaria BIT NOT NULL DEFAULT 0,
    EhRetornoDeSaidaTemporaria BIT NOT NULL DEFAULT 0;

UPDATE Folha.MotivosSaida
SET 
    EhSaidaTemporaria = CASE 
        WHEN Id IN (7, 8, 10, 11, 13) THEN 1
        ELSE 0
    END,
    EhRetornoDeSaidaTemporaria = CASE
        WHEN Id IN (6, 9, 12, 17) THEN 1
        ELSE 0
    END;


INSERT INTO folha.MotivosSaida (
	Descricao, 
	Ativo,
	UsuarioInclusao,
	Hash,
	DataInclusao,
	TodasAsRedes,
	EhSaidaTemporaria,
	EhRetornoDeSaidaTemporaria,
	EhMotivoPorTurma,
	EhMotivoPorProfessor,
	SelecionavelPeloUsuario
)
values (
	'Entrada de novo professor',
	1,
	1097334,
	NEWID(),
	GETDATE(),
	1,
	0,
	0,
	0,
	0,
	1
);

