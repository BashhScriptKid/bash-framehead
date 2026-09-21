# `device::input::tablet::read`

**Signature:** `device::input::tablet::read(arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- TABLET / TOUCHPAD ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
device::input::tablet::read() {
		local _dev="$1"
		local _x=0 _y=0 _pressure=0 _tilt_x=0 _tilt_y=0 _has_pressure=0 _has_tilt=0
		local _raw _ev_type _ev_code _ev_value
		while true; do
				_raw=$(device::event::raw::read "$_dev") || return 1
				device::event::raw::parse "$_raw"
				case "$_ev_type" in
						$EV_ABS)
								case "$_ev_code" in
										$ABS_X) _x=$_ev_value ;;
										$ABS_Y) _y=$_ev_value ;;
										$ABS_PRESSURE) _pressure=$_ev_value; _has_pressure=1 ;;
										$ABS_TILT_X) _tilt_x=$_ev_value; _has_tilt=1 ;;
										$ABS_TILT_Y) _tilt_y=$_ev_value; _has_tilt=1 ;;
								esac
								;;
						$EV_SYN) break ;;
				esac
		done
		if (( _has_tilt )); then
				printf '%d %d %d %d %d' "$_x" "$_y" "$_pressure" "$_tilt_x" "$_tilt_y"
		elif (( _has_pressure )); then
				printf '%d %d %d' "$_x" "$_y" "$_pressure"
		else
				printf '%d %d' "$_x" "$_y"
		fi
}
```

