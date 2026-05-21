// app-side-panel — Eleva Design System
// Behaviour: slides from the right (translateX 100% → 0), fades overlay in,
// closes on internal × button or overlay click, locks page scroll while open,
// internal scroll for tall content. Mobile (≤480px): panel goes full-width.

const { useEffect, useRef } = React;

/**
 * <SidePanel show onClose width>...children...</SidePanel>
 *
 * Props
 *   show     boolean  — controlled by the parent (CA-02)
 *   onClose  ()=>void — emitted when user dismisses (× or overlay) (CA-03)
 *   width    number   — panel width in px (default 480)
 *   children React node — projected content slot (CA-05)
 */
function SidePanel({ show, onClose, width = 480, anchor = 'right', children }) {
  // Lock body scroll while the panel is open (CA-04)
  useEffect(() => {
    if (!show) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => { document.body.style.overflow = prev; };
  }, [show]);

  // ESC to close — a small accessibility courtesy on top of the brief
  useEffect(() => {
    if (!show) return;
    const onKey = (e) => { if (e.key === 'Escape') onClose && onClose(); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [show, onClose]);

  return (
    <div className={`sp-root ${show ? 'is-open' : ''}`} aria-hidden={!show}>
      {/* Overlay — clickable close target (CA-03) */}
      <div
        className="sp-overlay"
        onClick={onClose}
        role="presentation"
      />
      {/* Panel — fixed, right-anchored, 100vh, scrollable inside */}
      <aside
        className="side-panel"
        style={{ '--sp-width': `${width}px` }}
        data-anchor={anchor}
        role="dialog"
        aria-modal="true"
      >
        <button
          type="button"
          className="btn-side-panel-close"
          aria-label="Fechar"
          onClick={onClose}
        >
          <span className="material-symbols-outlined" aria-hidden="true">close</span>
        </button>
        <div className="side-panel-body">
          {children}
        </div>
      </aside>
    </div>
  );
}

Object.assign(window, { SidePanel });
