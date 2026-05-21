"""
bench_scan_frontend.py — benchmark: mapa Angular vs análise direta, via Claude Code CLI.

Usa `claude -p` (modo não-interativo) para rodar dois fluxos contra a mesma tarefa:
  Flow A — Claude lê o mapa pré-gerado como primeiro passo, depois confirma nos arquivos
  Flow B — Claude explora o frontend diretamente sem mapa

Não requer ANTHROPIC_API_KEY — usa a sessão do Claude Code já autenticada.

Saída: _benchmark/runs/<timestamp>_results.md

Uso:
    python bench_scan_frontend.py
    python bench_scan_frontend.py --repo estrutura-pedagogica
    python bench_scan_frontend.py --flow a     # roda apenas Flow A
    python bench_scan_frontend.py --flow b     # roda apenas Flow B
    python bench_scan_frontend.py --model claude-sonnet-4-6
"""

import argparse
import json
import subprocess
import sys
import time
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from salta_config import SALTA_BRAIN, ANGULAR_FRONTENDS, FRONTEND_MAPS_DIR

BENCHMARK_DIR = SALTA_BRAIN / "_benchmark"
RUNS_DIR      = BENCHMARK_DIR / "runs"

DEFAULT_REPO  = "estrutura-pedagogica"
TIMEOUT_SEC   = 300  # 5 minutos por flow

# ---------------------------------------------------------------------------
# Tarefa
# ---------------------------------------------------------------------------

TASK_QUESTIONS = """
O time precisa adicionar o campo `nomeResponsavel` ao filtro de importação de alocação
de professores. Responda as 5 perguntas abaixo com o maior detalhe possível:

1. **Componente do filtro**: Qual componente Angular renderiza o filtro de importação
   de alocação de professores? Qual é o seu selector?

2. **Model/Interface**: Qual interface TypeScript define os campos do request de filtro
   para alocação de professores? Liste todos os campos existentes com seus tipos.

3. **Service HTTP**: Qual service faz a chamada HTTP para buscar os dados de importação?
   Qual é o nome exato do método que deve ser atualizado?

4. **Cadeia de dependências**: Descreva o fluxo completo do componente até a chamada HTTP
   (componente → service → método → endpoint).

5. **Arquivos a modificar**: Liste todos os arquivos (caminhos relativos a partir de
   `frontend/`) que precisarão ser modificados para adicionar o campo `nomeResponsavel`.
"""

# ---------------------------------------------------------------------------
# Gabarito para scoring automático
# ---------------------------------------------------------------------------

GABARITO: dict[str, list[str]] = {
    "P1": ["AlocacaoProfessoresComponent", "app-alocacao-professores"],
    "P2": ["ImportacaoAlocacaoProfessoresFilterRequest", "hashAnoLetivo", "hashRede"],
    "P3": ["ImportacaoAlocacaoProfessoresService", "getImportacoes"],
    "P4": [
        "AlocacaoProfessoresComponent",
        "ImportacaoAlocacaoProfessoresService",
        "getImportacoes",
        "importacaoalocacaoprofessores",
    ],
    "P5": [
        "cargas-iniciais.models.ts",
        "importacao-alocacao-professores.service.ts",
        "alocacao-professores.component.ts",
    ],
}

# ---------------------------------------------------------------------------
# Montagem dos prompts
# ---------------------------------------------------------------------------

def build_flow_a_prompt(map_path: Path, frontend_root: Path) -> str:
    return (
        f"Leia primeiro o mapa do frontend Angular em: {map_path}\n\n"
        "Use o mapa como ponto de partida. "
        "Tente responder usando apenas o mapa antes de abrir arquivos individuais. "
        "Se precisar confirmar algum detalhe, abra o arquivo específico.\n\n"
        f"Frontend Angular em: {frontend_root}\n"
        f"{TASK_QUESTIONS}"
    )


def build_flow_b_prompt(frontend_root: Path) -> str:
    return (
        f"Explore o frontend Angular em: {frontend_root}\n\n"
        f"{TASK_QUESTIONS}"
    )

# ---------------------------------------------------------------------------
# Execução via Claude Code CLI
# ---------------------------------------------------------------------------

def _claude_exe() -> str:
    """Retorna o nome correto do executável claude para o sistema operacional."""
    if sys.platform == "win32":
        return "claude.cmd"
    return "claude"


def run_claude_cli(prompt: str, cwd: Path, model: str | None, timeout: int = TIMEOUT_SEC) -> dict:
    cmd = [_claude_exe(), "-p", prompt, "--output-format", "stream-json", "--verbose"]
    if model:
        cmd += ["--model", model]

    t0 = time.time()
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
    except subprocess.TimeoutExpired:
        return _empty_result(error="timeout", elapsed=timeout)
    except FileNotFoundError:
        print("ERRO: `claude` não encontrado. Instale o Claude Code CLI e certifique-se de que está no PATH.")
        sys.exit(1)

    elapsed = time.time() - t0
    return _parse_stream_json(proc.stdout, proc.stderr, elapsed, proc.returncode)


