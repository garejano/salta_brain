# Análise de Permissões — LancamentoFrequencia (EFC-6241)

## Resumo do Fluxo de Autorização

O módulo possui três camadas de permissão em sequência. A falha em qualquer camada bloqueia o acesso.

```
[1] Funcionalidade 101 (módulo)    →  Controller level (RequiredAuthorization)
[2] Escola do usuário               →  ValidacaoService.GetEscolasDoUsuario()
[3] Turmas do usuário               →  FilterRepository.FiltrarPorAlocacao() (só professor)
```

---

## Camada 1 — Acesso ao Módulo (Funcionalidade 101)

**Código:** `RequiredAuthorizationAttribute` → `RequiredAuthorizationFilter.OnAuthorizationAsync()`  
**Classe:** `LancamentoFrequenciaController` (atributo na classe, linha 18)

O filtro valida o Bearer token e consulta `UsuarioAcesso` verificando se o usuário possui `FuncionalidadeId = 101` em **qualquer** escola. Se não encontrar, retorna **403 Forbidden** antes de chegar ao serviço.

**Teste CA-01 / FT-01 / FT-02:**  
- Usuário **com** `UsuarioAcesso(FuncionalidadeId=101, EscolaId=X)` → passa  
- Usuário **sem** nenhum `UsuarioAcesso` com funcionalidade 101 → **403**

---

## Camada 2 — Escolas Autorizadas do Usuário

**Código:** `ValidacaoService.GetEscolasDoUsuario()` (chamada em todo `ValidarRequest`)  
**Repositório:** `UsuarioAcessoRepository.GetEscolaIdByFuncionalidadeUsuarioAutenticado(101)`

Consulta todos os registros `UsuarioAcesso` do usuário com funcionalidade 101 e popula `request.EscolasDoUsuario` com os IDs resultantes.

Todos os `SELECT` do módulo passam por `GetQueryable()` com:
```csharp
.Where(x => request.EscolasDoUsuario.Contains(x.EscolaSerie.EscolaId))
```

Portanto, **mesmo que a requisição informe uma escola**, o dado só é retornado se essa escola estiver na lista de escolas autorizadas do usuário.

**FT-03 — Redes permitidas:**  
`GetRedes()` retorna apenas redes cujas escolas estão em `EscolasDoUsuario`.

**FT-04 — Escolas permitidas:**  
`GetEscolas()` retorna apenas escolas da rede selecionada que estão em `EscolasDoUsuario`.

**FT-11 — Permissão varia por escola:**  
Se o usuário tem `UsuarioAcesso` para Escola A mas não para Escola B, o filtro retorna dados apenas de A.

**FT-13 — Bloqueio por manipulação de request:**  
Mesmo que o frontend/API envie `HashEscola` de uma escola não autorizada, a query de turmas já aplica `EscolasDoUsuario.Contains(...)`, retornando lista vazia (não um erro explícito, mas dado inacessível).

---

## Camada 3 — Visão Coordenação vs. Professor

**Código:** `ValidacaoService.PossuiVisaoCoordenacao()`  
**Verifica:** `UsuarioAcesso(FuncionalidadeId=68, HashEscola=X)` para a escola selecionada

```
Funcionalidade 68 = LancamentoFrequencia_VisaoCoordenacao
```

O resultado é armazenado em `request.PossuiVisaoCoordenacao` (bool) e propagado para todos os repositórios.

### Comportamento por perfil

| Caminho | Funcionalidade 68 presente? | `PossuiVisaoCoordenacao` | Filtra turmas? |
|---|---|---|---|
| Coordenador | Sim | `true` | Não — vê todas |
| Professor | Não | `false` | Sim — só alocadas |

### FiltrarPorAlocacao (professor)

```csharp
// FilterLancamentoFrequenciaRepository, linhas 60-66
.Where(x => x.Professores
  .Any(p => p.Ativo
         && p.PessoaEscolaAcesso.PessoaEscola.Pessoa.Usuario.Id
            == _usuarioAutenticadoRepository.IdUsuarioAutenticado))
```

Percorre: `Turma → ProfessorTurmaDisciplina → PessoaEscolaAcesso → Usuario`

**Aplicado em:**
- `GetSeries()` — linha 121
- `GetTurmas()` — linha 145
- `GetTurmasParaEventos()` — linha 177 (usado no `GetEventosService`)

