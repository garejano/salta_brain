# Skill: scan-frontend

## Objetivo

Escanear uma pasta de projeto Angular usando `ts-morph` e gerar um arquivo `angular-map.md` compacto que a IA pode carregar em vez de ler centenas de arquivos para entender a estrutura do projeto.

**Problema resolvido:** projetos Angular têm centenas de arquivos. Sem um mapa, a IA gasta contexto explorando a estrutura antes de poder ajudar. O mapa comprimido substitui essa exploração.

---

## Uso

```
/scan-frontend <caminho>       → escaneia o projeto Angular no caminho informado
/scan-frontend                 → escaneia o projeto Angular definido em CLAUDE.md do repo atual
```

---

## Onde os mapas ficam armazenados

Os mapas gerados ficam em `salta_brain/frontend-maps/`, nomeados por repositório:

```
frontend-maps/
  changelog.md                          ← registro de todos os scans (data + repositório)
  estrutura-pedagogica-angular-map.md   ← gerado pelo /scan-frontend
  notas-angular-map.md
  documentacao-pedagogica-angular-map.md
  ...
```

**Regra:** nunca salvar o `angular-map.md` dentro do repositório alvo — sempre em `frontend-maps/` do `salta_brain`.

---

## O que o script extrai

| Categoria | O que capturar |
|---|---|
| **Módulos** | Nome, declarations, imports, exports, providers |
| **Componentes** | Selector, inputs, outputs, services injetados, rota associada (se houver) |
| **Services** | `providedIn`, dependências injetadas, métodos públicos |
| **Rotas** | path → component, children, guards, resolvers |
| **NgRx** | Actions (por feature), Selectors, Effects, Reducers |
| **Interfaces/Models** | Interfaces e types exportados em `*.model.ts` / `*.interface.ts` |
| **HTTP** | Interceptors, base URLs encontradas em environments |

---

## Implementação — Script Node com ts-morph

### Localização

```
_scripts/scan-angular.mjs
```

### Dependências

```bash
npm install ts-morph   # ou pnpm/yarn — não precisa instalar no projeto alvo
```

### Lógica do script

```
scan-angular.mjs <projeto-path>
  │
  ├── 1. Inicializa ts-morph Project apontando para tsconfig.json do projeto alvo
  │
  ├── 2. Percorre source files em src/
  │     ├── @NgModule   → extrai declarations / imports / exports
  │     ├── @Component  → extrai selector, inputs, outputs, construtor (inject)
  │     ├── @Injectable → extrai providedIn, construtor (inject), métodos públicos
  │     ├── createAction / createReducer / createEffect / createSelector
  │     │     → agrupa por feature (nome do arquivo/pasta)
  │     ├── interface / type export → captura nome + campos principais
  │     └── app-routing.module.ts → monta árvore de rotas
  │
  └── 3. Grava frontend-maps/<repo-name>-angular-map.md no salta_brain
```

### Pseudocódigo core

```js
import { Project } from 'ts-morph';

const project = new Project({ tsConfigFilePath: `${targetPath}/tsconfig.json` });

for (const sourceFile of project.getSourceFiles()) {
  for (const cls of sourceFile.getClasses()) {
    const componentDecorator = cls.getDecorator('Component');
    if (componentDecorator) {
      const selector = getDecoratorProp(componentDecorator, 'selector');
      const inputs = cls.getProperties()
        .filter(p => p.getDecorator('Input'))
        .map(p => p.getName());
      // ... captura constructor params como services injetados
    }
  }
}
```

### Output: `frontend-maps/<repo>-angular-map.md`

```markdown
# Angular Map — <nome do projeto>
> Gerado em: <data>  
> Fonte: <caminho>

## Módulos
- **AppModule** → declara: [AppComponent, HeaderComponent] · importa: [RouterModule, HttpClientModule]
- **AlunosModule** → lazy-loaded em `/alunos` · declara: [ListaAlunosComponent, FichaAlunoComponent]

## Rotas
- `/` → HomeComponent
- `/alunos` → AlunosModule (lazy)
  - `/alunos/:id` → FichaAlunoComponent (guard: AuthGuard)

## Componentes
- **ListaAlunosComponent** `[lista-alunos]`
  - @Input: filtros: FiltroAluno
  - @Output: selecionado: EventEmitter<Aluno>
  - Injeta: AlunosService, Router

## Services
- **AlunosService** (root)
  - Injeta: HttpClient, AuthService
  - Métodos: getAlunos(filtro), getAluno(id), salvar(aluno)

## NgRx — feature: alunos
- Actions: loadAlunos, loadAlunosSuccess, loadAlunosFailure, selecionarAluno
- Selectors: selectAlunos, selectAlunoAtivo, selectLoading
- Effects: loadAlunos$ → AlunosService.getAlunos()

## Models
- **Aluno**: id, nome, matricula, turma, situacao
- **FiltroAluno**: turmaId?, situacao?, nomeContains?
```

