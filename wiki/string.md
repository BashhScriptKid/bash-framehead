# `string`

The largest module — **204 functions** covering inspection, case conversion, naming convention conversion, trimming, substrings, manipulation, splitting/joining, encoding, hashing, and generation. Pure Bash where possible.

## Input Convention

Most functions accept input as the first argument **or** via stdin:

```bash
string::upper "hello"          # argument
echo "hello" | string::upper   # pipe
```

Fast variants (suffixed `::fast`) use namerefs to write results directly into a variable:

```bash
string::upper::fast result_var "hello"
echo "$result_var"   # → HELLO
```

---

## Inspection

Check properties of strings. All return exit code 0 (true) or 1 (false).

| Function | Description |
|----------|-------------|
| `string::length` | Return the length of a string |
| `string::is_empty` | Check if string is empty |
| `string::is_not_empty` | Check if string is non-empty |
| `string::contains` | Check if string contains a substring |
| `string::starts_with` | Check if string starts with a prefix |
| `string::ends_with` | Check if string ends with a suffix |
| `string::matches` | Check if string matches a regex |
| `string::is_integer` | Check if string is a valid integer |
| `string::is_float` | Check if string is a valid floating-point number |
| `string::is_hex` | Check if string is valid hexadecimal |
| `string::is_bin` | Check if string is valid binary |
| `string::is_octal` | Check if string is valid octal |
| `string::is_numeric` | Check if string is any numeric format |
| `string::is_alnum` | Check if string is alphanumeric only |
| `string::is_alpha` | Check if string is alphabetic only |

```bash
string::contains "hello world" "world" && echo "found"
string::starts_with "hello world" "hello" && echo "matches"
string::length "hello"  # → 5
```

## Case Conversion

| Function | Description | Fast |
|----------|-------------|------|
| `string::upper` | Convert to uppercase | `::fast` |
| `string::lower` | Convert to lowercase | `::fast` |
| `string::capitalise` | Capitalise first character only | `::fast` |
| `string::title` | Title case each word (requires `awk`) | `::fast` |

Each has a `::legacy` variant for Bash 3 compatibility.

```bash
string::upper "hello"         # → HELLO
string::lower "WORLD"         # → world
string::capitalise "hello"    # → Hello
string::title "hello world"   # → Hello World
```

---

## Naming Convention Conversion

Bidirectional conversion between 8 naming conventions. All functions have `::fast` variants.

### Supported Conventions

| Convention | Example |
|------------|---------|
| plain | `hello world` |
| snake_case | `hello_world` |
| kebab-case | `hello-world` |
| camelCase | `helloWorld` |
| PascalCase | `HelloWorld` |
| CONSTANT_CASE | `HELLO_WORLD` |
| dot.case | `hello.world` |
| path/case | `hello/world` |

### Conversion Functions

Pattern: `string::{from}_to_{to}` — 56 base conversion functions (8×7):

```bash
string::snake_to_camel "hello_world"      # → helloWorld
string::camel_to_snake "helloWorld"       # → hello_world
string::pascal_to_kebab "HelloWorld"      # → hello-world
string::constant_to_plain "HELLO_WORLD"   # → hello world
string::dot_to_path "hello.world"         # → hello/world
string::snake_to_pascal "hello_world"     # → HelloWorld
```

---

## Trimming & Whitespace

| Function | Description | Fast |
|----------|-------------|------|
| `string::trim_left` | Remove leading whitespace | `::fast` |
| `string::trim_right` | Remove trailing whitespace | `::fast` |
| `string::trim` | Remove leading and trailing whitespace | `::fast` |
| `string::collapse_spaces` | Collapse multiple spaces into one | `::fast` |
| `string::strip_spaces` | Remove all whitespace | `::fast` |

```bash
string::trim "  hello  "             # → "hello"
string::collapse_spaces "a   b   c"  # → "a b c"
string::strip_spaces "a b c"         # → "abc"
```

## Substrings

| Function | Description | Fast |
|----------|-------------|------|
| `string::substr` | Extract substring by start and optional length | `::fast` |
| `string::index_of` | Index of first occurrence (-1 if not found) | — |
| `string::before` | Everything before first occurrence of delimiter | `::fast` |
| `string::after` | Everything after first occurrence of delimiter | `::fast` |
| `string::before_last` | Everything before last occurrence of delimiter | `::fast` |
| `string::after_last` | Everything after last occurrence of delimiter | `::fast` |

```bash
string::substr "hello world" 6 5     # → "world"
string::index_of "hello world" "o"   # → 4
string::before "hello world" " "     # → "hello"
string::after "hello world" " "      # → "world"
string::after_last "/a/b/c" "/"      # → "c"
```

## Manipulation

| Function | Description | Fast |
|----------|-------------|------|
| `string::replace` | Replace first occurrence of search with replace | `::fast` |
| `string::replace_all` | Replace all occurrences of search with replace | `::fast` |
| `string::remove` | Remove all occurrences of a substring | `::fast` |
| `string::remove_first` | Remove first occurrence of a substring | `::fast` |
| `string::reverse` | Reverse a string (requires `rev` or `awk`) | `::fast` |
| `string::repeat` | Repeat a string n times | `::fast` |
| `string::pad_left` | Pad string on the left to a given width | `::fast` |
| `string::pad_right` | Pad string on the right to a given width | `::fast` |
| `string::pad_center` | Centre a string within a given width | `::fast` |
| `string::truncate` | Truncate to max length, appending suffix if cut | `::fast` |

```bash
string::replace_all "hello" "l" "x"  # → "hexxo"
string::reverse "hello"              # → "olleh"
string::repeat "ab" 3                # → "ababab"
string::pad_left "5" 3 "0"          # → "005"
string::truncate "hello world" 8 "…" # → "hello w…"
```

## Splitting & Joining

| Function | Description | Fast |
|----------|-------------|------|
| `string::split` | Split by delimiter, one element per line | — |
| `string::join` | Join arguments with a delimiter | `::fast` |

```bash
string::split "a,b,c" ","  # → a⏎b⏎c
string::join ", " a b c    # → "a, b, c"
```

## Encoding

| Function | Description | Fast |
|----------|-------------|------|
| `string::url_encode` | URL-encode a string | `::fast` |
| `string::url_decode` | URL-decode a string | `::fast` |
| `string::base64_encode` | Base64 encode | `::fast` |
| `string::base64_decode` | Base64 decode | `::fast` |
| `string::base64_encode::pure` | Pure Bash base64 encoding | — |
| `string::base64_decode::pure` | Pure Bash base64 decoding | — |
| `string::base32_encode` | Base32 encode | `::fast` |
| `string::base32_decode` | Base32 decode | `::fast` |
| `string::base32_encode::pure` | Pure Bash base32 encoding | — |
| `string::base32_decode::pure` | Pure Bash base32 decoding | — |

## Hashing

| Function | Description |
|----------|-------------|
| `string::md5` | MD5 hash (requires `md5sum` or `md5`) |
| `string::sha256` | SHA256 hash (requires `sha256sum` or `shasum`) |

## Generation

| Function | Description |
|----------|-------------|
| `string::random` | Generate a random alphanumeric string of given length |
| `string::uuid` | Generate a UUID v4 (random) |

```bash
string::random 16    # → a3b9k2m5x8f1p0q4
string::uuid         # → 550e8400-e29b-41d4-a716-446655440000
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `awk` (for `string::title` and `string::reverse` fallback), `rev` (for `string::reverse`), `md5sum`/`sha256sum` (for hash functions), system `base64`/`base32` (with pure Bash fallbacks)
