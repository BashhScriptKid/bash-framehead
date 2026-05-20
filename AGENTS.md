# Repository Guidelines

## Project Structure & Module Organization
- Single-file Bash stdlib built from [src/](/home/bashh/Documents/! Codes/bash-framehead/src) modules (18 files; `runtime.sh` is required by all).  
- Tooling scripts live at repo root: `main.sh` (compiler/test/stats runner), `tester.sh` (≈2000 test functions), `wiki-gen.sh` (docs), and compiled artifacts (git-ignored) such as `bash-framehead.sh`.  
- Working copies and experimental builds (e.g., `bash-framehead_opt_full.sh`, `bash-framehead_ieee754_wip.sh`) stay at root; avoid committing generated outputs.

## Build, Test, and Development Commands
- Fast dev build (no minify): `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
- Optimized build: `OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
- Full optimize+minify (slow; minifier can hang): `OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''` — use only if minifier is healthy.
- Run tests: `./main.sh test ./bash-framehead.sh`
- Stats: `./main.sh stat ./bash-framehead.sh`
- Development mode (no compile): `source ./main.sh` to auto-source all modules for rapid editing.

## Coding Style & Naming Conventions
- Language: Bash 4.3+. Prefer pure Bash; external tools only where already used (e.g., `bc` for floats).
- Function names: `module::function`; private helpers `_module::helper`; fast variants `module::function::fast` (nameref pattern).
- One module per concern; no horizontal dependencies except via `runtime.sh`.
- Follow existing formatting; keep ASCII; add comments only where non-obvious.

## Testing Guidelines
- Tests live in `tester.sh`; each test is `test::module::function()`.
- Use `_assert "label" "expected" "actual"`; call `_sub_done` after grouped asserts; `_skip "reason"` for environment-sensitive cases.
- Run `./main.sh test ./bash-framehead.sh` after changes; keep new public functions covered.

## Commit & Pull Request Guidelines
- Commit messages: present-tense, concise scope (“fix pfloat div guard”). Group related edits; do not commit compiled artifacts.
- PRs/CLs should include: summary of change, key commands run (e.g., tests/build), notable warnings (e.g., ShellCheck). Link issues when applicable.

## Agent-Specific Notes
- Minifier and tokenizer are performance hotspots; when debugging them, add temporary progress logs and be ready to fall back to non-minified builds.
- Avoid touching `runtime.sh` unless coordinated; it is a shared dependency for all modules.
