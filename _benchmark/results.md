# Benchmark Results — Angular Map vs Análise Direta

> Preencha após cada sessão. Não altere a estrutura da tabela para manter comparabilidade.

---

## Sessão 1 — Flow A (Com Mapa)

**Data:** ___________  
**Modelo:** ___________  
**Projeto testado:** estrutura-pedagogica

### Métricas de processo

| Métrica | Valor |
|---|---|
| Arquivos lidos (Read) | |
| Buscas Glob | |
| Buscas Grep | |
| Contexto usado ao final (%) | |
| A IA usou o mapa como 1º passo | Sim / Não |
| Arquivos extras além do mapa | (liste) |

### Ferramenta calls — lista completa

```
(Cole ou anote aqui os tool calls usados durante a sessão, em ordem)
1. 
2.
3.
...
```

### Qualidade das respostas

| Pergunta | Resposta correta? | Observação |
|---|---|---|
| P1 — Componente | Sim / Parcial / Não | |
| P2 — Interface | Sim / Parcial / Não | |
| P3 — Service / método | Sim / Parcial / Não | |
| P4 — Cadeia | Sim / Parcial / Não | |
| P5 — Arquivos | Sim / Parcial / Não | |

**Score: ___ / 5**

### Observações livres

```

```

---

## Sessão 2 — Flow B (Análise Direta)

**Data:** ___________  
**Modelo:** ___________  
**Projeto testado:** estrutura-pedagogica

### Métricas de processo

| Métrica | Valor |
|---|---|
| Arquivos lidos (Read) | |
| Buscas Glob | |
| Buscas Grep | |
| Contexto usado ao final (%) | |
| Primeira estratégia da IA | Glob / Grep / Read direto |
| Arquivos lidos desnecessariamente | (liste) |

### Ferramenta calls — lista completa

```
(Cole ou anote aqui os tool calls usados durante a sessão, em ordem)
1.
2.
3.
...
```

### Qualidade das respostas

| Pergunta | Resposta correta? | Observação |
|---|---|---|
| P1 — Componente | Sim / Parcial / Não | |
| P2 — Interface | Sim / Parcial / Não | |
| P3 — Service / método | Sim / Parcial / Não | |
| P4 — Cadeia | Sim / Parcial / Não | |
| P5 — Arquivos | Sim / Parcial / Não | |

**Score: ___ / 5**

### Observações livres

```

```

---

## Comparativo Final

> Preencher após as duas sessões.

| Métrica | Flow A (Mapa) | Flow B (Direto) | Vencedor |
|---|---|---|---|
| Total de arquivos lidos | | | |
| Total de tool calls | | | |
| Contexto consumido (%) | | | |
| Score de qualidade | / 5 | / 5 | |
| Arquivos desnecessários lidos | | | |
| Chegou correto na P1 | | | |
| Chegou correto na P5 (lista completa) | | | |

### Conclusão

```
(Escreva aqui a conclusão após os dois testes:
 - O mapa reduziu o número de leituras?
 - A qualidade das respostas foi equivalente, melhor ou pior?
 - Vale manter o fluxo de scan? Em quais situações?)
```

---

## Gabarito verificado

> Preencha manualmente antes de rodar os testes para ter o benchmark de referência.

**P1 — Componente:**
```
AlocacaoProfessoresComponent
selector: app-alocacao-professores
arquivo: src/app/features/cargas-iniciais/alocacao-professores/alocacao-professores.component.ts
```

**P2 — Interface e campos:**
```
ImportacaoAlocacaoProfessoresFilterRequest (cargas-iniciais.models.ts)
  hashAnoLetivo: string
  hashRede: string[]
  pagina?: number
```

**P3 — Service e método:**
```
ImportacaoAlocacaoProfessoresService
método: getImportacoes(request: ImportacaoAlocacaoProfessoresFilterRequest)
arquivo: src/app/features/cargas-iniciais/services/importacao-alocacao-professores.service.ts
```

**P4 — Cadeia completa:**
```
AlocacaoProfessoresComponent
  → chama FilterAlocacaoProfessorService (para estado do filtro)
  → chama ImportacaoAlocacaoProfessoresService.getImportacoes(request)
    → ApiClient.post('/importacaoalocacaoprofessores/get-importacoes', request)
      → endpoint: POST /importacaoalocacaoprofessores/get-importacoes
```

**P5 — Arquivos a modificar:**
```
1. src/app/features/cargas-iniciais/cargas-iniciais.models.ts
   (adicionar campo nomeResponsavel: string à interface)
2. src/app/features/cargas-iniciais/services/importacao-alocacao-professores.service.ts
   (o campo novo já é passado via interface — sem mudança se só for no request)
3. src/app/features/cargas-iniciais/alocacao-professores/alocacao-professores.component.ts
   (se o campo vier do filtro, precisa capturar e passar no request)
4. src/app/features/cargas-iniciais/filtro_alocacao_professores.ts  (ou equivalente)
   (adicionar o campo na config do filtro visual, se existir)

Nota: se o campo vier de um filtro visual (FiltroComponent), pode haver um 5º arquivo
de configuração do filtro. Verificar existência de filtro_alocacao_professores.ts.
```
