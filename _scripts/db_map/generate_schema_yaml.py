"""
generate_schema_yaml.py — Gera schema/tables.yaml, schema/relations.yaml e schema/views.yaml.

Uso:
    python generate_schema_yaml.py
"""

import sys
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import DB_MAP_SCHEMA_DIR

from extractor import extract_all
from common import classify_domain, is_audit_column, yaml_dumper


def generate(schema: dict) -> None:
    DB_MAP_SCHEMA_DIR.mkdir(parents=True, exist_ok=True)

    # ---- tables.yaml ----
    tables_out: dict = {}
    for name, info in sorted(schema["tables"].items()):
        entry: dict = {}
        if info["pk"]:
            entry["pk"] = info["pk"][0] if len(info["pk"]) == 1 else info["pk"]
        if info["description"]:
            entry["description"] = info["description"]

        # Colunas importantes: PKs + FKs de negócio + primeiras 5 não-nullable não-auditoria
        fk_cols = {r["via"] for r in info["relations"] if not is_audit_column(r["via"])}
        pk_cols = set(info["pk"])
        important = sorted(pk_cols | fk_cols)
        non_key_non_audit = [
            c["name"] for c in info["columns"]
            if not c["nullable"]
            and c["name"] not in pk_cols
            and c["name"] not in fk_cols
            and not is_audit_column(c["name"])
        ]
        important += non_key_non_audit[:5]
        if important:
            entry["importantColumns"] = important

        # Relações — apenas FKs de negócio
        business_rels = [r for r in info["relations"] if not is_audit_column(r["via"])]
        if business_rels:
            entry["relations"] = [{"to": r["to"], "via": r["via"]} for r in business_rels]

        tables_out[name] = entry

    tables_path = DB_MAP_SCHEMA_DIR / "tables.yaml"
    tables_path.write_text(
        yaml.dump({"tables": tables_out}, Dumper=yaml_dumper(), allow_unicode=True,
                  default_flow_style=False, sort_keys=False),
        encoding="utf-8"
    )
    print(f"  tables.yaml   -> {len(tables_out)} tabelas")

    # ---- relations.yaml — apenas FKs de negócio ----
    relations_out: list = []
    for fk in schema["fks"]:
        if is_audit_column(fk["parent_column"]):
            continue
        relations_out.append({
            "fk":   fk["fk_name"],
            "from": f"{fk['parent_table']}.{fk['parent_column']}",
            "to":   f"{fk['referenced_table']}.{fk['referenced_column']}",
        })

    relations_path = DB_MAP_SCHEMA_DIR / "relations.yaml"
    relations_path.write_text(
        yaml.dump({"relations": relations_out}, Dumper=yaml_dumper(), allow_unicode=True,
                  default_flow_style=False, sort_keys=False),
        encoding="utf-8"
    )
    print(f"  relations.yaml -> {len(relations_out)} FKs de negócio (de {len(schema['fks'])} totais)")

    # ---- views.yaml ----
    views_out: dict = {}
    for v in sorted(schema["views"], key=lambda x: x["name"]):
        entry: dict = {"domain": classify_domain(v["name"])}
        if v["description"]:
            entry["description"] = v["description"]
        if v["columns"]:
            entry["columns"] = [{"name": c["name"], "type": c["type"]} for c in v["columns"]]
        views_out[v["name"]] = entry

    views_path = DB_MAP_SCHEMA_DIR / "views.yaml"
    views_path.write_text(
        yaml.dump({"views": views_out}, Dumper=yaml_dumper(), allow_unicode=True,
                  default_flow_style=False, sort_keys=False),
        encoding="utf-8"
    )
    encrypted = sum(1 for v in schema["views"] if not v["columns"])
    print(f"  views.yaml    -> {len(views_out)} views ({encrypted} encriptadas, sem colunas)")


if __name__ == "__main__":
    print("Extraindo schema...")
    schema = extract_all()
    print("Gerando YAML...")
    generate(schema)
    print("Concluído.")
