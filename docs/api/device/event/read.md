# `device::event::read`

**Signature:** `device::event::read(arg1)`

**Module:** [`device`](../../device.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Read one event, return type code value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::event::read() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		_raw=$(device::event::raw::read "$_dev") || { echo "unknown"; return 1; }
		device::event::raw::parse "$_raw"
		printf '%d %d %d' "$_ev_type" "$_ev_code" "$_ev_value"
}
```