def _empty_result(error: str, elapsed: float) -> dict:
    return {
        "tool_calls": [], "files_read": [], "globs_run": 0, "searches_run": 0,
        "final_answer": "", "cost_usd": 0.0, "num_turns": 0,
        "elapsed_sec": elapsed, "returncode": -1, "stderr": "", "error": error,
    }


def _parse_stream_json(stdout: str, stderr: str, elapsed: float, returncode: int) -> dict:
    tool_calls   : list[dict] = []
    files_read   : list[str]  = []
    globs_run    : int        = 0
    searches_run : int        = 0
    final_answer : str        = ""
    cost_usd     : float      = 0.0
    num_turns    : int        = 0

    for line in stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        etype = event.get("type")

        if etype == "assistant":
            for block in event.get("message", {}).get("content", []):
                if block.get("type") != "tool_use":
                    continue
                name   = block.get("name", "")
                inputs = block.get("input", {})
                tool_calls.append({"name": name, "inputs": inputs})
                if name == "Read":
                    files_read.append(inputs.get("file_path", ""))
                elif name == "Glob":
                    globs_run += 1
                elif name == "Grep":
                    searches_run += 1

        elif etype == "result":
            final_answer = event.get("result", "")
            cost_usd     = event.get("total_cost_usd") or event.get("cost_usd") or 0.0
            num_turns    = event.get("num_turns") or 0

    return {
        "tool_calls"  : tool_calls,
        "files_read"  : files_read,
        "globs_run"   : globs_run,
        "searches_run": searches_run,
        "final_answer": final_answer,
        "cost_usd"    : cost_usd,
        "num_turns"   : num_turns,
        "elapsed_sec" : elapsed,
        "returncode"  : returncode,
        "stderr"      : (stderr or "")[:500],
        "error"       : None,
    }

# ---------------------------------------------------------------------------
# Model de resultado + scoring
# ---------------------------------------------------------------------------

class FlowResult:
    def __init__(self, flow_name: str, data: dict):
        self.flow_name    = flow_name
        self.tool_calls   = data["tool_calls"]
        self.files_read   = data["files_read"]
        self.globs_run    = data["globs_run"]
        self.searches_run = data["searches_run"]
        self.final_answer = data["final_answer"]
        self.cost_usd     = data["cost_usd"]
        self.num_turns    = data["num_turns"]
        self.elapsed_sec  = data["elapsed_sec"]
        self.stderr       = data["stderr"]
        self.error        = data.get("error")
        self.score: dict[str, bool] = {}
        self.total_score = 0

    def compute_score(self):
        answer_lower = self.final_answer.lower()
        for q, keywords in GABARITO.items():
            self.score[q] = all(kw.lower() in answer_lower for kw in keywords)
        self.total_score = sum(self.score.values())

    def print_summary(self):
        if self.error:
            print(f"  ERRO: {self.error}")
            if self.stderr:
                print(f"  stderr: {self.stderr[:200]}")
            return
        print(f"  Score: {self.total_score}/5")
        print(f"  Tool calls: {len(self.tool_calls)} (Read={len(self.files_read)}, Grep={self.searches_run}, Glob={self.globs_run})")
        print(f"  Turns: {self.num_turns} | Custo: ${self.cost_usd:.4f} | Tempo: {self.elapsed_sec:.1f}s")

# ---------------------------------------------------------------------------
# Relatório Markdown
# ---------------------------------------------------------------------------

