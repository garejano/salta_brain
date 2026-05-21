INSERT INTO MenuItem (
    MenuItemPai, Nome, IconeFontAwesome, Funcionalidade, Rota, TipoRota, Ordem,
    Desktop, Mobile, Hash, Ativo, UsuarioInclusao, DataInclusao,
    UsuarioUltimaAlteracao, DataUltimaAlteracao, UsuarioInativacao, DataInativacao,
    ViewModel, PrefixoDoModulo, RotaKO, PerfilAcesso, TipoRede, Fixo, NomeCurto
)
VALUES
(
    367,                                        -- MenuItemPai
    'Consulta de Processamento de Boletins',    -- Nome
    'fas fa-fw fa-tasks',                       -- IconeFontAwesome
    92,                                         -- Funcionalidade
    '/estrutura-pedagogica/boletim/processamento', -- Rota
    1,                                          -- TipoRota
    3,                                          -- Ordem
    1,                                          -- Desktop
    1,                                          -- Mobile
    NEWID(),                                    -- Hash
    0,                                          -- Ativo
    1097334,                                    -- UsuarioInclusao
    GETDATE(),                                  -- DataInclusao
    NULL,                                       -- UsuarioUltimaAlteracao
    NULL,                                       -- DataUltimaAlteracao
    NULL,                                       -- UsuarioInativacao
    NULL,                                       -- DataInativacao
    NULL,                                       -- ViewModel
    '/estrutura-pedagogica',                    -- PrefixoDoModulo
    NULL,                                       -- RotaKO
    NULL,                                       -- PerfilAcesso
    NULL,                                       -- TipoRede
    0,                                          -- Fixo
    NULL                                        -- NomeCurto
);
