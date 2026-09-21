# `device::input::mouse::read`

**Signature:** `device::input::mouse::read(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- MOUSE ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::mouse::read() {
		local _dev="$1"
		local _dx=0 _dy=0 _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_REL)
								case "$_ev_code" in
										$REL_X) ((_dx += _ev_value)) ;;
										$REL_Y) ((_dy += _ev_value)) ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		printf '%d %d' "$_dx" "$_dy"
}
```

