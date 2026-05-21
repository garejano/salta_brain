# Plano: Migração do Builder Angular (browser → application)

> **Status: Executado em 2026-05-21**  
> Desvios encontrados na execução estão documentados na seção **Resultado da Execução** ao final.



**Projeto:** `c:\projects\estrutura-pedagogica\frontend`
**Objetivo:** Substituir o builder legado baseado em Webpack (`@angular-devkit/build-angular:browser`) pelo builder novo baseado em esbuild (`@angular/build:application`) para habilitar HMR real e rebuilds mais rápidos.
**Contexto:** Este plano é autossuficiente — não depende de conversas anteriores.

---

## O que muda e por quê

| Aspecto | Antes (browser) | Depois (application) |
|---|---|---|
| Engine de build | Webpack | esbuild |
| HMR | Instável, falha após 1ª mudança | Nativo e estável |
| Rebuild incremental | ~5–15s | ~300ms–1s |
| SSR/prerender | Não suportado | Opcional (não usar aqui) |

---

## Cobertura dos scripts existentes

O plano **cobre todos os scripts** do `package.json`:

| Script | Comando | Coberto? | Observação |
|---|---|---|---|
| `dev:hot` | `ng serve --configuration=hot` | Sim | HMR passa a funcionar de verdade |
| `dev` | `ng build ... --watch` | Sim | Funciona sem alteração no script |
| `build` | `ng build` | Sim | Requer ajuste no `outputPath` das options padrão |
| `prod` | `ng build --configuration=production --output-path ...\wwwroot` | Sim* | Script precisa de ajuste — ver Passo 4 |
| `homolog` | `ng build --configuration=homolog ...` | Sim* | Além do ajuste de outputPath, há um bug: a configuração se chama `homologation` no angular.json mas o script passa `--configuration=homolog` — será corrigido aqui |
| `build-aws` | `ng build --output-path dist` | Sim* | Requer ajuste de script — ver Passo 4 |
| `test` | `ng test` | Não alterado | Usa o builder Karma, permanece igual |
| `lint` | `ng lint` | Não alterado | Sem relação com o builder |

> **Nota importante sobre `outputPath`:** No builder `browser`, `--output-path <caminho>` coloca os arquivos diretamente no caminho. No builder `application`, o mesmo flag coloca os arquivos em `<caminho>/browser/` por padrão. Para manter o comportamento atual (arquivos diretamente no destino), os scripts e/ou o `angular.json` precisam usar o formato `{ "base": "...", "browser": "" }`.

---

## Pré-requisitos

Verificar antes de executar:

```powershell
# Dentro de c:\projects\estrutura-pedagogica\frontend

# 1. Verificar se @angular/build já está instalado
cat node_modules/@angular/build/package.json | Select-String '"version"' -First 1

# 2. Versão do Angular CLI
npx ng version
```

Se `@angular/build` não estiver instalado:
```powershell
npm install --save-dev @angular/build
```

> Para Angular 20, o `@angular/build` geralmente já vem como dependência transitiva de `@angular-devkit/build-angular`. Se já estiver instalado, apenas a mudança nos builders do `angular.json` é suficiente.

---

## Passo 1 — Trocar os builders no `angular.json`

**Arquivo:** `frontend/angular.json`

Fazer três substituições:

### 1a. Build builder
```json
// DE:
"builder": "@angular-devkit/build-angular:browser",

// PARA:
"builder": "@angular/build:application",
```

### 1b. Serve builder
```json
// DE:
"builder": "@angular-devkit/build-angular:dev-server",

// PARA:
"builder": "@angular/build:dev-server",
```

### 1c. Extract-i18n builder (se existir)
```json
// DE:
"builder": "@angular-devkit/build-angular:extract-i18n",

// PARA:
"builder": "@angular/build:extract-i18n",
```

---

## Passo 2 — Atualizar `architect.build.options` (opções padrão)

