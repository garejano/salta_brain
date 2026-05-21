# Lógica de Usuário / Perfil / Funcionalidade — LancamentoFrequencia

## Como funciona

O sistema usa uma tabela central chamada `UsuarioAcesso` (schema `ModuloAuth`) que liga um usuário a uma funcionalidade em uma escola específica. Não existe "perfil" como entidade separada — o acesso é definido pelas linhas dessa tabela.

```
Usuario  ──►  UsuarioAcesso  ◄──  Funcionalidade
                    │
                    ▼
                  Escola
```

Cada linha de `UsuarioAcesso` representa: **"este usuário tem acesso a esta funcionalidade nesta escola"**.

---

## Funcionalidades relevantes para LancamentoFrequencia

| Id  | Significado                                      |
|-----|--------------------------------------------------|
| 101 | Acesso ao módulo LancamentoFrequencia            |
| 68  | Visão Coordenação (vê todas as turmas da escola) |

**Regra prática:**
- Usuário com **101** → pode acessar o módulo
- Usuário com **101 + 68** → coordenador (vê tudo)
- Usuário com **101** mas **sem 68** → professor (vê só turmas onde está alocado)

---

## Queries

### 1. Ver o que um usuário tem acesso (pelo email)

```sql
SELECT
    u.Id          AS UsuarioId,
    u.Email,
    ua.FuncionalidadeId,
    f.Nome        AS Funcionalidade,
    ua.EscolaId,
    e.Nome        AS Escola,
    r.Nome        AS Rede
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Usuario      u  ON u.Id  = ua.UsuarioId
JOIN dbo.Funcionalidade f ON f.Id = ua.FuncionalidadeId
JOIN dbo.Escola        e  ON e.Id = ua.EscolaId
JOIN dbo.Rede          r  ON r.Id = e.Rede
WHERE u.Email = 'email@dominio.com'
ORDER BY ua.EscolaId, ua.FuncionalidadeId;
```

### 2. Encontrar usuários que têm acesso ao módulo (funcionalidade 101)

```sql
SELECT
    u.Id,
    u.Email,
    e.Nome  AS Escola,
    r.Nome  AS Rede,
    -- Se tem 68 = coordenador, senão = professor
    CASE WHEN EXISTS (
        SELECT 1 FROM ModuloAuth.UsuarioAcesso ua2
        WHERE ua2.UsuarioId       = ua.UsuarioId
          AND ua2.EscolaId        = ua.EscolaId
          AND ua2.FuncionalidadeId = 68
    ) THEN 'Coordenador' ELSE 'Professor' END AS Perfil
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Usuario u  ON u.Id  = ua.UsuarioId
JOIN dbo.Escola  e  ON e.Id  = ua.EscolaId
JOIN dbo.Rede    r  ON r.Id  = e.Rede
WHERE ua.FuncionalidadeId = 101
ORDER BY r.Nome, e.Nome, Perfil;
```

### 3. Confirmar que um professor está alocado em turmas

Liga `UsuarioAcesso` → `Usuario` → `Pessoa` → `PessoaEscola` → `PessoaEscolaAcesso` → `ProfessorTurmaDisciplina` → `Turma`.

```sql
SELECT
    u.Email,
    t.Nome   AS Turma,
    d.Nome   AS Disciplina,
    ptd.NaoPossuiAula
FROM dbo.Usuario u
JOIN dbo.Pessoa                p    ON p.Id              = u.Pessoa
JOIN dbo.PessoaEscola          pe   ON pe.Pessoa          = p.Id
JOIN dbo.PessoaEscolaAcesso    pea  ON pea.PessoaEscola   = pe.Id
JOIN dbo.ProfessorTurmaDisciplina ptd ON ptd.PessoaEscolaAcesso = pea.Id
JOIN dbo.Turma                 t    ON t.Id              = ptd.Turma
JOIN dbo.Disciplina            d    ON d.Id              = ptd.Disciplina
WHERE u.Email = 'email@professor.com'
  AND t.Ativo = 1
ORDER BY t.Nome, d.Nome;
```

