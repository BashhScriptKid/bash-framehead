# ext/dotenv — Pure Bash dotenv Parser

A zero-dependency `.env` file parser.  Handles KEY=value pairs, quoting,
inline comments, blank lines, and `export` prefix.  No external binaries.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: none

## Usage

```bash
source ./bash-framehead.sh
source ./ext/dotenv/dotenv.sh
```

## API Reference

### `dotenv::get <env> <key>`

Return the value for `<key>`.  Returns non-zero if the key is not found.

```bash
env='HOST=localhost
PORT=3000'

dotenv::get "$env" HOST   # → localhost
dotenv::get "$env" PORT   # → 3000
```

### `dotenv::get_file <file> <key>`

Same as `dotenv::get` but reads from a file.

```bash
dotenv::get_file .env DATABASE_URL
```

### `dotenv::keys <env>`

List all keys, one per line.

```bash
dotenv::keys "$env"  # → HOST\nPORT
```

### `dotenv::to_json <env>`

Convert the env contents to a JSON object.

```bash
dotenv::to_json "$env"  # → {"HOST":"localhost","PORT":"3000"}
```

### `dotenv::load <file>`

Source a `.env` file into the current shell.  Parses each line and exports
the variable.  Only keys matching `[A-Za-z_][A-Za-z0-9_]*` are loaded.

```bash
dotenv::load .env
echo "$HOST"  # → localhost
```

## Parsing Rules

- **Comments**: `#` begins an inline comment.  `#` inside quoted values is preserved.
- **Quoted values**: matching `"` or `'` is stripped (one layer).  Double-quoted
  values process `\n`, `\t`, `\\`, `\"`, `\$` escape sequences.  Single-quoted
  values are literal.
- **Whitespace**: leading and trailing whitespace is stripped from keys and values.
- **`export` prefix**: `export KEY=value` is treated identically to `KEY=value`.
- **Duplicate keys**: last occurrence wins.
- **Line endings**: LF and CRLF are both accepted.

## Limitations

- **No variable interpolation**: `${VAR}` references in values are not expanded.
- **No multi-line values**: each KEY=value pair must be on a single line.
- **No subshell expansion**: `$(...)` in values is not executed.
- **Bash 4.3+** required (associative arrays in guard).
