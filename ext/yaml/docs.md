# ext/yaml — Pure Bash YAML Parser (Pragmatic Subset)

Converts YAML to JSON via indentation tracking.  Supports the 90% of YAML you
actually see in config files — maps, sequences, nesting, flow style, quoted
strings, comments, and boolean/null types.  No `yq`, no `python`, pure Bash.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: none
- **Extensions**: `json` (required for `yaml::get` — sources `ext/json/json.sh`)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/yaml/yaml.sh

# Optional, for yaml::get:
source ./ext/json/json.sh
```

## API Reference

### `yaml::to_json <yaml>`

Convert a YAML document to JSON.

```bash
yaml='server:
  host: localhost
  port: 8080'

yaml::to_json "$yaml"
# → {"server":{"host":"localhost","port":8080}}
```

### `yaml::get <yaml> <path>`

Extract a value by dot-notation path.  Converts to JSON internally then
delegates to `json::get`.  Requires `ext/json` to be sourced first.

```bash
yaml::get "$yaml" server.host  # → localhost
```

### `yaml::get_file <file> <path>`

Same as `yaml::get` but reads YAML from a file.

## Supported YAML Features

| Feature | Supported | Notes |
|---------|-----------|-------|
| Maps (`key: value`) | Yes | |
| Nested maps (indentation) | Yes | Spaces and tabs |
| Sequences (`- item`) | Yes | |
| Sequence of objects (`- key: val`) | Yes | |
| Comments (`#`) | Yes | Inline and whole-line, `#` must be preceded by whitespace |
| Quoted strings (`"`, `'`) | Yes | Multi-line, escape sequences (`\n`, `\t`, etc.) |
| Flow style (`{k: v}`, `[a, b]`) | Yes | Nested (depth-tracking splitter) |
| YAML types | Yes | `true`/`false`/`yes`/`no`, `null`/`~`, integers, floats |
| Top-level sequences | Yes | |
| Empty values (`key:`) | Yes | Resolves to `null` if no continuation |
| Block scalars (`\|`, `>`) | Yes | Literal and folded, chomping (`-`/`+`) |
| Anchors & aliases | Yes | `&name`, `*name`, `<<: *name` merge keys |
| Tags (`!!str`, `!foo`) | Yes | Stripped (type information discarded) |
| Double-quoted escapes | Yes | `\n`, `\t`, `\\`, `\"`, etc. |
| Doc markers (`---`, `...`) | Yes | Skipped |

## Not Supported

- **Explicit mapping keys** (`? key : value`)
- **Multi-document streams** (`---` separating documents, `%TAG` directives)
- **Anchors inside flow containers** — anchors are stripped but not resolved when aliased
  from outside the flow container
- **Block scalar tag-on-separate-line** — `!foo` on one line then `\|`/`>` on the next
- **Flow collections spanning multiple lines** — opening `{`/`[` without closing on same line

## Limitations

- **No streaming**: the entire YAML must fit in a Bash string
- **Bash 4.3+** required (associative arrays)
- **Type detection is YAML 1.1 style**: `yes`/`no`/`on`/`off` are booleans
- **Indentation must be consistent**: mixing 2-space and 4-space indent in the
  same document produces unexpected results
