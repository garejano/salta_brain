"""
extractor.py — Conecta no SQL Server e extrai o schema bruto.

Uso direto:
    python extractor.py              # imprime resumo do schema
    python extractor.py --tables     # lista tabelas
    python extractor.py --fks        # lista FKs

Importado pelos outros scripts do db_map:
    from extractor import extract_all
"""

import sys
import json
import argparse
from pathlib import Path

# Adiciona _scripts/ ao path para importar salta_config
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import (
    SQLSERVER_HOST, SQLSERVER_DATABASE, SQLSERVER_DRIVER,
    SQLSERVER_USER, SQLSERVER_PASSWORD,
    SQLSERVER_ENCRYPT, SQLSERVER_TRUST_CERT,
)

try:
    import pyodbc
except ImportError:
    print("ERRO: pyodbc não instalado. Execute: pip install pyodbc")
    sys.exit(1)


def get_connection() -> "pyodbc.Connection":
    # Mesmos parâmetros do MCP sqlserver (claude_desktop_config.json)
    conn_str = (
        f"DRIVER={{{SQLSERVER_DRIVER}}};"
        f"SERVER={SQLSERVER_HOST};"
        f"DATABASE={SQLSERVER_DATABASE};"
        f"UID={SQLSERVER_USER};"
        f"PWD={SQLSERVER_PASSWORD};"
        f"Encrypt={'yes' if SQLSERVER_ENCRYPT.lower() == 'true' else 'no'};"
        f"TrustServerCertificate={'yes' if SQLSERVER_TRUST_CERT.lower() == 'true' else 'no'};"
    )
    return pyodbc.connect(conn_str, timeout=10)


# ---------------------------------------------------------------------------
# Queries
# ---------------------------------------------------------------------------

_SQL_TABLES = """
SELECT
    t.name        AS table_name,
    CAST(ep.value AS NVARCHAR(500)) AS description
FROM sys.tables t
LEFT JOIN sys.extended_properties ep
    ON ep.major_id = t.object_id
    AND ep.minor_id = 0
    AND ep.name = 'MS_Description'
ORDER BY t.name
"""

_SQL_COLUMNS = """
SELECT
    t.name        AS table_name,
    c.name        AS column_name,
    tp.name       AS data_type,
    c.max_length,
    c.is_nullable,
    c.column_id,
    CAST(ep.value AS NVARCHAR(500)) AS description
FROM sys.columns c
JOIN sys.tables  t  ON c.object_id      = t.object_id
JOIN sys.types   tp ON c.user_type_id   = tp.user_type_id
LEFT JOIN sys.extended_properties ep
    ON ep.major_id  = c.object_id
    AND ep.minor_id = c.column_id
    AND ep.name     = 'MS_Description'
ORDER BY t.name, c.column_id
"""

_SQL_PKS = """
SELECT
    t.name  AS table_name,
    c.name  AS column_name,
    ic.key_ordinal
FROM sys.key_constraints kc
JOIN sys.tables       t  ON kc.parent_object_id = t.object_id
JOIN sys.index_columns ic ON ic.object_id = t.object_id
                          AND ic.index_id  = kc.unique_index_id
JOIN sys.columns       c  ON c.object_id  = t.object_id
                          AND c.column_id  = ic.column_id
WHERE kc.type = 'PK'
ORDER BY t.name, ic.key_ordinal
"""

_SQL_FKS = """
SELECT
    fk.name            AS fk_name,
    tp.name            AS parent_table,
    cp.name            AS parent_column,
    tr.name            AS referenced_table,
    cr.name            AS referenced_column
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id           = fkc.constraint_object_id
JOIN sys.tables  tp ON fkc.parent_object_id                = tp.object_id
JOIN sys.columns cp ON fkc.parent_object_id                = cp.object_id
                    AND fkc.parent_column_id               = cp.column_id
JOIN sys.tables  tr ON fkc.referenced_object_id            = tr.object_id
JOIN sys.columns cr ON fkc.referenced_object_id            = cr.object_id
                    AND fkc.referenced_column_id           = cr.column_id
ORDER BY tp.name, fk.name
"""

_SQL_VIEWS = """
SELECT
    v.name        AS view_name,
    CAST(ep.value AS NVARCHAR(500)) AS description
FROM sys.views v
LEFT JOIN sys.extended_properties ep
    ON ep.major_id = v.object_id
    AND ep.minor_id = 0
    AND ep.name = 'MS_Description'
ORDER BY v.name
"""

