# SPDD — REASONS Canvas

> Etapa 3 do workflow — artefato principal do SPDD.
> Este documento é a fonte de verdade. Mantenha-o versionado junto ao código.
> Quando código e canvas divergirem: corrija o canvas primeiro, depois o código.

---

## Cabeçalho

**Feature / Story:** <!-- título -->  
**Repositório:** <!-- ex: salta-api -->  
**Versão do canvas:** <!-- v1.0 -->  
**Última atualização:** <!-- YYYY-MM-DD -->  
**Autor:** <!-- nome -->

---

## R — Requirements
> O problema a ser resolvido e os critérios de aceite.

### Problema

<!-- Descreva em 2-3 frases o problema de negócio que esta implementação resolve. -->

### Definição de Pronto (DoD)

- [ ] ...
- [ ] ...
- [ ] ...

### Fora de Escopo

- ...
- ...

---

## E — Entities
> Entidades de domínio, suas propriedades relevantes e relacionamentos.

### Entidades

```
[NomeEntidade]
  - propriedade: tipo       // descrição se não óbvio
  - propriedade: tipo

[OutraEntidade]
  - propriedade: tipo
```

### Relacionamentos

```
[EntidadeA] --[verbo]--> [EntidadeB]
[EntidadeB] --[verbo]--> [EntidadeC]
```

### Invariantes de Domínio

> Regras que nunca podem ser violadas.

- ...
- ...

---

## A — Approach
> Estratégia de solução escolhida e racional.

### Estratégia

<!-- Como o problema será resolvido em alto nível. 3-5 frases. -->

### Padrão(ões) Aplicado(s)

<!-- ex: Strategy Pattern para variação de preço, Repository para acesso a dados -->

- ...

### Decisões de Design

| Decisão | Opção escolhida | Alternativa descartada | Motivo |
|---------|----------------|----------------------|--------|
| ... | ... | ... | ... |

---

## S — Structure
> Como esta feature se encaixa no sistema existente.

### Componentes Envolvidos

| Componente | Papel nesta feature | Ação (criar / alterar / estender / ler) |
|------------|--------------------|-----------------------------------------|
| `path/to/module` | ... | ... |

### Diagrama de Dependências (se útil)

```
[Novo Módulo] --> [Módulo Existente A]
[Novo Módulo] --> [Módulo Existente B]
[Controller]  --> [Novo Módulo]
```

### Interface Pública (contratos)

```typescript
// Assinaturas de métodos / tipos que serão expostos
interface NomeInterface {
  metodo(param: Tipo): ReturnType;
}
```

---

## O — Operations
> Passos concretos e testáveis de implementação. Este é o roteiro de geração de código.

> **Instrução para a IA:** execute cada operação em ordem, uma por vez. Não implemente nada além do que está descrito aqui. Nada de improviso.

### Operação 1 — [Nome]

**O que fazer:** ...  
**Arquivo(s):** `path/to/file`  
**Critério de conclusão:** ...

---

### Operação 2 — [Nome]

**O que fazer:** ...  
**Arquivo(s):** `path/to/file`  
**Critério de conclusão:** ...

---

### Operação 3 — [Nome]

**O que fazer:** ...  
**Arquivo(s):** `path/to/file`  
**Critério de conclusão:** ...

---

<!-- Repita para cada operação. Mantenha atômico e testável. -->

---

## N — Norms
> Padrões de engenharia que toda a implementação deve seguir.

### Naming

- ...

### Observabilidade

- ...

### Coding Standards

- ...

### Padrões do Projeto

- Seguir convenções de `[arquivo de referência ou guia de estilo]`
- ...

---

## S — Safeguards
> Limites não negociáveis. Violá-los é um blocker de PR.

### Segurança

- [ ] ...

### Performance

- [ ] ...

### Invariantes (não podem ser quebradas)

- [ ] ...

### Compatibilidade

- [ ] Não quebrar contratos públicos existentes
- [ ] ...

---

## Histórico de Atualizações

| Data | Versão | O que mudou | Motivo |
|------|--------|-------------|--------|
| YYYY-MM-DD | v1.0 | Criação inicial | — |
| YYYY-MM-DD | v1.1 | ... | ... |
