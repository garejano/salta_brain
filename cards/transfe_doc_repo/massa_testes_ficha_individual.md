# Massa de Testes — FichaIndividual (document-builder)

**Feature:** Migração da FichaIndividual de `documentacao-pedagogica` para o document-builder em `estrutura-pedagogica`  
**Cards:** EFC-6292 (transfer endpoints) · EFC-6325 (document-builder)  
**Data:** 2026-05-22  
**Banco:** ElevaPortalHomolog  

> **Nota:** Os nomes dos alunos no ambiente de homologação são anonimizados (padrão "LOREM IPSUM"). Isso é esperado — os hashes abaixo são válidos para uso nos requests.

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

### Cenário 1 — Aluno Cursando (ano letivo vigente 2026)

**Objetivo:** Validar a ficha de um aluno com matrícula ativa no ano corrente. `ResultadoFinal` deve aparecer como vazio ou "Cursando".

| Campo | Valor |
|---|---|
| Rede | **Ábaco** |
| Escola | Ipiranga |
| Turma | 1ª série A - M |
| HashRede | `A43C39F2-91B7-4425-8921-1849090C1804` |
| HashTurma | `9FBB71B9-E5E8-467F-BAC0-518128E1E698` |

**Alunos disponíveis (qualquer um serve):**

| HashAluno | Nome (anonimizado) |
|---|---|
| `E52F3658-BE77-4B69-B0B4-F70B476F2A45` | AMALOREM IPSUM... |
| `95A4C11D-F633-43E2-8CEF-0B3BD00CC100` | CARLOREM IPSUM... |
| `0B5CE9C9-3A9F-4994-8580-EA871E7268DD` | SOFLOREM IPSUM... |
| `0169F3F4-896B-485A-84DD-D4AD3642CB06` | ANTLOREM IPSUM... |

**Request pronto:**
```json
{
  "hashRede": "A43C39F2-91B7-4425-8921-1849090C1804",
  "hashUsuario": "E52F3658-BE77-4B69-B0B4-F70B476F2A45",
  "hashTurma": "9FBB71B9-E5E8-467F-BAC0-518128E1E698",
  "ativo": true
}
```

---

### Cenário 2 — Aluno Aprovado (resultado final fechado)

**Objetivo:** Validar que "Aprovado" aparece no rodapé e a frequência está preenchida.

> **Observação:** No homolog, registros com `Status = 'Aprovado'` existem apenas no AnoLetivo 2022. Usar esses dados para validar a exibição do resultado final.

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

### Cenário 3 — Aluno Reprovado

**Objetivo:** Validar exibição de resultado "Reprovado" e possível baixa frequência.

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

**Alternativa — Em Recuperação:**

| Campo | Valor |
|---|---|
| Rede | **Coleguium MG** |
| Escola | Conceição do Mato Dentro |
| Turma | Serviços 7º ano - M |
| HashRede | `98CD62E1-0350-4DB8-9181-420BA0EEE1FC` |
| HashTurma | `1ED75C16-F913-489A-B512-5ED0205393BF` |
| HashAluno | `04C01F72-64B5-43AC-80E5-2BB0064F7B61` |

---

### Cenário 4 — Aluno com Observações Preenchidas

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

**Alternativa (observação diferente):**

| HashAluno | Escola | Observação resumida |
|---|---|---|
| `9A7E9DAA-DF3A-4F7B-BD3C-6CA7483993A0` | Mais Belvedere | "Colégio Santa Maria Minas - Unidade Nova Lima, antigo Liceu Santa Maria Imaculada..." |

```json
{
  "hashRede": "98CD62E1-0350-4DB8-9181-420BA0EEE1FC",
  "hashUsuario": "9A7E9DAA-DF3A-4F7B-BD3C-6CA7483993A0",
  "hashTurma": "D3F751FE-E8C8-4CF0-A700-26977B2F79E8",
  "ativo": true
}
```

---

### Cenário 5 — Grade Grande (validar quebra de colunas)

**Objetivo:** O LayoutEngine deve quebrar automaticamente quando as colunas não cabem em uma página. Turmas com 40 disciplinas garantem essa quebra.

#### Opção A — Rede Nota 10 (40 disciplinas)

| Campo | Valor |
|---|---|
| Rede | **Nota 10** |
| Escola | Garças |
| Turma | Pré-vestibular A - N |
| HashRede | `73380414-983F-4271-82DF-0CCBF19F08EE` |
| HashTurma | `2E482BCA-DB0F-445E-8DAF-CA39A1078D73` |
| QtdDisciplinas | **40** |

**Alunos disponíveis:**

| HashAluno | Nome (anonimizado) |
|---|---|
| `B3B4AF68-628C-4B2E-8095-50443948313F` | ALFLOREM IPSUM... |
| `A6105B02-1F38-4B16-B997-D99EE4EDCE4B` | ALLLOREM IPSUM... |
| `9852591A-4C71-4C9A-AA4D-EBBCBA29D89F` | ALLLOREM IPSUM... |

**Request pronto:**
```json
{
  "hashRede": "73380414-983F-4271-82DF-0CCBF19F08EE",
  "hashUsuario": "B3B4AF68-628C-4B2E-8095-50443948313F",
  "hashTurma": "2E482BCA-DB0F-445E-8DAF-CA39A1078D73",
  "ativo": true
}
```

#### Opção B — Rede Integrado, Escola Jaó (40 disciplinas)

| Campo | Valor |
|---|---|
| Rede | **Integrado** |
| Escola | Jaó |
| Turma | 3ª série A - M |
| HashRede | `A7D29956-021C-4873-A23D-E1D35C4B040E` |
| HashTurma | `26CC5191-69F3-4185-9256-C7C9DE157090` |
| QtdDisciplinas | **40** |

#### Opção C — Rede Nota 10, Internacional Dourados (36 disciplinas)

| Campo | Valor |
|---|---|
| Rede | **Nota 10** |
| Escola | Internacional Dourados |
| Turma | 1ª série A - I |
| HashRede | `73380414-983F-4271-82DF-0CCBF19F08EE` |
| HashTurma | `63D4C6F4-BF98-4C45-9A7E-CD713944FDF2` |
| QtdDisciplinas | **36** |

---

### Cenário 6 — Ficha Resumida

**Objetivo:** Validar que o endpoint `getResumida` retorna estrutura diferente e é renderizado corretamente.

Usar os mesmos pares `(HashRede, HashAluno, HashTurma)` dos cenários anteriores, mas chamar a rota de resumida:

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
