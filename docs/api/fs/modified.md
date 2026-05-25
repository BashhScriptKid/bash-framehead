# `fs::modified`

**Signature:** `fs::modified(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Last modified time (unix timestamp)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::modified() {
		stat -c '%Y' "$1" 2>/dev/null
}
```

