# `device::event::read::frame`

**Signature:** `device::event::read::frame(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Read a complete event frame (all events until SYN_REPORT)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::event::read::frame() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				printf '%d %d %d\n' "$_ev_type" "$_ev_code" "$_ev_value"
				# SYN_REPORT = type 0, code 0
				(( _ev_type == 0 && _ev_code == 0 )) && return 0
		done
}
```

