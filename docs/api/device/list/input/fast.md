# `device::list::input::fast`

**Signature:** `device::list::input::fast(result_var, arg1, arg2)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
device::list::input::fast() {
		local -n _ref="$1"
		local -a _out=()
		if [[ -f /proc/bus/input/devices ]]; then
				while IFS= read -r _line; do
						[[ -n "$_line" ]] && _out+=("$_line")
				done < <(awk -F= '/^N:/{gsub(/^[[:space:]]+/,"",$2); print $2}' /proc/bus/input/devices)
		fi
		_ref=("${_out[@]}")
}
```

