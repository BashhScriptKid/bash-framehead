# Contributing

## Ways to contribute

Bug reports, new functions, new modules, documentation. All welcome.

Open an issue before writing code if you're adding a new module — modules have architectural implications (no horizontal dependencies, clear scope separation). For individual functions, a pull request with tests is enough.

## Naming conventions

- Public functions: `module::function_name`
- Private helpers: `_module::function_name`
- Bash 3 compatible variants: `module::function::legacy`
- No-subshell nameref variants: `module::function::fast`
- Float variants: `module::functionf` (f suffix, not a separate namespace)

## Module rules

**No horizontal dependencies.** A module can only depend on `runtime.sh`. It must not call functions from `string.sh`, `fs.sh`, or any other module. If you need logic from another module, either copy it inline as a private helper or extract the shared piece to `runtime.sh`.

`runtime.sh` is the one exception — all modules may use `runtime::*` functions (like `runtime::has_command`, `runtime::os`, `runtime::is_minimum_bash`).

**No side effects.** Functions must not mutate global state unless the function name explicitly promises side effects (like `process::lock::acquire` or `terminal::screen::alternate_enter`).

**Pure Bash where possible.** Prefer Bash builtins over external tools. If you must use an external tool, check for it with `runtime::has_command` and fail with a clear message if it's missing — not a cryptic "command not found".

## Adding a function to an existing module

1. Add the function to `src/modulename.sh`
2. Add a comment block above it. At minimum, a one-line description. A `# Usage:` line helps the API generator produce accurate signatures.
3. Add a test in `tester.sh` — naming follows `test::module::function`. Use `_assert "label" "expected" "actual"` for assertions.
4. Compile: `OPTIMIZE=0 MINIFY=0 ./main.sh compile bash-framehead.sh <<< ''`
5. Run: `./main.sh test ./bash-framehead.sh`
6. Regenerate API docs: `bash tools/api-gen.sh src docs/api`

## Adding a new module

Same steps as above, plus:

1. Discuss the module in an issue first. New modules must fill a clear gap — they can't overlap the scope of an existing module.
2. Follow the module rules from day one: no horizontal dependencies, pure Bash preference, side-effect discipline.
3. Add the module to the compile list in `main.sh`.
4. Write a narrative guide in `docs/guides/` if the module is substantial enough to need one.

## Testing

Don't skip tests. The test suite is the contract — if your function isn't tested, it will break silently when someone refactors around it.

Tests use `_assert "label" "expected" "actual"`. Group related assertions:

```bash
test::string::upper() {
    _assert "lowercase" "HELLO" "$(string::upper "hello")"
    _assert "already upper" "HELLO" "$(string::upper "HELLO")"
    _assert "mixed case" "HELLO WORLD" "$(string::upper "Hello World")"
    _sub_done
}
```

Skip tests that depend on the environment with `_skip "reason"`:

```bash
test::net::is_online() {
    runtime::has_command "ping" || { _skip "no ping available"; return; }
    # ...
}
```
