"""
generate_mermaid.py — Gera grafos Mermaid (ERD) por domínio e um ERD completo.

Uso:
    python generate_mermaid.py
"""

import sys
from pathlib import Path
from collections import defaultdict

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import DB_MAP_DIAGRAMS_DIR

from extractor import extract_all
from common import classify_domain, is_audit_column


def _mermaid_block(tables_in_set: set[str], all_fks: list[dict]) -> str:
    lines = ["graph TD"]
    seen_edges: set[tuple] = set()
    for fk in all_fks:
        # Omite arestas de auditoria no diagrama (reduz ruído visual)
        if is_audit_column(fk["parent_column"]):
            continue
        p, r = fk["parent_table"], fk["referenced_table"]
        if p not in tables_in_set or r not in tables_in_set:
            continue
        edge = (p, r)
        if edge in seen_edges:
            continue
        seen_edges.add(edge)
        lines.append(f"  {p} --> {r}")
    # tabelas isoladas (sem FK no subgraph) devem aparecer mesmo assim
    connected = {t for e in seen_edges for t in e}
    for t in sorted(tables_in_set - connected):
        lines.append(f"  {t}")
    return "\n".join(lines) + "\n"


def generate(schema: dict) -> None:
    DB_MAP_DIAGRAMS_DIR.mkdir(parents=True, exist_ok=True)
    tables = schema["tables"]
    fks    = schema["fks"]

    by_domain: dict[str, set[str]] = defaultdict(set)
    for t in tables:
        by_domain[classify_domain(t)].add(t)

    for domain, members in by_domain.items():
        content = _mermaid_block(members, fks)
        path    = DB_MAP_DIAGRAMS_DIR / f"erd-{domain}.mmd"
        path.write_text(content, encoding="utf-8")
        print(f"  erd-{domain}.mmd  -> {len(members)} tabelas")

    full_content = _mermaid_block(set(tables.keys()), fks)
    full_path    = DB_MAP_DIAGRAMS_DIR / "erd.mmd"
    full_path.write_text(full_content, encoding="utf-8")
    print(f"  erd.mmd (completo) -> {len(tables)} tabelas, {len(fks)} FKs")


if __name__ == "__main__":
    print("Extraindo schema...")
    schema = extract_all()
    print("Gerando Mermaid...")
    generate(schema)
    print("Concluído.")
