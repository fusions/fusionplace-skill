#!/usr/bin/env python3
"""
fusionplace-librarian スキルのトリガー評価スクリプト。
trigger_eval.json の各クエリを claude コマンドで実行し、
stream-json の tool_use イベントからスキルが発動したか判定する。
"""

import json
import subprocess
import sys
import os
import time
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

CLAUDE = str(Path(os.environ.get(
    "CLAUDE_EXE",
    r"C:\Users\鶴田大地\.vscode\extensions\anthropic.claude-code-2.1.119-win32-x64\resources\native-binary\claude.exe"
)))
PROJECT_DIR = Path(__file__).parent.parent
EVAL_FILE   = PROJECT_DIR / "evals" / "trigger_eval.json"
RESULTS_FILE = PROJECT_DIR / "evals" / "trigger_eval_results.json"
TIMEOUT = 240  # 秒 / クエリ（スキル発動時は WebFetch が走るため長め）

SKILL_NAME = "fusionplace-librarian"


def detect_skill_trigger(output: str) -> bool:
    """
    stream-json の出力から Skill ツール呼び出しを検出する。
    JSON パースに失敗した行は文字列フォールバックで判定。
    """
    for line in output.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            event = json.loads(line)
            # assistant イベント内の content を走査
            if event.get("type") == "assistant":
                content = event.get("message", {}).get("content", [])
                for block in content:
                    if (
                        block.get("type") == "tool_use"
                        and block.get("name") == "Skill"
                        and block.get("input", {}).get("skill") == SKILL_NAME
                    ):
                        return True
        except (json.JSONDecodeError, AttributeError):
            # JSON でない行はスキル名の単純文字列マッチで補完
            if f'"skill": "{SKILL_NAME}"' in line or f'"skill":"{SKILL_NAME}"' in line:
                return True
    return False


def run_query(query: str) -> tuple[bool, str, str]:
    """
    claude -p でクエリを実行し、(triggered, stdout, stderr) を返す。
    """
    cmd = [
        CLAUDE,
        "-p", query,
        "--output-format", "stream-json",
        "--verbose",
        "--permission-mode", "bypassPermissions",
        "--no-session-persistence",
    ]
    try:
        proc = subprocess.run(
            cmd,
            input="",          # stdin を即座に EOF にする
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            cwd=str(PROJECT_DIR),
            timeout=TIMEOUT,
            env={**os.environ, "PYTHONIOENCODING": "utf-8"},
        )
        triggered = detect_skill_trigger(proc.stdout + proc.stderr)
        return triggered, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired:
        print("  [WARN] timeout", flush=True)
        return False, "", "(timeout)"
    except Exception as exc:
        print(f"  [ERROR] {exc}", flush=True)
        return False, "", str(exc)


def main():
    if not Path(CLAUDE).exists():
        print(f"[ERROR] claude.exe が見つかりません: {CLAUDE}", file=sys.stderr)
        sys.exit(1)

    with open(EVAL_FILE, encoding="utf-8") as f:
        queries = json.load(f)

    results = []
    total = len(queries)
    passed_count = 0

    print(f"claude: {CLAUDE}")
    print(f"cwd   : {PROJECT_DIR}")
    print(f"queries: {total}")
    print("=" * 60)

    for i, item in enumerate(queries, 1):
        query = item["query"]
        should_trigger = item["should_trigger"]

        print(f"\n[{i:02d}/{total}] {query[:70]}", flush=True)
        t0 = time.time()
        triggered, stdout, stderr = run_query(query)
        elapsed = time.time() - t0

        passed = triggered == should_trigger
        if passed:
            passed_count += 1

        mark = "✓ PASS" if passed else "✗ FAIL"
        print(f"  {mark} | triggered={triggered} | expected={should_trigger} | {elapsed:.1f}s", flush=True)

        if not passed:
            # 失敗時は直近のログを表示
            for line in (stdout + stderr).splitlines()[-10:]:
                if line.strip():
                    print(f"  LOG: {line[:120]}", flush=True)

        results.append({
            "query": query,
            "should_trigger": should_trigger,
            "triggered": triggered,
            "passed": passed,
        })

    with open(RESULTS_FILE, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    print("\n" + "=" * 60)
    print(f"結果: {passed_count}/{total} passed ({100 * passed_count // total}%)")
    print(f"保存: {RESULTS_FILE}")


if __name__ == "__main__":
    main()
