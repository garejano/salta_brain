# Flow A — Com Angular Map (mapa pré-gerado)

> Abra uma **nova sessão** do Claude Code no projeto `estrutura-pedagogica`.
> Não deixe contexto de conversas anteriores.

## Setup da sessão

1. Abra o Claude Code em `c:/projects/estrutura-pedagogica`
2. Na primeira mensagem, inclua o conteúdo do mapa como contexto:

```
@c:/projects/salta_brain/frontend-maps/estrutura-pedagogica-angular-map.md

Com base neste mapa do frontend Angular, responda as perguntas abaixo.
Tente responder usando apenas o mapa antes de abrir arquivos individuais.
Se precisar ler um arquivo específico para confirmar algum detalhe, faça isso,
mas registre quais arquivos precisou abrir além do mapa.

[COLE AQUI O CONTEÚDO DE _benchmark/task.md]
```

## O que monitorar durante a sessão

Anote no `results.md` ao final:

| Métrica | Como capturar |
|---|---|
| Arquivos lidos (Read) | Observe os tool calls na sessão |
| Buscas (Glob/Grep) | Observe os tool calls na sessão |
| Contexto usado | Barra de contexto no canto inferior direito |
| A IA abriu o mapa como primeiro passo? | Sim/Não |
| Precisou de arquivos além do mapa? | Liste quais |

## Gabarito esperado para Flow A

Com o mapa, a IA **deveria conseguir responder 1, 3 e 4 sem ler arquivos**.
Perguntas 2 e 5 podem exigir leitura do arquivo de models/componente.

Respostas corretas (verifique após a sessão):

- **P1**: `AlocacaoProfessoresComponent` — selector `app-alocacao-professores`
  - Arquivo: `src/app/features/cargas-iniciais/alocacao-professores/alocacao-professores.component.ts`
- **P2**: `ImportacaoAlocacaoProfessoresFilterRequest` em `cargas-iniciais.models.ts`
  - Campos: `hashAnoLetivo: string`, `hashRede: string[]`, outros (verificar no arquivo)
- **P3**: `ImportacaoAlocacaoProfessoresService` — método a verificar no arquivo
- **P4**: `AlocacaoProfessoresComponent` → `FilterAlocacaoProfessorService` ou `ImportacaoAlocacaoProfessoresService` → chamada HTTP
- **P5**: Pelo menos: `cargas-iniciais.models.ts`, `alocacao-professores.component.ts`,
  o service HTTP, possivelmente o arquivo de config do filtro
