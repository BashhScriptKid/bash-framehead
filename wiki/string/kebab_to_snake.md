# `string::kebab_to_snake`

kebab-case → snake_case

## Source

```bash
string::kebab_to_snake() {
  echo "${1//-/_}"
}
```

## Module

[`string`](../string.md)
