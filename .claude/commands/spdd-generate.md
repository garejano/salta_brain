# Skill: spdd-generate

## Descrição

Executa **uma operação específica** do bloco `O — Operations` de um REASONS Canvas (`EFC-xxxx.spdd-canvas.md`) no código real do repositório alvo. Segue estritamente as Norms e Safeguards do Canvas — nenhuma improvisação, nenhuma feature além do que está descrito. Após a execução, marca a operação como concluída no Canvas.

---

## Uso

```
/spdd-generate EFC-1234          → executa a próxima operação pendente
/spdd-generate EFC-1234 3        → executa a Operação 3 especificamente
/spdd-generate EFC-1234 criar-repositorio  → executa pelo nome
```

---

## Processo

### 1. Verificar pré-requisitos

Verificar se `cards/EFC-{NUMERO}/EFC-{NUMERO}.spdd-canvas.md` existe.

- **Não existe** → informar que o Canvas não foi gerado e sugerir `/spdd-refine EFC-{N}` ou `/spdd-canvas EFC-{N}`. Encerrar.
- **Existe** → ler o arquivo integralmente.

---

### 2. Localizar o repositório alvo

No cabeçalho do Canvas, ler o campo `**Repositório:**`. Confirmar que o caminho `c:/projects/<repositório>` existe.

- **Não existe** → informar e encerrar.

---

### 3. Identificar a operação a executar

**Se `[operacao]` foi fornecido:**
- Buscar no bloco `## O — Operations` a operação com o número ou nome correspondente.
  - Número: `### Operação 3 —` → operação 3
  - Nome parcial: busca case-insensitive no título da operação
- Se não encontrada: informar quais operações existem e encerrar.

**Se `[operacao]` não foi fornecido:**
- Listar todas as operações do Canvas na ordem em que aparecem.
- Selecionar a primeira que **não** contém `**Status:** ✅ concluída`.
- Se todas estão concluídas: informar e exibir resumo das operações.

---

### 4. Apresentar a operação e confirmar

Antes de tocar qualquer código, exibir um resumo claro:

```
Operação X — <título>

Arquivos:
  [criar]    c:/projects/<repo>/path/to/file.cs
  [modificar] c:/projects/<repo>/path/to/other.cs
  [remover]   c:/projects/<repo>/path/to/old.cs

Critério de conclusão:
  <texto do critério>

Confirmar execução? (responda "sim" para prosseguir)
```

Aguardar confirmação explícita antes de prosseguir.

---

### 5. Ler contexto necessário

Antes de gerar código, ler os arquivos que a operação indica como dependência ou referência:

- Arquivos a **modificar**: ler o conteúdo atual completo.
- Arquivos a **remover**: verificar se existem e se outros arquivos os referenciam.
- Arquivos vizinhos mencionados na operação: ler para entender padrão existente.

Se a operação menciona entidades, interfaces ou serviços existentes: localizá-los e lê-los para garantir consistência de naming e assinaturas.

---

### 6. Executar a operação

Implementar exatamente o que a operação descreve:

- **Criar arquivo:** gerar o arquivo com o código especificado no Canvas, respeitando o padrão dos arquivos vizinhos lidos no passo 5.
- **Modificar arquivo:** aplicar as mudanças descritas — nada mais, nada menos.
- **Remover arquivo:** verificar que não há mais referências ao arquivo no projeto antes de remover.

**Regras invioláveis durante a execução:**

- Seguir todas as **Norms** da seção `N — Norms` do Canvas.
- Não violar nenhum **Safeguard** da seção `S — Safeguards`.
- Não adicionar nenhuma feature, refatoração ou melhoria não descrita na operação.
- Se o Canvas mostra um trecho `// antes` / `// depois`: seguir exatamente a estrutura do `depois`.
- Se houver ambiguidade entre o Canvas e o código existente: **pausar**, apresentar a ambiguidade ao usuário e aguardar decisão. Não improvisar.

---

### 7. Verificar o critério de conclusão

Após criar/modificar os arquivos, verificar o **Critério de conclusão** da operação:

- Se o critério é "compila sem erros": verificar se há erros de sintaxe óbvios nos arquivos gerados.
- Se o critério menciona ausência de referências a um símbolo removido: fazer grep no repositório para confirmar.
- Se o critério é sobre comportamento de teste ou query: documentar que o critério precisa ser verificado manualmente e instruir o usuário.

Reportar o resultado da verificação ao usuário.

---

### 8. Marcar operação como concluída no Canvas

Após execução bem-sucedida, atualizar `cards/EFC-{N}/EFC-{N}.spdd-canvas.md`:

Localizar o heading da operação executada e adicionar a linha de status logo após o heading:

```markdown
### Operação X — <título>

**Status:** ✅ concluída — <data>
```

Também atualizar o Histórico de Atualizações no rodapé do Canvas:

```markdown
| <data> | v<atual+0.1> | Operação X concluída | execução via /spdd-generate |
```

---

### 9. Resumo e próximo passo

Ao final, exibir:

```
✅ Operação X concluída — <título>

Arquivos alterados:
  [criado]    c:/projects/<repo>/path/to/file.cs
  [modificado] c:/projects/<repo>/path/to/other.cs

Canvas atualizado: EFC-{N}.spdd-canvas.md

Próxima operação pendente:
  Operação Y — <título>
  Execute: /spdd-generate EFC-{N} Y
```

Se era a última operação do Canvas:

```
✅ Operação X concluída — <título> (última)

Todas as operações do Canvas foram executadas.
Próximos passos sugeridos:
  → Rodar os testes do repositório
  → /spdd-review EFC-{N}   (se disponível)
  → Abrir PR com as mudanças
```

---

## Tratamento de Situações Especiais

### Operação de remoção de arquivo

Antes de remover qualquer arquivo:
1. Fazer grep no repositório por referências ao arquivo (nome da classe, namespace, interface).
2. Se houver referências: **não remover** — listar os arquivos que ainda referenciam e informar o usuário.
3. Só remover após confirmação de que todas as referências foram tratadas.

### Operação de script SQL

Scripts SQL em `scripts-db-pedagogico` não são aplicados automaticamente. Ao criar/alterar um script SQL:
1. Criar o arquivo conforme descrito.
2. Informar explicitamente: *"Script criado em `<path>`. Deve ser executado manualmente em staging antes do deploy do código C#."*
3. Não prosseguir para operações de código C# dependentes sem confirmar que o usuário está ciente.

### Operação de "verificar"

Quando a operação é descrita como "verificar" (sem mudança esperada):
1. Ler os arquivos indicados.
2. Verificar se há referências ao símbolo/padrão mencionado.
3. Reportar: "sem alteração necessária" ou listar o que precisa ser ajustado.
4. Se ajuste for necessário: tratar como uma sub-operação de modificação e confirmar com o usuário.

---

## O que **não** fazer

- Não executar múltiplas operações em uma única invocação — uma operação por vez.
- Não prosseguir sem confirmação explícita do usuário (passo 4).
- Não improvisar código além do descrito na operação — nem refatorações "óbvias".
- Não marcar operação como concluída se o critério de conclusão não foi verificado.
- Não ignorar Safeguards mesmo que o código "funcione" sem eles.
- Não aplicar scripts SQL automaticamente — sempre delegar ao usuário.
- Não alterar as seções R, E, A, S, N, S do Canvas durante a execução — apenas a seção O (status das operações) e o Histórico.
