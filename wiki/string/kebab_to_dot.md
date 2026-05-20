# `string::kebab_to_dot`

kebab-case → dot.case

## Source

```bash
string::kebab_to_dot() {
  echo "${1//-/.}"
}
```

## Module

[`string`](../string.md)
