# Análise: Documentação Pedagógica — Problemas, Chamados e Evolução (2022–2026)

> Gerado em: 2026-05-13  
> Fonte: Jira — projetos **EFC** (desenvolvimento) e **SP** (Suporte Pedagógico)  
> Contexto: levantamento para embasar o desenvolvimento do **EFC-6325 — document-builder**

---

## 1. Resumo executivo

A documentação pedagógica é um dos domínios com **maior volume de chamados** do Suporte Pedagógico (SP). Em 4 anos, foram registrados pelo menos **250+ tickets de suporte** apenas nos documentos Boletim, Ficha Individual, Ata de Resultados Finais e Certificado. No lado de desenvolvimento, mais de **150 cards EFC** tocaram em algum desses documentos — entre features, bugs e operacionais.

O motor de geração legado (`gerador-documentos`) foi a principal fonte de limitação técnica. O **EFC-6325** (document-builder) representa a resposta arquitetural a esses problemas acumulados.

---

## 2. Volume de chamados por documento

| Documento | Tickets SP (2022–2026) | Situação predominante |
|---|---|---|
| **Boletim** | 100+ (limite da busca) | ~80% concluídos, 20% reclassificados |
| **Ata de Resultados Finais** | 68 | ~85% concluídos |
| **Ficha Individual** | 60 | ~80% concluídos, alguns "Enviado para N3" |
| **Certificado** | 22 | ~95% concluídos |
| **Diário de Classe** | 1 confirmado | Concluído |

> **Nota:** A busca retornou no máximo 100 resultados por termo. O volume real de boletim é superior a 100 tickets no período.

---

## 3. Padrões de problemas por documento

### 3.1 Boletim

**Problemas recorrentes identificados:**

| Categoria | Exemplos | Freq. estimada |
|---|---|---|
| **Nota não reflete / ausente** | "Nota não aparece no boletim", "Nota de Química não reflete no boletim", "AUSÊNCIA DA NOTA NO BOLETIM" | Alta |
| **Cálculo incorreto** | "Erro no cálculo de RT1", "erro cálculo da média final", "ERRO DE CÁLCULO - BOLETIM", "nota acima da nota máxima" | Alta |
| **Sem acesso / fora do ar** | "Boletim fora do ar", "RP não consegue acessar boletim", "tempo expirado", "aluno não visualiza boletim" | Média |
| **Disciplinas ausentes** | "ESPANHOL AUSENTE NO BOLETIM", "Disciplina Matemática II não aparece", "Disciplinas de Dependência não aparecem" | Média |
| **Configuração** | "ESTRUTURA DO BOLETIM - 2026", "Tela do configurador de boletim", "Remoção de coluna", "ABA BOLETIM NÃO APARECE" | Média |
| **Divergência com outros documentos** | "Divergência entre o boletim e o portal Atlas", "Notas divergentes: Histórico Escolar x Boletim", "divergência de % de frequencia entre Boletim e DocPed" | Média |
| **Zero indevido** | "Zero lançado indevidamente no boletim", "Remover zero lançado na 2º chamada" | Baixa |
| **Faltas ausentes/erradas** | "Investigar ausência de faltas no boletim do Núcleo Anglo", "BOLETIM ÁBACO - COLUNAS DE FALTAS ZERADA", "Boletim - SEM FALTAS 2º TRIMESTRE" | Baixa |

**Cards EFC notáveis:**
- `EFC-4942` — Refatoração do cálculo de Boletim (Aberta)
- `EFC-5012` — Novo tipo de cálculo "Percentual de desempenho"
- `EFC-4898` — Teste de conversão do boletim ASP para Angular com IA
- `EFC-4879` — Epic: Boletim Ábaco
- `EFC-5672` — Epic: Boletim por escola
- `EFC-2751` — Epic: Boletim Acadêmico
- `EFC-2762` — Pesquisa de satisfação boletim (Discover)
- `EFC-4856` — Implementação do método avaliativo Innopeda (Aberta)
- `EFC-4855` — Criação da "Progressão Parcial" (Aberta)
- `EFC-4853` — Revisão do Boletim do Ensino Médio (Aberta)