**FT-05 — Coordenador vê todas as turmas:**  
`PossuiVisaoCoordenacao = true` → `FiltrarPorAlocacao` não é chamado.

**FT-06 — Professor vê apenas turmas alocadas:**  
`PossuiVisaoCoordenacao = false` → `FiltrarPorAlocacao` aplicado em `GetTurmas` e `GetTurmasParaEventos`.

**FT-07 — Professor vê apenas disciplinas vinculadas:**  
O filtro de alocação passa por `ProfessorTurmaDisciplina` (que inclui disciplina), então as disciplinas retornadas já são as do vínculo do professor.

**FT-08 — Restrição independe do tipo de chamada:**  
`PossuiVisaoCoordenacao` é verificado em `ValidacaoService`, que é chamado antes de qualquer repositório. O tipo de chamada da escola não altera essa verificação.

**FT-09 — Coordenador vê todas as séries:**  
`GetSeries()` não chama `FiltrarPorAlocacao` quando `PossuiVisaoCoordenacao = true`.

**FT-10 — Professor vê apenas séries relacionadas:**  
`GetSeries()` aplica `FiltrarPorAlocacao` — retorna só séries das turmas onde o professor está alocado.

---

## FT-12 — Revalidação ao trocar escola

`ValidacaoService.ValidarRequest()` é chamado em **toda requisição**. Não há cache de estado no servidor.  
Cada troca de escola no frontend gera uma nova chamada a `filter-escolas` → `filter-series` → `filter-turmas`, e cada uma recalcula `GetEscolasDoUsuario()` e `PossuiVisaoCoordenacao()` do zero.

---

## Cenários de Teste Sugeridos

### Pré-requisito para todos os testes
Usuário A = coordenador (tem `UsuarioAcesso` com funcionalidade 101 **e** 68 para Escola X)  
Usuário B = professor (tem `UsuarioAcesso` apenas com funcionalidade 101 para Escola X, alocado nas turmas T1 e T2)  
Usuário C = sem permissão (sem `UsuarioAcesso` para funcionalidade 101)

### FT-01 / FT-02 — Acesso ao módulo
- Usuário A ou B: acessa → 200  
- Usuário C: qualquer chamada → **403** (bloqueado no `RequiredAuthorizationFilter`)

### FT-03 / FT-04 — Filtros de rede e escola
- Usuário B com `UsuarioAcesso` apenas para Escola X da Rede R:  
  - `filter-redes` → retorna apenas Rede R  
  - `filter-escolas` → retorna apenas Escola X  

### FT-05 / FT-06 — Turmas
- Usuário A (`filter-turmas`): retorna todas as turmas da Escola X  
- Usuário B (`filter-turmas`): retorna apenas T1 e T2

### FT-07 — Disciplinas
- Usuário B: disciplinas no `get-eventos` limitadas às de T1 e T2 (conforme `ProfessorTurmaDisciplina`)

### FT-11 — Permissão varia por escola
- Usuário B com `UsuarioAcesso` para Escola X mas **não** para Escola Y:  
  - Escola X: retorna turmas  
  - Escola Y: `EscolasDoUsuario` não contém Y → turmas retornam lista vazia

### FT-13 — Manipulação de request
- Usuário B envia `HashEscola = Y` (sem permissão) via Postman/API:  
  - Passa na camada 1 (tem funcionalidade 101)  
  - `GetEscolasDoUsuario()` não inclui Y → `GetQueryable()` retorna vazio  
  - Nenhum dado de Y é exposto

---

## Pontos de Atenção

1. **`get-chamada/{hashAulaEvento}`** não repete o check de escola/turma explicitamente — depende de `ValidacaoChamadaService.ValidarEvento()`. Vale confirmar se esse serviço verifica se o professor tem acesso àquela aula antes de retornar os alunos.

2. **`save-chamada`** idem — `ISaveChamadaService.Save()` precisa revalidar se o usuário pode salvar frequência para aquele evento, não apenas se ele chegou ao endpoint.

3. **FT-13 não gera 403**, retorna lista vazia. Se o comportamento esperado for erro explícito de acesso negado, seria necessário adicionar uma validação em `ValidarRequest` após `GetEscolasDoUsuario`.
