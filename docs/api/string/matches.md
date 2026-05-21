# `string::matches`

**Signature:** `string::matches(str, regex)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string matches a regex

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `regex` | regex | Yes | |

## Source

```bash
string::matches() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  [[ "$input" =~ $1 ]]
}
```

