# `string::after`

Return everything after the first occurrence of delimiter

## Usage

```bash
string::after str delimiter
```

## Source

```bash
string::after() {
  echo "${1#*"$2"}"
}
```

## Module

[`string`](../string.md)
