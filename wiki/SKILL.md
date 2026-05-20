# Framework Skill — bash-framehead

How to use bash-framehead when writing Bash scripts. Read this before writing any code that depends on the framework.

## Setup

```bash
# Option A: source the compiled artifact
source ./bash-framehead.sh

# Option B: dev mode — sources all modules directly (no compile needed)
source ./main.sh
```

All modules depend on `runtime.sh`; it loads first automatically.

## Naming

```
module::function               # Public API
module::function::fast         # Nameref variant — writes to variable, no subshell
_module::helper                # Internal — don't call directly
```

## Calling Conventions

Most functions accept input **as an argument or via stdin**:

```bash
string::upper "hello"          # argument
echo "hello" | string::upper   # pipe
```

**Inspection functions** return exit codes (0 = true, 1 = false):

```bash
if fs::is_dir "/etc"; then ...
if string::contains "$line" "error"; then ...
```

**Transform functions** print to stdout:

```bash
result=$(string::upper "hello")
```

**`::fast` variants** take a variable name as first arg, write directly, no subshell:

```bash
string::upper::fast out "hello"   # $out = "HELLO"
array::reverse::fast rev "${arr[@]}"  # $rev = reversed array
```

Use `::fast` when you're chaining calls or care about performance. Use the regular variant in one-liners where the subshell cost doesn't matter.

## Float vs Integer

- Functions named `foo` operate on **integers** (pure bash arithmetic)
- Functions named `foof` use **floating point** (delegates to `bc`)
- `pfloat::fixed::*` is pure-bash fixed-point (no `bc` needed, set `pfloat_SCALE` first)

## Key Modules at a Glance

| When you need to... | Use |
|---------------------|-----|
| Check if running interactively / in CI / as root | `runtime::is_*` |
| Check if a command exists | `runtime::has_command` |
| Detect OS, distro, arch | `runtime::os`, `runtime::distro`, `runtime::arch` |
| String inspection / case / trim | `string::is_*`, `string::upper/lower`, `string::trim` |
| Convert naming conventions | `string::snake_to_camel`, `string::camel_to_kebab`, etc. |
| Substring / split / join | `string::before/after`, `string::split`, `string::join` |
| URL / base64 encoding | `string::url_encode`, `string::base64_encode` |
| Path manipulation | `fs::path::join`, `fs::path::basename`, `fs::path::absolute` |
| File checks | `fs::exists`, `fs::is_file`, `fs::is_dir`, `fs::is_empty` |
| Read / write files | `fs::read`, `fs::write`, `fs::append`, `fs::replace` |
| Temp files | `fs::temp::file`, `fs::temp::dir` (and `::auto` for EXIT cleanup) |
| Array operations | `array::contains`, `array::push/pop/shift`, `array::filter` |
| Set operations | `array::intersect`, `array::diff`, `array::union`, `array::unique` |
| Integer math | `math::abs`, `math::min/max`, `math::gcd`, `math::pow` |
| Float math | `math::absf`, `math::round`, `math::sqrt`, `math::sin/cos` |
| Vector math | `math::vec2::*`, `math::vec3::*` (comma-separated strings) |
| Matrix algebra | `math::matrix::new/add/mul/determinant/inverse` |
| Networking | `net::is_online`, `net::fetch`, `net::http::status`, `net::ip::public` |
| DNS | `net::resolve`, `net::dns::records`, `net::dns::propagation` |
| Git info | `git::is_repo`, `git::branch::current`, `git::is_dirty`, `git::commit::hash` |
| Hardware info | `hardware::cpu::*`, `hardware::ram::*`, `hardware::battery::*` |
| ANSI colour | `colour::fg::red`, `colour::bold`, `colour::print`, `colour::strip` |
| Terminal control | `terminal::cursor::move`, `terminal::clear`, `terminal::read_key` |
| User input | `terminal::confirm`, `terminal::read_password` |
| Process management | `process::pid`, `process::is_running`, `process::kill::graceful` |
| Background jobs | `process::run_bg`, `process::job::wait_all` |
| Locking | `process::lock::acquire/release` (file-based advisory locks) |
| Hashing | `hash::sha256`, `hash::djb2`, `hash::slot` (consistent hashing) |
| Random numbers | `random::pcg32`, `random::xoshiro256ss` |
| Logging | `log::debug/info/warn/error/fatal` |
| Timestamps / dates | `timedate::timestamp::unix`, `timedate::date::today`, `timedate::date::add_days` |
| Duration formatting | `timedate::duration::format`, `timedate::duration::relative` |
| Package management | `pm::install`, `pm::update` (cross-distro) |

## Patterns to Follow

### Guard with runtime checks
```bash
runtime::has_command "jq" || { echo "jq required" >&2; exit 1; }
if runtime::is_pipe; then read_stdin; else read_args; fi
```

### Use ::fast in loops
```bash
# Bad — forks on every iteration
for item in "${items[@]}"; do
    upper=$(string::upper "$item")
done

# Good — no forks
for item in "${items[@]}"; do
    string::upper::fast upper "$item"
done
```

### Use array functions with expanded arrays
```bash
my_arr=(a b c d)
array::contains "b" "${my_arr[@]}"  # don't forget [@]
array::length "${my_arr[@]}"
```

### Set operations take space-separated strings
```bash
array::intersect "a b c" "b c d"     # → b c
array::union "a b" "b c"             # → a b c
```

### Temp files with auto cleanup
```bash
tmp=$(fs::temp::file::auto "mytask-")  # removed on EXIT automatically
```

## Gotchas

- **Don't source modules directly** — use `main.sh` or the compiled artifact; `runtime.sh` must load first
- **`bc` is required** for `math::*f`, trig, and matrix determinant/inverse
- **Bash 5.0+** required for `array::unique::fast` (uses associative arrays)
- **Matrix functions** use flat space-separated element lists with dimension strings (`"RxC"`)
- **pfloat** fixed-point needs `pfloat_SCALE` set before use; IEEE 754 operates on raw 64-bit integers
- **Some functions need external tools** — `net::fetch` needs curl/wget, `hash::sha256` needs sha256sum, etc. Check the module docs.
- **`string::title` requires `awk`**
- **Wiki is gitignored** — don't expect `git status` to show doc changes
