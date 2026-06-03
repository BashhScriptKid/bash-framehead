# ext/json — Pure Bash JSON Parser

A zero-dependency JSON parser/query tool written entirely in Bash. No `jq`, no `python`, no
external binaries beyond GNU `grep`. Designed for shell scripts that need to poke at JSON
without pulling in a heavyweight runtime.

## Dependencies

- **bash-framehead core**: `runtime`, `string` (specifically `string::is_integer`, `string::split::fast`)
- **External (optional)**: GNU `grep` with `-b` flag for C-speed large-container scanning. Auto-detected at source time. Pure bash fallback when unavailable.

### Forcing pure bash (no grep)

Three ways to disable the grep-accelerated path:

```bash
NOGREP=1 source ./ext/json/json.sh          # env var at source time
NOGREP=1 json::get _ctx "$json" "a.b"       # env var per call
declare -A _ctx=( [no_grep]=1 )             # context flag
json::get _ctx "$json" "a.b"
```

The pure bash path is slower for large containers (> 64 bytes) but removes the GNU grep dependency entirely — useful on macOS (BSD grep) or minimal systems.

## Usage

```bash
source ./bash-framehead.sh
source ./ext/json/json.sh
```

## Architecture

All parser state lives in an associative array (`_ctx`) owned by the caller. No module-level
mutable state — every function receives the context as its first parameter. This makes the
parser reentrant and the state visible:

```bash
declare -A _ctx
json::get _ctx "$json" "a.b"    # caller owns _ctx
json::type _ctx "$json" ""      # each call is independent
```

The KV API is stateful by design — the caller provides a context, and kv functions mutate it
across calls. The state (`kv_root`, `kv_path`, `kv_cstart`, `kv_cend`, `kv_ctype`) lives
inside the same `_ctx`:

```bash
declare -A _ctx
json::kv _ctx "$json"           # initialise kv state in _ctx
json::kv::at _ctx "user"        # mutate _ctx[kv_path]
json::kv::value::get _ctx "name" # read from current position
```

## API Reference

### Stateless API

All stateless functions take a context (`_ctx`) as the first argument, a JSON string as the
second, and a **dot-notation path** as the third. Bracket notation `foo[0].bar` is normalised
to the equivalent `foo.0.bar`. An empty path refers to the root of the document. Every call
re-parses from the beginning.

### `json::get <ctx> <json> <path>`

Extract a value. Strings are decoded (escape sequences resolved). Everything else
(objects, arrays, numbers, booleans, null) is returned as raw JSON.

```bash
declare -A _ctx
json::get _ctx '{"a":{"b":42}}' a.b          # → 42
json::get _ctx '["x","y","z"]' 2             # → z
json::get _ctx '{"msg":"hello\nworld"}' msg  # → hello<newline>world
```

### `json::get_file <ctx> <file> <path>`

Same as `json::get` but reads JSON from a file.

```bash
declare -A _ctx
json::get_file _ctx /path/to/config.json server.port
```

### `json::type <ctx> <json> <path>`

Return the JSON type of a value: `object`, `array`, `string`, `number`, `boolean`, or `null`.

```bash
declare -A _ctx
json::type _ctx '{"x": [1,2,3]}' x   # → array
json::type _ctx '{"x": null}'    x   # → null
```

### `json::keys <ctx> <json> [path]`

List keys (for objects) or indices (for arrays) at the given path. One per line.

```bash
declare -A _ctx
json::keys _ctx '{"a":1,"b":2,"c":3}'       # → a\nb\nc
json::keys _ctx '[10,20,30]'                 # → 0\n1\n2
json::keys _ctx '{"p":{"x":1,"y":2}}' p     # → x\ny
```

### `json::len <ctx> <json> [path]`

Return the number of entries in a container. Objects: key count. Arrays: element count.
Scalars produce an error.

```bash
declare -A _ctx
json::len _ctx '{"a":1,"b":2}'          # → 2
json::len _ctx '[10,20,30,40]'          # → 4
json::len _ctx '{"data": [1,2,3]}' data # → 3
```

### Stateful API (`json::kv`)

