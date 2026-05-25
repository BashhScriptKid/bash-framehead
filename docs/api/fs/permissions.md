# `fs::permissions`

**Signature:** `fs::permissions(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Octal permissions

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::permissions() {
		stat -c '%a' "$1" 2>/dev/null
}
```

