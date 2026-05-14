/* tour-demos.js — interactive mini-demos for the Document Builder tour */
(function () {
  'use strict';

  // ────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────
  const $ = (sel, root = document) => root.querySelector(sel);
  const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

  function wireSlider(inputId, valId, suffix, onChange) {
    const r = $('#' + inputId);
    const p = valId ? $('#' + valId) : null;
    if (!r) return;
    const update = () => {
      const pct = ((r.value - r.min) / (r.max - r.min)) * 100;
      r.style.setProperty('--pct', pct + '%');
      if (p) p.textContent = r.value + (suffix || '');
      onChange && onChange(r.value);
    };
    r.addEventListener('input', update);
    update();
  }

  function wireSegmented(rootId, onChange) {
    const root = $('#' + rootId);
    if (!root) return;
    $$('button', root).forEach((b) => {
      b.addEventListener('click', () => {
        $$('button', root).forEach((x) => x.classList.remove('on'));
        b.classList.add('on');
        onChange && onChange(b.dataset.val, b);
      });
    });
  }

  // Generic .cbx toggle (visual only)
  $$('.cbx').forEach((b) => {
    b.addEventListener('click', () => {
      b.classList.toggle('on');
    });
  });

  // ────────────────────────────────────────────────────────────────
  // 04 — Configuração de página
  // ────────────────────────────────────────────────────────────────
  (function configPage() {
    const doc = $('#cfgDoc');
    if (!doc) return;
    wireSegmented('cfgOrient', (val) => {
      doc.dataset.orient = val;
    });
    wireSlider('cfgGap', 'cfgGapVal', ' px', (v) => {
      doc.style.setProperty('--doc-gap', v + 'px');
    });
    wireSlider('cfgMarg', 'cfgMargVal', ' px', (v) => {
      doc.style.setProperty('--doc-margin', v + 'px');
    });
  })();

  // ────────────────────────────────────────────────────────────────
  // 05 — Tipografia
  // ────────────────────────────────────────────────────────────────
  (function typography() {
    const doc = $('#typoDoc');
    if (!doc) return;
    wireSlider('typoSize', 'typoVal', ' px', (v) => {
      doc.style.setProperty('--typo-size', v + 'px');
    });
  })();

  // ────────────────────────────────────────────────────────────────
  // 06 — Padding de células
  // ────────────────────────────────────────────────────────────────
  (function tablePadding() {
    const doc = $('#tblDoc');
    if (!doc) return;
    const y = $('#tblY'),
      x = $('#tblX');
    const yVal = $('#tblYVal'),
      xVal = $('#tblXVal');
    const presetBtns = $$('#tblPreset button');

    function syncPresetActive() {
      presetBtns.forEach((b) => {
        b.classList.toggle('on', b.dataset.y === y.value && b.dataset.x === x.value);
      });
    }
    function apply() {
      doc.style.setProperty('--tpad-y', y.value + 'px');
      doc.style.setProperty('--tpad-x', x.value + 'px');
      yVal.textContent = y.value + ' px';
      xVal.textContent = x.value + ' px';
      [y, x].forEach((r) => {
        const pct = ((r.value - r.min) / (r.max - r.min)) * 100;
        r.style.setProperty('--pct', pct + '%');
      });
      syncPresetActive();
    }
    [y, x].forEach((r) => r.addEventListener('input', apply));
    presetBtns.forEach((b) => {
      b.addEventListener('click', () => {
        y.value = b.dataset.y;
        x.value = b.dataset.x;
        apply();
      });
    });
    apply();
  })();

  // ────────────────────────────────────────────────────────────────
  // 07 — Cabeçalho / Rodapé
  // ────────────────────────────────────────────────────────────────
  (function headerFooter() {
    const pages = $$('#hfPages .page');
    if (!pages.length) return;
    const headerBtn = $('#hfHeader');
    const headerAllBtn = $('#hfHeaderAll');
    const footerBtn = $('#hfFooter');

    function apply() {
      const headerOn = headerBtn.classList.contains('on');
      const headerAll = headerAllBtn.classList.contains('on');
      const footerOn = footerBtn.classList.contains('on');

      pages.forEach((p, i) => {
        // Header: if off → hide on all. If on + all → show on all. If on + not all → only first page.
        const showHeader = headerOn && (headerAll || i === 0);
        p.classList.toggle('no-header', !showHeader);
        p.classList.toggle('no-footer', !footerOn);
      });

      // Disable headerAll subcheck visually when header is off
      headerAllBtn.style.opacity = headerOn ? '1' : '0.35';
      headerAllBtn.style.pointerEvents = headerOn ? 'auto' : 'none';
    }

    // The generic cbx handler above already toggles .on; this handler runs after
    // because it was registered later → so we just react.
    [headerBtn, headerAllBtn, footerBtn].forEach((b) =>
      b.addEventListener('click', () => requestAnimationFrame(apply))
    );
    apply();
  })();

  // ────────────────────────────────────────────────────────────────
  // 08 — Bloco de assinaturas
  // ────────────────────────────────────────────────────────────────
  (function signatures() {
    const sigDate = $('#sigDate');
    const sigRow = $('#sigRow');
    if (!sigDate || !sigRow) return;

    wireSegmented('sigDatePos', (v) => {
      sigDate.style.textAlign = v === 'left' ? 'left' : v === 'right' ? 'right' : 'center';
    });
    wireSegmented('sigAlignCtl', (v) => {
      sigRow.style.justifyContent = v === 'left' ? 'flex-start' : v === 'right' ? 'flex-end' : 'center';
    });
    wireSlider('sigGapInp', 'sigGapVal', ' px', (v) => {
      sigRow.style.gap = v + 'px';
    });

    const sigRoleBtn = $('#sigRole');
    sigRoleBtn.addEventListener('click', () => {
      // generic handler already toggled .on
      requestAnimationFrame(() => {
        const showRole = sigRoleBtn.classList.contains('on');
        sigRow.querySelectorAll('.sig-cell').forEach((c) => c.classList.toggle('no-role', !showRole));
      });
    });
  })();

  // ────────────────────────────────────────────────────────────────
  // 09 — Exportação
  // ────────────────────────────────────────────────────────────────
  (function exportPanel() {
    const q = $('#expQual');
    const s = $('#expStrat');
    if (!q || !s) return;

    const QUAL = {
      padrao: { label: 'Padrão · 96 DPI', size: '120 KB' },
      alta:   { label: 'Alta · 150 DPI',   size: '240 KB' },
      maxima: { label: 'Máxima · 300 DPI', size: '680 KB' },
    };
    const STRAT = {
      css:     { label: 'CSS nativo',       text: 'Vetorial · selecionável' },
      canvas:  { label: 'Canvas',           text: 'Rasterizado · 1:1 pixel' },
      hibrido: { label: 'Híbrido',          text: 'Texto vetorial + img canvas' },
    };

    function apply() {
      const qv = QUAL[q.value], sv = STRAT[s.value];
      $('#expVQual').textContent = qv.label;
      $('#expVStrat').textContent = sv.label;
      $('#expVText').textContent = sv.text;
      $('#expVSize').textContent = '~ ' + qv.size;
      const dpi = q.value === 'padrao' ? '96dpi' : q.value === 'alta' ? '150dpi' : '300dpi';
      $('#expFilename').textContent = 'relatorio-notas-' + dpi + '-' + s.value + '.pdf';
    }
    q.addEventListener('change', apply);
    s.addEventListener('change', apply);
    apply();
  })();

  // ────────────────────────────────────────────────────────────────
  // 10 — Minimizar páginas (looping simulation)
  // ────────────────────────────────────────────────────────────────
  (function minimize() {
    const phasesRoot = $('#mPhases');
    if (!phasesRoot) return;
    const mNum = $('#mNum');
    const dots = $$('#mDots .pdot');
    const barFill = $('#mBarFill');
    const stepNow = $('#mStepNow');
    const sub = $('#mSub');

    // Step plan: idx → { reduced, from, to }
    const PLAN = [
      { reduced: true,  from: 7, to: 5, result: '7 → 5 pág.' },
      { reduced: false, from: 5, to: 5, result: '5 → 5 (mantido)' },
      { reduced: false, from: 5, to: 5, result: '5 → 5 (mantido)' },
      { reduced: true,  from: 5, to: 4, result: '5 → 4 pág.' },
      { reduced: false, from: 4, to: 4, result: '4 → 4 (mantido)' },
      { reduced: false, from: 4, to: 4, result: '4 → 4 (mantido)' },
      { reduced: false, from: 4, to: 4, result: '4 → 4 (mantido)' },
    ];

    const stepsEls = $$('.step', phasesRoot);
    let runTimers = [];

    function reset() {
      runTimers.forEach((t) => clearTimeout(t));
      runTimers = [];
      stepsEls.forEach((el) => {
        el.classList.remove('active', 'reduced', 'kept');
        el.querySelector('.ico .material-symbols-outlined').textContent = 'circle';
        el.querySelector('.res').textContent = '';
      });
      mNum.textContent = '7';
      mNum.classList.remove('flash');
      dots.forEach((d) => d.classList.remove('gone'));
      barFill.style.width = '0%';
      stepNow.textContent = '0';
      sub.textContent = 'Testando configurações ótimas';
    }

    function setStep(i, state, resultText) {
      const el = stepsEls[i];
      if (!el) return;
      el.classList.remove('active', 'reduced', 'kept');
      el.classList.add(state);
      const ico = el.querySelector('.ico .material-symbols-outlined');
      const res = el.querySelector('.res');
      if (state === 'active') {
        ico.textContent = 'progress_activity';
        res.textContent = 'testando…';
      } else if (state === 'reduced') {
        ico.textContent = 'check';
        res.textContent = resultText || '';
      } else if (state === 'kept') {
        ico.textContent = 'remove';
        res.textContent = resultText || '';
      } else {
        ico.textContent = 'circle';
        res.textContent = '';
      }
    }

    function setPages(n) {
      mNum.textContent = n;
      dots.forEach((d, i) => d.classList.toggle('gone', i >= n));
      mNum.classList.add('flash');
      setTimeout(() => mNum.classList.remove('flash'), 360);
    }

    function run() {
      reset();
      const stepDelay = 1000;
      const activeHold = 600;
      let cum = 400;

      PLAN.forEach((step, i) => {
        runTimers.push(
          setTimeout(() => {
            if (i > 0) {
              const prev = PLAN[i - 1];
              setStep(i - 1, prev.reduced ? 'reduced' : 'kept', prev.result);
            }
            setStep(i, 'active');
            stepNow.textContent = i + 1;
            barFill.style.width = ((i + 1) / PLAN.length) * 100 + '%';
            if (step.reduced) {
              runTimers.push(
                setTimeout(() => setPages(step.to), activeHold)
              );
            }
          }, cum)
        );
        cum += stepDelay;
      });

      // Finalize last
      runTimers.push(
        setTimeout(() => {
          const last = PLAN[PLAN.length - 1];
          setStep(PLAN.length - 1, last.reduced ? 'reduced' : 'kept', last.result);
          barFill.style.width = '100%';
          sub.textContent = 'Concluído · 7 → 4 páginas';
        }, cum)
      );

      // Loop after a pause
      runTimers.push(setTimeout(run, cum + 3000));
    }

    // Start loop once visible (use IntersectionObserver to avoid burning CPU on hidden slides)
    const slide = phasesRoot.closest('.slide');
    if (slide && 'IntersectionObserver' in window) {
      let started = false;
      const io = new IntersectionObserver(
        (entries) => {
          entries.forEach((e) => {
            if (e.isIntersecting && !started) {
              started = true;
              run();
            }
          });
        },
        { threshold: 0.2 }
      );
      io.observe(slide);
    } else {
      run();
    }
  })();
})();
