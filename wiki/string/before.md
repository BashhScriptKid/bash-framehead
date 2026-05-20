# `string::before`

Return everything before the first occurrence of delimiter

## Usage

```bash
string::before str delimiter
```

## Source

```bash
string::before() {
  echo "${1%%"$2"*}"
}
```

## Module

[`string`](../string.md)
