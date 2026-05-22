"""
run_all.py — Orquestra todos os geradores do db_map e atualiza changelog.md.

Uso:
    python run_all.py

Variáveis de ambiente opcionais (ver salta_config.py):
    SALTA_DB_SERVER   — servidor SQL Server (padrão: localhost)
    SALTA_DB_NAME     — banco (padrão: ElevaPortalHomolog)
    SALTA_DB_DRIVER   — driver ODBC (padrão: ODBC Driver 17 for SQL Server)
"""

import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import (
    DB_MAP_CHANGELOG, DB_MAP_DIR,
    SQLSERVER_HOST, SQLSERVER_DATABASE, SQLSERVER_USER,
)

from extractor           import extract_all
from generate_schema_yaml import generate as gen_schema
from generate_joins       import generate as gen_joins
from generate_mermaid     import generate as gen_mermaid
from generate_domains     import generate as gen_domains


def _update_changelog(elapsed: float, stats: dict) -> None:
    DB_MAP_DIR.mkdir(parents=True, exist_ok=True)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    entry = (
        f"## {now}\n"
        f"- Banco: `{SQLSERVER_DATABASE}` em `{SQLSERVER_HOST}` (usuário: `{SQLSERVER_USER}`)\n"
        f"- Tabelas: {stats.get('tables', '?')}  |  "
        f"FKs: {stats.get('fks', '?')}  |  "
        f"Views: {stats.get('views', '?')}\n"
        f"- Tempo de extração: {elapsed:.1f}s\n"
    )

    existing = DB_MAP_CHANGELOG.read_text(encoding="utf-8") if DB_MAP_CHANGELOG.exists() else ""
    DB_MAP_CHANGELOG.write_text(entry + "\n" + existing, encoding="utf-8")
    print(f"\n  changelog.md atualizado ({now})")


def main() -> None:
    print("=" * 60)
    print(f"db_map extractor — {SQLSERVER_DATABASE} @ {SQLSERVER_HOST} ({SQLSERVER_USER})")
    print("=" * 60)

    t0 = time.time()

    print("\n[1/5] Extraindo schema do banco...")
    schema = extract_all()
    tables_n = len(schema["tables"])
    fks_n    = len(schema["fks"])
    views_n  = len(schema["views"])
    print(f"  {tables_n} tabelas, {fks_n} FKs, {views_n} views")

    print("\n[2/5] Gerando schema YAML...")
    gen_schema(schema)

    print("\n[3/5] Gerando join paths...")
    gen_joins(schema)

    print("\n[4/5] Gerando diagramas Mermaid...")
    gen_mermaid(schema)

    print("\n[5/5] Gerando domain docs...")
    gen_domains(schema)

    elapsed = time.time() - t0
    _update_changelog(elapsed, {"tables": tables_n, "fks": fks_n, "views": views_n})

    print(f"\nConcluído em {elapsed:.1f}s")
    print(f"Saída em: {DB_MAP_DIR}")


if __name__ == "__main__":
    main()
