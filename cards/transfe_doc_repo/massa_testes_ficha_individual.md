# Massa de Testes — FichaIndividual (document-builder)

**Feature:** Migração da FichaIndividual de `documentacao-pedagogica` para o document-builder em `estrutura-pedagogica`  
**Cards:** EFC-6292 (transfer endpoints) · EFC-6325 (document-builder)  
**Data:** 2026-05-22  
**Banco:** ElevaPortalHomolog  

> **Nota:** Os nomes dos alunos no ambiente de homologação são anonimizados (padrão "LOREM IPSUM"). Isso é esperado — os hashes abaixo são válidos para uso nos requests.
>
> **AnoLetivo:** O `documentacao-pedagogica` de homolog está defasado, portanto os cenários de "Cursando" e "Grade Grande" usam dados de **2025**. Aprovado e Reprovado só existem no homolog para **2022** — usar esses dados para validar exibição do resultado final.

---

## O que está sendo testado

A FichaIndividual foi recriada no `estrutura-pedagogica` usando o novo `document-builder`.  
O comportamento esperado é **idêntico** ao da tela antiga (`documentacao-pedagogica`), mas agora:

- A paginação é automática (LayoutEngine)
- A quebra de colunas é automática (ColumnSplittable)
- O PDF é gerado pelo PrintService do document-builder

**Fluxo de dados:** Frontend → `POST /api/fichaindividual/impressao` (em `estrutura-pedagogica`) → backend → response renderizado pelo document-builder.

---

## Como Montar o Request

```json
{
  "hashRede": "{{HashRede}}",
  "hashUsuario": "{{HashAluno}}",
  "hashTurma": "{{HashTurma}}",
  "ativo": true
}
```

> `hashAnoLetivo` e `hashSerie` são opcionais. Se omitidos, o backend infere pela turma.

---

## Cenários de Teste com Dados Reais

### Cenário 1 — Aluno Cursando (AnoLetivo 2025)

**Objetivo:** Validar a ficha de um aluno com matrícula ativa. `ResultadoFinal` deve aparecer como vazio ou "Cursando".

| Campo | Valor |
|---|---|
| Rede | **Ábaco** |
| Escola | Ipiranga |
| Turma | 1ª série A - M |
| HashRede | `A43C39F2-91B7-4425-8921-1849090C1804` |
| HashTurma | `BD93C9B1-CEA9-41B9-9673-088A3D2D897D` |

**Alunos disponíveis (qualquer um serve):**

| HashAluno | Nome (anonimizado) |
|---|---|
| `72F60410-0C4F-42A3-96E5-1BED54C52774` | MANLOREM IPSUM... |
| `9F2986F3-B34D-4207-8E70-861D8CE1429E` | CAMLOREM IPSUM... |
| `3CDC526B-D99A-4E73-B150-878BBA8C9C18` | HELLOREM IPSUM... |
| `306FA049-ACED-4460-892C-D68CD8886921` | ISALOREM IPSUM... |

**Request pronto:**
```json
{
  "hashRede": "A43C39F2-91B7-4425-8921-1849090C1804",
  "hashUsuario": "72F60410-0C4F-42A3-96E5-1BED54C52774",
  "hashTurma": "BD93C9B1-CEA9-41B9-9673-088A3D2D897D",
  "ativo": true
}
```

---

### Cenário 2 — Aluno Aprovado (AnoLetivo 2022)

**Objetivo:** Validar que "Aprovado" aparece no rodapé e a frequência está preenchida.

> No homolog, registros com `Status = 'Aprovado'` existem apenas no AnoLetivo 2022.

| Campo | Valor |
|---|---|
| Rede | **Anglo Alante SP** |
| Escola | Chácara Santo Antônio |
| Turma | 2.2 AM |
| HashRede | `7F9E9798-3D78-44F6-8338-8D0C4495B641` |
| HashTurma | `A1B55EB3-CF25-4E54-849E-BF3D54D2A8D1` |

**Alunos disponíveis:**

