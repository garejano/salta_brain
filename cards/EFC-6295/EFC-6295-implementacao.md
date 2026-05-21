# EFC-6295 — Registro de Implementação

> Data: 2026-05-21

---

## Resumo

O hot reload (`dev:hot`) foi implementado com sucesso. No processo, o builder do projeto foi migrado de Webpack para esbuild, e foi adicionado um modo `dev:hot-homolog` que roda sem backend local.

---

## O Que Foi Feito

### 1. CORS no backend

**Arquivo:** `backend/EstruturaPedagogica.Api/Startup.cs:89–93`

O plano original previa adicionar `https://localhost:4200`. Mas o dev server roda sobre **HTTP** (sem SSL — ver item 2), portanto o origin real é `http://localhost:4200`. Adicionados os dois:

```csharp
.WithOrigins(
    "https://localhost",
    "https://localhost:4200",
    "http://localhost:4200"   // ← necessário: dev server sem SSL
);
```

---

### 2. SSL removido do script

O plano original incluía `--ssl true --ssl-cert ssl/server.crt --ssl-key ssl/server.key`. A pasta `ssl/` **não existe no repositório** — os certificados nunca foram gerados. O dev server roda sobre HTTP em `http://localhost:4200`.

---

### 3. `--base-href /` não funciona como flag CLI no Angular 20

O Angular 20 com `ng serve` não aceita `--base-href` como argumento direto. A solução foi criar uma configuração de build dedicada no `angular.json` com `"baseHref": "/"`:

```json
// angular.json — architect.build.configurations
"hot": {
  "baseHref": "/",
  "fileReplacements": [{ "replace": "src/environments/environment.ts", "with": "src/environments/environment.hot.ts" }]
}
```

---

### 4. Proxy para o IIS local

Sem proxy, o `ng serve` não conseguia encaminhar as chamadas `/ped/...` ao IIS. Criado `frontend/proxy.conf.json`:

```json
{
  "/ped": {
    "target": "https://localhost",
    "secure": false,
    "changeOrigin": true,
    "logLevel": "info"
  }
}
```

A configuração de serve `hot` referencia esse proxy via `"proxyConfig": "proxy.conf.json"`.

---

### 5. `environment.hot.ts` — necessário por causa do ElevaId

O campo `base: "estrutura-pedagogica"` em `environment.ts` fazia o `PortalModuloComponent` construir a URL de callback do ElevaId como `http://localhost:4200/estrutura-pedagogica/auth/eleva-id`. Com `baseHref: /`, essa rota não existe no Angular — toda autenticação caia em `page-not-found`, e o token nunca era processado.

Criado `src/environments/environment.hot.ts` com `base: ""`:

```typescript
export const environment = {
  base: "",  // ← com "estrutura-pedagogica" o callback do ElevaId ia para rota inexistente
  apiUrl: "https://localhost/estrutura-pedagogica/api",
  ELEVA_ID: "https://homolog-id.gruposaltaedu.dev",
  // ... demais campos iguais ao environment.ts
};
```

---

### 6. Migração do builder: Webpack → esbuild

**Por quê:** Com o builder legado (`@angular-devkit/build-angular:browser`), o HMR falhava após a primeira mudança. O builder novo (`@angular/build:application`, baseado em esbuild) tem HMR nativo e estável, e rebuilds ~10x mais rápidos.

**Arquivo:** `frontend/angular.json` e `frontend/package.json`

#### O que mudou no `angular.json`

| Item | Antes | Depois |
|---|---|---|
| `architect.build.builder` | `@angular-devkit/build-angular:browser` | `@angular/build:application` |
| `architect.serve.builder` | `@angular-devkit/build-angular:dev-server` | `@angular/build:dev-server` |
| `options.main` | `"src/main.ts"` | renomeado para `"browser"` |
| `options.polyfills` | string | array |
| `options.outputPath` | string `"../wwwroot"` | objeto `{ "base": "../wwwroot", "browser": "" }` |
| Flags removidas | — | `vendorChunk`, `buildOptimizer`, `namedChunks`, `extractLicenses` (não existem no esbuild) |
| Configs adicionadas | — | `production-iis`, `homologation-iis` (output → wwwroot, para deploy IIS) |

**Por que `production-iis` e `homologation-iis`:** O builder antigo aceitava `--output-path <string>` e jogava os arquivos direto no destino. O novo builder, ao receber `--output-path <string>` via CLI, cria uma subpasta `browser/` dentro do destino. Para contornar sem usar flags CLI frágeis, foram criadas configurações dedicadas para IIS com `outputPath` já no formato objeto correto.

