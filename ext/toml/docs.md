# ext/toml — Pure Bash TOML Parser

Converts TOML to JSON.  Supports tables, arrays-of-tables, dotted keys, inline
tables, all TOML types (strings, integers in decimal/hex/octal/binary, floats,
booleans, datetimes), comments, and multiline strings.  No `tomlq`, no `python`,
pure Bash.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: none
- **Extensions**: `json` (required for `toml::get` — sources `ext/json/json.sh`)

## Usage

```bash
source ./bash-framehead.sh
source ./ext/toml/toml.sh

# Optional, for toml::get:
source ./ext/json/json.sh
```

## API Reference

### `toml::to_json <toml>`

Convert a TOML document to JSON.

```bash
toml='name = "myapp"
port = 3000

[db]
host = "localhost"
port = 5432'

toml::to_json "$toml"
# → {"name":"myapp","port":3000,"db":{"host":"localhost","port":5432}}
```

### `toml::get <toml> <path>`

Extract a value by dot-notation path.  Converts to JSON internally then
delegates to `json::get`.  Requires `ext/json` to be sourced first.

```bash
toml::get "$toml" db.host  # → localhost
```

### `toml::get_file <file> <path>`

Same as `toml::get` but reads TOML from a file.

```bash
toml::get_file Cargo.toml package.version
```

## Supported TOML Features

| Feature | Supported | Notes |
|---------|-----------|-------|
| Key-value pairs | Yes | |
| Tables (`[name]`) | Yes | Nested dotted tables (`[a.b.c]`) |
| Arrays of tables (`[[name]]`) | Yes | Including interleaved |
| Dotted keys (`a.b.c = 1`) | Yes | Bare keys only; quoted keys with dots are literal |
| Inline tables (`{k = v}`) | Yes | |
| Arrays (`[1, 2, 3]`) | Yes | Mixed types |
| Strings (basic `"..."`) | Yes | Escape sequences: `\n`, `\t`, `\\`, `\"`, `\b`, `\f`, `\e`, `\xNN`, `\uXXXX`, `\UXXXXXXXX` |
| Strings (literal `'...'`) | Yes | No escapes processed |
| Multiline basic (`"""..."""`) | Yes | Leading newline stripped, escapes processed |
| Multiline literal (`'''...'''`) | Yes | Leading newline stripped |
| Integers | Yes | Decimal, hex (`0xFF`), octal (`0o777`), binary (`0b1010`) |
| Floats | Yes | Including `inf`, `-inf`, `nan` |
| Numeric separators (`1_000_000`) | Yes | Underscores stripped |
| Booleans | Yes | `true`, `false` |
| Datetimes | Yes | Output as strings with space→T normalisation |
| Comments (`#`) | Yes | Inline and whole-line |
| Quoted keys (`"key"`, `'key'`) | Yes | |

## Limitations

- **No streaming**: the entire TOML must fit in a Bash string
- **Bash 4.3+** required (associative arrays, namerefs)
- **Datetime values**: type information is lost — datetimes are output as
  JSON strings
- **Mixed-type arrays**: TOML allows them but the parser passes them through
  as-is
- **No `\x02` in values**: the internal record separator uses DEL (`\x7F`)
  which is not valid UTF-8 and should never appear in real TOML data
