# ext/yaml — Pure Bash YAML Parser

A native YAML parser written entirely in Bash. Parses YAML into a caller-owned AST
(queryable tree), not just a JSON converter. No external dependencies.

## Dependencies

- **bash-framehead core**: `runtime`, `string`
- **External**: none
- **Optional**: `ext/json` (for `yaml::to_json` converter)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/yaml/yaml.sh
```

## Architecture

The parser builds a flat AST stored in caller-owned associative arrays.
Every function takes the context as its first parameter — no module-level
mutable state.

```bash
declare -A _ctx
yaml::parse _ctx "$yaml_string"    # build AST
yaml::get _ctx "$yaml" "server.host"  # query by path
yaml::to_json "$yaml"              # convert to JSON (requires json extension)
```

## API Reference

### `yaml::parse <ctx> <yaml>`

Parse YAML into the AST context. The context must be declared as an
associative array before calling.

```bash
declare -A _ctx
yaml::parse _ctx "name: test\nport: 3000"
```

### `yaml::get <ctx> <yaml> <path>`

Parse YAML and extract a value by dot-notation path. Strings are returned
decoded; containers are returned as JSON.

```bash
declare -A _ctx
yaml::get _ctx "server:\n  host: localhost" server.host   # → localhost
yaml::get _ctx "fruits:\n  - apple\n  - banana" fruits.0  # → apple
yaml::get _ctx "name: test" ""                            # → test (root)
```

### `yaml::keys <ctx> <yaml> [path]`

List keys (object) or indices (array) at the given path. One per line.

```bash
declare -A _ctx
yaml::keys _ctx "a: 1\nb: 2"     # → a\nb
yaml::keys _ctx "[x, y, z]"       # → 0\n1\n2
```

### `yaml::type <ctx> <yaml> <path>`

Return the type: `mapping`, `sequence`, `string`, `number`, `boolean`, or `null`.

```bash
declare -A _ctx
yaml::type _ctx "server:\n  host: localhost" server     # → mapping
yaml::type _ctx "fruits:\n  - apple" fruits            # → sequence
yaml::type _ctx "count: 42" count                      # → number
```

### `yaml::len <ctx> <yaml> [path]`

Return the number of entries in a container.

```bash
declare -A _ctx
yaml::len _ctx "a: 1\nb: 2\nc: 3"    # → 3
yaml::len _ctx "[1, 2, 3]"            # → 3
```

### `yaml::to_json <yaml>`

Convert YAML to JSON. Requires `ext/json` to be sourced.

```bash
yaml::to_json "name: test\nport: 3000"  # → {"name":"test","port":3000}
yaml::to_json "items:\n  - a\n  - b"   # → {"items":["a","b"]}
```

### `yaml::validate <yaml>`

Return 0 if the YAML is parseable, 1 otherwise.

```bash
yaml::validate "name: test" && echo "valid"
yaml::validate "bad: yaml: :::" && echo "valid"  # → valid (lenient)
```

### `yaml::get_file <file> <path>`

Read YAML from a file and extract a value.

```bash
yaml::get_file /path/to/config.yaml server.host
```

## Supported YAML Features

- **Mappings**: `key: value` (block style)
- **Sequences**: `- item` (block style)
- **Flow containers**: `{k: v}` and `[a, b]`
- **Nested structures** via indentation
- **Quoted strings**: `"double"` and `'single'`
- **Escape sequences**: `\n`, `\t`, `\"`, `\\`, etc.
- **Comments**: `# inline comment`
- **Multi-line quoted strings**: unclosed quotes span multiple lines
- **Block scalars**: `|` (literal) and `>` (folded) with chomp indicators
- **Boolean types**: true/false, yes/no, on/off (case-insensitive)
- **Null types**: `~`, `null`, `Null`, `NULL`
- **Document markers**: `---` and `...`
- **Tags**: `!!str`, `!tag`, etc. (stripped during parsing)
- **Anchors and aliases**: `&anchor` / `*alias` (basic support)

## AST Storage

The AST is stored in flat associative arrays within the caller's context:

| Key | Value |
|-----|-------|
| `_TYPE[id]` | `scalar`, `sequence`, or `mapping` |
| `_VAL[id]` | Scalar value (for scalar nodes) |
| `_KEY[id]` | Key name (when node is a child of a mapping) |
| `_CHILDREN[id]` | Space-separated child node IDs |
| `_PARENT[id]` | Parent node ID |
| `[_root]` | Root node ID |

Node IDs are integers starting from 1. The root is always node 1.

## Limitations

- **No streaming**: the entire YAML must fit in a Bash string.
- **Bash 4.3+** required (associative arrays, namerefs).
- **Merge keys** (`<<: *anchor`) have limited support.
- **Multi-document** (`---` separators): only the first document is parsed.
- **Complex keys** (keys that are themselves mappings/sequences): not supported.
- **Line folding** in block scalars: basic implementation only.
