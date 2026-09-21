# `device::event::wait::any`

**Signature:** `device::event::wait::any(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Block until any event, return type code value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::event::wait::any() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		_raw=$(device::event::raw::read "$_dev") || { echo "unknown"; return 1; }
		device::event::raw::parse "$_raw"
		printf '%d %d %d' "$_ev_type" "$_ev_code" "$_ev_value"
}
```