The `kv` namespace acts like `cd` for JSON — pre-navigate to a container once, then
operate from that position without re-walking ancestor paths. The caller provides a
context (`_ctx`) that stores the kv state. All `::*` functions take `_ctx` as their
first parameter. Write operations mutate the context's JSON string via text splicing.

### `json::kv <ctx> <json> [path]`

Pre-navigate to a container. Silent on success (exit 0). On failure prints to stderr
and exits 1.

```bash
declare -A _ctx
json::kv _ctx '{"a":1,"b":{"x":9,"y":8},"c":[1,2,3]}'     # at root object
json::kv _ctx '{"a":1,"b":{"x":9,"y":8}}' b                 # at the 'b' object
```

### `::keys`

List keys (object) or indices (array), newline-separated. Requires active kv context.

```bash
json::kv::keys                     # → a\nb\nc
```

### `::keys::exists <key>`

Return 0 if the key exists in the current object, 1 otherwise. Objects only.

```bash
json::kv::keys::exists b && echo "found"   # → found
```

### `::value::get <key>`

Extract a value from the current container. Same semantics as `json::get` but operates
from the parked position.

```bash
json::kv::value::get a              # → 1
json::kv::value::get b              # → {"x":9,"y":8}
```

### `::value::type <key>`

Return the JSON type of a value in the current container.

```bash
json::kv::value::type a             # → number
json::kv::value::type b             # → object
```

### `::list [fmt]`

Dump all entries in the current container.

```bash
json::kv::list                      # tab-separated key\tvalue\n  (default)
json::kv::list json                 # raw container as JSON string
json::kv::list csv                  # comma-separated values
```

### `::count`

Return the number of entries in the current container.

```bash
json::kv::count                     # → 3
```

### `::at <relpath>`

Navigate deeper into a nested container. Appends to the current path.

```bash
json::kv _ctx '{"a":{"b":{"c":"deep"}}}' a
json::kv::at _ctx b && json::kv::keys _ctx    # → c
```

### `::parent`

Navigate up one level. Strips the last segment from the current path.

```bash
json::kv::parent _ctx && json::kv::keys _ctx  # → a  (back to root object)
```

### `::root`

Return to the document root (clear the path).

```bash
json::kv::root _ctx && json::kv::keys _ctx    # → a  (root object keys)
```

### `::value::set <key> <raw_json>`

Insert or update a key-value pair. The value must be **valid raw JSON** — `42` for
a number, `'"hello"'` for a string, `'{"nested":true}'` for an object. The mutation
is applied to the context; subsequent `::*` calls see the modified JSON.

```bash
json::kv::value::set _ctx c 3           # → {"a":1,"b":2,"c":3}
json::kv::value::set _ctx a 99          # → {"a":99,"b":2,"c":3}
```

### `::keys::remove <key>`

Delete a key-value pair. Objects only. Fails if the key is not found.

```bash
json::kv::keys::remove _ctx b           # → {"a":99,"c":3}
```

### `::keys::rename <old> <new>`

Rename a key, preserving its value. Objects only. Fails if the old key is not found.

```bash
json::kv::keys::rename _ctx c d         # → {"a":99,"d":3}
```

### `json::validate <ctx> <json>`

Return 0 if the input is parseable JSON, 1 otherwise. Errors include the byte
position. Does not modify kv context. Lenient about trailing commas and
non-standard number formatting — validates parseability, not strict spec
compliance.

```bash
declare -A _ctx
json::validate _ctx '{"a":1}' && echo "valid"    # → valid
json::validate _ctx '{bad}' && echo "valid"      # → json::validate: unexpected character 'b' at 1
```

## Path Syntax

| Input | Normalised | Meaning |
|-------|-----------|---------|
| `""` | `""` | Root value |
| `"a"` | `"a"` | Object key `a` |
| `"a.b"` | `"a.b"` | Key `a` then key `b` |
| `"[0]"` | `"0"` | Array index 0 |
| `"foo[0].bar"` | `"foo.0.bar"` | Key `foo`, index 0, key `bar` |

## Performance

The parser uses a hybrid approach:

- **Shallow / small containers** (< 64 bytes): pure Bash character walker with optional
  indexed array for O(1) single-byte access. No external processes.
