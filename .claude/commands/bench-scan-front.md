# /bench-scan-front

Roda o benchmark automatizado comparando dois fluxos de análise de código Angular:
- **Flow A**: Claude lê o mapa pré-gerado (`frontend-maps/<repo>-angular-map.md`) como primeiro passo
- **Flow B**: Claude explora o frontend diretamente, sem mapa

Usa o Claude Code CLI (`claude -p`) — **não requer API key separada**.
Ao final, gera um relatório em `_benchmark/runs/`.

## Pré-requisito para Flow A

Gerar o mapa antes de rodar (se ainda não existir ou estiver desatualizado):

```
python c:/projects/salta_brain/_scripts/scan_angular.py estrutura-pedagogica
```

## Como rodar

```powershell
# Benchmark completo (Flow A + Flow B)
python c:/projects/salta_brain/_scripts/bench_scan_frontend.py

# Especificar repo
python c:/projects/salta_brain/_scripts/bench_scan_frontend.py --repo estrutura-pedagogica

# Especificar modelo
python c:/projects/salta_brain/_scripts/bench_scan_frontend.py --model claude-sonnet-4-6

# Rodar apenas um flow
python c:/projects/salta_brain/_scripts/bench_scan_frontend.py --flow a
python c:/projects/salta_brain/_scripts/bench_scan_frontend.py --flow b
```

## O que é medido

| Métrica | Descrição |
|---|---|
| Arquivos lidos (Read) | Quantos arquivos `.ts` o Claude abriu |
| Buscas (Grep)         | Quantas buscas por conteúdo |
| Listagens (Glob)      | Quantas listagens de diretório |
| Total tool calls      | Soma de todas as ferramentas usadas |
| Custo estimado (USD)  | Reportado pelo CLI no evento `result` |
| Score qualidade       | 0–5 baseado em palavras-chave do gabarito |
| Tempo (s)             | Do início ao fim do flow |

## Gabarito embutido (estrutura-pedagogica)

- **P1**: `AlocacaoProfessoresComponent`, selector `app-alocacao-professores`
- **P2**: `ImportacaoAlocacaoProfessoresFilterRequest`, campos `hashAnoLetivo`, `hashRede`
- **P3**: `ImportacaoAlocacaoProfessoresService`, método `getImportacoes`
- **P4**: Cadeia completa até endpoint `importacaoalocacaoprofessores`
- **P5**: `cargas-iniciais.models.ts`, `importacao-alocacao-professores.service.ts`, `alocacao-professores.component.ts`

## Relatório gerado

Salvo em `_benchmark/runs/<timestamp>_<repo>_results.md` com:
- Métricas por flow
- Lista de tool calls em ordem
- Score de qualidade por pergunta (P1–P5)
- Resposta final completa
- Tabela comparativa A vs B com vencedor por métrica
