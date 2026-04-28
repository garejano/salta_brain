### Descrição JIRA

A tela PED de alocação de professores e monitores exibe apenas a alocação atual (foto do momento), sem informar desde quando aquele professor/monitor está alocado. Isso causa divergências na Pesquisa de Opinião dos Alunos (POA): a POA usa uma **data de corte** para definir qual professor estava presente na época da avaliação, mas o usuário vê o professor atual e reporta inconsistência.

**Exemplo:** sistema mostra Gisele, mas na época da avaliação era Marina.

Hoje a única forma de entender o histórico é consultar diretamente a base de dados ou gerar planilhas manualmente. A informação existe na base — só não está exposta.

---

### Detalhes Técnicos

- Rota: `https://homolog.atlasedu.dev/ped/#AlocacaoProfessores`
- View frontend: `Eleva.Portal.Web\app\views\AlocacaoProfessores\Listagem.html`

---

### Análise

#### Onde está a data de início da alocação

**`ProfessorTurmaDisciplina`** (professores):

| Coluna | Tipo | Nullable | Observação |
|---|---|---|---|
| `DataInclusao` | datetime | NOT NULL | Criação do registro = **início da alocação** |
| `UsuarioInclusao` | int | NOT NULL | FK para `Pessoa.Id` — quem alocou |
| `DataEntrada` | datetime | NULL | Existe na tabela mas **nunca foi preenchida** (0 registros com valor) |
| `DataSaida` | datetime | NULL | Fim da alocação |
| `DataInativacao` | datetime | NULL | Quando o registro foi desativado |

> `DataEntrada` não pode ser usada — está vazia em 100% dos registros. O campo de facto que representa o início é `DataInclusao`.

**`MonitorTurmaDisciplina`** (monitores — redes de excelência):

| Coluna | Tipo | Nullable |
|---|---|---|
| `DataInclusao` | datetime | NOT NULL |
| `UsuarioInclusao` | int | NOT NULL |

#### Por que a informação não aparece no exportador hoje

A view SQL `ViewAlocacaoProfessoresMonitorTurma` faz um `UNION` entre as duas tabelas para montar o snapshot atual de alocações, mas não seleciona nenhuma coluna de data ou usuário. Consequentemente, a classe de domínio `ViewAlocacaoProfessoresMonitorTurma.cs` e o adaptador `AlocacaoProfessores_CsvAdapter.cs` não conhecem esses campos.

#### Relação com a POA

Com `DataInclusao` no exportador, o analista consegue cruzar essa data com a data de corte da POA e identificar qual professor estava alocado na época da avaliação — sem precisar consultar a base.

---

### Solução Proposta

**Escopo combinado:** adicionar ao exportador CSV duas novas colunas — `DataInclusao` e o nome do usuário que fez a inclusão (`UsuarioInclusao`) — vindas de `ProfessorTurmaDisciplina` / `MonitorTurmaDisciplina`.

**Sem alterações na tela** — somente no arquivo exportado.

#### Regras das novas colunas

| Situação | Data de Início da Alocação | Incluído por |
|---|---|---|
| Professor/Monitor alocado | `DataInclusao` no formato `dd/MM/yyyy` | Nome da pessoa |
| "Não possui aula" (`NaoPossuiAula = true`) | em branco | em branco |
| "Não informado" (`IdPessoaEscolaAcesso = 0`) | em branco | em branco |

---

### Plano de Implementação

#### 1. Executar script SQL — alterar a view `ViewAlocacaoProfessoresMonitorTurma`

Script salvo em `EFC-6196/alter_view_ViewAlocacaoProfessoresMonitorTurma.sql` — **executar diretamente no banco antes de publicar o código**.

O script adiciona `DataInclusao` e `UsuarioInclusao` na CTE `ProfessoresOuMonitores` (nos dois branches do `UNION`), projeta `DataInclusao` e `NomeUsuarioInclusao` no `SELECT` principal, e inclui um `LEFT JOIN Pessoa AS PeUsuario` para resolver o nome do responsável pela alocação.

#### 2. Classe de domínio — `ViewAlocacaoProfessoresMonitorTurma.cs`

Arquivo: `Eleva.Portal/EstruturaEscolar/ViewAlocacaoProfessoresMonitorTurma.cs`

Adicionar após `public virtual bool Monitor { get; set; }`:

```csharp
public virtual DateTime? DataInclusao { get; set; }
public virtual string NomeUsuarioInclusao { get; set; }
```

#### 3. Mapeamento NHibernate — `ViewAlocacaoProfessoresMonitorTurmaMap.cs`

Arquivo: `Eleva.Portal/EstruturaEscolar/NHMapping/ViewAlocacaoProfessoresMonitorTurmaMap.cs`

Adicionar após `Property(d => d.Monitor, ...)`:

```csharp
Property(d => d.DataInclusao,        n => n.NotNullable(false));
Property(d => d.NomeUsuarioInclusao, n => n.NotNullable(false));
```

#### 4. Adaptador CSV — `AlocacaoProfessores_CsvAdapter.cs`

Arquivo: `Eleva.Portal.Web/Adapters/AlocacaoProfessores_CsvAdapter.cs`

No cabeçalho, após a coluna de Perfil/Professor:

```csharp
cabecalhoDoCsv.AdicionarCelula("Data de Início da Alocação");
cabecalhoDoCsv.AdicionarCelula("Incluído por");
```

No loop de linhas, após a lógica do `nomeProfessor`:

```csharp
if (linha.NaoPossuiAula || linha.IdPessoaEscolaAcesso == 0)
{
    linhaDoCsv.AdicionarCelula("");
    linhaDoCsv.AdicionarCelula("");
}
else
{
    linhaDoCsv.AdicionarCelula(linha.DataInclusao?.ToString("dd/MM/yyyy") ?? "");
    linhaDoCsv.AdicionarCelula(linha.NomeUsuarioInclusao ?? "");
}
```

---

### Arquivos a Modificar

| Arquivo | Alteração |
|---|---|
| `EFC-6196/alter_view_ViewAlocacaoProfessoresMonitorTurma.sql` | Executar no banco — `CREATE OR ALTER VIEW ViewAlocacaoProfessoresMonitorTurma` com `DataInclusao` e `NomeUsuarioInclusao` |
| `Eleva.Portal/EstruturaEscolar/ViewAlocacaoProfessoresMonitorTurma.cs` | +2 propriedades |
| `Eleva.Portal/EstruturaEscolar/NHMapping/ViewAlocacaoProfessoresMonitorTurmaMap.cs` | +2 mapeamentos |
| `Eleva.Portal.Web/Adapters/AlocacaoProfessores_CsvAdapter.cs` | +2 colunas no cabeçalho e valores no loop |