O estado atual das `options` padrão (linha ~20 do `angular.json`):
```json
"options": {
  "outputPath": "../backend/EstruturaPedagogica.Api/wwwroot",
  "index": "src/index.html",
  "main": "src/main.ts",
  "polyfills": "src/polyfills.ts",
  "tsConfig": "tsconfig.app.json",
  "inlineStyleLanguage": "scss",
  "assets": [ "src/favicon.ico", "src/assets" ],
  "styles": [ "src/styles/global.scss", "node_modules/ngx-toastr/toastr.css", "src/shared/components/toastr-eleva/toastr-eleva.component.css" ],
  "scripts": [],
  "vendorChunk": true,       ← REMOVER (não existe no application builder)
  "extractLicenses": false,  ← REMOVER (não existe no application builder)
  "buildOptimizer": false,   ← REMOVER (não existe no application builder)
  "sourceMap": true,
  "optimization": false,
  "namedChunks": true        ← REMOVER (não existe no application builder)
}
```

O novo estado deve ser:
```json
"options": {
  "outputPath": {
    "base": "../backend/EstruturaPedagogica.Api/wwwroot",
    "browser": ""
  },
  "index": "src/index.html",
  "browser": "src/main.ts",
  "polyfills": ["src/polyfills.ts"],
  "tsConfig": "tsconfig.app.json",
  "inlineStyleLanguage": "scss",
  "assets": [ "src/favicon.ico", "src/assets" ],
  "styles": [
    "src/styles/global.scss",
    "node_modules/ngx-toastr/toastr.css",
    "src/shared/components/toastr-eleva/toastr-eleva.component.css"
  ],
  "scripts": [],
  "sourceMap": true,
  "optimization": false
}
```

Mudanças:
- `outputPath`: string → objeto `{ base, browser: "" }` (sem isso arquivos iriam para `wwwroot/browser/`)
- `main` → renomear para `browser` (novo nome no application builder)
- `polyfills`: string → array (formato correto para o novo builder)
- Removidos: `vendorChunk`, `extractLicenses`, `buildOptimizer`, `namedChunks`

---

## Passo 3 — Limpar flags obsoletas nas configurações

As configurações `production`, `homologation` e `development` têm flags que não existem no application builder:

**Remover de todas as configurações onde aparecerem:**
- `"vendorChunk": false` / `"vendorChunk": true`
- `"buildOptimizer": true` / `"buildOptimizer": false`
- `"namedChunks": false` / `"namedChunks": true`
- `"extractLicenses": true` / `"extractLicenses": false`

> `outputPath` nas configurações `production` e `homologation` já está no formato correto (`{ "base": "dist", "browser": "" }`) — não precisa alterar.

Estado final esperado de `production`:
```json
"production": {
  "budgets": [
    { "type": "initial", "maximumWarning": "4mb", "maximumError": "5mb" },
    { "type": "anyComponentStyle", "maximumWarning": "6kb", "maximumError": "10kb" }
  ],
  "fileReplacements": [
    { "replace": "src/environments/environment.ts", "with": "src/environments/environment.prod.ts" }
  ],
  "outputPath": { "base": "dist", "browser": "" },
  "optimization": true,
  "outputHashing": "all",
  "sourceMap": false
}
```

Estado final esperado de `homologation`:
```json
"homologation": {
  "assets": [
    "src/favicon.ico",
    "src/assets",
    {
      "glob": "**/*",
      "input": "src/app/features/exemplos/document-builder-tour/tour-assets",
      "output": "assets/exemplos/tour"
    }
  ],
  "fileReplacements": [
    { "replace": "src/environments/environment.ts", "with": "src/environments/environment.homolog.ts" }
  ],
  "outputPath": { "base": "dist", "browser": "" },
  "optimization": true,
  "outputHashing": "all",
  "sourceMap": false,
  "budgets": [
    { "type": "initial", "maximumWarning": "2mb", "maximumError": "5mb" },
    { "type": "anyComponentStyle", "maximumWarning": "25kb", "maximumError": "40kb" }
  ]
}
```

Estado final esperado de `development` (igual a `homologation` sem budgets diferentes):
```json
"development": {
  "assets": [
    "src/favicon.ico",
    "src/assets",
    {
      "glob": "**/*",
      "input": "src/app/features/exemplos/document-builder-tour/tour-assets",
      "output": "assets/exemplos/tour"
    }
  ],
  "fileReplacements": [
    { "replace": "src/environments/environment.ts", "with": "src/environments/environment.dev.ts" }
  ],
  "outputPath": { "base": "dist", "browser": "" },
  "optimization": true,
  "outputHashing": "all",
  "sourceMap": false,
  "budgets": [
    { "type": "initial", "maximumWarning": "2mb", "maximumError": "5mb" },
    { "type": "anyComponentStyle", "maximumWarning": "25kb", "maximumError": "40kb" }
  ]
}
```