#### O que mudou nos scripts (`package.json`)

| Script | Antes | Depois | Por quê |
|---|---|---|---|
| `dev:hot` | `ng serve --ssl true ... --base-href /` | `ng serve --configuration=hot --open` | SSL inexistente; base-href vai no angular.json |
| `build` | `ng build --output-path ...\wwwroot --base-href ...` | `ng build --base-href ...` | outputPath agora nas options padrão do angular.json |
| `build-aws` | `ng build --output-path dist --base-href ...` | `ng build --base-href ...` | outputPath nas configs production/homologation |
| `prod` | `ng build --configuration=production --output-path ...\wwwroot` | `ng build --configuration=production-iis` | Nova config dedicada para output em wwwroot |
| `homolog` | `ng build --configuration=homolog ...` (**bug:** config se chama `homologation`) | `ng build --configuration=homologation-iis` | Bug corrigido + nova config iis |
| `start` | `ng serve --ssl true ...` | removido | Certificados SSL não existem |

#### SCSS — importação do Bootstrap

O esbuild não resolve o prefixo `node_modules/` no Sass. Corrigido em `src/styles/bootstrap-custom.scss`:

```scss
// Antes (funcionava no Webpack, quebra no esbuild):
@use "node_modules/bootstrap/scss/bootstrap";

// Depois:
@use "bootstrap/scss/bootstrap";
```

---

### 7. Modo `dev:hot-homolog` (feature adicional)

Para desenvolver sem precisar rodar o backend local, foi criado um modo que roteia todas as chamadas de API para o ambiente de homologação via proxy.

**Arquivos criados:**
- `src/environments/environment.hot-homolog.ts` — URLs relativas (para o proxy interceptar)
- `proxy.conf.homolog.json` — proxy de `/ped`, `/estrutura-pedagogica/api`, `/processador-boletim/api`, `/Frequencia/api` para `https://homolog.atlasedu.com.br`

**Como funciona:** O browser só fala com `localhost:4200`. O proxy do Angular dev server encaminha para o homolog — sem CORS, sem necessidade de configurar o backend remoto.

---

### 8. Impacto no deploy AWS

O CI executa `npm run build-aws -- --configuration=$STAGE` e sincroniza `dist/` com S3. Durante a migration, o script `build-aws` foi incorretamente setado com `--configuration=production` hardcoded, criando dois flags conflitantes. Corrigido para apenas `ng build --base-href /estrutura-pedagogica/` — o CI injeta o `--configuration` como sempre fez.

As configurações `production`, `homologation` e `development` todas têm `outputPath: { base: "dist", browser: "" }`, então os arquivos continuam indo direto para `dist/index.html` (sem subpasta `browser/`). O `aws s3 sync dist s3://...` funciona sem alteração.

---

## Limitações Conhecidas (HMR)

O Angular HMR, mesmo com esbuild, re-executa `ngOnInit` em mudanças de `.ts`, `.html` e `.scss` de componentes. Isso ocorre porque os estilos de componente são compilados dentro do bundle JS do módulo. O que não re-executa `ngOnInit` são mudanças em **estilos globais** (`global.scss` e arquivos no array `styles` do `angular.json`).

O ganho real do HMR é:
- Permanece na rota atual (sem voltar ao login)
- Rebuild incremental ~300ms (vs ~30s no Webpack)
- Não precisa re-autenticar após cada mudança

---

## Arquivos Modificados

| Arquivo | Tipo de mudança |
|---|---|
| `backend/EstruturaPedagogica.Api/Startup.cs` | CORS: adicionado `http://localhost:4200` |
| `frontend/angular.json` | Builder migrado; novas configs `hot`, `hot-homolog`, `production-iis`, `homologation-iis`; flags obsoletas removidas |
| `frontend/package.json` | Scripts reescritos; `build-aws` corrigido; bug `homolog` → `homologation-iis` corrigido |
| `frontend/proxy.conf.json` | Criado — proxy `/ped` → IIS local |
| `frontend/proxy.conf.homolog.json` | Criado — proxy todas as APIs → homolog |
| `frontend/src/environments/environment.hot.ts` | Criado — `base: ""` para callback correto do ElevaId |
| `frontend/src/environments/environment.hot-homolog.ts` | Criado — URLs relativas para proxy homolog |
| `frontend/src/styles/bootstrap-custom.scss` | Corrigido import esbuild-compatível |
| `estrutura-pedagogica/CLAUDE.md` | Documentados os modos `dev:hot` e `dev:hot-homolog` |