**Padrão temporal:** picos de chamados em jan/fev (fechamento de ano letivo) e nov/dez (avaliações finais).

---

### 3.2 Ficha Individual

**Problemas recorrentes identificados:**

| Categoria | Exemplos |
|---|---|
| **Erro de geração** | "Erro ao gerar a ficha individual", "ERRO AO EXPORTAR FICHA INDIVIDUAL DO ALUNO", "🔥 Erro na exportação da Ficha Individual em lote", "Ficha Individual- Não gera" |
| **Dados incorretos** | "Ficha individual sem nota", "Ausência de disciplinas na Ficha Individual", "Ficha Individual incompleta 2025 - EF1 e EF2", "Nota de Inglês Instrumental na Ficha Individual" |
| **Layout/paginação** | "FICHA INDIVIDUAL SAINDO EM 02 PÁGINAS", "A assinatura da ficha individual está em sobreposição à tabela" |
| **Nome do aluno errado** | "ERRO NO NOME DO ALUNO AO GERAR A FICHA INDIVIDUAL" — ao gerar em lote, todos os arquivos recebiam o nome da primeira aluna |
| **Ano letivo incorreto** | "Ficha Individual em Massa está sem Ano Letivo e UF" |
| **Dados de ano anterior** | "Histórico Escolar e Ficha Individual referentes ao ano letivo de 2025 não aparecem na documentação Pedagógica" |
| **Divergência entre documentos** | "Erro ficha individual e histórico - Ana Luiza Sousa Silva" |

**Cards EFC notáveis:**
- `EFC-4715` — Backendização da ficha individual (Concluído)
- `EFC-4779` — Ficha Individual pelo backend - Cabeçalho e assinatura
- `EFC-5842` — Incluir RA Digital na Ficha Individual
- `EFC-4960` — INCLUSÃO DE LEGENDA NAS FICHAS INDIVIDUAIS - ELITE RJ (Aberta)
- `EFC-5019` — Ficha de Anamnese - Desenvolvimento Psicomotor - Texto Livre (Aberta)
- `EFC-2271` — Epic: Ficha Individual (2023)
- `EFC-6292` — Migração de endpoint da Ficha Individual de notas para estrutura-avaliacao (Aberta)

---

### 3.3 Ata de Resultados Finais

**Problemas recorrentes identificados:**

| Categoria | Exemplos |
|---|---|
| **Não aparece / erro ao abrir** | "Não aparece a Ata de Resultados Finais", "Ata não abre", "ERRO NA TELA - DOCUMENTAÇÃO 'ATA DE RESULTADOS FINAIS'", "ERRO NO DOCUMENTO - ATA DE RESULTADOS FINAIS" |
| **Dados faltando** | "Ata de Resultados Finais - Sem situação de aprovado", "EAI SEM O RESULTADO FINAL INFORMADO", "Ata de resultados finais sem nota", "Ausência de conceitos na Ata de resultados finais" |
| **Alunos faltando / duplicados** | "ALUNO APARECE EM DUAS ATAS DE RESULTADOS FINAIS", "Ata da 3ª série EM IME/ITA faltando alunos", "Reprovados rematriculados não aparecem em Ata e Ficha" |
| **Disciplinas duplicadas** | "ATA DE RESULTADOS FINAIS COM DISCIPLINAS DUPLICADAS" |
| **Frequência incorreta** | "Frequência na Ata de Resultados Finais", "Atas 2022 com frequência errada" |
| **Anos letivos antigos** | "Atas de dependência 2024 e 2025 não aparecem no portal", "Ata de Resultados Finais - Ano Letivo de 2024" (múltiplos em 2025) |