### 4. Montar os 3 usuários de teste (A = coordenador, B = professor, C = sem acesso)

```sql
-- Usuário A: tem 101 + 68 para Escola X
SELECT u.Id, u.Email, 'Coordenador (A)' AS Papel
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Usuario u ON u.Id = ua.UsuarioId
WHERE ua.FuncionalidadeId = 101
  AND ua.EscolaId = <EscolaId>
  AND EXISTS (
      SELECT 1 FROM ModuloAuth.UsuarioAcesso
      WHERE UsuarioId        = ua.UsuarioId
        AND EscolaId         = ua.EscolaId
        AND FuncionalidadeId = 68
  );

-- Usuário B: tem 101 mas NÃO tem 68 para Escola X, e está alocado em turmas
SELECT u.Id, u.Email, 'Professor (B)' AS Papel
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Usuario u ON u.Id = ua.UsuarioId
WHERE ua.FuncionalidadeId = 101
  AND ua.EscolaId = <EscolaId>
  AND NOT EXISTS (
      SELECT 1 FROM ModuloAuth.UsuarioAcesso
      WHERE UsuarioId        = ua.UsuarioId
        AND EscolaId         = ua.EscolaId
        AND FuncionalidadeId = 68
  )
  AND EXISTS (
      SELECT 1
      FROM dbo.Pessoa p
      JOIN dbo.PessoaEscola pe  ON pe.Pessoa        = p.Id
      JOIN dbo.PessoaEscolaAcesso pea ON pea.PessoaEscola = pe.Id
      JOIN dbo.ProfessorTurmaDisciplina ptd ON ptd.PessoaEscolaAcesso = pea.Id
      WHERE p.Id = (SELECT Pessoa FROM dbo.Usuario WHERE Id = ua.UsuarioId)
        AND pe.Escola = <EscolaId>
  );

-- Usuário C: não tem nenhum registro com funcionalidade 101
SELECT u.Id, u.Email, 'Sem acesso (C)' AS Papel
FROM dbo.Usuario u
WHERE u.Ativo = 1
  AND NOT EXISTS (
      SELECT 1 FROM ModuloAuth.UsuarioAcesso
      WHERE UsuarioId        = u.Id
        AND FuncionalidadeId = 101
  )
LIMIT 5; -- pegar qualquer um
```

> Substitua `<EscolaId>` pelo Id da escola que vai usar nos testes.

---

## Como descobrir o EscolaId para usar

```sql
-- Listar escolas que têm usuários com funcionalidade 101
SELECT
    e.Id,
    e.Nome  AS Escola,
    r.Nome  AS Rede,
    COUNT(DISTINCT ua.UsuarioId) AS Usuarios
FROM ModuloAuth.UsuarioAcesso ua
JOIN dbo.Escola e ON e.Id = ua.EscolaId
JOIN dbo.Rede   r ON r.Id = e.Rede
WHERE ua.FuncionalidadeId = 101
  AND e.Ativo = 1
GROUP BY e.Id, e.Nome, r.Nome
ORDER BY Usuarios DESC;
```

---

## Resumo das tabelas

| Tabela                              | Schema     | Descrição                                      |
|-------------------------------------|------------|------------------------------------------------|
| `UsuarioAcesso`                     | ModuloAuth | Vínculo usuário ↔ funcionalidade ↔ escola      |
| `Funcionalidade`                    | dbo        | Catálogo de funcionalidades (101, 68, etc.)    |
| `Usuario`                           | dbo        | Login / email do usuário                       |
| `Escola`                            | dbo        | Escolas                                        |
| `Rede`                              | dbo        | Redes de ensino                                |
| `PessoaEscola`                      | dbo        | Vínculo pessoa ↔ escola                        |
| `PessoaEscolaAcesso`                | dbo        | Perfil de acesso da pessoa na escola           |
| `ProfessorTurmaDisciplina`          | dbo        | Alocação professor ↔ turma ↔ disciplina        |
