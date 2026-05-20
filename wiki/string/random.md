# `string::random`

Generate a random alphanumeric string of given length

## Usage

```bash
string::random [length]
```

## Source

```bash
string::random() {
  local len="${1:-16}"
  cat /dev/urandom 2>/dev/null |
    tr -dc 'a-zA-Z0-9' |
    head -c "$len" ||
    echo "string::random: /dev/urandom unavailable" >&2
}
```

## Module

[`string`](../string.md)
