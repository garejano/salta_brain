# document-builder — Dores que o módulo se propõe a resolver

> Cruzamento entre `analise_documentacao_pedagogica.md` (chamados SP + bugs EFC, 2022–2026)
> e o que foi efetivamente implementado no `src/shared/document-builder/` (EFC-6325).

---

## 1. Ficha Individual saindo em 2 páginas

**Evidência nos chamados:**  
`SP-4227` "FICHA INDIVIDUAL SAINDO EM 02 PÁGINAS" · `EFC-4752` "[OTRS] FICHA INDIVIDUAL SAINDO EM 02 PÁGINAS (ECSA somente EFAI)"

**Causa raiz (legado):**  
O `gerador-documentos` não tinha motor de layout — cada documento implementava manualmente sua lógica de quebra de página via `limitePrimeiraPagina` / `limite` e uma função `divideEmPaginas()` customizada. Se o conteúdo variava (mais disciplinas, nome longo), a estimativa manual falhava.

**Solução implementada:**  
`LayoutEngineService.distribute()` — distribui componentes entre páginas A4 com base nas alturas medidas. Componentes que implementam `Splittable` (ex: `DocTableComponent`) são divididos automaticamente sem estimativa manual. O cálculo é determinístico: não há setTimeout, não há estimativa por número de linhas fixo.

**Arquivos:** `layout-engine.service.ts` · `layout.models.ts` (interface `Splittable`)

---

## 2. Assinatura sobreposta ao conteúdo

**Evidência nos chamados:**  
`EFC-4394` "Corrigir espaço entre a ultima informação e a assinatura na Ficha individual, Ata e Livro de matricula"  
`EFC-4669` "A assinatura da ficha individual está em sobreposição à tabela"

**Causa raiz (legado):**  
A assinatura era tratada como mais um componente de conteúdo. Não havia reserva de espaço garantida na última página.

**Solução implementada:**  
`SignatureConfig` na `DocumentConfig` + `LayoutEngine` reserva `DOC_SIGNATURE_HEIGHT` (120px) na última página (ou em todas, se `onAllPages: true`). A ordem da página foi fixada em DEV_004: `content → signature → footer` — assinatura sempre acima do rodapé, nunca sobreposta.

**Arquivos:** `document-config.ts` · `document-page.component.html` (DEV_004) · `layout-engine.service.ts`

---

## 3. Páginas em branco ao gerar PDF

**Evidência nos chamados:**  
Chamados de "boletim não disponível", "erro ao gerar boletim/ficha" — muitos relatados como página em branco ou arquivo corrompido.

**Causa raiz técnica identificada (DEV_007 + DEV_008):**  
Três causas independentes no pipeline `html-to-image`:
1. Pipeline SVG não carregava fontes externas no contexto clonado → canvas em branco
2. `pixelRatio: 4` × múltiplas páginas em paralelo → ~570MB de canvas → browser descartava silenciosamente
3. `cacheBust: true` impedia o aquecimento do cache entre renders

**Solução implementada:**  
- `Imprimir` → `window.print()` com `@media print` CSS — renderização nativa, zero risco de branco
- `Salvar PDF` → `html2canvas` — renderiza DOM diretamente em canvas, sem pipeline SVG
- `html-to-image` mantido como fallback com double-render e `pixelRatio: 2`
- Presets `PdfQuality`: `draft` / `standard` / `high` para override por documento

**Arquivos:** `print.service.ts` · `print-overlay.component.scss` · `document-viewer.component.scss` · `document-page.component.scss`

---

## 4. Timeout e lentidão ao gerar múltiplas páginas em lote

**Evidência nos chamados:**  
`EFC-5275` "🔥 Erro na exportação da Ficha Individual em lote" · `SP-5272` "ERRO NO NOME DO ALUNO AO GERAR A FICHA INDIVIDUAL" (geração em lote)

**Causa raiz (legado):**  
Loop sequencial `for...of` para converter páginas — cada página aguardava a anterior. Sem compressão. Sem tratamento de erro por página.

**Solução implementada:**  
`PrintService` (TAREFA 05):
- `Promise.allSettled` — todas as páginas são convertidas para PNG em paralelo
- Erro em uma página loga `[PrintService] failed to render page N:` e filtra, sem interromper o PDF
- `compress: true` no jsPDF — PDF menor sem perda de qualidade

**Arquivos:** `print.service.ts`

---

## 5. Arquivo PDF com nome errado ao gerar em lote

**Evidência nos chamados:**  
`SP-5272` "ERRO NO NOME DO ALUNO AO GERAR A FICHA INDIVIDUAL — ao gerar em lote, todos os arquivos recebiam o nome da primeira aluna da turma"

**Causa raiz (legado):**  
Contexto de nome compartilhado entre documentos no loop de geração.

**Solução implementada:**  
Cada `DocumentSample` é um objeto independente com `fileName` próprio. `DEV_015` (múltiplos documentos em 1 PDF) encapsula cada documento como unidade isolada — o contexto de um não vaza para o outro.

