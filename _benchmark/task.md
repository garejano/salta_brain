# Benchmark Task — Tarefa Idêntica para os Dois Fluxos

> Use este arquivo para ambas as sessões. Copie a tarefa abaixo e cole no Claude Code.
> Não modifique a tarefa entre as sessões.

---

## Contexto

Você está trabalhando no frontend Angular do repositório `estrutura-pedagogica`
(`c:/projects/estrutura-pedagogica/frontend`).

## Tarefa

O time precisa adicionar um novo campo **`nomeResponsavel`** ao filtro de importação
de alocação de professores. Antes de implementar, você precisa mapear o que existe.

Responda as 5 perguntas abaixo com o maior detalhe possível:

1. **Componente do filtro**: Qual componente Angular renderiza o filtro de importação
   de alocação de professores? Qual é o seu selector?

2. **Model/Interface**: Qual interface TypeScript define os campos do request de filtro
   para alocação de professores? Liste todos os campos existentes com seus tipos.

3. **Service HTTP**: Qual service faz a chamada HTTP para buscar os dados de importação?
   Qual é o nome exato do método que deve ser atualizado?

4. **Cadeia de dependências**: Descreva o fluxo completo do componente até a chamada HTTP
   (componente → service → método → endpoint).

5. **Arquivos a modificar**: Liste todos os arquivos (caminhos relativos a partir de
   `frontend/`) que precisarão ser modificados para adicionar o campo `nomeResponsavel`.

---

## Como registrar os resultados

Após a sessão, preencha `_benchmark/results.md` com:
- Quais ferramentas foram usadas (Glob, Grep, Read, etc.)
- Quantos arquivos foram lidos
- Se as respostas estavam corretas (verifique manualmente)
- Contexto aproximado consumido (visível no canto inferior do Claude Code)
