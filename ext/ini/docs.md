# ext/ini — Pure Bash INI Parser

A zero-dependency INI config-file parser written entirely in Bash. Handles
sections, key-value pairs, inline comments, quoted values, and whitespace.
No `crudini`, no `python`, no external binaries at all.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: none

## Usage

```bash
source ./bash-framehead.sh
source ./ext/ini/ini.sh
```

## API Reference

### `ini::get <ini> <key> [section]`

Return the value for `<key>`. If `<section>` is given, search only that section;
otherwise search the global scope (keys before the first `[section]`).

```bash
ini='host=localhost
port=3306
[database]
user=admin
pass=secret'

ini::get "$ini" host          # → localhost
ini::get "$ini" user database # → admin
```

### `ini::get_file <file> <key> [section]`

Same as `ini::get` but reads INI from a file.

```bash
ini::get_file /etc/myapp.conf server port
```

### `ini::sections <ini>`

List all section names, one per line.

```bash
ini::sections "$ini"  # → database
```

### `ini::keys <ini> [section]`

List keys. If `<section>` is given, list keys from that section; otherwise
list global-scope keys.

```bash
ini::keys "$ini"          # → host\nport
ini::keys "$ini" database # → user\npass
```

### `ini::to_json <ini>`

Convert the INI document to JSON. Global keys become top-level entries;
sections become nested objects.

## Parsing Rules

- **Comments**: `;` and `#` begin inline comments. Whole-line comments also
  start with `;` or `#` after optional whitespace.
- **Quoted values**: one layer of matching `"` or `'` is stripped from values.
  Inline comments inside quotes are preserved.
- **Whitespace**: leading and trailing whitespace is stripped from keys and values.
- **Case-sensitive**: both section names and keys are case-sensitive.
- **Duplicate keys**: last occurrence wins.
- **Line endings**: LF and CRLF are both accepted (CRLF handled by Bash `read`).

## Limitations

- **No multi-line values**: continuation lines (backslash, indentation) are
  not supported — each key-value pair must be on a single line.
- **No nested sections**: `[a.b.c]` is treated as a flat section name `a.b.c`.
- **No type inference**: all values are strings.
- **Bash 4.3+** required (associative arrays).
