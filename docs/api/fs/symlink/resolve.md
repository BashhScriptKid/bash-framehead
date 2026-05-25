# `fs::symlink::resolve`

**Signature:** `fs::symlink::resolve(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Resolved symlink target (follows chain)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::symlink::resolve() {
		readlink -f "$1" 2>/dev/null
}
```