| HashAluno | Nome (anonimizado) |
|---|---|
| `538FFC36-9DAC-48E3-8658-CFD0B6930D42` | BEALOREM IPSUM... |
| `7A1DC4AC-C828-4B5F-B81A-C0FA6EB65127` | GABLOREM IPSUM... |
| `76D08A60-D0CB-443B-B599-1AAA7DA2381F` | MANLOREM IPSUM... |

**Request pronto:**
```json
{
  "hashRede": "7F9E9798-3D78-44F6-8338-8D0C4495B641",
  "hashUsuario": "538FFC36-9DAC-48E3-8658-CFD0B6930D42",
  "hashTurma": "A1B55EB3-CF25-4E54-849E-BF3D54D2A8D1",
  "ativo": true
}
```

---

### Cenário 3 — Aluno Reprovado (AnoLetivo 2022)

**Objetivo:** Validar exibição de resultado "Reprovado".

> No homolog, o único registro com `Status = 'Reprovado'` é do AnoLetivo 2022.

| Campo | Valor |
|---|---|
| Rede | **Motivo** |
| Escola | Caruaru |
| Turma | 2.2 AM |
| HashRede | `4F79ADEC-4D7F-43E8-B4EF-B0172DC000DB` |
| HashTurma | `96664705-833F-48CF-AF31-D75BF971779C` |
| HashAluno | `CB5ACECC-15E6-4520-A1B0-686420F3AFD2` |

**Request pronto:**
```json
{
  "hashRede": "4F79ADEC-4D7F-43E8-B4EF-B0172DC000DB",
  "hashUsuario": "CB5ACECC-15E6-4520-A1B0-686420F3AFD2",
  "hashTurma": "96664705-833F-48CF-AF31-D75BF971779C",
  "ativo": true
}
```

**Alternativa — Em Recuperação (2022):**

| Campo | Valor |
|---|---|
| Rede | **Coleguium MG** |
| Escola | Conceição do Mato Dentro |
| Turma | Serviços 7º ano - M |
| HashRede | `98CD62E1-0350-4DB8-9181-420BA0EEE1FC` |
| HashTurma | `1ED75C16-F913-489A-B512-5ED0205393BF` |
| HashAluno | `04C01F72-64B5-43AC-80E5-2BB0064F7B61` |

---

### Cenário 4 — Aluno com Observações Preenchidas (AnoLetivo 2025)

**Objetivo:** Validar que o campo "Observações" aparece na ficha quando preenchido.

| Campo | Valor |
|---|---|
| Rede | **Coleguium MG** |
| Escola | Ouro Preto |
| Turma | 3ª série A - M |
| HashRede | `98CD62E1-0350-4DB8-9181-420BA0EEE1FC` |
| HashTurma | `49B57797-F302-4DA5-8ECA-84A003A1C245` |
| HashAluno | `9D01F492-A6DB-4189-BF24-D11D50B3F965` |

**Conteúdo esperado no campo Observações:**
> "2020: Lei Federal nº 14.040 de 19/08/2020; Resolução CEE nº 474 de 08/05/2020. // 2021: Lei Federal nº 14.040..."

**Request pronto:**
```json
{
  "hashRede": "98CD62E1-0350-4DB8-9181-420BA0EEE1FC",
  "hashUsuario": "9D01F492-A6DB-4189-BF24-D11D50B3F965",
  "hashTurma": "49B57797-F302-4DA5-8ECA-84A003A1C245",
  "ativo": true
}
```

---

### Cenário 5 — Grade Grande (AnoLetivo 2025, validar quebra de colunas)

**Objetivo:** O LayoutEngine deve quebrar automaticamente quando as colunas não cabem em uma página.

#### Opção A — Rede Embraer / SJC (50 disciplinas) ⭐ recomendada

| Campo | Valor |
|---|---|
| Rede | **Embraer** |
| Escola | SJC |
| Turma | 1ª série C - I |
| HashRede | `35A4C874-DAD6-48F1-B6F1-7521E8943F5E` |
| HashTurma | `EF5AAF35-A83E-4C4D-853A-B9D14BC6DF90` |
| QtdDisciplinas | **50** |

**Alunos disponíveis:**

