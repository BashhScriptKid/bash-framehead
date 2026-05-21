# `fs::created`

**Signature:** `fs::created(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Creation time (unix timestamp) — not available on all filesystems

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::created() {
    stat -c '%W' "$1" 2>/dev/null
}
```

