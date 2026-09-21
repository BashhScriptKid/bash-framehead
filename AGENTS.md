# Repository Guidelines

## Project Structure & Module Organization
- Single-file Bash stdlib built from [src/](src/) modules (21 files; `runtime.sh` is required by all).  
- Extensions in [ext/](ext/) are self-contained units with documented `# Requires:` headers (e.g., `json → string → runtime`).
- Tooling scripts live at repo root: `main.sh` (compiler/test/stats runner), `tester.sh` (≈2000 test functions), `wiki-gen.sh` (docs), and compiled artifacts (git-ignored) such as `bash-framehead.sh`.  
- Working copies and experimental builds stay at root; avoid committing generated outputs.

## Build, Test, and Development Commands
- Fast dev build (no minify): `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
- Optimized build: `OPTIMIZE=1 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
- Full optimize+minify: `OPTIMIZE=1 MINIFY=1 ./main.sh compile out.sh <<< ''` — use only if minifier is healthy.
- Bare-minimum compile (call-graph tracing): `./main.sh compile_bare "<pattern>" [output.sh]` — emits only functions and globals reachable from the pattern (e.g., `"json::*"`).
- Run tests: `./main.sh test ./bash-framehead.sh`
- Stats: `./main.sh stat ./bash-framehead.sh`
- Development mode (no compile): `source ./main.sh` to auto-source all modules for rapid editing.

## Coding Style & Naming Conventions
- The authoritative style guide is [STYLING.md](STYLING.md).  All conventions below are summaries; the full guide takes precedence.
- Language: Bash 4.3+. Prefer pure Bash; external tools only where already used (e.g., `bc` for floats).
- **Indentation**: tabs only.
- **Column limit**: soft 80; break with `\` unless it ruins alignment.
- **Function names**: `module::function`; private helpers `_module::helper`; fast variants `module::function::fast` (nameref pattern).
- **Section separators**: `# --- Section Name ---` (no longer `=====`).
- One module per concern; no horizontal dependencies except via `runtime.sh`.
- ASCII only in comments; add comments only where non-obvious.

### Variable Naming
- Variables must be self-documenting; single-letter or abbreviated names are forbidden except as listed in [STYLING.md §2.1](STYLING.md).
- Exemptions: loop counters (`i`/`j`/`k`), Cartesian coords (`x`/`y`/`z`), color channels (`r`/`g`/`b`), PRNG state registers (`s0`/`s1`), Unix standard abbrevs (`_fd`/`_pid`).
- **Niche-context rule**: the more obscure the domain, the more explicit the name must be (`_codepoint` over `_cp`).
- **Algebraic leeway**: math/neural variables may use `{letter}_{disambiguated}` (`_W_weights`, `_lr_learning_rate`).

## Testing Guidelines
- Tests live in `tester.sh`; each test is `test::module::function()`.
- Single-assertion tests: use the simple `_pass`/`_fail` pattern, not subtests:
  ```bash
  test::module::function() { if [[ "$(module::function)" == "expected" ]]; then _pass; else _fail; fi; }
  ```
- Multi-assertion tests: use `_assert "label" "expected" "actual"` and call `_sub_done` at the end.
- Write APIs that would modify kernel/system state must use `_skip "reason"` so auto-discovery lists them as skipped, not untested.
- Run `./main.sh test ./bash-framehead.sh` after changes; keep new public functions covered.

## Commit & Pull Request Guidelines
- Commit messages: present-tense, concise scope (“fix pfloat div guard”). Group related edits; do not commit compiled artifacts.
- PRs/CLs should include: summary of change, key commands run (e.g., tests/build), notable warnings (e.g., ShellCheck). Link issues when applicable.

## Agent-Specific Notes
- Minifier and tokenizer are performance hotspots; when debugging them, add temporary progress logs and be ready to fall back to non-minified builds.
- Avoid touching `runtime.sh` unless coordinated; it is a shared dependency for all modules.
- Use `compile_bare` to verify that new functions don't accidentally pull in unintended transitive dependencies.
