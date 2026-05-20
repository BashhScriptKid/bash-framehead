# `string::trim_right`

Trim trailing whitespace

## Source

```bash
string::trim_right() {
  local s="$1"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}
```

## Module

[`string`](../string.md)
