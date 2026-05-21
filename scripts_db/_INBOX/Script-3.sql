CREATE TRIGGER [Folha].[TR_TipoEvento_AfterUpdate_LogAlteracao]
ON [Folha].[TipoEvento]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON d.Id = i.Id
        WHERE EXISTS (
            SELECT i.[Hash], i.Nome, i.RedePagamento, i.TipoPagamento, i.Ativo,
                   i.UsuarioInclusao, i.DataInclusao,
                   i.UsuarioUltimaAlteracao, i.DataUltimaAlteracao,
                   i.UsuarioInativacao, i.DataInativacao
            EXCEPT
            SELECT d.[Hash], d.Nome, d.RedePagamento, d.TipoPagamento, d.Ativo,
                   d.UsuarioInclusao, d.DataInclusao,
                   d.UsuarioUltimaAlteracao, d.DataUltimaAlteracao,
                   d.UsuarioInativacao, d.DataInativacao
        )
    )
    BEGIN
        INSERT INTO LogAlteracoes.TipoEvento
        (
            [Hash], TipoEvento, Nome, RedePagamento, TipoPagamento, Ativo,
            UsuarioInclusao, DataInclusao, UsuarioUltimaAlteracao, DataUltimaAlteracao,
            UsuarioInativacao, DataInativacao
        )
        SELECT
            d.[Hash], d.Id, d.Nome, d.RedePagamento, d.TipoPagamento, d.Ativo,
            d.UsuarioInclusao, d.DataInclusao, d.UsuarioUltimaAlteracao, d.DataUltimaAlteracao,
            d.UsuarioInativacao, d.DataInativacao
        FROM deleted d;
    END
END;
GO

