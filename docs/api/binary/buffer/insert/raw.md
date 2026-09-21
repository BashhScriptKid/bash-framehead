# `binary::buffer::insert::raw`

**Signature:** `binary::buffer::insert::raw(<name>, <byte1>, <byte2>, ...)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- INSERT VARIANTS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<byte1>` | string | Yes | |
| `<byte2>` | string | Yes | |
| `...` | any | — | |

## Source

```bash
binary::buffer::insert::raw() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	shift
	_bbuf_ref+=("$@")
}
```

