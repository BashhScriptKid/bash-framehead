# `string::starts_with`

**Signature:** `string::starts_with(str, prefix)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string starts with prefix

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `prefix` | string | Yes | |

## Source

```bash
string::starts_with() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  [[ "$input" == "$1"* ]]
}
```

