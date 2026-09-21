# `binary::buffer::write`

**Signature:** `binary::buffer::write(<name>)`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Flush buffer contents to stdout and clear.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
binary::buffer::write() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	_binary::_emit_raw _bbuf_ref
	_bbuf_ref=()
}
```

