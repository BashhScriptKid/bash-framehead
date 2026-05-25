# `fs::copy`

**Signature:** `fs::copy(src, dst)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- OPERATIONS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `src` | path | Yes | |
| `dst` | path | Yes | |

## Source

```bash
fs::copy() {
		cp -r "$1" "$2"
}
```

