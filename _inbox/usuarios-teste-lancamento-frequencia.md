# Usuários de Teste — LancamentoFrequencia (EFC-6241)

**Banco:** ElevaPortalHomolog  
**Data de geração:** 2026-05-19  
**Critério de seleção:** 1 usuário por tipo por rede; coordenadores com QtdEscolas ≤ 10 (excluindo admins globais); professores com ProfessorTurmaDisciplina.Ativo = 1 + Turma.Ativo = 1.

---

## Legenda dos perfis

| Tipo | Funcionalidades | Comportamento no módulo |
|------|-----------------|-------------------------|
| **A — Coordenador** | 101 + 68 | Vê todas as turmas da escola |
| **B — Professor** | 101 (sem 68) | Vê apenas turmas onde está alocado |
| **C — Sem acesso** | Outras (ex: 198, 422, 437) mas sem 101 | Loga no portal, recebe 403 no módulo |

> **Observação importante:** Em 33 das 41 redes, TODOS os usuários com funcionalidade 101 também possuem a funcionalidade 68. Nessas redes não existe perfil B — qualquer usuário com acesso ao módulo é tratado como coordenador.

---

## Tipo C — Sem acesso ao módulo (valem para qualquer rede)

Usuários válidos no portal (têm `UsuarioAcesso` com outras funcionalidades) mas **sem a funcionalidade 101**. Logam normalmente e recebem **403** ao acessar qualquer endpoint do LancamentoFrequencia.

| UsuarioId | Nome | Email | Escola | Funcionalidades que possui |
|-----------|------|-------|--------|---------------------------|
| 2782106 | MARLOREM IPSUM DOLOR SO | maari.salees@gmail.com | Opção Mauá - EI/EF1 (Elite SP) | 198, 422, 437 |

---

## Tipo A — Coordenador (1 por rede)

