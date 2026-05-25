# `fs::owner::group`

**Signature:** `fs::owner::group(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Owner group

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::owner::group() {
		stat -c '%G' "$1" 2>/dev/null
}
```

