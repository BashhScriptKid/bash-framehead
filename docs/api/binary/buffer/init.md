# `binary::buffer::init`

**Signature:** `binary::buffer::init(<name>)`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Initialise (or clear) a named buffer.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
binary::buffer::init() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	_bbuf_ref=()
}
```