| Rede | EscolaId | Escola | UsuarioId | Nome | Email |
|------|----------|--------|-----------|------|-------|
| Ábaco | 2343 | São Bernardo do Campo 2 | 2717678 | DANLOREM IPSUM DOLOR SIT AMET CA | daniela.beatriz@colegioabaco.com.br |
| Alfa | 467 | Ponta Grossa 2 | 2780628 | PAMLOREM IPSUM DOLOR SIS | pamela.padilha@alfaonline.com.br |
| Anglo Alante GO | 2360 | Ápice - EF | 2623320 | BRULOREM IPSUM DOLOR SIT AMETA | bruna.francelin@angloalante.com.br |
| Anglo Alante SP | 2245 | São José dos Campos | 2423879 | ALELOREM IPSUM DOLOR SIT O | alexandre.castro@angloalante.com.br |
| Antares | 2413 | Seis Bocas | 2780719 | YEHLOREM IPSUM DOLOR SIT AMS | yehoshua.shivaya@colegioantares.com.br |
| CBV | 1607 | Boa Viagem | 2763672 | MATEUS HENRIQUE SILVA DE SOUSA | mateushenrique.silva@colegiocbv.com.br |
| CEI | 736 | Zona Sul | 2413616 | GABLOREM IPSUM DOLORA | gabrielalves.barbosa@estudecei.com.br |
| CIE | 2121 | Rondonópolis | 1669519 | FERLOREM IPSUM DOLOR SIT AMET CO | fernanda.valerio@cieducando.com.br |
| Colégio do Salvador | 2194 | Aracaju | 2425989 | IRILOREM IPSUM DOLOA | iris.silva@colegiodosalvador.com.br |
| Coleguium MG | 100 | Santa Amélia | 2506385 | ANALOREM IPSUM DOLOR SIT AMET CONO | ana.ramalho@coleguium.com.br |
| Coleguium PA | 1063 | Internacional Carajás | 2330022 | MICLOREM IPSUM DOLOR SIT AMET CONSA | micheline.costa@coleguium.com.br |
| ECSA | 2207 | Cuiabá | 2416366 | JESLOREM IPSUM DOLOR SIT AI | jessica.ferri@ecsacuiaba.com.br |
| Elite DF | 772 | Guará | 2430048 | MELLOREM IPSUM DOLOR R | melissa.deuner@ensinoelite.com.br |
| Elite ES | 2331 | Contec Vila Velha | 2407408 | Josane Lima dos Santos | josane.santos@ensinoelite.com.br |
| Elite GO | 1340 | Goiânia - EI | 2430044 | ALILOREM IPSUM DOLO | aline.sacramento@ensinoelite.com.br |
| Elite MG | 1018 | Floresta | 2763505 | CAMLOREM IPSUM DOLOR SIT AMET COS | camila.rabech@ensinoelite.com.br |
| Elite MS | 518 | Mace Campo Grande | 2780781 | ISALOREM IPSUM DOLOR SS | isabela.sales@ensinoelite.com.br |
| Elite PE | 2409 | Dourado | 2720019 | ROBLOREM IPSUM DOLOR SIT N | roberta.lion@ensinoelite.com.br |
| Elite PR | 765 | SJP - Centro | 2358628 | LARLOREM IPSUM DOLOR SIT AMET CONSECO | larissa.graziele@ensinoelite.com.br |
| Elite RJ | 22 | Madureira 2 | 2726788 | BRULOREM IPSUM DOLOR SIT AMET O | bruna.sersosimo@ensinoelite.com.br |
| Elite SC | 1061 | CEB São José - EI | 2753800 | RENLOREM IPSUM DOLOR SIT AMEZ | renata.queiroz@ensinoelite.com.br |
| Elite SP | 2225 | Piracicaba | 2717742 | PATLOREM IPSUM DOLOR SIT AMET CONSECTETURI | patricia.cavaggioni@ensinoelite.com.br |
| Embraer | 2131 | SJC | 1672489 | PAULOREM IPSUM DOLOR SIT AMET A | paulo.ferreira@colegiopitagoras.com.br |
| Ideal | 1032 | Taguatinga 31 | 2051600 | CRILOREM IPSUM DOLOR SIT AO | cristiane.rodrigues@idealbsb.com.br |
| Integrado | 2205 | Jaó | 2006447 | GABRIEL RODRIGUES DO NASCIMENTO | nascimento.gabriel@integrado-go.com.br |
| ISO | 1888 | Zona Sul | 2441761 | JOCLOREM IPSUM DOLOR SIT AMET CONSECTETUR AA | jocielle.batista@isocolegioecursos.com.br |
| Lato Sensu AC | 2204 | Rio Branco | 2737635 | THALOREM IPSUM DOLOO | thaina.brandao@colegiolatosensu.com.br |
| Lato Sensu AM | 2199 | Adrianópolis | 2714591 | SUZLOREM IPSUM DOLOR SIT A | suzi.danielle@colegiolatosensu.com.br |
| Lato Sensu PA | 2426 | Lato Sensu Belém | 2735478 | MARLOREM IPSUM DOLOR S | maria.maues@colegiolatosensu.com.br |
| Master | 1043 | Alvorada | 2714587 | JANLOREM IPSUM DOLORA | jane.vieira@colegiomaster.com.br |
| Maxi | 2193 | Cuiabá | 1990579 | ROSLOREM IPSUM DOA | rosangela.dasilva@maxicuiaba.com.br |
| Máxima | 2424 | Campo Grande | 2436286 | CRISTIANE SARTORELLI E SILVA JUSTINO | cristiane.sartorelli@escolamaxima.com.br |
| Motivo | 2195 | Boa Viagem | 2766612 | ANALOREM IPSUM DOLOR SIT AMET CONSEA | anamaria.albuquerque@colegiomotivo.com.br |
| Nosso CEI | 2208 | Romualdo Galvão | 2748540 | AMALOREM IPSUM DOLOR SIT AMETA | amandacamila.silva@ceinet.com.br |
| Nota 10 | 767 | Internacional Máxima | 2436286 | CRISTIANE SARTORELLI E SILVA JUSTINO | cristiane.sartorelli@escolamaxima.com.br |
| Pensi | 12 | Tijuca 1 | 2778531 | FABLOREM IPSUM DOLOS | fabiana.bento@pensi.com.br |
| pH | 2141 | Icaraí 3 | 2703513 | ELALOREM IPSUM DOLOR SIT AMET CM | elayne.teixeira@ph.com.br |
| Pitágoras | 2124 | Barcarena | 2342031 | MILLOREM IPSUM DOLOR SIT AMEO | milena.maria@colegiopitagoras.com.br |
| Santi | 2123 | Paraíso | 2486795 | LUCLOREM IPSUM DOLOR SIA | lucilene.rosa@escolasanti.com.br |
| Sigma | 2191 | 910 Norte | 2742911 | ANDLOREM IPSUM DOLOR SS | andreagomes.santos@sigmadf.com.br |
| Upaon-Açu | 2355 | São Luís - EF1 Manhã | 2296824 | Andre Fernandes dos Santos | andre.fdossantos@upaon.com.br |