_SQL_VIEW_COLUMNS = """
SELECT
    v.name      AS view_name,
    c.name      AS column_name,
    tp.name     AS data_type,
    c.column_id
FROM sys.views v
JOIN sys.columns c  ON c.object_id      = v.object_id
JOIN sys.types   tp ON c.user_type_id   = tp.user_type_id
ORDER BY v.name, c.column_id
"""


# ---------------------------------------------------------------------------
# Funções de extração
# ---------------------------------------------------------------------------

def _rows(cursor, sql: str) -> list[dict]:
    cursor.execute(sql)
    cols = [d[0] for d in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def extract_all() -> dict:
    """Retorna schema completo como dict Python."""
    conn = get_connection()
    cur  = conn.cursor()

    raw_tables      = _rows(cur, _SQL_TABLES)
    raw_columns     = _rows(cur, _SQL_COLUMNS)
    raw_pks         = _rows(cur, _SQL_PKS)
    raw_fks         = _rows(cur, _SQL_FKS)
    raw_views       = _rows(cur, _SQL_VIEWS)
    raw_view_cols   = _rows(cur, _SQL_VIEW_COLUMNS)

    conn.close()

    # --- montar estrutura por tabela ---
    tables: dict[str, dict] = {}
    for row in raw_tables:
        name = row["table_name"]
        tables[name] = {
            "description": row["description"] or "",
            "columns":     [],
            "pk":          [],
            "relations":   [],   # preenchido abaixo
        }

    for row in raw_columns:
        t = row["table_name"]
        if t in tables:
            tables[t]["columns"].append({
                "name":        row["column_name"],
                "type":        row["data_type"],
                "nullable":    bool(row["is_nullable"]),
                "description": row["description"] or "",
            })

    pk_map: dict[str, list[str]] = {}
    for row in raw_pks:
        pk_map.setdefault(row["table_name"], []).append(row["column_name"])
    for t, cols in pk_map.items():
        if t in tables:
            tables[t]["pk"] = cols

    # FKs brutas
    fks: list[dict] = []
    for row in raw_fks:
        fks.append({
            "fk_name":          row["fk_name"],
            "parent_table":     row["parent_table"],
            "parent_column":    row["parent_column"],
            "referenced_table": row["referenced_table"],
            "referenced_column":row["referenced_column"],
        })
        # relação resumida na tabela pai
        if row["parent_table"] in tables:
            tables[row["parent_table"]]["relations"].append({
                "to":  row["referenced_table"],
                "via": row["parent_column"],
                "ref": row["referenced_column"],
            })

    # Agrupa colunas por view
    view_cols_map: dict[str, list[dict]] = {}
    for row in raw_view_cols:
        vn = row["view_name"]
        view_cols_map.setdefault(vn, []).append({
            "name": row["column_name"],
            "type": row["data_type"],
        })

    views = [
        {
            "name":        r["view_name"],
            "description": r["description"] or "",
            "columns":     view_cols_map.get(r["view_name"], []),
        }
        for r in raw_views
    ]

    return {
        "database": SQLSERVER_DATABASE,
        "server":   SQLSERVER_HOST,
        "tables":   tables,
        "fks":      fks,
        "views":    views,
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Extrai schema do SQL Server")
    parser.add_argument("--tables", action="store_true", help="Lista tabelas")
    parser.add_argument("--fks",    action="store_true", help="Lista FKs")
    parser.add_argument("--json",   action="store_true", help="Output JSON completo")
    args = parser.parse_args()

    print(f"Conectando em {SQLSERVER_HOST}/{SQLSERVER_DATABASE} (usuário: {SQLSERVER_USER})...")
    schema = extract_all()

    if args.json:
        print(json.dumps(schema, indent=2, ensure_ascii=False, default=str))
    elif args.tables:
        for name in sorted(schema["tables"]):
            pk = ", ".join(schema["tables"][name]["pk"]) or "—"
            print(f"  {name:50s}  PK: {pk}")
    elif args.fks:
        for fk in schema["fks"]:
            print(f"  {fk['parent_table']}.{fk['parent_column']}  ->  {fk['referenced_table']}.{fk['referenced_column']}")
    else:
        t_count = len(schema["tables"])
        v_count = len(schema["views"])
        fk_count = len(schema["fks"])
        print(f"Tabelas: {t_count}  |  Views: {v_count}  |  FKs: {fk_count}")
