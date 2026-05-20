# `string::substr`

Extract substring

## Usage

```bash
string::substr str start [length]
```

## Source

```bash
string::substr() {
  local s="$1" start="$2" len="${3:-}"
  if [[ -n "$len" ]]; then
    echo "${s:$start:$len}"
  else
    echo "${s:$start}"
  fi
}
```

## Module

[`string`](../string.md)
