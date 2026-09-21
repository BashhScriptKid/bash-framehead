# `device::input::keyboard::state::keycode`

**Signature:** `device::input::keyboard::state::keycode(arg1)`

**Module:** [`device`](../../../../device.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- KEYBOARD ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::keyboard::state::keycode() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								local _state
								case "$_ev_value" in
										0) _state="release" ;;
										1) _state="press" ;;
										2) _state="repeat" ;;
										*) _state="$_ev_value" ;;
								esac
								printf '%d %s' "$_ev_code" "$_state"
								return 0
								;;
						$EV_SYN) break ;;
				esac
		done
}
```

