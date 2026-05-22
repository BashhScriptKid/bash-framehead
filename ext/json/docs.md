# ext/json — Pure Bash JSON Parser

A zero-dependency JSON parser/query tool written entirely in Bash. No `jq`, no `python`, no
external binaries beyond GNU `grep`. Designed for shell scripts that need to poke at JSON
without pulling in a heavyweight runtime.

## Dependencies

- **bash-framehead core**: `runtime`, `string` (specifically `string::is_integer`, `string::split::fast`)
- **External**: `grep` (GNU grep with `-b` flag for byte-offset reporting)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/json/json.sh
```

## API Reference

All functions take a JSON string as the first argument and a **dot-notation path** as the second.
Bracket notation `foo[0].bar` is normalised to the equivalent `foo.0.bar`. An empty path refers
to the root of the document.

### `json::get <json> <path>`

Extract a value. Strings are decoded (escape sequences resolved). Everything else
(objects, arrays, numbers, booleans, null) is returned as raw JSON.

```bash
json::get '{"a":{"b":42}}' a.b          # → 42
json::get '["x","y","z"]' 2             # → z
json::get '{"msg":"hello\nworld"}' msg  # → hello<newline>world
```

### `json::get_file <file> <path>`

Same as `json::get` but reads JSON from a file.

```bash
json::get_file /path/to/config.json server.port
```

### `json::type <json> <path>`

Return the JSON type of a value: `object`, `array`, `string`, `number`, `boolean`, or `null`.

```bash
json::type '{"x": [1,2,3]}' x   # → array
json::type '{"x": null}'    x   # → null
```

### `json::keys <json> [path]`

List keys (for objects) or indices (for arrays) at the given path. One per line.

```bash
json::keys '{"a":1,"b":2,"c":3}'       # → a\nb\nc
json::keys '[10,20,30]'                 # → 0\n1\n2
json::keys '{"p":{"x":1,"y":2}}' p     # → x\ny
```

### `json::len <json> [path]`

Return the number of entries in a container. Objects: key count. Arrays: element count.
Scalars produce an error.

```bash
json::len '{"a":1,"b":2}'          # → 2
json::len '[10,20,30,40]'          # → 4
json::len '{"data": [1,2,3]}' data # → 3
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
- **Large containers**: delegates to `grep -ob` which scans structural characters
  (`{}[]",:`) at C speed. Bash only iterates over the ~10% of bytes that are
  structurally significant.

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

- **Escaped quotes in strings** (`\"`): the grep-based fast path uses a simple
  quote-toggle for string tracking and does not detect backslash-escaped quotes.
  In practice this is vanishingly rare in machine-generated JSON.
- **No streaming**: the entire JSON must fit in a Bash string. For files over
  ~10 MB, Bash's string handling becomes the bottleneck.
- **Bash 4.3+** required (associative arrays, namerefs).
- **GNU grep required**: the `-b` flag for byte offsets is not POSIX. macOS
  users need `brew install grep`.
