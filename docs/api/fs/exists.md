# `fs::exists`

**Signature:** `fs::exists(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- FILE / DIR CHECKS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::exists()        { [[ -e "$1" ]]; }
```

