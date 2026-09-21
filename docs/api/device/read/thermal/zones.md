# `device::read::thermal::zones`

**Signature:** `device::read::thermal::zones()`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

--- THERMAL ---


## Source

```bash
device::read::thermal::zones() {
		local _dir _type _temp
		for _dir in /sys/class/thermal/thermal_zone*; do
				[[ -d "$_dir" ]] || continue
				_type=$(cat "$_dir/type" 2>/dev/null) || _type="unknown"
				_temp=$(cat "$_dir/temp" 2>/dev/null) || _temp="unknown"
				[[ "$_temp" != "unknown" ]] && _temp=$((_temp / 1000))
				printf '%s: %s°C\n' "$_type" "$_temp"
		done
}
```