---

## Passo 4 — Corrigir scripts do `package.json`

**Arquivo:** `frontend/package.json`

### Problema com `--output-path` nos scripts

Com o builder `application`, `--output-path <string>` coloca arquivos em `<string>/browser/`. É preciso usar a forma com chave separada:

```
--output-path.base=<caminho> --output-path.browser=
```

### Bug no script `homolog`

O script usa `--configuration=homolog` mas a configuração no `angular.json` se chama `homologation`. Corrigir para `--configuration=homologation`.

### Scripts atualizados

```json
"scripts": {
  "ng": "ng",
  "dev:hot": "ng serve --configuration=hot --open",
  "dev": "ng build --output-path.base=..\\backend\\EstruturaPedagogica.Api\\wwwroot --output-path.browser= --base-href /estrutura-pedagogica/ --watch",
  "build": "ng build --output-path.base=..\\backend\\EstruturaPedagogica.Api\\wwwroot --output-path.browser= --base-href /estrutura-pedagogica/",
  "build-aws": "ng build --output-path.base=dist --output-path.browser= --base-href /estrutura-pedagogica/",
  "prod": "ng lint && ng build --configuration=production --output-path.base=..\\backend\\EstruturaPedagogica.Api\\wwwroot --output-path.browser= --base-href /estrutura-pedagogica/",
  "homolog": "ng lint && ng build --configuration=homologation --output-path.base=..\\backend\\EstruturaPedagogica.Api\\wwwroot --output-path.browser= --base-href /estrutura-pedagogica/",
  "test": "ng test",
  "lint": "ng lint"
}
```

> O script `start` (com SSL) foi removido pois os certificados não existem no repositório. Se necessário, pode ser restaurado após gerar os certs.

---

## Passo 5 — Verificar `tsconfig.app.json`

O application builder é mais estrito com o `tsconfig`. Verificar:

```powershell
cat c:\projects\estrutura-pedagogica\frontend\tsconfig.app.json
```

Garantir que `"types"` no `compilerOptions` não inclua tipos incompatíveis. Se houver erros de compilação TS após a migração, eles aparecerão no primeiro build.

---

## Passo 6 — Testar cada script

Executar em ordem, validando que os arquivos saem no lugar certo:

```powershell
cd c:\projects\estrutura-pedagogica\frontend

# 1. Dev com HMR (deve abrir no browser e HMR deve funcionar em mudanças subsequentes)
npm run dev:hot

# 2. Build padrão (deve gerar arquivos em wwwroot sem subpasta browser/)
npm run build
dir ..\backend\EstruturaPedagogica.Api\wwwroot\  # confirmar index.html na raiz

# 3. Build AWS (deve gerar em dist/ sem subpasta browser/)
npm run build-aws
dir dist\  # confirmar index.html na raiz

# 4. Build produção (deve sobrescrever wwwroot, sem subpasta browser/)
npm run prod
dir ..\backend\EstruturaPedagogica.Api\wwwroot\

# 5. Build homolog (idem)
npm run homolog
dir ..\backend\EstruturaPedagogica.Api\wwwroot\
```

**O que verificar:** `index.html` deve estar na raiz do destino, não dentro de `browser/`.

---

## Rollback

Se a migração causar problemas irrecuperáveis:

```powershell
cd c:\projects\estrutura-pedagogica\frontend
git diff angular.json package.json   # revisar o que mudou
git checkout angular.json package.json   # reverter para estado anterior
```

---

## Possíveis erros e soluções

| Erro | Causa provável | Solução |
|---|---|---|
| `Cannot find module '@angular/build'` | Pacote não instalado | `npm install --save-dev @angular/build` |
| `Unknown option 'vendorChunk'` | Flag legada ainda no angular.json | Remover do options/configurations |
| `index.html` em `wwwroot/browser/` | `outputPath` ainda é string | Usar formato objeto com `"browser": ""` |
| Erro de compilação TypeScript | tsconfig mais estrito com esbuild | Corrigir erros de tipo que o Webpack ignorava |
| `Cannot find configuration 'homolog'` | Bug no script (nome errado) | Já corrigido no Passo 4 para `homologation` |
| Karma tests falhando | Karma não usa o application builder | O builder de test (`karma`) não muda — não deve afetar |
