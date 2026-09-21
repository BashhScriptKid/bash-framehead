# `device::input::mouse::button`

**Signature:** `device::input::mouse::button(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Read mouse button state until SYN_REPORT, return button press/release

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::mouse::button() {
		local _dev="$1"
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								# BTN_LEFT=0x110, BTN_RIGHT=0x111, BTN_MIDDLE=0x112
								if (( _ev_code >= 0x110 && _ev_code <= 0x117 )); then
										local _name
										case "$_ev_code" in
												0x110) _name="left" ;;
												0x111) _name="right" ;;
												0x112) _name="middle" ;;
												0x113) _name="side" ;;
												0x114) _name="extra" ;;
												*) _name="$_ev_code" ;;
										esac
										printf '%s %s' "$_name" "$([[ $_ev_value -eq 1 ]] && echo press || echo release)"
										return 0
								fi
								;;
						$EV_SYN) break ;;
				esac
		done
}
```