---

## Como criar o skill/command no Claude Code

### Opção A — Custom Command (mais simples)

Criar `.claude/commands/scan-frontend.md` neste repositório (`salta_brain`) com instruções para a IA executar o script e pós-processar.

**Fluxo quando o usuário digita `/scan-frontend <path>`:**
1. Claude verifica se `_scripts/scan-angular.mjs` existe; se não, gera o script
2. Executa `node _scripts/scan-angular.mjs <path>` via Bash
3. O script grava `frontend-maps/<repo>-angular-map.md` no `salta_brain`
4. Claude atualiza `frontend-maps/changelog.md`
5. Claude atualiza a entrada do repositório em `repository_map.md` adicionando o campo `Frontend Map:`
6. Claude confirma e resume o que foi encontrado

### Opção B — Script standalone + command que o invoca (recomendada)

```
_scripts/
  scan-angular.mjs     ← lógica ts-morph (roda no terminal independente)

.claude/commands/
  scan-frontend.md     ← command que chama o script e faz os pós-processamentos
```

**Vantagem:** `node _scripts/scan-angular.mjs ../meu-projeto` funciona sem Claude Code aberto.

---

## Plano de implementação

### Fase 1 — Script básico (MVP)
- [ ] Instalar `ts-morph` em `_scripts/` (ou globalmente)
- [ ] Escrever `_scripts/scan-angular.mjs` que extrai **componentes e services**
- [ ] Validar output manual em um projeto Angular real (ex: `estrutura-pedagogica/frontend`)
- [ ] Ajustar formato do markdown para ser denso mas legível pela IA

### Fase 2 — Cobertura completa
- [ ] Adicionar extração de **rotas** (parsing de `Routes` array)
- [ ] Adicionar extração de **NgRx** (actions, selectors, effects)
- [ ] Adicionar **interfaces/models**

### Fase 3 — Command Claude Code + integração salta_brain
- [ ] Criar `.claude/commands/scan-frontend.md`
- [ ] Command deve: gravar em `frontend-maps/`, atualizar `changelog.md`, atualizar `repository_map.md`
- [ ] Testar com `/scan-frontend c:/projects/estrutura-pedagogica/frontend`
- [ ] Verificar que `repository_map.md` exibe campo `Frontend Map:` corretamente

---

## Comportamento pós-scan (responsabilidade do command)

Após o script Node gravar o mapa, o command deve executar os seguintes passos adicionais:

### 1. Atualizar `frontend-maps/changelog.md`

Adicionar ou atualizar a linha do repositório na tabela:

```markdown
| estrutura-pedagogica | 2026-05-20 | [angular-map](estrutura-pedagogica-angular-map.md) |
```

### 2. Atualizar `repository_map.md`

Adicionar ou atualizar o campo `**Frontend Map:**` na entrada do repositório:

```markdown
**Frontend Map:** [`frontend-maps/estrutura-pedagogica-angular-map.md`](frontend-maps/estrutura-pedagogica-angular-map.md) *(escaneado em: 2026-05-20)*
```

### 3. Exibir resumo

```
✔ Mapa gerado: frontend-maps/estrutura-pedagogica-angular-map.md
  Componentes: 34 · Services: 12 · Rotas: 8 · Models: 15
  changelog.md atualizado
  repository_map.md atualizado
```

---

## Como a IA deve usar o mapa

Quando o usuário pedir ajuda em um frontend Angular:

1. Verificar se existe `frontend-maps/<repo>-angular-map.md`
2. Verificar a data em `frontend-maps/changelog.md` — se o mapa tiver mais de 30 dias, sugerir reescan
3. Carregar o mapa antes de explorar arquivos individuais — evita gastar contexto em leitura de diretórios

---

---

## Alternativa Python — scan sem dependências externas

Quando Node.js não está disponível, ou para evitar instalar `ts-morph`, o scan pode ser feito com um script Python puro (stdlib only, zero `pip install`).

### Localização

```
_scripts/scan_angular.py
```

### Config compartilhada

Todos os scripts Python em `_scripts/` importam de `salta_config.py`:

```python
from salta_config import ANGULAR_FRONTENDS, FRONTEND_MAPS_DIR, STALE_SCAN_DAYS
```

`salta_config.py` centraliza:
- Caminhos base (`SALTA_BRAIN`, `PROJECTS_BASE`)
- Mapa de todos os frontends Angular conhecidos (`ANGULAR_FRONTENDS`)
- Configurações do scanner (`STALE_SCAN_DAYS`, `SCAN_IGNORE_DIRS`)

### Abordagem: regex sobre arquivos `.ts`

Python puro não tem um parser TypeScript, então o scanner usa **regex calibrado para padrões Angular**. É menos preciso que ts-morph (não entende imports circulares nem tipos genéricos), mas suficiente para gerar o mapa de contexto.

