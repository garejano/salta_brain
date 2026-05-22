"""
generate_domains.py — Gera domains/*.md com conceitos, notas e tabelas por domínio.

Uso:
    python generate_domains.py
"""

import sys
from pathlib import Path
from collections import defaultdict

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from salta_config import DB_MAP_DOMAINS_DIR

from extractor import extract_all
from common import classify_domain, is_audit_column


# Descrições manuais por domínio — conceitos e notas de schema estáveis.
# NÃO incluir "flow" aqui: fluxos são derivados do schema real (ver _derive_hubs).
DOMAIN_DESCRIPTIONS: dict[str, dict] = {
    "frequencia": {
        "title": "Frequência",
        "concepts": [
            "AulaEvento: registro de uma aula realizada em uma turma (possui Turma, DataInicio, PossuiFrequencia)",
            "AlunoFalta: ausência registrada por aluno em uma data (Pessoa + DataAula + TipoPresenca)",
            "AlunoFrequencia: frequência consolidada por aluno/escola/turno/data",
            "TipoPresenca: lookup de status de presença (Presenca, Atraso, Falta)",
            "ViewChamadaPorAula: view que cruza aula + aluno + status — ponto de entrada recomendado para queries",
        ],
        "notes": [
            "A ligação AulaEvento -> aluno com status de presença existe em views encriptadas (ViewChamadaPorAula).",
            "AlunoFalta registra faltas por Pessoa.Id + DataAula, sem FK direta para AulaEvento.",
            "Para queries de frequência por turma: usar ViewChamadaPorAula (IdTurma, NomeAluno, DataAula, NomeTipoPresenca).",
        ],
    },
    "avaliacao": {
        "title": "Avaliação / Notas",
        "concepts": [
            "Avaliacao: instrumento de avaliação aplicado a uma turma",
            "Nota: valor atribuído a um aluno em uma avaliação",
            "Bimestre: período letivo de referência",
        ],
        "notes": [],
    },
    "academico": {
        "title": "Acadêmico",
        "concepts": [
            "AlunoEscola: matrícula do aluno em uma escola/ano letivo",
            "Turma: grupo de alunos de uma série em uma escola",
            "EscolaSerie: série ofertada por uma escola em um ano letivo",
            "AnoLetivo: ano letivo (Id = o próprio ano, ex: 2026; Vigente=1 indica o corrente)",
        ],
        "notes": [
            "AlunoEscola.AlunoEscola_key é FK para PessoaEscolaAcesso.Id, NÃO para Pessoa.Id.",
            "AlunoEscola.AnoLetivo armazena o valor numérico do ano diretamente (não FK convencional).",
            "Turma.EscolaSerie, EscolaSerie.Escola, Escola.Rede são IDs diretos sem sufixo `Id`.",
        ],
    },
    "acesso": {
        "title": "Acesso / Identidade",
        "concepts": [
            "Pessoa: identidade central (contém Hash único)",
            "PessoaEscola: vínculo de uma Pessoa com uma Escola",
            "PessoaEscolaAcesso: credencial de acesso ao portal (Id referenciado por AlunoEscola_key)",
        ],
        "notes": [
            "Para obter hash do aluno: AlunoEscola_key -> PessoaEscolaAcesso -> PessoaEscola -> Pessoa.Hash",
        ],
    },
    "outros": {
        "title": "Outros",
        "concepts": [],
        "notes": ["Tabelas sem classificação por palavra-chave de domínio."],
    },
}


def _derive_hubs(tables: list[str], all_tables: dict) -> list[str]:
    """Tabelas do domínio com mais FKs de negócio de saída — candidatas a hubs."""
    scores: dict[str, int] = {}
    for t in tables:
        info = all_tables.get(t, {})
        business_rels = [r for r in info.get("relations", []) if not is_audit_column(r["via"])]
        scores[t] = len(business_rels)
    ranked = sorted(tables, key=lambda t: scores.get(t, 0), reverse=True)
    return [t for t in ranked[:5] if scores.get(t, 0) > 0]


def _domain_views(domain: str, views: list[dict]) -> list[dict]:
    """Filtra views do schema cujo nome pertence ao domínio dado."""
    return [v for v in views if classify_domain(v["name"]) == domain]


def _md_for_domain(domain: str, tables: list[str], all_tables: dict,
                   views: list[dict]) -> str:
    desc = DOMAIN_DESCRIPTIONS.get(
        domain,
        {"title": domain.title(), "concepts": [], "notes": []}
    )
    lines = [f"# {desc['title']}", ""]

    if desc["concepts"]:
        lines += ["## Conceitos principais", ""]
        for c in desc["concepts"]:
            lines.append(f"- {c}")
        lines.append("")

    if desc["notes"]:
        lines += ["## Notas de schema", ""]
        for n in desc["notes"]:
            lines.append(f"- {n}")
        lines.append("")

    # Hubs derivados do schema real
    hubs = _derive_hubs(tables, all_tables)
    if hubs:
        lines += ["## Tabelas principais (hubs)", ""]
        for t in hubs:
            info = all_tables.get(t, {})
            pk   = ", ".join(info.get("pk", [])) or "—"
            rels = [r for r in info.get("relations", []) if not is_audit_column(r["via"])]
            lines.append(f"- **{t}** (PK: `{pk}`) — {len(rels)} FK(s) de negócio")
        lines.append("")

    lines += ["## Todas as tabelas", ""]
    for t in sorted(tables):
        info    = all_tables.get(t, {})
        pk      = ", ".join(info.get("pk", [])) or "—"
        desc_t  = info.get("description", "")
        rels    = [r for r in info.get("relations", []) if not is_audit_column(r["via"])]
        suffix  = f" — {desc_t}" if desc_t else ""
        lines.append(f"- **{t}** (PK: `{pk}`, {len(rels)} FK(s) negócio){suffix}")
    lines.append("")

    # Views do domínio
    domain_views = _domain_views(domain, views)
    if domain_views:
        lines += ["## Views disponíveis", ""]
        for v in sorted(domain_views, key=lambda x: x["name"]):
            col_names = [c["name"] for c in v.get("columns", [])]
            desc_v    = v.get("description", "")
            if col_names:
                lines.append(f"- **{v['name']}** — colunas: `{'`, `'.join(col_names)}`")
            else:
                suffix_v = f" — {desc_v}" if desc_v else " (definição encriptada)"
                lines.append(f"- **{v['name']}**{suffix_v}")
        lines.append("")

    return "\n".join(lines) + "\n"


def generate(schema: dict) -> None:
    DB_MAP_DOMAINS_DIR.mkdir(parents=True, exist_ok=True)

    by_domain: dict[str, list[str]] = defaultdict(list)
    for t in schema["tables"]:
        by_domain[classify_domain(t)].append(t)

    for domain, tables in by_domain.items():
        content = _md_for_domain(domain, tables, schema["tables"], schema["views"])
        path    = DB_MAP_DOMAINS_DIR / f"{domain}.md"
        path.write_text(content, encoding="utf-8")
        print(f"  domains/{domain}.md -> {len(tables)} tabelas")


if __name__ == "__main__":
    print("Extraindo schema...")
    schema = extract_all()
    print("Gerando domains/...")
    generate(schema)
    print("Concluído.")