---

## Tipo B — Professor (redes onde o perfil existe)

Apenas 8 redes possuem usuários com funcionalidade 101 **sem** funcionalidade 68. Nas demais 33 redes, todos têm as duas funcionalidades (tratar como coordenador).

| Rede | EscolaId | Escola | UsuarioId | Nome | Email |
|------|----------|--------|-----------|------|-------|
| Ábaco | 2342 | Ipiranga | 2780622 | VITORIA PERRONE LIMA DE BRITO | vitoria.perrone@colegioabaco.com.br |
| Anglo Alante GO | 2360 | Ápice - EF | 2775361 | TIAGO DOS SANTOS BATISTA | tiago.batista@angloalante.com.br |
| Anglo Alante SP | 2403 | Guarulhos Guilherme de Almeida | 2779459 | ANA BEATRIZ DE BARROS PONTES | anabeatriz.pontes@angloalante.com.br |
| Colégio do Salvador | 2194 | Aracaju | 2779375 | ROBERTA EMANUELLE VIEIRA SANTOS | roberta.emanuelle@colegiodosalvador.com.br |
| Elite PR | 744 | Umuarama | 2775469 | MARCO AURELIO CORDEIRO STRAIOTTO COELHO | marco.straiotto@ensinoelite.com.br |
| Motivo | 2195 | Boa Viagem | 2771464 | ARDALE MARIA ANDRADE MARTINS MOURA | ardale.martins@colegiomotivo.com.br |
| Nosso CEI | 2208 | Romualdo Galvão | 2766656 | MATHEUS DANTAS DE LUCENA | matheus.lucena@ceinet.com.br |
| Santi | 2123 | Paraíso | 2778911 | Rafael Henrique Colavite de Aguiar | rafael.mindkids@parceiro.escolasanti.com.br |

---

## Cenário FT-12 — Permissão varia ao trocar de escola (mesmo usuário)

Usuário que é **coordenador em Escola A** e **professor com turmas restritas em Escola B** — mesma rede.

### Usuário recomendado — mínimo de série/disciplinas

| Campo | Escola A (visão ampla) | Escola B (visão restrita) |
|-------|------------------------|---------------------------|
| **Rede** | Nosso CEI | Nosso CEI |
| **EscolaId** | 2208 | 2209 |
| **Escola** | Romualdo Galvão | Roberto Freire |
| **Funcionalidades** | 101 + 68 (coordenador) | 101 sem 68 (professora) |
| **Comportamento esperado** | Vê todas as turmas | Vê apenas 1 turma alocada |

**Usuário:** Isadora Cristina Ricardo Pires — `isadorapires@ceinet.com.br` (UsuarioId: 1615897)

**Turmas visíveis em Escola B** (Roberto Freire — AnoLetivo 2026):

| TurmaId | Turma | Série | Disciplinas |
|---------|-------|-------|-------------|
| 276339 | 2º ano B - M | 2º Ano Regular | Pensamento Computacional 2, Regente2 |

> Cenário ideal para o teste: ao selecionar Escola A o professor vê tudo; ao trocar para Escola B vê **apenas esta turma** com **2 disciplinas**.

---

### Alternativa — mais turmas para testar restrição mais ampla

| Campo | Escola A | Escola B |
|-------|----------|----------|
| **Rede** | Ábaco | Ábaco |
| **EscolaId** | 2342 (Ipiranga) | 2343 (São Bernardo do Campo 2) |
| **Funcionalidades** | 101 + 68 | 101 sem 68 |

