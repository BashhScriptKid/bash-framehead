# `fs::symlink::target`

**Signature:** `fs::symlink::target(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Symlink target

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::symlink::target() {
		readlink "$1" 2>/dev/null
}
```

