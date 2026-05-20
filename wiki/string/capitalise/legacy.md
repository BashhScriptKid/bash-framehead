# `string::capitalise::legacy`

Capitalise first character (Bash 3 compatible)

## Source

```bash
string::capitalise::legacy() {
  local s="$1"
  echo "$(echo "${s:0:1}" | tr '[:lower:]' '[:upper:]')${s:1}"
}
```

## Module

[`string`](../string.md)
