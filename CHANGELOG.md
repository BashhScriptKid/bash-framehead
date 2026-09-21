# Changelog

Notable changes to **bash::framehead**. Loosely follows
[Keep a Changelog](https://keepachangelog.com/); pre-1.0, so a minor bump
can include breaking changes.

## [0.2] - 2026-09-21

First substantial release. `0.1` was a minimal core; `0.2` adds the
extension framework, the compiler toolchain, and the capability system.
192 commits, ~2,770 files changed since `0.1`.

### Added

- **Extensions framework** (`ext/`): self-contained units with declared
  `# Dependencies:` headers and source-time guards. Sixteen extensions ship:
  `json`, `yaml`, `toml`, `ini`, `csv`, `dotenv`, `sqlite`, `dbus`,
  `systemd`, `tui`, `http-server`, `bmp`, `wav`, `media`, `neural`, `uinput`.
- **Core modules**: `binary`, `debug`, `kernel`, `log`, `pfloat`, `pubsub`.
- **Capability API**: `runtime::features` (list), `runtime::features::has`,
  `runtime::features::mask`, `runtime::features::probe`, and the hot-path
  predicate `runtime::has_param_transform`, backed by the cached
  `_RUNTIME_FEATURES` register. Thresholds live in one place; call sites use
  the API instead of repeating `BASH_VERSINFO` checks.
- **Compiler**: `compile`, `compile_extended` (core + extensions with
  dependency validation), and `compile_bare` (reachable-subset extraction
  with call-graph tracing). `BFH_VERSION` now stamps a build non-interactively.
- **Tooling**: `tester.sh` (~1,900 tests), `api-gen.sh`, `minify.sh`,
  `optimize.sh`, `obfuscate.sh`, `tokeniser.sh`.
- **Docs**: generated API dictionary (`docs/api/`, 1,824 pages), narrative
  guides and worked examples.
- **Release artifacts** under the `bfh.[o][f][m][e].sh` naming convention
  (plain / optimized / minified / extended, plus an obfuscated product
  build). `tools/release-build.sh` builds the matrix and `BFH_VERSION`
  stamps the version.

### Changed

- **Minimum Bash is 4.3.** Bash 4.4+ `${var@...}` transforms and 5.x features
  are feature-detected and degrade gracefully (`printf %q`, `declare -p`,
  `read -d` fallbacks) rather than failing cryptically.
- Modules document their dependencies via `# Requires:` headers; extensions
  via `# Dependencies:` + guard blocks.

### Fixed

- `compile_bare` now parses `declare -A` and flag-bearing declarations and
  multi-line global literals; previously it emitted corrupt output and
  silently dropped all top-level `declare -A` globals.
- `string::quote` / `string::expand_escapes` / `debug::vardump` no longer
  abort on pre-4.4 Bash.
- `ext/dotenv` (`${k@Q}`) and `ext/dbus` (`mapfile -d`) guard their 4.4
  features with portable fallbacks.

### Notes

- Compiled artifacts are not committed; build them with `./main.sh compile`.

[0.2]: https://github.com/BashhScriptKid/bash-framehead/compare/0.1...0.2
