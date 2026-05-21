// Demo host for <SidePanel>. Mirrors how a consumer component would wire it up.
const { useState } = React;

// --- Tiny chrome ---------------------------------------------------------
function ElevaLogo() {
  return (
    <a className="brand" href="#">
      <svg viewBox="0 0 122.12 170" aria-hidden="true" className="brand-mark">
        <defs>
          <linearGradient id="eleva-g" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#30B7BE" />
            <stop offset="100%" stopColor="#39D881" />
          </linearGradient>
        </defs>
        <path fill="url(#eleva-g)" d="M 17.12 37.18 C 20.28 26.97 39.71 16.64 65 16.64 C 87.29 16.64 101.89 22.99 109.62 27.66 C 110.86 28.41 112.29 28.78 113.79 28.78 C 118.39 28.78 122.12 25.05 122.12 20.45 C 122.12 17.43 120.51 14.77 118.07 13.3 C 108.53 7.6 90.97 0 64.99 0 C 28.55 0 0 17.59 0 40.06 C 0 44.2 1.01 48.18 2.81 51.9 C 6.7 46.38 11.54 41.42 17.12 37.18 Z M 45.77 61.34 C 39.16 64.39 33.85 68.93 30.75 74.28 C 40.64 77.99 52.33 80.13 64.99 80.13 C 84.82 80.13 114.17 72.33 114.17 55.59 C 114.18 38.82 84.83 31 64.99 31 C 30.09 31 1.59 55.22 1.59 84.99 C 1.59 90.37 2.53 95.56 4.26 100.47 C 8.33 96.68 13.21 93.33 18.75 90.49 C 18.42 88.7 18.24 86.86 18.24 84.99 C 18.24 64.37 39.34 47.65 64.99 47.65 C 79.32 47.65 92.66 52.32 96.71 55.57 C 92.65 58.81 79.32 63.47 64.99 63.47 C 58.07 63.47 51.61 62.68 45.77 61.34 Z M 113.79 141.21 C 112.28 141.21 110.85 141.58 109.61 142.33 C 101.89 147 87.24 153.35 64.99 153.35 C 37.26 153.35 16.65 140.99 16.65 129.93 C 16.65 118.87 37.32 106.5 64.99 106.5 C 79.32 106.5 92.66 111.17 96.71 114.41 C 92.66 117.67 79.32 122.33 64.99 122.33 C 57.8 122.33 51 121 44.91 118.68 C 35.4 121.35 29.28 125.47 27.09 128.24 C 37.67 134.98 50.79 138.98 64.99 138.98 C 84.82 138.98 114.17 131.17 114.17 114.4 C 114.17 97.66 84.82 89.86 64.99 89.86 C 28.55 89.86 0 107.45 0 129.92 C 0 152.4 28.55 170 64.99 170 C 90.97 170 108.53 162.39 118.06 156.68 C 120.51 155.21 122.11 152.56 122.11 149.53 C 122.12 144.94 118.39 141.21 113.79 141.21 Z" />
      </svg>
      <span className="brand-word">eleva</span>
    </a>
  );
}

function AppHeader() {
  return (
    <header className="app-header">
      <ElevaLogo />
      <button type="button" className="header-menu" aria-label="Abrir menu">
        <span className="material-symbols-outlined">menu</span>
        <span>Menu</span>
      </button>
      <div className="header-spacer" />
      <button type="button" className="header-icon" aria-label="Notificações">
        <span className="material-symbols-outlined">notifications</span>
      </button>
      <div className="header-avatar" aria-hidden="true">MS</div>
    </header>
  );
}

// --- Demo content slotted INTO the side panel ----------------------------
// Equivalent of <ng-content> at runtime: the host of the component
// composes its own title / fields / actions. SidePanel knows nothing.