**Usuário:** Davidson Gogora de Paulo — `davidson.gogora@colegioabaco.com.br` (UsuarioId: 2201456)  
**Escola B:** 13 turmas (1ª série A–G e 2ª série A–F), disciplinas Programação 1-I e Programação 2-I.

---

## Redes sem perfil B (todos têm func 101 + 68)

Alfa, Antares, CBV, CEI, CIE, Coleguium MG, Coleguium PA, ECSA, Elite DF, Elite ES, Elite GO, Elite MG, Elite MS, Elite PE, Elite RJ, Elite SC, Elite SP, Embraer, Ideal, Integrado, ISO, Lato Sensu AC, Lato Sensu AM, Lato Sensu PA, Master, Maxi, Máxima, Nota 10, Pensi, pH, Pitágoras, Sigma, Upaon-Açu

---

## Queries utilizadas

### Escolher 1 escola representativa por rede

```sql
WITH EscolaPorRede AS (
    SELECT r.Id AS RedeId, r.Nome AS Rede,
           e.Id AS EscolaId, e.Nome AS Escola,
           COUNT(DISTINCT ua.UsuarioId) AS Total,
           ROW_NUMBER() OVER (PARTITION BY r.Id ORDER BY COUNT(DISTINCT ua.UsuarioId) DESC) AS rn
    FROM ModuloAuth.UsuarioAcesso ua
    JOIN dbo.Escola e ON e.Id = ua.EscolaId
    JOIN dbo.Rede   r ON r.Id = e.Rede
    WHERE ua.FuncionalidadeId = 101 AND e.Ativo = 1 AND r.Ativo = 1
    GROUP BY r.Id, r.Nome, e.Id, e.Nome
)
SELECT * FROM EscolaPorRede WHERE rn = 1;
```

### Usuário A — Coordenador por rede

```sql
WITH EscolaPorRede AS (
    SELECT r.Id AS RedeId, r.Nome AS Rede,
           e.Id AS EscolaId, e.Nome AS Escola,
           ROW_NUMBER() OVER (PARTITION BY r.Id ORDER BY COUNT(DISTINCT ua.UsuarioId) DESC) AS rn
    FROM ModuloAuth.UsuarioAcesso ua
    JOIN dbo.Escola e ON e.Id = ua.EscolaId
    JOIN dbo.Rede   r ON r.Id = e.Rede
    WHERE ua.FuncionalidadeId = 101 AND e.Ativo = 1 AND r.Ativo = 1
    GROUP BY r.Id, r.Nome, e.Id, e.Nome
),
EscolaRep AS (SELECT RedeId, Rede, EscolaId, Escola FROM EscolaPorRede WHERE rn = 1),
EscolasPorUsuario AS (
    SELECT UsuarioId, COUNT(DISTINCT EscolaId) AS QtdEscolas
    FROM ModuloAuth.UsuarioAcesso WHERE FuncionalidadeId = 101
    GROUP BY UsuarioId
),
UsuarioA AS (
    SELECT er.RedeId, er.Rede, er.EscolaId, er.Escola,
           u.Id AS UsuarioId, p.Nome, u.Email,
           ROW_NUMBER() OVER (PARTITION BY er.RedeId ORDER BY epu.QtdEscolas ASC, u.Id DESC) AS rn
    FROM EscolaRep er
    JOIN ModuloAuth.UsuarioAcesso ua1 ON ua1.EscolaId = er.EscolaId AND ua1.FuncionalidadeId = 101
    JOIN ModuloAuth.UsuarioAcesso ua2 ON ua2.EscolaId = er.EscolaId AND ua2.FuncionalidadeId = 68
                                      AND ua2.UsuarioId = ua1.UsuarioId
    JOIN dbo.Usuario u ON u.Id = ua1.UsuarioId
    JOIN dbo.Pessoa  p ON p.Id = u.Pessoa
    JOIN EscolasPorUsuario epu ON epu.UsuarioId = u.Id
    WHERE u.Email IS NOT NULL AND u.Ativo = 1
      AND u.Email NOT LIKE '%@gruposaltaedu.com'
      AND u.Email NOT LIKE '%@escolaeleva.com.br'
      AND epu.QtdEscolas <= 10
)
SELECT RedeId, Rede, EscolaId, Escola, UsuarioId, Nome, Email
FROM UsuarioA WHERE rn = 1 ORDER BY Rede;
```

