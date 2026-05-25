# `fs::find::type`

**Signature:** `fs::find::type(arg2)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Recursive find by type (f=file, d=dir, l=symlink)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |

## Source

```bash
fs::find::type() {
		find "${1:-.}" -type "$2" 2>/dev/null
}
```

