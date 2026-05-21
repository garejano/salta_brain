"""
salta_config.py — configuração compartilhada para scripts Python do salta_brain.

Importe assim em qualquer script em _scripts/:
    from salta_config import SALTA_BRAIN, ANGULAR_FRONTENDS, FRONTEND_MAPS_DIR

Não precisa de pip install — usa apenas stdlib do Python.
"""

from pathlib import Path

# ---------------------------------------------------------------------------
# Caminhos base
# ---------------------------------------------------------------------------

# Raiz do salta_brain (pasta pai deste arquivo)
SALTA_BRAIN: Path = Path(__file__).resolve().parent.parent

# Base de todos os projetos (c:/projects)
PROJECTS_BASE: Path = SALTA_BRAIN.parent

# ---------------------------------------------------------------------------
# Diretórios dentro do salta_brain
# ---------------------------------------------------------------------------

FRONTEND_MAPS_DIR: Path = SALTA_BRAIN / "frontend-maps"
SCRIPTS_DIR:       Path = SALTA_BRAIN / "_scripts"
CARDS_DIR:         Path = SALTA_BRAIN / "cards"
ARCHIVE_DIR:       Path = SALTA_BRAIN / "_archive"

# ---------------------------------------------------------------------------
# Arquivos de saída/índice
# ---------------------------------------------------------------------------

REPOSITORY_MAP:      Path = SALTA_BRAIN / "repository_map.md"
FRONTEND_CHANGELOG:  Path = FRONTEND_MAPS_DIR / "changelog.md"

# ---------------------------------------------------------------------------
# Frontends Angular conhecidos
# key   = nome do repositório (igual à entrada em repository_map.md)
# value = caminho para a pasta raiz do frontend Angular (onde tsconfig.json fica)
# ---------------------------------------------------------------------------

ANGULAR_FRONTENDS: dict[str, Path] = {
    "atlas":                           PROJECTS_BASE / "atlas"                    / "frontend",
    "estrutura-pedagogica":            PROJECTS_BASE / "estrutura-pedagogica"     / "frontend",
    "notas":                           PROJECTS_BASE / "notas"                    / "frontend",
    "documentacao-pedagogica":         PROJECTS_BASE / "documentacao-pedagogica"  / "frontend",
    "documentacao-pedagogica-diario":  PROJECTS_BASE / "documentacao-pedagogica"  / "frontend-diario-classe",
    "aulas-comportamento":             PROJECTS_BASE / "aulas"                    / "frontend-comportamento",
    "aulas-consulta":                  PROJECTS_BASE / "aulas"                    / "frontend-consulta-aulas",
    "frequencia":                      PROJECTS_BASE / "frequencia"               / "frontend",
}

# ---------------------------------------------------------------------------
# Configurações gerais
# ---------------------------------------------------------------------------

# Dias antes de o mapa ser considerado stale (o command sugere reescan)
STALE_SCAN_DAYS: int = 30

# Extensões de arquivo varridas pelo scanner Angular
ANGULAR_EXTENSIONS: tuple[str, ...] = (".ts",)

# Pastas ignoradas durante o scan
SCAN_IGNORE_DIRS: set[str] = {
    "node_modules", ".angular", "dist", "coverage",
    ".git", "__pycache__", ".cache",
}
