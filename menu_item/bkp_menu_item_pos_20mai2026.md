# Backup — MenuItems criados após 2026-05-19

Capturado em: 2026-05-20  
Filtro: `DataInclusao > '2026-05-19'`  
Total de registros: 3

---

## Registros

### Id 787 — Itinerário Formativo

| Campo | Valor |
|---|---|
| `Id` | 787 |
| `MenuItemPai` | 343 (Gestão Escolar) |
| `Nome` | Itinerário Formativo |
| `IconeFontAwesome` | fas fa-fw fa-graduation-cap |
| `Funcionalidade` | 426 |
| `Rota` | /estrutura-pedagogica/itinerario-formativo/listar |
| `TipoRota` | 1 |
| `Ordem` | 35 |
| `Desktop` | 1 |
| `Mobile` | 1 |
| `Ativo` | 1 |
| `UsuarioInclusao` | 1097334 |
| `DataInclusao` | 2026-05-20 11:02:16 |
| `PrefixoDoModulo` | /estrutura-pedagogica |
| `ViewModel` | NULL |
| `RotaKO` | NULL |
| `PerfilAcesso` | NULL |
| `TipoRede` | NULL |
| `Fixo` | 0 |
| `NomeCurto` | NULL |

---

### Id 788 — Lançamento de Frequência (Novo)

| Campo | Valor |
|---|---|
| `Id` | 788 |
| `MenuItemPai` | 329 (Rotinas Acadêmicas) |
| `Nome` | Lançamento de Frequência (Novo) |
| `IconeFontAwesome` | fas fa-fw fa-tasks |
| `Funcionalidade` | 422 |
| `Rota` | /estrutura-pedagogica/lancamento-frequencia/listar |
| `TipoRota` | 1 |
| `Ordem` | 17 |
| `Desktop` | 1 |
| `Mobile` | 1 |
| `Ativo` | 1 |
| `UsuarioInclusao` | 1097334 |
| `DataInclusao` | 2026-05-20 11:02:49 |
| `PrefixoDoModulo` | /estrutura-pedagogica |
| `ViewModel` | NULL |
| `RotaKO` | NULL |
| `PerfilAcesso` | NULL |
| `TipoRede` | NULL |
| `Fixo` | 0 |
| `NomeCurto` | NULL |

---

### Id 789 — Lançamento de Eventos (Novo)

| Campo | Valor |
|---|---|
| `Id` | 789 |
| `MenuItemPai` | 394 (Professores) |
| `Nome` | Lançamento de Eventos (Novo) |
| `IconeFontAwesome` | fas fa-fw fa-chalkboard-teacher |
| `Funcionalidade` | 215 |
| `Rota` | /estrutura-pedagogica/movimentacao-pedagogica/lancamento-eventos |
| `TipoRota` | 1 |
| `Ordem` | 2 |
| `Desktop` | 1 |
| `Mobile` | 1 |
| `Ativo` | 1 |
| `UsuarioInclusao` | 1324989 |
| `DataInclusao` | 2026-05-20 15:53:52 |
| `PrefixoDoModulo` | /estrutura-pedagogica |
| `ViewModel` | NULL |
| `RotaKO` | NULL |
| `PerfilAcesso` | NULL |
| `TipoRede` | NULL |
| `Fixo` | 0 |
| `NomeCurto` | NULL |

---

## Script de restore (DELETE)

Caso precise desfazer todos os itens acima:

```sql
DELETE FROM MenuItem WHERE Id IN (787, 788, 789);
```
