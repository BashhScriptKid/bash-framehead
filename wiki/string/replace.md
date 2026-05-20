# `string::replace`

Replace first occurrence of search with replace

## Usage

```bash
string::replace str search replace
```

## Source

```bash
string::replace() {
  echo "${1/"$2"/"$3"}"
}
```

## Module

[`string`](../string.md)
