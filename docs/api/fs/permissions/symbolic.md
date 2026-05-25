# `fs::permissions::symbolic`

**Signature:** `fs::permissions::symbolic(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Symbolic permissions (e.g. -rwxr-xr-x)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::permissions::symbolic() {
		stat -c '%A' "$1" 2>/dev/null
}
```

