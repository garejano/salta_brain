"""
common.py — Utilidades compartilhadas entre os scripts do db_map.

Importar assim:
    from common import classify_domain, build_business_graph, bfs_path, yaml_dumper
"""

import sys
from collections import defaultdict, deque
from pathlib import Path

import yaml

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import DOMAIN_KEYWORDS

# ---------------------------------------------------------------------------
# Colunas de auditoria — excluídas do grafo de joins de negócio
# ---------------------------------------------------------------------------

# Colunas que existem em praticamente toda tabela para rastreio de auditoria.
# FKs que passam por elas conectam qualquer par de tabelas via Usuario/Data,
# gerando ruído alto no BFS.
_AUDIT_STARTSWITH = ("Usuario", "Data")
_AUDIT_EXACT = frozenset({"Hash", "HashTemp", "HashOrigem", "EventTime", "Ativo"})

# Datas que SÃO joins de negócio (não auditoria)
_DATE_BUSINESS_WHITELIST = frozenset({"DataAula", "DataNascimento", "DataMatricula",
                                       "DataInicio", "DataTermino", "DataEvento"})


def is_audit_column(col_name: str) -> bool:
    """True se a coluna é de auditoria/metadado e não deve virar aresta de join."""
    if col_name in _AUDIT_EXACT:
        return True
    if col_name.startswith("Usuario"):
        return True
    if col_name.startswith("Data") and col_name not in _DATE_BUSINESS_WHITELIST:
        return True
    return False


# ---------------------------------------------------------------------------
# Grafo de FKs
# ---------------------------------------------------------------------------

def build_business_graph(fks: list[dict]) -> dict[str, list[tuple[str, str, str]]]:
    """
    Grafo bidirecional de FKs de negócio.
    Exclui arestas onde a coluna FK é de auditoria (is_audit_column=True).
    Formato: tabela -> [(vizinho, col_origem, col_destino)]
    """
    graph: dict[str, list] = defaultdict(list)
    for fk in fks:
        pc = fk["parent_column"]
        rc = fk["referenced_column"]
        if is_audit_column(pc) or is_audit_column(rc):
            continue
        p = fk["parent_table"]
        r = fk["referenced_table"]
        graph[p].append((r, pc, rc))
        graph[r].append((p, rc, pc))
    return dict(graph)


# ---------------------------------------------------------------------------
# BFS
# ---------------------------------------------------------------------------

def bfs_path(graph: dict, start: str, end: str,
             max_hops: int = 5) -> list[str] | None:
    """
    BFS entre duas tabelas no grafo de negócio.
    Retorna lista alternando TABELA e TABELA.COLUNA, ou None se não encontrado.
    Exemplo: ["TB_A", "TB_A.col_fk", "TB_B.col_ref", "TB_B"]
    """
    if start == end:
        return [start]
    visited = {start}
    queue: deque = deque()
    queue.append((start, [start]))
    while queue:
        node, path = queue.popleft()
        if len(path) > max_hops * 2 + 1:
            continue
        for neighbor, col_from, col_to in graph.get(node, []):
            if neighbor in visited:
                continue
            new_path = path + [f"{node}.{col_from}", f"{neighbor}.{col_to}", neighbor]
            if neighbor == end:
                return new_path
            visited.add(neighbor)
            queue.append((neighbor, new_path))
    return None


# ---------------------------------------------------------------------------
# Classificação de domínio
# ---------------------------------------------------------------------------

def classify_domain(name: str) -> str:
    """Classifica tabela ou view em um domínio pelo nome."""
    upper = name.upper()
    for domain, keywords in DOMAIN_KEYWORDS.items():
        if any(kw in upper for kw in keywords):
            return domain
    return "outros"


# ---------------------------------------------------------------------------
# YAML dumper sem aliases
# ---------------------------------------------------------------------------

def yaml_dumper() -> type:
    """Retorna subclasse de yaml.Dumper sem aliases e com unicode."""
    class _D(yaml.Dumper):
        pass
    _D.ignore_aliases = lambda *_: True
    return _D