| HashAluno | Nome (anonimizado) |
|---|---|
| `BEC475F4-01F9-4162-A7EA-E7642E8AFFA2` | ANALOREM IPSUM... |
| `5B96D18D-332E-45D3-83A1-164749327208` | ANALOREM IPSUM... |
| `0C67A537-F89E-4EA8-803F-5E9070432F8D` | ANALOREM IPSUM... |

**Request pronto:**
```json
{
  "hashRede": "35A4C874-DAD6-48F1-B6F1-7521E8943F5E",
  "hashUsuario": "BEC475F4-01F9-4162-A7EA-E7642E8AFFA2",
  "hashTurma": "EF5AAF35-A83E-4C4D-853A-B9D14BC6DF90",
  "ativo": true
}
```

#### Opção B — Rede Embraer / Botucatu (48 disciplinas)

| Campo | Valor |
|---|---|
| Rede | **Embraer** |
| Escola | Botucatu |
| Turma | 1ª série B - I |
| HashRede | `35A4C874-DAD6-48F1-B6F1-7521E8943F5E` |
| HashTurma | `F4B59F09-74CB-4BC8-85CA-B5455B1F8F6E` |

#### Opção C — Rede Nosso CEI / Romualdo Galvão (48 disciplinas)

| Campo | Valor |
|---|---|
| Rede | **Nosso CEI** |
| Escola | Romualdo Galvão |
| Turma | 2ª série B - M |
| HashRede | `6F2E00CB-95CB-4BC6-BB20-3E20365C7CD1` |
| HashTurma | `3E259C19-C3F4-4FC0-A9D8-16D46211B9A8` |

---

### Cenário 6 — Ficha Resumida

**Objetivo:** Validar que o endpoint `getResumida` retorna estrutura diferente e é renderizado corretamente.

Usar os mesmos pares dos cenários anteriores com a rota de resumida:

- **Endpoint:** `POST /api/fichaindividual/impressaoresumida`
- **Request:** mesmo body

---

## Configurações de Rede (Cenários 7 e 8 — investigar)

> **Atenção:** As colunas `DeveAgruparPorAreaDoConhecimento` e `NotasComUmaCasaDecimal` **não existem** na tabela `Rede` no banco `ElevaPortalHomolog`.  
> Essas configurações podem estar em outra tabela (ex: `EscolaConfiguracao`) ou serem específicas de outro ambiente.  
> **Ação recomendada:** verificar com o dev responsável em qual tabela/endpoint essas configurações são lidas pelo backend da FichaIndividual antes de definir os dados de teste para esses cenários.

---

## Verificações Visuais Esperadas

| O que verificar | Onde aparece na ficha |
|---|---|
| Nome do aluno e RA | Cabeçalho do documento |
| Nome da escola e rede | Cabeçalho do documento |
| Grade de disciplinas + notas por etapa | Corpo — tabela principal |
| Disciplinas de enriquecimento com `**` | Corpo — tabela principal |
| Legenda de siglas | Após a tabela |
| Percentual de frequência | Rodapé / campo de texto |
| Resultado final (Aprovado/Reprovado/Cursando) | Rodapé / campo de texto |
| Observações do aluno | Rodapé / campo de texto (apenas se preenchido) |
| Quebra automática de colunas em PDF | Ao imprimir com grade grande (≥12 disciplinas) |
| Quebra automática de páginas | Ao imprimir com múltiplos escopos |

---

## Diferença da implementação anterior

| Aspecto | `documentacao-pedagogica` (antigo) | `estrutura-pedagogica` (novo) |
|---|---|---|
| Paginação | Manual via `page-control.service.ts` | Automática via LayoutEngine |
| Quebra de colunas | Manual | Automática via ColumnSplittable |
| Geração de PDF | `print.service.ts` local | PrintService do document-builder |
| Rota | `/documentacao-pedagogica/fichaindividual` | `/estrutura-pedagogica/fichaindividual` |

A saída visual deve ser **equivalente** — mesmo conteúdo, mesmo layout — mas o novo não deve ter os problemas de paginação da versão antiga.