def render_report(results: list[FlowResult], repo: str) -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    lines = [
        f"# Benchmark — {repo}",
        "",
        f"**Data:** {now}  ",
        f"**Repo:** {repo}  ",
        f"**Executor:** Claude Code CLI (`claude -p`)",
        "",
        "---",
        "",
    ]

    for r in results:
        lines.append(f"## {r.flow_name}")
        lines.append("")

        if r.error:
            lines += [f"**ERRO:** {r.error}", "", "---", ""]
            continue

        lines += [
            "### Métricas de processo",
            "",
            "| Métrica | Valor |",
            "|---|---|",
            f"| Arquivos lidos (Read) | {len(r.files_read)} |",
            f"| Buscas (Grep)         | {r.searches_run} |",
            f"| Listagens (Glob)      | {r.globs_run} |",
            f"| Total tool calls      | {len(r.tool_calls)} |",
            f"| Turns                 | {r.num_turns} |",
            f"| Custo estimado (USD)  | ${r.cost_usd:.4f} |",
            f"| Tempo (s)             | {r.elapsed_sec:.1f} |",
            "",
            "### Tool calls em ordem",
            "",
            "```",
        ]
        for i, tc in enumerate(r.tool_calls, 1):
            first_val = list(tc["inputs"].values())[0] if tc["inputs"] else ""
            if isinstance(first_val, str) and len(str(first_val)) > 80:
                first_val = "…" + str(first_val)[-60:]
            lines.append(f"{i:>2}. {tc['name']}({first_val})")
        lines += [
            "```",
            "",
            "### Score de qualidade",
            "",
            "| Pergunta | Correto? |",
            "|---|---|",
        ]
        for q, hit in r.score.items():
            lines.append(f"| {q} | {'Sim' if hit else 'Não'} |")
        lines += [
            "",
            f"**Score: {r.total_score} / 5**",
            "",
            "### Resposta final",
            "",
            "```",
            r.final_answer[:4000] + ("…" if len(r.final_answer) > 4000 else ""),
            "```",
            "",
            "---",
            "",
        ]

    # Tabela comparativa (só quando os dois flows rodaram)
    complete = [r for r in results if not r.error]
    if len(complete) == 2:
        a, b = complete

        def w(va, vb, lower: bool = True) -> str:
            if va == vb:
                return "—"
            better = va < vb if lower else va > vb
            return "A" if better else "B"

        lines += [
            "## Comparativo Final",
            "",
            "| Métrica | Flow A (Mapa) | Flow B (Direto) | Vencedor |",
            "|---|---|---|---|",
            f"| Arquivos lidos     | {len(a.files_read)} | {len(b.files_read)} | {w(len(a.files_read), len(b.files_read))} |",
            f"| Total tool calls   | {len(a.tool_calls)} | {len(b.tool_calls)} | {w(len(a.tool_calls), len(b.tool_calls))} |",
            f"| Turns              | {a.num_turns} | {b.num_turns} | {w(a.num_turns, b.num_turns)} |",
            f"| Custo (USD)        | ${a.cost_usd:.4f} | ${b.cost_usd:.4f} | {w(a.cost_usd, b.cost_usd)} |",
            f"| Score qualidade    | {a.total_score}/5 | {b.total_score}/5 | {w(a.total_score, b.total_score, lower=False)} |",
            f"| Tempo (s)          | {a.elapsed_sec:.1f} | {b.elapsed_sec:.1f} | {w(a.elapsed_sec, b.elapsed_sec)} |",
            "",
        ]

    return "\n".join(lines)

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Benchmark Angular Map vs Análise Direta via Claude Code CLI"
    )
    parser.add_argument("--repo",  default=DEFAULT_REPO, choices=list(ANGULAR_FRONTENDS.keys()))
    parser.add_argument("--flow",  choices=["a", "b"], default=None, help="Roda apenas um flow")
    parser.add_argument("--model", default=None, help="Modelo a usar (ex: claude-sonnet-4-6)")
    args = parser.parse_args()

    frontend_root = ANGULAR_FRONTENDS[args.repo]
    map_path      = FRONTEND_MAPS_DIR / f"{args.repo}-angular-map.md"

    if not frontend_root.exists():
        print(f"AVISO: frontend não encontrado: {frontend_root}")

    results: list[FlowResult] = []

    if args.flow in (None, "a"):
        if not map_path.exists():
            print(f"\nAVISO: mapa não encontrado em {map_path}")
            print("  Gere com:  python _scripts/scan_angular.py " + args.repo)
            print("  Flow A rodará sem mapa — resultados podem ser iguais ao Flow B.\n")
        prompt = build_flow_a_prompt(map_path, frontend_root)
        print(f"\n{'='*60}\n  Flow A — Com Mapa Angular\n{'='*60}")
        data = run_claude_cli(prompt, cwd=frontend_root, model=args.model)
        r = FlowResult("Flow A — Com Mapa Angular", data)
        r.compute_score()
        results.append(r)
        r.print_summary()

    if args.flow in (None, "b"):
        prompt = build_flow_b_prompt(frontend_root)
        print(f"\n{'='*60}\n  Flow B — Análise Direta\n{'='*60}")
        data = run_claude_cli(prompt, cwd=frontend_root, model=args.model)
        r = FlowResult("Flow B — Análise Direta", data)
        r.compute_score()
        results.append(r)
        r.print_summary()

    RUNS_DIR.mkdir(parents=True, exist_ok=True)
    ts          = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_path = RUNS_DIR / f"{ts}_{args.repo}_results.md"
    report_path.write_text(render_report(results, args.repo), encoding="utf-8")

    print(f"\nRelatório salvo em: {report_path}")


if __name__ == "__main__":
    main()
