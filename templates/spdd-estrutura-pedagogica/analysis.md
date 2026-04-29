# SPDD — Analysis | estrutura-pedagogica

> Etapa 2. Capture conceitos de domínio, riscos e direção estratégica.
> Não desça para detalhes de implementação — isso fica no Canvas.

---

## Referência

**Story / Card:** <!-- EFC-XXXX — título -->  
**Data:** <!-- YYYY-MM-DD -->  
**Autor:** <!-- nome -->

---

## Conceitos de Domínio

> Quais entidades, termos e regras de negócio são centrais para este problema?

| Conceito | Tipo | Definição no contexto desta feature |
|----------|------|-------------------------------------|
| [Ex: Turma] | Entidade (Stateful) | ... |
| [Ex: AlocacaoProfessor] | Entidade (Base) | ... |
| [Ex: RegraX] | Regra de negócio | ... |

---

## Código Existente Relevante

> Quais partes do codebase esta feature vai tocar, estender ou depender?

| Camada | Arquivo / Classe | Ação |
|--------|-----------------|------|
| Domain | `Entities/.../XxxEntity.cs` | leitura / extensão / nova entidade |
| Domain.Services | `[Feature]/IXxxService.cs` | extensão / novo service |
| Infra | `Repositories/.../XxxRepository.cs` | extensão / novo repositório |
| Api | `Controllers/XxxController.cs` | extensão / novo controller |
| Frontend | `features/[feature]/` | novo component / extensão |
| scripts-db-pedagogico | `Views/` ou `Triggers/` | novo script / alteração |

---

## Banco de Dados

> Atenção: este projeto **não usa EF Migrations**. Alterações de schema são scripts SQL manuais no repositório `scripts-db-pedagogico`.

| Alteração necessária | Tipo | Repositório |
|---------------------|------|------------|
| Nova tabela `[Nome]` | CREATE TABLE | scripts-db-pedagogico |
| Nova coluna em `[Tabela]` | ALTER TABLE | scripts-db-pedagogico |
| Nova view `[View]` | CREATE VIEW | scripts-db-pedagogico |

---

## Riscos e Incertezas

| Risco | Prob. | Impacto | Mitigação |
|-------|-------|---------|-----------|
| ... | alta/média/baixa | alto/médio/baixo | ... |

**Perguntas em aberto:**
- [ ] ...
- [ ] ...

---

## Direção Estratégica

**Abordagem preferida:**
<!-- ex: estender IXxxRepository com novo método, criar novo service XxxService dentro de [Feature]/ -->

**Alternativas descartadas:**
- [Alternativa A] — descartada porque: ...

**Restrições:**
- Schema gerenciado externamente (sem migrations EF)
- ...

---

## Dependências

| Dependência | Tipo | Status |
|-------------|------|--------|
| Script SQL para nova tabela | scripts-db-pedagogico | pendente / feito |
| Funcionalidade enum no portal-atlas | externo | pendente / N/A |
| ... | | |

---

## Próximo passo

Com esta análise validada, preencha `reasons-canvas.md`.
