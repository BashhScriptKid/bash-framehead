# `string::path_to_dot`

path/case → dot.case

## Source

```bash
string::path_to_dot() {
  echo "${1//\//.}"
}
```

## Module

[`string`](../string.md)
