# `device::event::wait::key`

**Signature:** `device::event::wait::key(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Block until key event, return key code (only on press, not release)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::event::wait::key() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				(( _ev_type == EV_KEY && _ev_value == 1 )) && { echo "$_ev_code"; return 0; }
		done
}
```

