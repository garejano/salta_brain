# EFC-6292 — Plano de Testes: FichaIndividualGetService

> Testes unitários para `FichaIndividualGetService` em `EstruturaPedagogica.Test`.  
> Padrão: xUnit + Moq + Bogus. Herança de `BaseTest`. Nomenclatura em português.

---

## Arquivos a Criar

```
EstruturaPedagogica.Test/
├── Unit/
│   └── Services/
│       └── FichaIndividualGetServiceTests.cs          ✅ criado
└── Integration/
    └── Fixtures/
        ├── DTO/
        │   ├── FichaIndividualGetRequestFixture.cs     ✅ criado
        │   └── FichaIndividualInternalGetResponseFixture.cs  ✅ criado
        └── Entities/
            ├── CicloFixture.cs                        ✅ criado
            └── RedeSerieCicloFixture.cs                ✅ criado
```

> `.csproj` atualizado com `<Compile Include>` para as duas fixtures de DTO.

---

## Fixtures

### `FichaIndividualGetRequestFixture`

```csharp
public static FichaIndividualGetRequest Gerar(
    Guid? hashUsuario = null,
    Guid? hashTurma = null,
    bool retornarResultadosParciais = true)
```

### `FichaIndividualInternalGetResponseFixture`

```csharp
// Gera um item de ficha — os booleans de escopo controlam em qual "bucket" cai
public static FichaIndividualInternalGetResponse Gerar(
    Guid? hashDisciplina = null,
    string nomeDisciplina = null,
    Guid? hashEtapa = null,
    string nomeEtapa = null,
    Guid? hashEstruturaAvaliacao = null,
    int tipoResultadoId = TipoResultado.Nota,
    decimal? notaComPeso = null,
    string notaFormativa = null,
    string situacao = null,
    int? faltas = null,
    bool ehRegular = true,
    bool ehDiversificado = false,
    bool ehItinerarioFormativo = false,
    bool ehDependencia = false,
    bool ehResultadoEtapa = false,
    int cicloId = 1)

// Gera lista homogênea — mesmo hashEtapa e hashEstruturaAvaliacao para simular disciplinas na mesma coluna
public static List<FichaIndividualInternalGetResponse> GerarLista(int quantidade = 3, ...)
```

### `CicloFixture`

```csharp
public static Ciclo Gerar(
    int? id = null,
    int etapaId = 1,
    bool totalEtapa = false,
    bool totalEtapaRecuperada = false,
    bool mediaEtapa = false,
    bool mediaEtapaRecuperada = false,
    Etapa etapa = null)
```

### `RedeSerieCicloFixture`

```csharp
public static RedeSerieCiclo Gerar(
    int? id = null,
    int cicloId = 1,
    Ciclo ciclo = null,   // ciclo.Etapa.Hash é usado para filtrar etapas parciais
    DateTime? dataFechamento = null,  // > DateTime.Now = parcial
    bool ativo = true)
```

---

## Testes: `FichaIndividualGetServiceTests`

### Setup do construtor

```csharp
// Mocks:
Mock<IRelatorioAlunoNotaRepository> _mockRelatorio
Mock<IAlunoEscolaRepository>        _mockAlunoEscola
Mock<ICicloRepository>              _mockCiclo
Mock<IRedeSerieCicloRepository>     _mockRedeSerieCiclo

// DI:
AddGlobalization()
serviceCollection.AddScoped(_ => _mockRelatorio.Object)
serviceCollection.AddScoped(_ => _mockAlunoEscola.Object)
serviceCollection.AddScoped(_ => _mockCiclo.Object)
serviceCollection.AddScoped(_ => _mockRedeSerieCiclo.Object)
serviceCollection.AddTransient<IFichaIndividualGetService, FichaIndividualGetService>()
AddServiceProvider()
```

---

### Grupo 1 — Validação de entrada (`GetModeloCompleto` e `GetModeloResumido`) ✅ IMPLEMENTADO

| # | Nome do Teste | Status |
|---|---------------|--------|
| 1 | `GetModeloCompleto_Deve_Retornar_Erro_Quando_Request_Eh_Nulo` | ✅ |
| 2 | `GetModeloCompleto_Deve_Retornar_Erro_Quando_HashTurma_Eh_Default` | ✅ |
| 3 | `GetModeloCompleto_Deve_Retornar_Erro_Quando_HashUsuario_Eh_Default` | ✅ |
| 4 | `GetModeloCompleto_Deve_Retornar_Erro_Quando_AlunoEscola_Nao_Encontrado` | ✅ |
| 5 | `GetModeloCompleto_Deve_Retornar_Erro_Quando_FichaIndividual_Vazia` | ✅ |
| 6 | `GetModeloResumido_Deve_Retornar_Erro_Quando_Request_Eh_Nulo` | ✅ |
| 7 | `GetModeloResumido_Deve_Retornar_Erro_Quando_AlunoEscola_Nao_Encontrado` | ✅ |
| 8 | `GetModeloResumido_Deve_Retornar_Erro_Quando_Ciclos_Vazios` | ✅ |
| 9 | `GetModeloResumido_Deve_Retornar_Erro_Quando_FichaIndividual_Vazia` | ✅ |

---

### Grupo 2 — Formatação da ficha (`GetModeloCompleto` — caminho feliz) ✅ IMPLEMENTADO

