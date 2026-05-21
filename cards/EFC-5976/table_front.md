# Tabela do Frontend — Configurador de Avaliações (CF Anual)

## Contexto

Captura da tabela exibida no frontend do Configurador de Avaliações com o filtro abaixo. A tabela apresentava **mais colunas de dados do que cabeçalhos visíveis** — o problema foi investigado, a causa raiz identificada e a correção aplicada. Ver análise completa em `analise_table_front.md`.

---

## Filtro aplicado

| Campo | Valor |
|---|---|
| Rede | Nosso CEI |
| Ano Letivo | 2026 |
| Agrupamento | 1ª série do EM |
| Escopo | Componente Formativo — Anual |

---

## Tabela capturada (estado com bug — código antigo)

O cabeçalho visível mostrava apenas 5 colunas sob o grupo **1º Trimestre**, mas cada linha de disciplina exibia ~16 valores. As colunas extras vinham de auto-colunas do boletim regular (Média/Faltas/Situação dos 3 trimestres + Média Anual + Situação) injetadas pelo OR clause no `FiltroManager.GetEstrutura`.

| Componente Curricular | ATF1 (10) | AP1 (10) | *[+ 11 colunas extras do boletim regular]* | Faltas | MT1 (10) | MTF1 (10) | Situação |
|---|---|---|---|---|---|---|---|
| Academic English II | 10 | 10 | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| As grandes guerras da história | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| As grandes guerras da história II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Biologia Aplicada | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Ciência Forense | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Ciência Forense II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Ciências e Análises Clínicas e Lab. | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Ciências e análises clínicas e laboratoriais II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Debates Competitivos | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Direito, Justiça e Cidadania | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Direito, Justiça e Cidadania II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Educação Financeira | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Educação Financeira II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Eletiva EAI | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Eletiva EAI II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Física Aplicada | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| História de gente pouco importante? [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| História de gente pouco importante? [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Inteligência Artificial: [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Inteligência Artificial: [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Introdução à computação: [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Introdução à computação: [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Literature in English: [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Literature in English: [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| LitToc: clube de leituras do CEI | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| LitToc: clube de leituras do CEI II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Matemática Aplicada | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Matemática Básica | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Matemática Básica II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Oficina de Produção Textual | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Oratória e criatividade | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Oratória e criatividade II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Pensamento computacional aplicado: [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Pensamento computacional aplicado: [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Política, pra quê? [...] | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Política, pra quê? [...] II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Química Aplicada | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Tecnologias Aplicadas às Ciências Médicas | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |
| Tecnologias Aplicadas às Ciências Médicas II | - | - | 20 / F / 20 / 10 / F / 10 / 10 / F / 10 / 10 / 10 | F | 10 | 10 | N/A |

> **Nota:** A coluna `[+ 11 colunas extras do boletim regular]` representa as colunas indevidas: Média/Faltas/MédiaRec do 1T, 2T e 3T do boletim regular + Média Anual. Estas não deveriam aparecer no escopo CF Anual.

---

## Tabela esperada após a correção (5 colunas — CF Anual)

Grupo: **1º Trimestre**

| Componente Curricular | ATF1 (max 10) | AP1 (max 10) | Faltas | MT1 / Média (max 10) | MTF1 / Média Rec (max 10) |
|---|---|---|---|---|---|
| Academic English II | 10 | 10 | F | 10 | 10 |
| As grandes guerras da história | - | - | F | 10 | 10 |
| *(demais disciplinas)* | - | - | F | 10 | 10 |

> **Legenda:** `-` = disciplina não participa dessa avaliação; `F` = coluna de Faltas; valores numéricos = NotaMaxima configurada.

---

## Colunas do banco para CF Anual (ItinerarioFormativoCiclo = 1)

| Id | Ordem | Sigla | NotaMax | Ciclo | Etapa |
|----|-------|-------|---------|-------|-------|
| 694806 | 1 | ATF1 | 10 | Ciclo 1 | 1º Trimestre |
| 694805 | 2 | AP1 | 10 | Ciclo 1 | 1º Trimestre |
| 694815 | 81 | Faltas | 0 | Faltas do 1º Trimestre | 1º Trimestre |
| 694831 | 92 | Média (MT1) | 10 | Média do 1º Trimestre | 1º Trimestre |
| 694844 | 92 | Média (MTF1) | 10 | Média Recuperada do 1º Trimestre | 1º Trimestre |







#### Teste 2

como pode ver, nesse filtro, nao veio dados, algo foi implementado errado. 

filtro:

Rede: Nosso CEI
Ano Letivo: 2026
Agrupamento: 1ª série do EM
Escopo: Componente Formativo — Anual
dados da tabela:


	1º Trimestre
Componentes
Curriculares	
 ATF1 
10
 AP1 
10
 Faltas 
 
 MT1 
10
 MTF1 
10
    Academic English II	
-
-
-
    As grandes guerras da história	
-
-
-
    As grandes guerras da história II	
-
-
-
    Biologia Aplicada	
-
-
-
    Ciência Forense	
-
-
-
    Ciência Forense II	
-
-
-
    Ciências e Análises Clínicas e Lab.	
-
-
-
    Ciências e análises clínicas e laboratoriais II	
-
-
-
    Debates Competitivos	
-
-
-
    Direito, Justiça e Cidadania	
-
-
-
    Direito, Justiça e Cidadania II	
-
-
-
    Educação Financeira	
-
-
-
    Educação Financeira II	
-
-
-
    Eletiva EAI	
-
-
-
    Eletiva EAI II	
-
-
-
    Física Aplicada	
-
-
-
    História de gente pouco importante? Uma reflexão histórica vista de baixo	
-
-
-
    História de gente pouco importante? Uma reflexão histórica vista de baixo II	
-
-
-
    Inteligência Artificial: fundamentos e práticas para a resolução de problemas	
-
-
-
    Inteligência Artificial: fundamentos e práticas para a resolução de problemas II	
-
-
-
    Introdução à computação: conceitos e práticas	
-
-
-
    Introdução à computação: conceitos e práticas II	
-
-
-
    Literature in English: Stories That Bring Us Together	
-
-
-
    Literature in English: Stories That Bring Us Together II	
-
-
-
    LitToc: clube de leituras do CEI	
-
-
-
    LitToc: clube de leituras do CEI II	
-
-
-
    Matemática Aplicada	
-
-
-
    Matemática Básica	
-
-
-
    Matemática Básica II	
-
-
-
    Oficina de Produção Textual	
-
-
-
    Oratória e criatividade	
-
-
-
    Oratória e criatividade II	
-
-
-
    Pensamento computacional aplicado: do inglês técnico a noções de programação	
-
-
-
    Pensamento computacional aplicado: do inglês técnico a noções de programação II	
-
-
-
    Política, pra quê? Entendendo os fundamentos	
-
-
-
    Política, pra quê? Entendendo os fundamentos II	
-
-
-
    Química Aplicada	
-
-
-
    Tecnologias Aplicadas às Ciências Médicas	
-
-
-
    Tecnologias Aplicadas às Ciências Médicas II	
-
-
-



 ### Teste 3

- refine esse documento para deixar visualmente OK, a tabela tbm

## Filtro aplicado

| Campo | Valor |
|---|---|
| Rede | Nosso CEI |
| Ano Letivo | 2026 |
| Agrupamento | 1ª série do EM |
| Escopo | Componente Formativo — Anual |



Agora o numero de dados se encaixa na quantidade de colunas, mas o "F" de falta nao esta na coluna correta.
os valores da celulas devem estar alinhados com as colunas
ponto importante eh que no filtro de BOletim Regular, isso esta correto



	1º Trimestre
Componentes
Curriculares	
 ATF1 
10
 AP1 
10
 Faltas 
 
 MT1 
10
 MTF1 
10
    Academic English II	
10
10
F
10
10
-
    As grandes guerras da história I	
F
10
10
-
-
-
    As grandes guerras da história II	
F
10
10
-
-
-
    Biologia Aplicada	
F
10
10
-
-
-
    Ciência Forense I	
F
10
10
-
-
-
    Ciência Forense II	
F
10
10
-
-
-
    Ciências e Análises Clínicas e Lab. I	
F
10
10
-
-
-
    Ciências e Análises Clínicas e Lab. II	
F
10
10
-
-
-
    Debates Competitivos	
F
10
10
-
-
-
    Direito, Justiça e Cidadania I	
F
10
10
-
-
-
    Direito, Justiça e Cidadania II	
F
10
10
-
-
-
    Educação Financeira I	
F
10
10
-
-
-
    Educação Financeira II	
F
10
10
-
-
-
    Eletiva EAI I	
F
10
10
-
-
-
    Eletiva EAI II	
F
10
10
-
-
-
    Física Aplicada	
F
10
10
-
-
-
    História de gente pouco importante? Uma reflexão histórica vista de baixo I	
F
10
10
-
-
-
    História de gente pouco importante? Uma reflexão histórica vista de baixo II	
F
10
10
-
-
-
    Inteligência Artificial: fundamentos e práticas para a resolução de problemas I	
F
10
10
-
-
-
    Inteligência Artificial: fundamentos e práticas para a resolução de problemas II	
F
10
10
-
-
-
    Introdução à computação: conceitos e práticas I	
F
10
10
-
-
-
    Introdução à computação: conceitos e práticas II	
F
10
10
-
-
-
    Literature in English: Stories That Bring Us Together I	
F
10
10
-
-
-
    Literature in English: Stories That Bring Us Together II	
F
10
10
-
-
-
    LitToc: clube de leituras do CEI I	
F
10
10
-
-
-
    LitToc: clube de leituras do CEI II	
F
10
10
-
-
-
    Matemática Aplicada	
F
10
10
-
-
-
    Matemática Básica I	
F
10
10
-
-
-
    Matemática Básica II	
F
10
10
-
-
-
    Oficina de Produção Textual	
F
10
10
-
-
-
    Oratória e criatividade I	
F
10
10
-
-
-
    Oratória e criatividade II	
F
10
10
-
-
-
    Pensamento computacional aplicado: do inglês técnico a noções de programação I	
F
10
10
-
-
-
    Pensamento computacional aplicado: do inglês técnico a noções de programação II	
F
10
10
-
-
-
    Política, pra quê? Entendendo os fundamentos I	
F
10
10
-
-
-
    Política, pra quê? Entendendo os fundamentos II	
F
10
10
-
-
-
    Química Aplicada	
F
10
10
-
-
-
    Tecnologias Aplicadas às Ciências Médicas I	
F
10
10
-
-
-
    Tecnologias Aplicadas às Ciências Médicas II	
F
10
10
-
-
-