function StudentRecordContent({ onClose, onSave }) {
  return (
    <React.Fragment>
      <header className="record-header">
        <p className="record-eyebrow">Registro</p>
        <h2 className="record-title">Detalhes do aluno</h2>
      </header>

      <dl className="record-fields">
        <div className="field-row">
          <dt>Nome</dt>
          <dd>Maria da Silva Oliveira</dd>
        </div>
        <div className="field-row">
          <dt>Matrícula</dt>
          <dd>2024001234</dd>
        </div>
        <div className="field-row">
          <dt>Turma</dt>
          <dd>3º ano A — Ensino Médio</dd>
        </div>
        <div className="field-row">
          <dt>Situação</dt>
          <dd>
            <span className="status-tag status-tag--active">
              <span className="material-symbols-outlined" aria-hidden="true">check_circle</span>
              Ativo
            </span>
          </dd>
        </div>
        <div className="field-row">
          <dt>E-mail</dt>
          <dd>maria.oliveira@aluno.eleva.com.br</dd>
        </div>
        <div className="field-row">
          <dt>Nascimento</dt>
          <dd>26/06/2008</dd>
        </div>
        <div className="field-row">
          <dt>Responsável</dt>
          <dd>Joana Oliveira · (11) 98123-4567</dd>
        </div>
      </dl>

      <section className="record-section">
        <h3 className="record-section__title">Observações</h3>
        <p className="record-section__body">
          Conteúdo projetado via <code>ng-content</code>. O componente <code>app-side-panel</code> não conhece nada sobre este conteúdo — ele apenas reserva o espaço, controla a animação e dispara o evento de fechamento.
        </p>
      </section>

      <section className="record-section">
        <h3 className="record-section__title">Histórico recente</h3>
        <ul className="record-timeline">
          <li>
            <span className="timeline-dot" />
            <div>
              <p className="timeline-title">Boletim 2º bimestre publicado</p>
              <p className="timeline-meta">12/02/2025 às 13:30</p>
            </div>
          </li>
          <li>
            <span className="timeline-dot" />
            <div>
              <p className="timeline-title">Atualização cadastral</p>
              <p className="timeline-meta">04/02/2025 às 09:12</p>
            </div>
          </li>
          <li>
            <span className="timeline-dot" />
            <div>
              <p className="timeline-title">Matrícula confirmada</p>
              <p className="timeline-meta">22/01/2025 às 18:05</p>
            </div>
          </li>
        </ul>
      </section>

      <footer className="record-actions">
        <button type="button" className="btn btn--outline" onClick={onClose}>Fechar</button>
        <button type="button" className="btn btn--primary" onClick={onSave}>Salvar</button>
      </footer>
    </React.Fragment>
  );
}

// --- Tweaks --------------------------------------------------------------
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "width": 480,
  "anchor": "right",
  "overlayOpacity": 50,
  "demo": "record"
}/*EDITMODE-END*/;

function DemoTweaks() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Expose to App via window so we don't have to plumb context.
  window.__sp_tweaks = t;
  window.dispatchEvent(new CustomEvent('sp-tweaks-changed'));

  return (
    <TweaksPanel title="Tweaks">
      <TweakSection label="Painel" />
      <TweakSlider
        label="Largura"
        value={t.width} min={360} max={720} step={20}
        onChange={(v) => setTweak('width', v)}
        unit="px"
      />
      <TweakRadio
        label="Ancora"
        value={t.anchor}
        options={[
          { label: 'Direita', value: 'right' },
          { label: 'Esquerda', value: 'left' },
        ]}
        onChange={(v) => setTweak('anchor', v)}
      />
      <TweakSlider
        label="Overlay"
        value={t.overlayOpacity} min={0} max={70} step={5}
        onChange={(v) => setTweak('overlayOpacity', v)}
        unit="%"
      />
      <TweakSection label="Conteúdo projetado" />
      <TweakRadio
        label="Exemplo"
        value={t.demo}
        options={[
          { label: 'Registro', value: 'record' },
          { label: 'Form longo', value: 'form' },
        ]}
        onChange={(v) => setTweak('demo', v)}
      />
    </TweaksPanel>
  );
}

// --- Long-form alternative demo content ---------------------------------
function LongFormDemo({ onClose, onSave }) {
  const rows = Array.from({ length: 14 }, (_, i) => i);
  return (
    <React.Fragment>
      <header className="record-header">
        <p className="record-eyebrow">Cadastro</p>
        <h2 className="record-title">Editar dados do aluno</h2>
      </header>
      <div className="form-grid">
        {rows.map((i) => (
          <label key={i} className="form-field">
            <span className="form-label">Campo {i + 1}</span>
            <input className="form-input" defaultValue={i === 0 ? 'Maria da Silva' : ''} placeholder="—" />
          </label>
        ))}
      </div>
      <footer className="record-actions">
        <button type="button" className="btn btn--outline" onClick={onClose}>Cancelar</button>
        <button type="button" className="btn btn--primary" onClick={onSave}>Salvar alterações</button>
      </footer>
    </React.Fragment>
  );
}