- **Large containers**: delegates to `grep -ob` when GNU grep is available, scanning
  structural characters (`{}[]",:`) at C speed. Falls back to a pure bash
  character-by-character scan when grep is unavailable (`NOGREP=1` or no GNU grep).

Rough numbers vs `jq` on a 2.2 MB GeoJSON file:

| Operation | framehead | jq | notes |
|-----------|-----------|----|-------|
| type at root | 0.1s | 0.16s | framehead wins (no full parse) |
| get shallow key | 0.5s | 0.12s | 4x slower |
| len of large array | 5.5s | 0.14s | 39x slower |
| keys at root | 6.1s | 0.13s | 47x slower |
| deep nested path | 1–3s | 0.13s | 10–24x slower |

`jq` wins on everything that requires more than a single structural peek — it's a
purpose-built C library with an in-memory parse tree. framehead re-scans from the
target position for each path segment and forks a `grep` process for large containers.
The trade-off is zero install footprint vs raw speed.

## Limitations

- **No streaming**: the entire JSON must fit in a Bash string. For files over
  ~10 MB, Bash's string handling becomes the bottleneck.
- **Bash 4.3+** required (associative arrays, namerefs).
- **GNU grep optional**: the `-b` flag for byte offsets enables C-speed scanning of large
  containers. Without it, the parser falls back to pure bash (slower but functional).
  macOS users don't need `brew install grep`.
- **Number validation**: lenient — leading zeros (`01`), trailing commas,
  and malformed numbers are now rejected, but top-level scalars (bare `"hello"`)
  are accepted despite the spec requiring an array or object root.
- **Write operations (`::value::set`, etc.)** rebuild the container by text
  splicing — whitespace in the original JSON is not preserved; the rebuilt
  container uses compact formatting with no extra spaces.

## `json::sqlitestore::*` — JSON document store backed by SQLite

Loaded automatically when `sqlite3` is available. Each document is stored
as a JSON string in a SQLite table; the table is auto-created on first
open. Documents can have any shape; queries use `json_extract` to navigate
nested fields. Full-text search uses FTS5 (when compiled in).

**Functions:**

| Function | Purpose |
|---|---|
| `json::sqlitestore::open <db> <table>` | Create table if missing, ensure DB exists |
| `json::sqlitestore::put <db> <table> <key> <json>` | Store or replace a document |
| `json::sqlitestore::get <db> <table> <key>` | Retrieve a document |
| `json::sqlitestore::delete <db> <table> <key>` | Remove a document |
| `json::sqlitestore::list <db> <table>` | List all keys |
| `json::sqlitestore::count <db> <table>` | Count documents |
| `json::sqlitestore::query <db> <table> <json_path> <value>` | Find documents by JSON path |
| `json::sqlitestore::search <db> <table> <fts_query>` | Full-text search (FTS5) |
| `json::sqlitestore::import <db> <table> <file>` | Import a JSON array |
| `json::sqlitestore::export <db> <table>` | Export all as a JSON array |

**Example:**

```bash
_db=~/.cache/myapp/data.db
json::sqlitestore::open "$_db" users
json::sqlitestore::put "$_db" users alice '{"name":"Alice","age":30}'
json::sqlitestore::put "$_db" users bob   '{"name":"Bob","age":25}'

# Retrieve
json::sqlitestore::get "$_db" users alice
# → {"name":"Alice","age":30}

# Query nested fields (requires json1)
json::sqlitestore::query "$_db" users '$.age' '30'
# → {"name":"Alice","age":30}

# Full-text search (requires FTS5)
json::sqlitestore::search "$_db" users 'alice*'
# → {"name":"Alice","age":30}

# Export all
json::sqlitestore::export "$_db" users
# → [{"name":"Alice","age":30},{"name":"Bob","age":25}]
```

**Notes:**
- `query` and `export`/`import` require the `json1` compile-time option.
  Without it, those functions return an error; the rest still work.
- `search` requires FTS5. The first call creates a contentless FTS index
  and rebuilds it from the main table. For large stores this is slow —
  consider a trigger-based FTS index for production use.
- No HANDLE pattern: pass `<db>` and `<table>` to every call directly.