### Usuário B — Professor por rede (somente redes onde o perfil existe)

```sql
-- Professor = func 101 sem func 68, com ProfessorTurmaDisciplina ativo em turma ativa
WITH EscolasPorUsuario AS ( ... ),
UsuarioB AS (
    SELECT r.Id AS RedeId, r.Nome AS Rede,
           ua1.EscolaId, e.Nome AS Escola,
           u.Id AS UsuarioId, p.Nome, u.Email,
           ROW_NUMBER() OVER (PARTITION BY r.Id ORDER BY epu.QtdEscolas ASC, u.Id DESC) AS rn
    FROM ModuloAuth.UsuarioAcesso ua1
    JOIN dbo.Escola e ON e.Id = ua1.EscolaId AND e.Ativo = 1
    JOIN dbo.Rede   r ON r.Id = e.Rede AND r.Ativo = 1
    JOIN dbo.Usuario u ON u.Id = ua1.UsuarioId
    JOIN dbo.Pessoa  p ON p.Id = u.Pessoa
    JOIN EscolasPorUsuario epu ON epu.UsuarioId = u.Id
    JOIN dbo.PessoaEscola pe ON pe.Pessoa = u.Pessoa AND pe.Ativo = 1
    JOIN dbo.PessoaEscolaAcesso pea ON pea.PessoaEscola = pe.Id AND pea.Ativo = 1
    JOIN dbo.ProfessorTurmaDisciplina ptd ON ptd.PessoaEscolaAcesso = pea.Id AND ptd.Ativo = 1
    JOIN dbo.Turma t ON t.Id = ptd.Turma AND t.Ativo = 1
    WHERE ua1.FuncionalidadeId = 101
      AND u.Email IS NOT NULL AND u.Ativo = 1
      AND u.Email NOT LIKE '%@gruposaltaedu.com'
      AND u.Email NOT LIKE '%@escolaeleva.com.br'
      AND epu.QtdEscolas <= 5
      AND NOT EXISTS (
          SELECT 1 FROM ModuloAuth.UsuarioAcesso ua2
          WHERE ua2.UsuarioId = ua1.UsuarioId
            AND ua2.EscolaId  = ua1.EscolaId
            AND ua2.FuncionalidadeId = 68
      )
)
SELECT RedeId, Rede, EscolaId, Escola, UsuarioId, Nome, Email
FROM UsuarioB WHERE rn = 1 ORDER BY Rede;
```

### Usuário C — Sem acesso ao módulo

```sql
SELECT TOP 5 u.Id, p.Nome, u.Email
FROM dbo.Usuario u
JOIN dbo.Pessoa p ON p.Id = u.Pessoa
WHERE u.Email IS NOT NULL AND u.Ativo = 1
  AND NOT EXISTS (
      SELECT 1 FROM ModuloAuth.UsuarioAcesso ua
      WHERE ua.UsuarioId = u.Id AND ua.FuncionalidadeId = 101
  )
ORDER BY u.Id;
```

### Diagnóstico — quantos B existem por rede

```sql
SELECT r.Id, r.Nome AS Rede,
       COUNT(DISTINCT ua1.UsuarioId) AS TotalFunc101,
       COUNT(DISTINCT CASE WHEN ua2.UsuarioId IS NULL THEN ua1.UsuarioId END) AS SemFunc68
FROM ModuloAuth.UsuarioAcesso ua1
JOIN dbo.Escola e ON e.Id = ua1.EscolaId AND e.Ativo = 1
JOIN dbo.Rede   r ON r.Id = e.Rede AND r.Ativo = 1
LEFT JOIN ModuloAuth.UsuarioAcesso ua2 ON ua2.UsuarioId = ua1.UsuarioId
  AND ua2.EscolaId = ua1.EscolaId AND ua2.FuncionalidadeId = 68
WHERE ua1.FuncionalidadeId = 101
GROUP BY r.Id, r.Nome
ORDER BY SemFunc68 DESC;
```
