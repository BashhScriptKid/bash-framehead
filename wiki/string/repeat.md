# `string::repeat`

Repeat a string n times

## Usage

```bash
string::repeat str n
```

## Source

```bash
string::repeat() {
  local str="$1" n="$2" result=""
  for ((i = 0; i < n; i++)); do result+="$str"; done
  echo "$result"
}
```

## Module

[`string`](../string.md)
