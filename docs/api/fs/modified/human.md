# `fs::modified::human`

**Signature:** `fs::modified::human(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Last modified time (human readable)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::modified::human() {
		stat -c '%y' "$1" 2>/dev/null
}
```

