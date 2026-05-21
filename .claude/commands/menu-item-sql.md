# Gerar SQL de MenuItem

Gera o INSERT SQL para criar um novo `MenuItem` no banco de dados do portal.

## Uso

```
/menu-item-sql
```

Pode ser chamado com ou sem argumentos. Se chamado sem argumentos, faça as perguntas necessárias.

---

## Contexto obrigatório: ler antes de gerar

Leia o arquivo de análise completo antes de começar:

```
c:/projects/salta_brain/menu_item/analise_menu_item.md
```

Esse arquivo contém:
- Estrutura completa da tabela
- Enum de TipoRota
- Padrões por módulo
- Mapa de rotas existentes x pathing.service
- Template de INSERT

---

## Processo

### 1. Coletar informações

Perguntar ao usuário (se não forneceu nos argumentos):

1. **Nome do item de menu** — texto exibido no menu
2. **Rota** — URL completa (ex: `/estrutura-pedagogica/folha/novo-envio`). Se for para `estrutura-pedagogica`, consultar `pathing.service.ts` em `c:/projects/estrutura-pedagogica/frontend/src/shared/services/pathing.service.ts` para confirmar a rota correta.
3. **MenuItemPai** — ID do grupo pai. Consultar no banco se não souber:
   ```sql
   SELECT Id, Nome FROM MenuItem WHERE TipoRota = 0 ORDER BY Nome;
   ```
4. **Funcionalidade** — ID da funcionalidade (controla permissão de acesso). Se não souber:
   ```sql
   SELECT Id, Nome FROM Funcionalidade WHERE Nome LIKE '%{termo}%';
   ```
5. **Ordem** — posição dentro do pai. Sugerir o próximo disponível:
   ```sql
   SELECT MAX(Ordem) + 1 FROM MenuItem WHERE MenuItemPai = {MenuItemPai};
   ```
6. **Ícone FontAwesome** — classe do ícone (ex: `fas fa-fw fa-tasks`). Se não souber, sugerir o mesmo do pai ou ícones similares existentes.

### 2. Verificar se a rota já existe

```sql
SELECT Id, Nome, Ativo FROM MenuItem WHERE Rota = '{rota}';
```

Se já existir, informar ao usuário e não gerar insert duplicado.

### 3. Gerar o SQL

Usar o template do arquivo de análise. Padrões fixos:
- `UsuarioInclusao` = `1097334`
- `Hash` = `NEWID()`
- `DataInclusao` = `GETDATE()`
- `Ativo` = `0` (sempre começa inativo)
- `Desktop` = `1`, `Mobile` = `1`
- `Fixo` = `0`
- Para Angular (estrutura-pedagogica, etc.): `ViewModel = NULL`, `RotaKO = NULL`, `TipoRota = 1`
- Para menu pai sem rota: `TipoRota = 0`, `Rota = NULL`, `PrefixoDoModulo = NULL`

### 4. Salvar o script

Salvar o SQL gerado em:
```
c:/projects/salta_brain/_scripts/menu_item_{nome-kebab-case}.sql
```

Incluir comentário no topo do arquivo com:
- Data de geração
- Contexto (card Jira se disponível, ou descrição da feature)

### 5. Apresentar ao usuário

Mostrar:
1. O SQL gerado com campos comentados (igual ao padrão dos exemplos em `scripts_db/_INBOX/`)
2. O caminho do arquivo salvo
3. Lembrete: após executar o INSERT, ativar com:
   ```sql
   UPDATE MenuItem SET Ativo = 1 WHERE Id = SCOPE_IDENTITY();
   -- ou após confirmar o Id gerado:
   UPDATE MenuItem SET Ativo = 1 WHERE Id = {id};
   ```

---

## Notas

- `Funcionalidade` controla quem pode ver o item. Se não souber qual usar, reutilize a mesma funcionalidade de itens similares no mesmo módulo.
- `TipoRede` é `NULL` para itens gerais, `2` para itens de redes específicas (ex: Impulso).
- Sempre verificar o `Ordem` atual antes de definir para não duplicar posições.
- Após o INSERT, a equipe de backend geralmente precisa mapear a `Funcionalidade` para os perfis de acesso necessários em `ModuloAuth.UsuarioAcesso`.