// --- Page ---------------------------------------------------------------
function DemoPage() {
  const [open, setOpen] = useState(false);
  const [toast, setToast] = useState(null);

  // Listen to tweak changes and re-render
  const [, force] = useState(0);
  React.useEffect(() => {
    const h = () => force((n) => n + 1);
    window.addEventListener('sp-tweaks-changed', h);
    return () => window.removeEventListener('sp-tweaks-changed', h);
  }, []);

  const t = window.__sp_tweaks || TWEAK_DEFAULTS;
  const overlayAlpha = (t.overlayOpacity ?? 50) / 100;

  const handleSave = () => {
    setOpen(false);
    setToast('Registro salvo com sucesso');
    setTimeout(() => setToast(null), 3200);
  };

  return (
    <React.Fragment>
      <AppHeader />
      <main className="page">
        <div className="page-inner">
          <div className="crumbs">
            <span>Componentes</span>
            <span className="material-symbols-outlined">chevron_right</span>
            <span>Overlays</span>
            <span className="material-symbols-outlined">chevron_right</span>
            <span className="crumbs__current">Side Panel</span>
          </div>

          <header className="page-header">
            <h1 className="page-title">Side Panel</h1>
            <p className="page-sub">
              Painel lateral reutilizável. Recebe conteúdo via <code>ng-content</code>, fecha pelo botão "×" interno ou clicando no overlay. Substitui o <code>app-modal</code> em fluxos que precisam de mais altura.
            </p>
          </header>

          <div className="meta-grid">
            <div className="meta-card">
              <p className="meta-card__label">Componente</p>
              <p className="meta-card__value"><code>app-side-panel</code></p>
            </div>
            <div className="meta-card">
              <p className="meta-card__label">Card Jira</p>
              <p className="meta-card__value">EFC-6371</p>
            </div>
            <div className="meta-card">
              <p className="meta-card__label">Status</p>
              <p className="meta-card__value">
                <span className="status-tag status-tag--review">Em revisão</span>
              </p>
            </div>
            <div className="meta-card">
              <p className="meta-card__label">Última atualização</p>
              <p className="meta-card__value">21/05/2026</p>
            </div>
          </div>

          <section className="demo-card">
            <header className="demo-card__head">
              <h2 className="demo-card__title">Como usar</h2>
              <p className="demo-card__sub">O componente pai apenas controla a visibilidade via <code>[show]</code> e escuta o evento <code>(closeEvent)</code>.</p>
            </header>
            <pre className="code-block"><code>{`<app-side-panel [show]="showPanel" (closeEvent)="closePanel()">
  <!-- seu conteúdo aqui -->
</app-side-panel>`}</code></pre>

            <div className="demo-card__cta">
              <button type="button" className="btn btn--primary btn--lg" onClick={() => setOpen(true)}>
                <span className="material-symbols-outlined" aria-hidden="true">open_in_new</span>
                Abrir Side Panel
              </button>
              <p className="demo-card__hint">Esc, clique no overlay ou no botão × para fechar.</p>
            </div>
          </section>

          <section className="ca-card">
            <h2 className="ca-card__title">Critérios de aceite</h2>
            <ol className="ca-list">
              <li><strong>CA-01</strong> · Standalone — abrir/fechar e layout vivem no componente; o pai só diz se está aberto.</li>
              <li><strong>CA-02</strong> · <code>@Input() show</code> controla visibilidade; ao fechar, emite <code>closeEvent</code>.</li>
              <li><strong>CA-03</strong> · Dois pontos de fechamento — botão × interno e clique no overlay.</li>
              <li><strong>CA-04</strong> · 100vh à direita, scroll interno, página de fundo travada.</li>
              <li><strong>CA-05</strong> · Conteúdo projetado (<code>ng-content</code>) — o componente é um container puro.</li>
            </ol>
          </section>
        </div>
      </main>

      <SidePanel
        show={open}
        onClose={() => setOpen(false)}
        width={t.width}
        anchor={t.anchor}
      >
        {t.demo === 'form'
          ? <LongFormDemo onClose={() => setOpen(false)} onSave={handleSave} />
          : <StudentRecordContent onClose={() => setOpen(false)} onSave={handleSave} />
        }
      </SidePanel>

      {/* dynamic overlay alpha */}
      <style>{`.sp-overlay { background: rgba(15, 15, 16, ${overlayAlpha}); }`}</style>

      {toast && (
        <div className="toast" role="status">
          <span className="material-symbols-outlined">check_circle</span>
          <span>{toast}</span>
        </div>
      )}

      <DemoTweaks />
    </React.Fragment>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<DemoPage />);
