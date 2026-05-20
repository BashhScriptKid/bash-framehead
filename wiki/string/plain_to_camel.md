# `string::plain_to_camel`

plain → camelCase

## Source

```bash
string::plain_to_camel() {
  local result="" first=true
  for word in $1; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  echo "$result"
}
```

## Module

[`string`](../string.md)
