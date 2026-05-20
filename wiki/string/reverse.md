# `string::reverse`

Reverse a string

**Requires:** rev (coreutils) — falls back to awk

## Source

```bash
string::reverse() {
  if runtime::has_command rev; then
    echo "$1" | rev
  else
    echo "$1" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}'
  fi
}
```

## Module

[`string`](../string.md)
