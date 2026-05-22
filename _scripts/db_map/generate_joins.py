"""
generate_joins.py — Detecta caminhos de join de negócio e gera schema/joins.yaml.

Usa BFS no grafo de FKs de negócio (sem colunas de auditoria) para encontrar
caminhos curtos entre tabelas, priorizando pares âncora × folha e intra-domínio.

Uso:
    python generate_joins.py
"""

import sys
from pathlib import Path
from collections import defaultdict

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import DB_MAP_SCHEMA_DIR

from extractor import extract_all
from common import build_business_graph, bfs_path, classify_domain, yaml_dumper


def _anchor_tables(tables: dict) -> list[str]:
    """Tabelas com muitas referências de FKs de entrada (hubs do schema)."""
    ref_count: dict[str, int] = defaultdict(int)
    for info in tables.values():
        for rel in info["relations"]:
            ref_count[rel["to"]] += 1
    threshold = max(2, len(tables) // 20)
    return [t for t, c in ref_count.items() if c >= threshold]


def generate(schema: dict) -> None:
    DB_MAP_SCHEMA_DIR.mkdir(parents=True, exist_ok=True)

    # Grafo apenas com FKs de negócio (sem UsuarioInclusao, Data*, etc.)
    graph   = build_business_graph(schema["fks"])
    tables  = schema["tables"]
    anchors = _anchor_tables(tables)

    join_paths: dict = {}

    # Caminhos âncora <-> qualquer tabela
    for anchor in anchors:
        anchor_domain = classify_domain(anchor)
        for table in tables:
            if table == anchor:
                continue
            table_domain = classify_domain(table)
            key = f"{anchor.lower()}__to__{table.lower()}"
            if key in join_paths:
                continue
            path = bfs_path(graph, anchor, table, max_hops=4)
            if path and 2 <= len(path) <= 13:
                join_paths[key] = {
                    "description": f"De {anchor} até {table}",
                    "domains":     sorted({anchor_domain, table_domain}),
                    "path":        path,
                }

    # Caminhos dentro de cada domínio (entre tabelas do mesmo domínio)
    by_domain: dict[str, list[str]] = defaultdict(list)
    for t in tables:
        by_domain[classify_domain(t)].append(t)

    for domain, members in by_domain.items():
        for i, a in enumerate(members):
            for b in members[i + 1:]:
                key = f"{domain}__{a.lower()}__to__{b.lower()}"
                if key in join_paths:
                    continue
                path = bfs_path(graph, a, b, max_hops=3)
                if path and 2 <= len(path) <= 9:
                    join_paths[key] = {
                        "description": f"Join dentro de {domain}: {a} <-> {b}",
                        "domains":     [domain],
                        "path":        path,
                    }

    out_path = DB_MAP_SCHEMA_DIR / "joins.yaml"
    out_path.write_text(
        yaml.dump({"joinPaths": join_paths}, Dumper=yaml_dumper(), allow_unicode=True,
                  default_flow_style=False, sort_keys=True),
        encoding="utf-8"
    )
    print(f"  joins.yaml -> {len(join_paths)} caminhos detectados")


if __name__ == "__main__":
    print("Extraindo schema...")
    schema = extract_all()
    print("Gerando joins...")
    generate(schema)
    print("Concluído.")
