# `device::input::touchpad::read`

**Signature:** `device::input::touchpad::read(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

Read touchpad gesture (BTN_TOOL_FINGER + ABS_X/ABS_Y + ABS_PRESSURE)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::touchpad::read() {
		local _dev="$1"
		local _x=0 _y=0 _pressure=0 _touching=0
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_KEY)
								case "$_ev_code" in
										$BTN_TOUCH) _touching=$_ev_value ;;
										$BTN_TOOL_FINGER) _touching=$_ev_value ;;
								esac
								;;
						$EV_ABS)
								case "$_ev_code" in
										$ABS_X) _x=$_ev_value ;;
										$ABS_Y) _y=$_ev_value ;;
										$ABS_PRESSURE) _pressure=$_ev_value ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		printf '%d %d %d %d' "$_touching" "$_x" "$_y" "$_pressure"
}
```

