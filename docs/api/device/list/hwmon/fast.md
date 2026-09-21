# `device::list::hwmon::fast`

**Signature:** `device::list::hwmon::fast(result_var, arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
device::list::hwmon::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir _name
		for _dir in /sys/class/hwmon/hwmon*; do
				[[ -d "$_dir" ]] || continue
				_name=$(cat "$_dir/name" 2>/dev/null) || _name="unknown"
				_out+=("$(basename "$_dir") (${_name})")
		done
		_ref=("${_out[@]}")
}
```

