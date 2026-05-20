# `string::dot_to_path`

dot.case → path/case

## Source

```bash
string::dot_to_path() {
  echo "${1//.//}"
}
```

## Module

[`string`](../string.md)
