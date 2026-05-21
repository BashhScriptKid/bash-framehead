# `fs::owner`

**Signature:** `fs::owner(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Owner username

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::owner() {
    stat -c '%U' "$1" 2>/dev/null
}
```

