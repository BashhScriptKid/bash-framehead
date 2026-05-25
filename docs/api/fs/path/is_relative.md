# `fs::path::is_relative`

**Signature:** `fs::path::is_relative(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a path is relative

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::path::is_relative() {
		[[ "$1" != /* ]]
}
```

