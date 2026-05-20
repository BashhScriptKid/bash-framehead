# `string::index_of`

Index of first occurrence of substring (-1 if not found)

## Usage

```bash
string::index_of haystack needle
```

## Source

```bash
string::index_of() {
  local haystack="$1" needle="$2"
  local before="${haystack%%"$needle"*}"
  if [[ "$before" == "$haystack" ]]; then
    echo -1
  else
    echo "${#before}"
  fi
}
```

## Module

[`string`](../string.md)
