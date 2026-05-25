# `fs::link_count`

**Signature:** `fs::link_count(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Number of hard links

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::link_count() {
		stat -c '%h' "$1" 2>/dev/null
}
```

