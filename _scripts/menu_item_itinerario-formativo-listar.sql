-- MenuItem: Itinerário Formativo (listar)
-- Gerado em: 2026-05-20
-- Rota Angular: /estrutura-pedagogica/itinerario-formativo/listar
-- MenuItemPai 343 = "Gestão Escolar" (TipoRota 0, grupo raiz)
-- Funcionalidade 426 = "Configurador de Itinerário Formativo"

INSERT INTO MenuItem (
    MenuItemPai, Nome, IconeFontAwesome, Funcionalidade, Rota, TipoRota, Ordem,
    Desktop, Mobile, Hash, Ativo, UsuarioInclusao, DataInclusao,
    UsuarioUltimaAlteracao, DataUltimaAlteracao, UsuarioInativacao, DataInativacao,
    ViewModel, PrefixoDoModulo, RotaKO, PerfilAcesso, TipoRede, Fixo, NomeCurto
)
VALUES (
    343,                                                        -- MenuItemPai (Gestão Escolar)
    'Itinerário Formativo',                                     -- Nome
    'fas fa-fw fa-graduation-cap',                              -- IconeFontAwesome
    426,                                                        -- Funcionalidade (Configurador de Itinerário Formativo)
    '/estrutura-pedagogica/itinerario-formativo/listar',        -- Rota
    1,                                                          -- TipoRota (1 = Angular SPA)
    35,                                                         -- Ordem (próxima disponível sob 343)
    1,                                                          -- Desktop
    1,                                                          -- Mobile
    NEWID(),                                                    -- Hash
    0,                                                          -- Ativo (começa inativo)
    1097334,                                                    -- UsuarioInclusao (Gustavo)
    GETDATE(),                                                  -- DataInclusao
    NULL,                                                       -- UsuarioUltimaAlteracao
    NULL,                                                       -- DataUltimaAlteracao
    NULL,                                                       -- UsuarioInativacao
    NULL,                                                       -- DataInativacao
    NULL,                                                       -- ViewModel
    '/estrutura-pedagogica',                                    -- PrefixoDoModulo
    NULL,                                                       -- RotaKO
    NULL,                                                       -- PerfilAcesso
    NULL,                                                       -- TipoRede
    0,                                                          -- Fixo
    NULL                                                        -- NomeCurto
);

-- Após confirmar o Id gerado, ativar com:
UPDATE MenuItem SET Ativo = 1 WHERE Id = SCOPE_IDENTITY();