**Arquivos:** `documents.component.ts` (`DocumentDefinition.fileName`)

---

## 6. Componentes de tabela não sabem se dividir entre páginas

**Evidência nos chamados:**  
`SP-6664` "Ficha individual e Ata de resultados finais — Lucas Bellizzi..." (tabelas incompletas)  
`EFC-4263` "Diário de Classe — Aluno cancelado ainda em 2023 aparece no documento 2024"

**Causa raiz (legado):**  
O `gerador-documentos` implementava `split` manualmente por documento, sem contrato formal. Cada documento precisava reinventar a lógica de "quantas linhas cabem na página".

**Solução implementada:**  
Interface `Splittable` com contrato obrigatório:
```typescript
getRowsThatFit(availableHeight: number): number
split(rowCount: number): SplitResult
getRowHeight(): number
```
`DocTableComponent` implementa `Splittable` com `getRowHeight()` calculado via Pretext (sem DOM). Fix DEV_009 corrigiu `getRowsThatFit` para subtrair `DOC_TABLE_HEADER_HEIGHT` antes de calcular. `DocWideTableComponent` (DEV_017) adiciona quebra de colunas para tabelas largas (ex: lista de presença mensal com 31 dias).

**Arquivos:** `layout.models.ts` · `doc-table.component.ts` · `doc-wide-table.component.ts`

---

## 7. setTimeout frágil no pipeline de layout (causa raiz de instabilidade)

**Evidência nos cards EFC:**  
Descrito no próprio EFC-6325 como problema estrutural do `gerador-documentos` — a fase de medição dependia de delays não-determinísticos para aguardar o DOM.

**Causa raiz (legado):**  
`setTimeout` arbitrário para aguardar renderização do DOM antes de medir alturas — frágil em máquinas lentas, em documentos longos ou quando fontes carregavam tarde.

**Solução implementada:**  
Pipeline de 3 fases determinístico no `DocumentViewerComponent.init()`:
1. `await document.fonts.ready` — garante fontes carregadas antes de qualquer medição
2. Medição via Pretext (aritmética pura, sem DOM) para componentes `TextMeasurable`
3. DOM usado apenas como fallback via fake page (`transform: scale(0)`)

Nenhum `setTimeout` no pipeline de layout.

**Arquivos:** `document-viewer.component.ts` · `measurement.service.ts`

---

## 8. Impossibilidade de debugar layout em produção

**Evidência nos cards EFC:**  
Descrito no EFC-6325 como limitação do legado — impossível inspecionar distribuição de componentes por página sem `console.log`.

**Solução implementada:**  
`DocumentDebugComponent` — sidebar fixa ativada via `config.debug: true` (ou parâmetro de URL). Exibe por página:
- Espaço total / usado / livre (em px)
- Flags `[H]` header · `[F]` footer · `[A]` assinatura
- Por componente: nome, altura, `[S]` Splittable, `[T]` TextMeasurable (medido sem DOM)
- `@media print { display: none }` — some no PDF

**Arquivos:** `document-debug.component.ts`

---

## 9. Alto custo para criar um novo documento

**Evidência nos cards EFC:**  
`EFC-4856` Innopeda no Boletim (Aberta) · `EFC-4855` Progressão Parcial (Aberta) · `EFC-4853` Revisão do Boletim do EM (Aberta) · `EFC-4937` Assinatura Digital (Aberta) — múltiplas features de documento acumuladas como pendentes.

**Causa raiz (legado):**  
Criar um novo documento exigia reimplementar: controle de páginas, split de componentes, medição de alturas, pipeline de print. Desenvolvedor precisava conhecer toda a infra.

**Solução implementada:**  
API declarativa `DocumentEntry[]` (DEV_002 + DEV_006):
```typescript
entries: DocumentEntry[] = [
  { data: this.grades,      componentType: GradeTableComponent },
  { data: this.disciplines, componentType: DisciplineTableComponent },
]
```
O desenvolvedor descreve **o quê** — o `DocumentViewer` decide **o onde**. Nenhuma lógica de layout no componente do documento. Interface `DocumentDefinition { config, headerData, entries }` padroniza a estrutura de qualquer documento.

**Arquivos:** `document-viewer.component.ts` · `documents.component.ts`

---

## 10. Layout diferente por marca / dificuldade de configurar

**Evidência nos chamados:**  
Múltiplos chamados específicos por marca: "Boletim Ábaco", "Boletim Pensi", "Elite DF", "Coleguium" — bugs que afetavam só uma marca por acoplamento de configuração no template.

**Causa raiz (legado):**  
Configurações de marca espalhadas por flags booleanas no código, sem tipagem ou contrato.

**Solução implementada:**  
`DocumentConfig` fortemente tipada com `orientation`, `header`, `footer`, `signature`, `frame`, `debug`, `componentGap`, `pdfQuality`, `printStrategy`. Uma config por documento, declarada em TypeScript, validada em tempo de compilação. `HeaderConfig.onAllPages` (DEV_011) permite cabeçalho só na primeira página — economiza espaço em documentos longos.

