# `fs::dir::size`

**Signature:** `fs::dir::size(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get total size of directory

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::dir::size() {
		du -sb "${1:-.}" 2>/dev/null | awk '{print $1}'
}
```

