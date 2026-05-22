# Análise: Tabela MenuItem

## Estrutura da tabela

| Campo | Tipo | Nulo | Descrição |
|---|---|---|---|
| `Id` | int | NO | PK, auto-increment |
| `MenuItemPai` | int | YES | FK para outro MenuItem (NULL = item raiz/grupo) |
| `Nome` | varchar(255) | NO | Texto exibido no menu |
| `IconeFontAwesome` | varchar(2000) | YES | Classe FA, ex: `fas fa-fw fa-tasks` |
| `Funcionalidade` | int | YES | FK para tabela `Funcionalidade` (controla acesso) |
| `Rota` | varchar(255) | YES | URL completa do item |
| `TipoRota` | int | NO | Enum — ver abaixo |
| `Ordem` | int | NO | Ordem de exibição dentro do pai |
| `Desktop` | bit | NO | Visível no desktop |
| `Mobile` | bit | NO | Visível no mobile |
| `Hash` | uniqueidentifier | NO | Sempre `NEWID()` no insert |
| `Ativo` | bit | NO | 0 = inativo (padrão ao criar), 1 = ativo |
| `UsuarioInclusao` | int | NO | ID do usuário que criou (Gustavo = 1097334) |
| `DataInclusao` | datetime | NO | `GETDATE()` |
| `UsuarioUltimaAlteracao` | int | YES | NULL no insert |
| `DataUltimaAlteracao` | datetime | YES | NULL no insert |
| `UsuarioInativacao` | int | YES | NULL no insert |
| `DataInativacao` | datetime | YES | NULL no insert |
| `ViewModel` | varchar(255) | YES | NULL para apps Angular (legacy KO) |
| `PrefixoDoModulo` | varchar(100) | YES | Prefixo da app, ex: `/estrutura-pedagogica` |
| `RotaKO` | varchar(250) | YES | NULL para apps Angular (legacy KO) |
| `PerfilAcesso` | int | YES | NULL na maioria dos casos |
| `TipoRede` | int | YES | NULL ou 2 (rede privada) |
| `Fixo` | bit | NO | Sempre 0 |
| `NomeCurto` | nvarchar(500) | YES | NULL na maioria |

## Enum TipoRota

| Valor | Significado | Exemplo de Rota |
|---|---|---|
| `0` | Menu pai / grupo (sem rota) | NULL |
| `1` | Rota interna Angular (SPA) | `/estrutura-pedagogica/folha/listar-checklist` |
| `4` | Link externo (abre URL direta) | `https://saltamaisbeneficios.com/` |
| `6` | Especial / Notificação | `/ped/#Notificacao` |

## Padrão para rotas do `estrutura-pedagogica`

```sql
PrefixoDoModulo = '/estrutura-pedagogica'
TipoRota        = 1
Rota            = '/estrutura-pedagogica/{modulo}/{sub-rota}'
ViewModel       = NULL
RotaKO          = NULL
Desktop         = 1
Mobile          = 1
Ativo           = 0   -- começa inativo; ativar separadamente
Fixo            = 0
TipoRede        = NULL
PerfilAcesso    = NULL
NomeCurto       = NULL
UsuarioInclusao = 1097334
```

## Rotas do `pathing.service.ts` x MenuItem no banco

Arquivo: `c:/projects/estrutura-pedagogica/frontend/src/shared/services/pathing.service.ts`

