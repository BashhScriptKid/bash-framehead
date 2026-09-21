# `fifo::exists`

**Signature:** `fifo::exists(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check whether path is a FIFO

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fifo::exists() {
		[[ -p "$1" ]]
}
```

