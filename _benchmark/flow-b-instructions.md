# Flow B — Análise Direta (sem mapa)

> Abra uma **nova sessão** do Claude Code no projeto `estrutura-pedagogica`.
> Não use o mapa pré-gerado. Não mencione que ele existe.

## Setup da sessão

1. Abra o Claude Code em `c:/projects/estrutura-pedagogica`
2. Na primeira mensagem, forneça apenas o contexto mínimo:

```
Estou trabalhando no frontend Angular deste projeto.
A pasta do frontend é `frontend/`.

[COLE AQUI O CONTEÚDO DE _benchmark/task.md]
```

## O que monitorar durante a sessão

Anote no `results.md` ao final:

| Métrica | Como capturar |
|---|---|
| Arquivos lidos (Read) | Observe os tool calls na sessão |
| Buscas (Glob/Grep) | Observe os tool calls na sessão |
| Contexto usado | Barra de contexto no canto inferior direito |
| Primeira estratégia da IA | Globbing? Grep? Leu um arquivo específico? |
| Quantas iterações até encontrar o componente certo? | Contagem manual |

## Padrões esperados para Flow B

A IA provavelmente vai:
1. Rodar `Glob` para mapear a estrutura de pastas
2. Rodar `Grep` para encontrar "alocacao" ou "professor" nos arquivos
3. Ler o componente encontrado
4. Ler o service a partir dos imports do componente
5. Ler o arquivo de models a partir dos imports do service/componente

Observe se ela "erra o caminho" (lê arquivos irrelevantes antes de chegar ao certo).
Cada arquivo lido desnecessariamente é custo de contexto.
