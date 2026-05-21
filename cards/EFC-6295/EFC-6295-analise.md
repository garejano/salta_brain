# EFC-6295 — Análise do Estado Atual

> Gerado em: 2026-05-21

---

## 1. Fluxo de Desenvolvimento Atual

```
Desenvolvedor edita código Angular
        ↓
npm run dev  →  ng build --watch  →  output: backend/EstruturaPedagogica.Api/wwwroot/
        ↓
Backend (IIS local) serve os arquivos de wwwroot
        ↓
Browser acessa https://localhost/estrutura-pedagogica
        ↓
Para ver mudanças: aguardar rebuild (~5–15s) + F5 manual
```

**Problema:** o `ng build --watch` recompila a cada alteração mas não faz reload automático. O desenvolvedor precisa dar F5 após cada rebuild.

---

## 2. Backend — Como Serve o Frontend

**Arquivo:** `backend/EstruturaPedagogica.Api/Startup.cs`

### Middleware de arquivos estáticos
```csharp
// Startup.cs:243 — Serve /assets separadamente
app.UseStaticFiles(new StaticFileOptions {
    FileProvider = new PhysicalFileProvider(Path.Combine(env.WebRootPath, "assets")),
    RequestPath = "/assets"
});

// Startup.cs:250 — Serve arquivos da SPA
app.UseSpaStaticFiles();

// Startup.cs:252-255 — Fallback SPA: tudo que não for /api vai para wwwroot
app.MapWhen(x => !x.Request.Path.StartsWithSegments("/api"), builder => {
    builder.UseSpa(x => x.Options.SourcePath = "wwwroot");
});
```

### Configuração do RootPath
```csharp
// Startup.cs:94-97
if (SettingsGetter.Instance.HasStaticFiles)
{
    services.AddSpaStaticFiles(configuration => configuration.RootPath = "wwwroot/");
}
```

### HasStaticFiles em desenvolvimento local

`AppSettings.HasStaticFiles` é um `bool` simples (`AppSettings.cs:32`) — padrão C# é `false`.

O `appsettings-development.json` (em `BuildCfg/BackendConfigs/`) **não define** `HasStaticFiles`:
```json
{
  "AwsSecretManagerKey": "development/estrutura-pedagogica/parameters",
  "AwsRegion": "us-east-1",
  ...
}
```

O valor real vem do **AWS Secrets Manager** (`development/estrutura-pedagogica/parameters`). Para o hot reload, isso é irrelevante: se `false`, o backend simplesmente não serve estáticos — perfeito, pois o Angular ficará em `localhost:4200`. Se `true`, o backend também serve wwwroot, mas o browser estará apontado para `:4200`.

### CORS — Confirmado Incompleto
```csharp
// Startup.cs:81-90
services.AddCors(options =>
{
    options.AddPolicy(name: DefaultCorsPolicyName,
        builder =>
        {
            builder
                .AllowAnyMethod()
                .AllowAnyHeader();
            // ← nenhuma origem definida
        });
});
```

**Não há `.AllowAnyOrigin()` nem `.WithOrigins()` em nenhum ponto do código.** Em ASP.NET Core, uma política CORS sem origem configurada rejeita toda requisição com header `Origin`. Chamadas de `https://localhost:4200` para `https://localhost` **vão falhar com erro CORS**. Este é o único bloqueio real para o hot reload.

---

## 3. Frontend — Configuração Atual

**Angular versão:** 20 — HMR habilitado por padrão em `ng serve` desde Angular 17.

### Scripts (`package.json`)

| Script | Comando | Uso |
|--------|---------|-----|
| `start` | `ng serve --ssl true --ssl-cert ssl/server.crt --ssl-key ssl/server.key` | Já existe — serve com SSL em `localhost:4200` |
| `dev` | `ng build --watch --output-path ..\backend\...\wwwroot --base-href /estrutura-pedagogica/` | Fluxo atual — sem hot reload |
| `build` | `ng build` para `wwwroot/` | Build pontual |
| `prod` / `homolog` | Build otimizado | Deploy |

### `angular.json`

| Config | Valor |
|--------|-------|
| `outputPath` (default) | `../backend/EstruturaPedagogica.Api/wwwroot` |
| `optimization` (default) | `false` |
| `sourceMap` | `true` |
| `outputHashing` | `false` |
| `hmr` | não declarado — padrão Angular 20 já habilita |
| `serve` host/port | `localhost:4200` (padrão) |
| `proxy` | nenhum arquivo `proxy.conf` |

### Environments

| Arquivo | `apiUrl` |
|---------|----------|
| `environment.ts` (dev local) | `https://localhost/estrutura-pedagogica/api` (absoluta) |
| `environment.prod.ts` | `api` (relativa) |
| `environment.homolog.ts` | `api` (relativa) |

Como a URL de API é **absoluta** em dev, não é necessário `proxy.conf` — o browser fará chamadas diretas ao backend IIS.

### base-href — Problema Confirmado

O `index.html` tem hardcoded:
```html
<base href="/estrutura-pedagogica/" />
```

O script `start` **não passa `--base-href`**, então `ng serve` usa o valor do `index.html`. O resultado é que a app fica disponível em `https://localhost:4200/estrutura-pedagogica/`, não em `https://localhost:4200/`. O script `dev:hot` precisa passar `--base-href /` para sobrescrever isso e servir na raiz.

---

## 4. Por Que o Hot Reload Não Funciona Hoje

| Causa | Detalhe |
|-------|---------|
| `npm run dev` usa `ng build --watch` | Gera arquivos estáticos; sem servidor de desenvolvimento |
| Não usa `ng serve` | O dev server do Angular (com HMR via WebSocket) nunca é iniciado |
| CORS sem origem | Chamadas de `:4200` → `:443/80` serão bloqueadas pelo browser |
| `start` não é usado | O script que roda `ng serve` existe mas ninguém usa no dia a dia |

---

## 5. O Que Já Está Pronto

- Script `start` existe com `ng serve --ssl` e certificados em `ssl/`
- Angular 20 — HMR nativo, sem configuração adicional
- `apiUrl` absoluta em `environment.ts` — sem necessidade de proxy
- Certificados SSL já existem em `frontend/ssl/`

---

## 6. Bloqueios para Implementação

| Item | Situação | Impacto |
|------|----------|---------|
| CORS sem origem configurada | `Startup.cs:87-88` — falta `.AllowAnyOrigin()` ou `.WithOrigins(...)` | **Alto — bloqueia todas as chamadas de API do ng serve** |
| `base-href` hardcoded em `index.html` | `<base href="/estrutura-pedagogica/" />` | **Médio — app fica em `/estrutura-pedagogica/` em vez de `/`; script precisa passar `--base-href /`** |
