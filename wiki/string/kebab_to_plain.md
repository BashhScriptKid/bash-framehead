# `string::kebab_to_plain`

kebab-case → plain

## Source

```bash
string::kebab_to_plain() {
  echo "${1//-/ }"
}
```

## Module

[`string`](../string.md)