**Arquivos:** `document-config.ts`

---

## 11. Tabelas muito largas ultrapassam a página

**Evidência nos chamados:**  
`SP-6777` "Investigar ausência de faltas no boletim do Núcleo Anglo" — problema de colunas de faltas.  
`EFC-5771` "BOLETIM ÁBACO - COLUNAS DE FALTAS ZERADA"

**Causa raiz (legado):**  
Não havia mecanismo para quebrar colunas — tabelas com muitas colunas (lista de presença mensal, boletim com muitas disciplinas) simplesmente ultrapassavam a margem da página.

**Solução implementada:**  
`DocWideTableComponent` (DEV_017) com interface `ColumnSplittable`:
- Divide colunas em grupos que cabem na largura da página
- Cada grupo pode ainda implementar `Splittable` (quebra por linhas)
- `fixedColumns` — colunas como Nº/RA/Nome repetidas em todos os grupos
- Suporte a `columnWidths[]` para larguras explícitas por coluna

**Arquivos:** `doc-wide-table.component.ts` · `layout.models.ts` (`ColumnSplittable`)

---

## 12. Múltiplos documentos em um único PDF

**Evidência nos chamados:**  
Múltiplos SP de "Ata de Resultados Finais" geradas por turma — usuário precisava gerar e juntar manualmente.

**Solução implementada (DEV_015):**  
`DocumentViewerComponent` e `PrintOverlayComponent` suportam array de `DocumentDefinition[]`. O `PrintService` gera um único PDF com todos os documentos concatenados. Compatível com o modo de documento único existente.

---

## 13. Economia de papel — minimizar páginas

**Evidência nos chamados:**  
`EFC-4868` "Migrar dados do lançamento de frequência — economizar folhas" · vários chamados de configuração de boletim pedindo ajustes de layout para caber em menos páginas.

**Solução implementada (DEV_018 — planejada/concluída):**  
Feature "Minimizar páginas" — reduz iterativamente `gap`, `fontSize`, margens e `cellPadding` até atingir o menor número de páginas possível. Exibe loading com feedback visual do que está sendo tentado.

---

## Resumo: dores mapeadas × status de resolução

| Dor | Origem | Status no document-builder |
|---|---|---|
| Ficha saindo em 2 páginas | SP-4227, EFC-4752 | ✅ Resolvida — LayoutEngine + Splittable |
| Assinatura sobreposta | EFC-4394, EFC-4669 | ✅ Resolvida — SignatureConfig + DEV_004 |
| Páginas em branco no PDF | múltiplos SP | ✅ Resolvida — DEV_007 + DEV_008 (html2canvas + css print) |
| Lentidão / timeout em lote | EFC-5275 | ✅ Resolvida — Promise.allSettled + compress |
| Nome errado em PDF de lote | SP-5272 | ✅ Resolvida — DocumentDefinition isolada por documento |
| Tabelas não sabem se dividir | estrutural legado | ✅ Resolvida — Splittable + DocTableComponent + DEV_009 |
| setTimeout frágil no layout | EFC-6325 (legado) | ✅ Resolvida — document.fonts.ready + Pretext |
| Impossível debugar layout | EFC-6325 (legado) | ✅ Resolvida — DocumentDebugComponent |
| Alto custo para criar documento | backlog EFC acumulado | ✅ Resolvida — API DocumentEntry[] declarativa |
| Layout acoplado por marca | múltiplos bugs por marca | ✅ Resolvida — DocumentConfig tipada |
| Tabelas largas ultrapassam página | EFC-5771, SP-6777 | ✅ Resolvida — DocWideTableComponent (DEV_017) |
| Múltiplos docs em 1 PDF | fluxo de geração por turma | ✅ Resolvida — DEV_015 |
| Excesso de páginas / economia de papel | pedidos recorrentes | ✅ Resolvida — DEV_018 "Minimizar páginas" |
| Dados incorretos (nota, frequência) | SP-boletim / SP-ata (alto volume) | ⚠️ **Fora do escopo** — problema de dados/backend, não de geração |
| Alunos em situações especiais (NEE, transferido) | EFC-4473, SP-5293 | ⚠️ **Fora do escopo** — problema de query/regra de negócio |
| Configuração complexa por marca/rede | múltiplos EFC | 🔄 Parcial — config tipada melhora, mas regras de cálculo são do domínio |

---

## O que o document-builder NÃO resolve

O document-builder é um **motor de geração visual** — ele resolve como o documento é paginado, renderizado e exportado. Ele **não resolve**:

- **Dados incorretos** — notas erradas, frequência errada, alunos faltando na ata. Esses problemas estão no backend (cálculo de boletim, queries de ata) e continuarão existindo independente do motor de geração.
- **Lógica de negócio por marca** — regras de cálculo de média, critérios de aprovação, configuração de avaliações. São responsabilidade do domínio de avaliação.
- **Documentos existentes** — Ficha Individual, Ata e Boletim continuam no `gerador-documentos` até serem migrados. O document-builder é o destino da migração, não o substituto imediato.