#### Padrões regex por categoria

```python
import re

PATTERNS = {
    # @Component({ selector: 'app-foo', ... })
    "component_selector": re.compile(
        r"@Component\s*\(\s*\{[^}]*?selector\s*:\s*['\"]([^'\"]+)['\"]", re.DOTALL
    ),
    # @Input() nome: Tipo  /  @Input('alias') nome: Tipo
    "input":   re.compile(r"@Input\s*\([^)]*\)\s*(\w+)\s*[!?]?\s*:\s*([\w<>\[\]|]+)"),
    # @Output() evento = new EventEmitter
    "output":  re.compile(r"@Output\s*\([^)]*\)\s*(\w+)"),
    # constructor(private svc: NomeService, ...)
    "inject":  re.compile(r"(?:private|protected|public|readonly)\s+(\w+)\s*:\s*(\w+Service|\w+Store|\w+Facade)"),
    # @Injectable({ providedIn: 'root' })
    "injectable_scope": re.compile(r"@Injectable\s*\(\s*\{[^}]*?providedIn\s*:\s*['\"]([^'\"]+)['\"]"),
    # public métodoPublico(  — captura métodos públicos de services
    "public_method":  re.compile(r"^\s*(?:public\s+)?(\w+)\s*\([^)]*\)\s*(?::\s*[\w<>]+)?\s*\{", re.MULTILINE),
    # createAction('[Feature] Nome da Action', ...)
    "ngrx_action":    re.compile(r"createAction\s*\(\s*['\"]([^'\"]+)['\"]"),
    # createSelector(...)  — pega o nome da variável
    "ngrx_selector":  re.compile(r"(?:export\s+const\s+)(\w+)\s*=\s*createSelector"),
    # createEffect(...)
    "ngrx_effect":    re.compile(r"(?:export\s+const\s+)(\w+\$)\s*=\s*createEffect"),
    # export interface NomeInterface {
    "interface":      re.compile(r"export\s+(?:interface|type)\s+(\w+)"),
    # { path: 'rota', component: ComponenteXyz }
    "route":          re.compile(r"\{\s*path\s*:\s*['\"]([^'\"]*)['\"][^}]*?(?:component\s*:\s*(\w+))?"),
    # environment.apiUrl / environment.baseUrl
    "env_url":        re.compile(r"(?:apiUrl|baseUrl|url)\s*:\s*['\"]([^'\"]+)['\"]"),
}
```

### Estrutura do script

```
scan_angular.py <repo-name-ou-path>
  │
  ├── 1. Resolve caminho via salta_config.ANGULAR_FRONTENDS ou argumento direto
  │
  ├── 2. Walk recursivo em src/ ignorando SCAN_IGNORE_DIRS
  │     └── Para cada .ts:
  │           ├── Detecta tipo pelo decorator (@Component / @Injectable / @NgModule)
  │           ├── Aplica PATTERNS correspondentes
  │           └── Acumula resultados em dict por categoria
  │
  ├── 3. Infere feature por caminho:
  │     ex: src/app/alunos/lista-alunos.component.ts → feature "alunos"
  │
  ├── 4. Renderiza angular-map.md (mesmo template do ts-morph)
  │
  ├── 5. Grava FRONTEND_MAPS_DIR/<repo>-angular-map.md
  │
  ├── 6. Atualiza FRONTEND_CHANGELOG (tabela markdown)
  │
  └── 7. Atualiza REPOSITORY_MAP adicionando campo "Frontend Map:"
```

### Como rodar

```bash
# Pelo nome configurado em salta_config.py
python _scripts/scan_angular.py estrutura-pedagogica

# Pelo caminho direto
python _scripts/scan_angular.py c:/projects/notas/frontend
```

### Python vs ts-morph — quando usar cada um

| Critério | Python (regex) | ts-morph (Node) |
|---|---|---|
| Dependências | Zero | Node.js + `npm install ts-morph` |
| Precisão | Boa para decorators, fraca para tipos genéricos complexos | Alta — usa AST real |
| Velocidade | Muito rápido | Moderado (carrega compilador TS) |
| Standalone | Sim — roda em qualquer máquina com Python | Requer ambiente Node |
| Recomendado para | Scans rápidos, CI, máquinas sem Node | Projetos com muitos generics / NgRx complexo |

**Regra prática:** usar Python para o dia a dia; ts-morph se o mapa gerado perder informações importantes.

---

## Referências

- [ts-morph docs](https://ts-morph.com/)
- Config compartilhada: `_scripts/salta_config.py`
- Dependências Python: `_scripts/requirements.txt`
- Padrão de commands deste repo: `.claude/commands/repo_map.md`
- Mapas gerados: `frontend-maps/`
- Changelog de scans: `frontend-maps/changelog.md`
