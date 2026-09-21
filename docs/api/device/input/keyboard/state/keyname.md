# `device::input::keyboard::state::keyname`

**Signature:** `device::input::keyboard::state::keyname(arg1)`

**Module:** [`device`](../../../../device.md) — [Guide](../../../../guide/index.md)

**Return:** stdout — prints result

## Description

Read keyboard event, return key name instead of code

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::keyboard::state::keyname() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								local _name _state
								_name=$(device::input::keyname "$_ev_code")
								case "$_ev_value" in
										0) _state="release" ;;
										1) _state="press" ;;
										2) _state="repeat" ;;
										*) _state="$_ev_value" ;;
								esac
								printf '%s %s' "$_name" "$_state"
								return 0
								;;
						$EV_SYN) break ;;
				esac
		done
}
```

