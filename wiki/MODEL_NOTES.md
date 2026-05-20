# Model State Journal

Read this first — it carries context forward so each Claude instance picks up where the last left off.

---

## Current State

| Field | Value |
|-------|-------|
| **Date** | 2026-05-21 |
| **Base commit** | `e809942` — "Reorganise tools into tools/ with shared tokeniser.sh" |
| **Authored by** | Claude Opus 4.7 (1M) |
| **Branch** | `master` (clean, no uncommitted changes in tracked files) |
| **Function count** | ~785 public functions across 18 modules |

## How These Docs Are Made

The wiki is LLM-authored — module pages are written directly, not generated. The old `tools/wiki-gen.sh` script produced per-function stubs with raw source dumps; it's kept around as reference but no longer drives the workflow. Writing docs in one model pass produces better organisation, curated examples, and dependency notes without the maintenance overhead of annotation conventions and generator tweaking.

The tradeoff: docs can drift from source without re-runs. That's what this file is for — so the next model knows the commit they're based on and what to update.

## Modules

| Module | Functions | Notes |
|--------|-----------|-------|
| `array` | 42 | Most have `::fast` variants |
| `colour` | 65 | 4/8/24-bit ANSI, 16 fg + 16 bg shortcuts |
| `device` | 25 | Block/char device inspection |
| `fs` | 79 | Paths, I/O, temp files, watching |
| `git` | 35 | Repo introspection |
| `hardware` | 36 | CPU, GPU, RAM, disk, battery |
| `hash` | 25 | Crypto + non-crypto, HMAC, UUID5 |
| `log` | 10 | Structured logging with severity levels |
| `math` | 150 | Integer, float, vec2/vec3, matrices, trig |
| `net` | 38 | Connectivity, DNS, HTTP, interfaces |
| `pfloat` | 129 | Fixed-point + IEEE 754 arithmetic |
| `pm` | 5 | Cross-distro package manager abstraction |
| `process` | 51 | Query, control, locking, services |
| `random` | 25 | PRNGs — LCG to ISAAC |
| `runtime` | 54 | Shell state, OS detection — required by all |
| `string` | 204 | Inspection, case, conventions, encoding |
| `terminal` | 74 | Cursor, screen buffer, input, shopt |
| `timedate` | 76 | Timestamps, dates, durations, timezones |

## Things to Be Aware Of

- **Minifier can hang** — `MINIFY=1` builds are slow/unreliable; use `MINIFY=0` for development
- **AGENTS.md** at repo root contains build commands, coding conventions, and test guidelines
- **`tools/wiki-gen.sh`** exists but is not the primary doc workflow anymore

## For the Next Model

When you finish and are about to hand off:

1. **Update the Current State table** — date, short commit, branch state, function count
2. **Update the Modules table** if function counts changed or modules were added/removed
3. **Update "Things to Be Aware Of"** — new footguns, changed conventions
4. **If you changed how docs are made**, add a section explaining why so the next model doesn't revert it