| Rota completa | Em MenuItem? | Id |
|---|---|---|
| `/estrutura-pedagogica/periodoletivo/editar` | ✅ (como `periodo-letivo/editar`) | 681 |
| `/estrutura-pedagogica/escolas-publicas/listar` | ✅ | 690 |
| `/estrutura-pedagogica/escolas-publicas/detalhes` | ❌ | — |
| `/estrutura-pedagogica/lancamento-frequencia/listar` | ❌ | — |
| `/estrutura-pedagogica/lancamento-frequencia/lancamento` | ❌ | — |
| `/estrutura-pedagogica/folha/listar-checklist` | ✅ | 769 |
| `/estrutura-pedagogica/folha/listar-previa` | ✅ | 771 |
| `/estrutura-pedagogica/folha/novo-envio` | ❌ | — |
| `/estrutura-pedagogica/folha/informacoes-envio` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-escolas-pagamento` | ✅ | 774 |
| `/estrutura-pedagogica/folha/configuracao-chapa` | ✅ | 775 |
| `/estrutura-pedagogica/folha/edicao-chapa` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-segmentos-pagamento` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-segmentos-sindical` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-classes` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-tipos-evento` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-macroturmas` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-turmas-macroturmas` | ❌ | — |
| `/estrutura-pedagogica/folha/lista-cargos-pagamento` | ❌ | — |
| `/estrutura-pedagogica/folha/hora-aula-padrao` | ❌ | — |
| `/estrutura-pedagogica/relatorio/disciplinas` | ✅ | 697 |
| `/estrutura-pedagogica/boletim/processamento` | ✅ | 779 |
| `/estrutura-pedagogica/movimentacao-pedagogica/alteracao-carga` | ✅ | 602 |
| `/estrutura-pedagogica/movimentacao-pedagogica/detalhes` | ❌ | — |
| `/estrutura-pedagogica/movimentacao-pedagogica/lancamento-eventos` | ❌ | — |
| `/estrutura-pedagogica/movimentacao-pedagogica/detalhes-lancamento-evento` | ❌ | — |
| `/estrutura-pedagogica/cargas-iniciais/alocacao-professores` | ❌ | — |
| `/estrutura-pedagogica/cargas-iniciais/grade-horaria` | ❌ | — |
| `/estrutura-pedagogica/cargas-iniciais/validacao` | ❌ | — |
| `/estrutura-pedagogica/escolas-gerenciais/lista-escolas-gerencial` | ✅ | 778 |
| `/estrutura-pedagogica/itinerario-formativo/listar` | ❌ | — |
| `/estrutura-pedagogica/itinerario-formativo/selecao` | ❌ | — |

## MenuItens pai (grupos) usados em estrutura-pedagogica

Consulta útil para descobrir o `MenuItemPai` correto:
```sql
SELECT Id, MenuItemPai, Nome FROM MenuItem WHERE TipoRota = 0 ORDER BY Id;
-- Grupos identificados: 343, 317, 394, 773, 367
```

## Template de INSERT (padrão estrutura-pedagogica)

```sql
INSERT INTO MenuItem (
    MenuItemPai, Nome, IconeFontAwesome, Funcionalidade, Rota, TipoRota, Ordem,
    Desktop, Mobile, Hash, Ativo, UsuarioInclusao, DataInclusao,
    UsuarioUltimaAlteracao, DataUltimaAlteracao, UsuarioInativacao, DataInativacao,
    ViewModel, PrefixoDoModulo, RotaKO, PerfilAcesso, TipoRede, Fixo, NomeCurto
)
VALUES (
    {MenuItemPai},                                   -- MenuItemPai (ID do grupo pai)
    '{Nome}',                                        -- Nome
    'fas fa-fw fa-{icone}',                          -- IconeFontAwesome
    {FuncionalidadeId},                              -- Funcionalidade (ou NULL)
    '/estrutura-pedagogica/{modulo}/{sub-rota}',     -- Rota
    1,                                               -- TipoRota (1 = Angular SPA)
    {Ordem},                                         -- Ordem
    1,                                               -- Desktop
    1,                                               -- Mobile
    NEWID(),                                         -- Hash
    0,                                               -- Ativo (0 = começa inativo)
    1097334,                                         -- UsuarioInclusao (Gustavo)
    GETDATE(),                                       -- DataInclusao
    NULL,                                            -- UsuarioUltimaAlteracao
    NULL,                                            -- DataUltimaAlteracao
    NULL,                                            -- UsuarioInativacao
    NULL,                                            -- DataInativacao
    NULL,                                            -- ViewModel
    '/estrutura-pedagogica',                         -- PrefixoDoModulo
    NULL,                                            -- RotaKO
    NULL,                                            -- PerfilAcesso
    NULL,                                            -- TipoRede
    0,                                               -- Fixo
    NULL                                             -- NomeCurto
);
```

## Queries úteis de apoio

```sql
-- Ver todos os itens de um módulo
SELECT Id, MenuItemPai, Nome, Rota, TipoRota, Ordem, Ativo
FROM MenuItem WHERE PrefixoDoModulo = '/estrutura-pedagogica' ORDER BY Id;

-- Encontrar o próximo Ordem disponível dentro de um pai
SELECT MAX(Ordem) + 1 FROM MenuItem WHERE MenuItemPai = {MenuItemPai};

-- Verificar se a rota já existe
SELECT Id, Nome FROM MenuItem WHERE Rota = '/estrutura-pedagogica/...';

-- Buscar Funcionalidade por nome
SELECT Id, Nome FROM Funcionalidade WHERE Nome LIKE '%{termo}%';

-- Ativar após inserir
UPDATE MenuItem SET Ativo = 1 WHERE Id = {Id};
```