**Cards EFC notáveis:**
- `EFC-4473` — Alunos reprovados não constaram na ata após matrícula 2024 (Aberta — problema sistêmico documentado)
- `EFC-5039` — Adicionar Observação na Ata exibe documento em branco (Aberta)
- `EFC-5956` — Disciplinas duplicadas na Ata (Concluído)
- `EFC-5953` — Ata diz que não existem alunos (Concluído)
- `EFC-6086` — Frequência na Ata de Resultados Finais (Concluído)
- `EFC-6173` — Não aparece a Ata de Resultados Finais (Aberta)

---

### 3.4 Certificado de Conclusão

**Problemas recorrentes identificados:**

| Categoria | Exemplos |
|---|---|
| **Verso incorreto ou ausente** | "Não aparece o verso do Certificado", "Problema no verso do Certificado", "Verso certificado de conclusão" |
| **Dados incorretos** | "CH do certificado divergente do Histórico", "Verificação de inconsistência em documento (certificado)", "Erro no Certificado de conclusão" |
| **Não gera / não exibe** | "O Portal Atlas não libera a impressão do Certificado" |
| **Aluno reprovado com certificado** | "Alunos Reprovados na 3ª Série EM está emitindo certificado de conclusão" (EFC-1641) |
| **Solicitações de ajuste** | "CERTIFICADO DO HISTÓRICO", "Incluir as Escolas de 9ºano nos Certificados", "Nome da escola de conclusão do EF no Verso do Certificado da 3ª Série" |

---

### 3.5 Diário de Classe

- `SP-5195` — "Diario de Classe com erro — conteúdos ministrados não saindo" (2025)
- `EFC-2730` — Ajustes visuais documento diário de classe (Ideation, 2023)
- `EFC-2156` — Estrutura frontend de diário de classe conforme padrão de pastas (2023)
- `EFC-5779` — Incluir controle de geração do documento no formulário do diário de classe (Concluído)
- `EFC-5260` — Edição do nome do professor no diário de classe não reflete no documento (Concluído)

---

## 4. Categorias transversais de problemas

### 4.1 Dados inconsistentes entre documentos
Cards como SP-6421 "ERRO NA DOCUMENTAÇÃO PEDAGÓGICA: ATA DE RESULTADOS FINAIS E HISTÓRICO ESCOLAR" e SP-6012 "Notas divergentes: Histórico Escolar x Boletim" revelam que **diferentes documentos consomem dados de fontes distintas ou caches desatualizados**, gerando divergências que confundem o usuário final.

### 4.2 Falhas de geração de PDF
Recorrência de:
- Timeout durante geração em lote
- Arquivo gerado com nome incorreto (bug de closures)
- Documento em branco após ações do usuário
- Assinatura sobreposta ao conteúdo

**Raiz técnica (legado):** `setTimeout` frágil no pipeline de layout, ausência de pipeline determinístico, componentes não-splittable.

### 4.3 Configuração por marca/rede
O sistema serve múltiplas marcas (Elite, Pensi, Ábaco, Coleguium, Saber, IF, etc.), cada uma com configurações distintas de boletim, modelos de documento e regras de cálculo. Isso gera:
- Bugs específicos por marca que não afetam outras
- Alto custo de manutenção por acoplamento de configuração ao documento
- Necessidade de flags e modelos por marca (`EFC-873`, `EFC-963`, `EFC-1330`)

### 4.4 Alunos em situações especiais não tratadas
- NEE (Necessidades Educacionais Especiais): `SP-5293` informações desaparecendo
- Transferidos: não aparecem na Ata (`EFC-4708`)
- Cancelados: ainda aparecem no documento de outro ano (`EFC-4263`)
- Reprovados/rematriculados: não constam na ata (`EFC-4473` — ainda Aberta)
- Dependência: disciplinas não aparecem no boletim, atas incorretas

### 4.5 Anos letivos anteriores
Grande volume de chamados de acesso a documentos de anos anteriores (2021, 2022, 2023, 2024) que não aparecem ou têm dados incorretos. Sugere **fragilidade no modelo de histórico** — os documentos podem depender de dados que são migrados ou transformados entre anos.

