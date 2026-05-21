# EFC-6295 — Plano de Implementação: Hot Reload

> Gerado em: 2026-05-21  
> Repositório alvo: `c:/projects/estrutura-pedagogica`

---

## Resumo da Abordagem

Usar `ng serve` em vez de `ng build --watch`. O Angular 20 habilita HMR automaticamente. A URL de API em `environment.ts` já é absoluta, dispensando proxy. Dois ajustes necessários: CORS no backend e `--base-href /` no script.

**Esforço estimado:** 1–2h

---

## Passo 1 — Corrigir CORS no Backend

**Arquivo:** `backend/EstruturaPedagogica.Api/Startup.cs:81–90`

A política atual tem apenas `.AllowAnyMethod()` + `.AllowAnyHeader()` sem nenhuma origem — em ASP.NET Core isso rejeita toda requisição com header `Origin`. Adicionar a origem do dev server:

```csharp
builder
    .AllowAnyMethod()
    .AllowAnyHeader()
    .WithOrigins(
        "https://localhost",
        "https://localhost:4200"   // ← dev server Angular
    );
```

---

## Passo 2 — Adicionar Script `dev:hot` no Frontend

**Arquivo:** `frontend/package.json`

O `index.html` tem `<base href="/estrutura-pedagogica/" />` hardcoded. Sem `--base-href /`, o `ng serve` serviria a app em `https://localhost:4200/estrutura-pedagogica/` (ok, mas confuso). Com `--base-href /` a app fica na raiz e o roteamento interno continua funcionando.

```json
"scripts": {
  "start":   "ng serve --ssl true --ssl-cert ssl/server.crt --ssl-key ssl/server.key",
  "dev:hot": "ng serve --ssl true --ssl-cert ssl/server.crt --ssl-key ssl/server.key --base-href / --open",
  "dev":     "ng build --watch ..."
}
```

> `--open` abre o browser automaticamente. HMR já habilitado por padrão no Angular 20.

---

## Passo 3 — Testar o Fluxo

1. Iniciar backend no Visual Studio (IIS Local — `https://localhost/estrutura-pedagogica`)
2. No terminal, dentro de `frontend/`: `npm run dev:hot`
3. Browser abre em `https://localhost:4200/`
4. Editar qualquer `.ts` ou `.html` — a mudança deve refletir **sem F5**

**Checklist de validação:**
- [ ] App carrega em `https://localhost:4200` sem erro de certificado
- [ ] Chamadas de API chegam ao backend (`Network` no DevTools mostra `200` para `/estrutura-pedagogica/api/...`)
- [ ] Editar um componente reflete em tela em < 2s sem F5
- [ ] Console do browser não mostra erros de CORS

---

## Passo 4 — Documentar no CLAUDE.md do Repositório

Adicionar seção em `estrutura-pedagogica/CLAUDE.md`:

```markdown
## Desenvolvimento

| Modo | Comando | URL | Observação |
|------|---------|-----|------------|
| Hot Reload (recomendado) | `npm run dev:hot` | `https://localhost:4200` | HMR automático; requer backend rodando no IIS |
| Build Watch (legado) | `npm run dev` | `https://localhost/estrutura-pedagogica` | Gera bundle em wwwroot; requer F5 manual |
```

---

## Diagrama do Fluxo com Hot Reload

```
Desenvolvedor edita arquivo Angular
        ↓
ng serve --base-href / (HMR ativo)  →  detecta mudança  →  recompila módulo afetado
        ↓
WebSocket notifica o browser  →  aplica patch sem reload completo
        ↓
Chamadas de API: browser (localhost:4200) → IIS backend (localhost/estrutura-pedagogica/api)
```

---

## Contingências

| Situação | Solução |
|----------|---------|
| Erro de certificado SSL no browser | Rodar sem SSL: `ng serve --base-href / --open` |
| WebSocket de HMR bloqueado (antivírus/proxy local) | `ng serve --live-reload=false` — sem HMR mas build incremental rápido |
| Rotas internas quebradas com `--base-href /` | Verificar se `RouterModule` usa `useHash: true`; se sim, sem impacto |
