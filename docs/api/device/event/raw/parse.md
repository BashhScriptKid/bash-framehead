# `device::event::raw::parse`

**Signature:** `device::event::raw::parse(hex, bytes...)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- EVENT PRIMITIVES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `hex` | string | Yes | |
| `bytes...` | string | — | |

## Source

```bash
device::event::raw::parse() {
		local -a _bytes
		read -ra _bytes <<< "$1"
		_ev_type=$((16#${_bytes[16]} + 16#${_bytes[17]} * 256))
		_ev_code=$((16#${_bytes[18]} + 16#${_bytes[19]} * 256))
		_ev_value=$((16#${_bytes[20]} + 16#${_bytes[21]} * 256 + 16#${_bytes[22]} * 65536 + 16#${_bytes[23]} * 16777216))
}
```

