#!/usr/bin/env python3
"""
fusionplace-skill スキルを配布用の zip にまとめるスクリプト。

Usage:
    python3 package_skill.py [output-directory]

Example:
    python3 package_skill.py            # カレントディレクトリに fusionplace-skill.zip を作成
    python3 package_skill.py ./dist     # ./dist/fusionplace-skill.zip を作成
"""

import fnmatch
import sys
import zipfile
from pathlib import Path

SKILL_NAME = "fusionplace-skill"
REPO_ROOT = Path(__file__).resolve().parent

# スキル本体として zip に含めるディレクトリ。配下のファイルを再帰的にすべて含める。
# evals/・.claude/・CLAUDE.md・LICENSE/README 等はこのディレクトリの外にあるため含まれない。
SKILL_DIR = REPO_ROOT / SKILL_NAME

EXCLUDE_DIR_NAMES = {"__pycache__", "node_modules", ".git"}
EXCLUDE_FILE_NAMES = {".DS_Store"}
EXCLUDE_GLOBS = ("*.pyc",)


def should_exclude(rel_path: Path) -> bool:
    if any(part in EXCLUDE_DIR_NAMES for part in rel_path.parts):
        return True
    if rel_path.name in EXCLUDE_FILE_NAMES:
        return True
    return any(fnmatch.fnmatch(rel_path.name, pat) for pat in EXCLUDE_GLOBS)


def iter_files():
    if not (SKILL_DIR / "SKILL.md").is_file():
        sys.exit(f"error: {SKILL_DIR / 'SKILL.md'} not found")
    for file_path in sorted(SKILL_DIR.rglob("*")):
        if file_path.is_file():
            yield file_path


def package_skill(output_dir: Path) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    zip_path = output_dir / f"{SKILL_NAME}.zip"

    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for file_path in iter_files():
            rel_path = file_path.relative_to(SKILL_DIR)
            if should_exclude(rel_path):
                print(f"  skipped: {rel_path}")
                continue
            arcname = Path(SKILL_NAME) / rel_path
            zf.write(file_path, arcname)
            print(f"  added:   {arcname}")

    return zip_path


def main():
    output_dir = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else REPO_ROOT
    print(f"packaging skill '{SKILL_NAME}' -> {output_dir}")
    zip_path = package_skill(output_dir)
    print(f"\ncreated: {zip_path}")


if __name__ == "__main__":
    main()