---

## 5. Problemas do usuário ao usar geração de documentos

Com base nos relatos dos chamados SP, os problemas que o usuário experimenta diretamente são:

1. **"O documento não aparece"** — o botão de gerar está desabilitado, ou o documento retorna vazio
2. **"O dado está errado"** — nota, frequência, nome do aluno, série, escola
3. **"Está saindo com layout quebrado"** — ficha em 2 páginas, assinatura sobreposta, colunas erradas
4. **"O arquivo baixado está incorreto"** — nome do arquivo errado (todos com nome da primeira aluna)
5. **"Funciona para outros alunos mas não para esse"** — bugs específicos por situação do aluno (NEE, cancelado, transferido)
6. **"Está diferente do que aparece na tela"** — divergência entre boletim na tela e documento impresso
7. **"O sistema trava/timeout ao gerar em lote"** — geração paralela sem controle de erro por página

---

## 6. Evolução de desenvolvimento (linha do tempo)

| Período | Iniciativas técnicas principais |
|---|---|
| 2022 | Criação do módulo de documentos (Histórico/Certificado), Epic Boletim Acadêmico, Embarque Saber 2023 |
| 2023 | Epic Ficha Individual, Epic Boletim 2023, Diário de Classe, Pesquisa satisfação boletim |
| 2024 | Backendização da Ficha Individual, Boletim por escola, múltiplos ajustes de Ata e Certificado |
| 2025 | Boletim Ábaco, RA Digital na Ficha, Permissão Assinatura Digital (solicitação), Acesso Boletim no Conselho de Classe |
| 2026 | **EFC-6325 document-builder** (motor novo), Nova exibição de componentes formativos, Migração endpoint Ficha Individual |

---

## 7. Solicitações abertas relevantes para o document-builder

Estas stories ainda abertas no EFC são candidatas à implementação via document-builder:

| Card | Descrição |
|---|---|
| `EFC-4937` | Incluir Assinatura Digital em Documentos Pedagógicos |
| `EFC-4960` | Inclusão de Legenda nas Fichas Individuais - ELITE RJ |
| `EFC-5019` | Ficha de Anamnese - Desenvolvimento Psicomotor - Texto Livre |
| `EFC-5039` | Adicionar Observação na Ata exibe documento em branco |
| `EFC-6106` | Atualizar checkbox - Doc-Ped - Histórico por série |
| `EFC-4856` | Implementação do método avaliativo Innopeda no Boletim |
| `EFC-4855` | Criação da "Progressão Parcial" |
| `EFC-4853` | Revisão do Boletim do Ensino Médio |
| `EFC-4852` | Detalhamento de cálculo da Média de Ciências |

---

## 8. Implicações para o EFC-6325 (document-builder)

| Problema recorrente | Solução esperada no document-builder |
|---|---|
| Ficha saindo em 2 páginas | `LayoutEngine` com split determinístico resolve paginação automática |
| Assinatura sobreposta | `SignatureConfig` + reserva de espaço na última página |
| Timeout ao gerar em lote | `Promise.allSettled` por página + compressão jsPDF |
| Nome errado no arquivo gerado em lote | Encapsulamento do contexto por documento |
| Layout diferente por marca | `DocumentConfig` fortemente tipada, uma config por documento |
| Dificuldade de criar novos documentos | Contrato `DocumentEntry` — dev só descreve o quê |
| Debugging impossível em produção | `DocumentDebugComponent` com overlay visual |
| Componentes não sabem se dividir | Contrato `Splittable` obrigatório para tabelas |

---

## 9. Arquivos relacionados

- `cards/EFC-6325/EFC-6325.md` — card Jira do document-builder
- `cards/EFC-6325/product.md` — documento de produto
- `cards/EFC-6325/tarefas.md` — tarefas de implementação
- `cards/EFC-6325/changelog.md` — log de alterações
