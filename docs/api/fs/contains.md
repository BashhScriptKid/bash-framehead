# `fs::contains`

**Signature:** `fs::contains(path, string)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if file contains a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `path` | path | Yes | |
| `string` | string | Yes | |

## Source

```bash
fs::contains() {
		grep -qF "$2" "$1" 2>/dev/null
}
```

