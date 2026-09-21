# `device::list::power::fast`

**Signature:** `device::list::power::fast(result_var, arg1)`

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
device::list::power::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/power_supply/*/type; do
				[[ -f "$_dir" ]] || continue
				_out+=("$(basename "$(dirname "$_dir")")")
		done
		_ref=("${_out[@]}")
}
```

