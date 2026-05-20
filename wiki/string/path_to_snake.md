# `string::path_to_snake`

path/case → snake_case

## Source

```bash
string::path_to_snake() {
  echo "${1//\//_}"
}
```

## Module

[`string`](../string.md)
