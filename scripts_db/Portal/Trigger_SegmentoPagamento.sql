CREATE TRIGGER [Folha].[TR_SegmentoPagamento_AfterUpdate_LogAlteracao]
ON [Folha].[SegmentoPagamento]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.Id = i.Id
        WHERE EXISTS (
            SELECT i.[Hash], i.RedePagamento, i.Nome, i.Sigla, i.Ativo,
                   i.UsuarioInclusao, i.DataInclusao,
                   i.UsuarioUltimaAlteracao, i.DataUltimaAlteracao,
                   i.UsuarioInativacao, i.DataInativacao
            EXCEPT
            SELECT d.[Hash], d.RedePagamento, d.Nome, d.Sigla, d.Ativo,
                   d.UsuarioInclusao, d.DataInclusao,
                   d.UsuarioUltimaAlteracao, d.DataUltimaAlteracao,
                   d.UsuarioInativacao, d.DataInativacao
        )
    )
    BEGIN
        INSERT INTO LogAlteracoes.SegmentoPagamento
        (
            [Hash], SegmentoPagamento, RedePagamento, Nome, Sigla, Ativo,
            UsuarioInclusao, DataInclusao, UsuarioUltimaAlteracao, DataUltimaAlteracao,
            UsuarioInativacao, DataInativacao
        )
        SELECT
            d.[Hash], d.Id, d.RedePagamento, d.Nome, d.Sigla, d.Ativo,
            d.UsuarioInclusao, d.DataInclusao, d.UsuarioUltimaAlteracao, d.DataUltimaAlteracao,
            d.UsuarioInativacao, d.DataInativacao
        FROM deleted d;
    END
END;
GO

