# `string::trim_left`

Trim leading whitespace

## Source

```bash
string::trim_left() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  echo "$s"
}
```

## Module

[`string`](../string.md)
