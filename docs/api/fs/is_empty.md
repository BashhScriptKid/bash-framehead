# `fs::is_empty`

**Signature:** `fs::is_empty(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::is_empty()      { [[ -f "$1" && ! -s "$1" ]] || [[ -d "$1" && -z "$(ls -A "$1" 2>/dev/null)" ]]; }
```

