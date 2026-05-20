# `string::join`

Join an array of arguments with a delimiter

## Usage

```bash
string::join delimiter arg1 arg2 ...
```

## Source

```bash
string::join() {
  local delim="$1"
  shift
  local result=""
  local first=true
  for part in "$@"; do
    if $first; then
      result="$part"
      first=false
    else
      result+="${delim}${part}"
    fi
  done
  echo "$result"
}
```

## Module

[`string`](../string.md)
