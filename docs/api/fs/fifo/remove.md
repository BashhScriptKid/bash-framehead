# `fifo::remove`

**Signature:** `fifo::remove(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Remove a named pipe

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fifo::remove() {
		rm -f "$1"
}
```