| # | Nome do Teste | Status |
|---|---------------|--------|
| 10 | `GetModeloCompleto_Deve_Retornar_Ficha_Com_EscopoRegular` | ✅ |
| 11 | `GetModeloCompleto_Deve_Separar_Escopos_Por_Tipo` | ✅ |
| 12 | `GetModeloCompleto_Deve_Preencher_Legenda_Quando_EscopoRegular_Tem_Etapas` | ✅ |
| 13 | `GetModeloCompleto_Nao_Deve_Preencher_Legenda_Quando_EscopoRegular_Vazio` | ✅ |
| 14 | `GetModeloCompleto_Deve_Calcular_Nota_Por_TipoResultado_Nota` | ✅ |
| 15 | `GetModeloCompleto_Deve_Retornar_Situacao_Por_TipoResultado_Situacao` | ✅ |
| 16 | `GetModeloCompleto_Deve_Retornar_Formativa_Por_TipoResultado_Formativa` | ✅ |
| 17 | `GetModeloCompleto_Deve_Retornar_Faltas_Por_TipoResultado_Faltas` | ✅ |
| 18 | `GetModeloCompleto_Deve_Marcar_EhSituacao_Quando_TipoResultado_Situacao` | ✅ |
| 19 | `GetModeloCompleto_Deve_Marcar_EhResultado_Quando_EhResultadoEtapa` | ✅ |

---

### Grupo 3 — Resultados parciais (`GetModeloCompleto`) ✅ IMPLEMENTADO

| # | Nome do Teste | Cenário | Setup | Assert |
|---|---------------|---------|-------|--------|
| 20 | `GetModeloCompleto_Deve_Remover_Notas_Das_Etapas_Com_Fechamento_Futuro_Quando_RetornarResultadosParciais_False` | `RetornarResultadosParciais=false`, etapa com `DataFechamento > Now` e `AnoLetivoId >= Now.Year` | RedeSerieCiclo com fechamento futuro no hash da etapa presente na ficha | Nota da etapa parcial = `""` |
| 21 | `GetModeloCompleto_Nao_Deve_Remover_Notas_Quando_RetornarResultadosParciais_True` | `RetornarResultadosParciais=true` | Não chama `GetParaFichaIndividual` do RedeSerieCiclo | notas mantidas; `_mockRedeSerieCiclo.Verify(x => x.GetParaFichaIndividual(...), Times.Never)` |
| 22 | `GetModeloCompleto_Nao_Deve_Remover_Notas_Quando_Todas_Etapas_Com_Fechamento_Passado` | `RetornarResultadosParciais=false`, `DataFechamento < Now` | Sem etapas parciais | notas mantidas |

---

### Grupo 4 — Ficha resumida (`GetModeloResumido`) ✅ IMPLEMENTADO

| # | Nome do Teste | Cenário | Setup | Assert |
|---|---------------|---------|-------|--------|
| 23 | `GetModeloResumido_Deve_Retornar_Ficha_Resumida_Com_Sucesso` | Ciclos ok, relatorio com dados | ciclos = [1 ciclo], 2 itens na ficha | `IsSuccess`, `EscopoRegular` preenchido |
| 24 | `GetModeloResumido_Deve_Substituir_Nota_Por_Asterisco_Para_Ciclos_Com_Total_Ou_Media` | Ciclo com `TotalEtapa=true` | `HashEstruturaAvaliacao` do item bate com o ciclo total | `Notas[x].Descricao == "*"` |
| 25 | `GetModeloResumido_Nao_Deve_Substituir_Nota_Para_Ciclos_Sem_Total_E_Media` | Ciclo sem flags de total/media | Ciclo sem `TotalEtapa`, `MediaEtapa` etc. | nota original mantida |
| 26 | `GetModeloResumido_Deve_Remover_Notas_Parciais_Quando_RetornarResultadosParciais_False` | `RetornarResultadosParciais=false`, etapa parcial presente | RedeSerieCiclo com fechamento futuro | nota = `""` |

---

### Grupo 5 — Método público estático `RemoverNotasParciaisEscopo` ✅ IMPLEMENTADO

> Este método é `public static` — pode ser testado diretamente sem instanciar o service.

| # | Nome do Teste | Cenário | Assert |
|---|---------------|---------|--------|
| 27 | `RemoverNotasParciaisEscopo_Deve_Limpar_Descricao_Quando_HashEtapa_Esta_Na_Lista` | Escopo com 1 disciplina, 2 notas — uma com hash na lista de parciais | nota da etapa parcial = `""`, outra mantida |
| 28 | `RemoverNotasParciaisEscopo_Nao_Deve_Alterar_Notas_De_Etapas_Nao_Parciais` | Nenhuma nota com hash na lista | todas as notas mantidas intactas |

---

## Cobertura Total: 28 testes

| Grupo | Qtd |
|-------|-----|
| Validação de entrada | 9 |
| Formatação da ficha | 10 |
| Resultados parciais | 3 |
| Ficha resumida | 4 |
| `RemoverNotasParciaisEscopo` (static) | 2 |

---

## Observações de Implementação

- **Fixtures de `FichaIndividualInternalGetResponse`** devem ter o campo `EhRegular` calculado de forma consistente: `EhRegular = !EhDependencia && !EhDiversificado && !EhItinerarioFormativo`
- **Testes de `RemoverNotasParciais`** precisam de `Ciclo.Etapa.Hash` preenchido no `RedeSerieCiclo` para o filtro funcionar — usar `CicloFixture.Gerar(etapa: EtapaFixture.Gerar(hash: hashEtapaEsperada))`
- **Testes de Nota tipo `Nota`**: o service soma todos os `NotaComPeso` do mesmo `HashEstruturaAvaliacao` — gerar pelo menos 2 itens com o mesmo hash para testar a soma
- **Testes de Legenda**: o service filtra por `!EhDiversificado && !EhItinerarioFormativo && LegendaTipoAvaliacao.Contains(" - ")` — garantir esse formato na fixture
