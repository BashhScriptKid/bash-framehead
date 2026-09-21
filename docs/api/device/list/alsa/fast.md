# `device::list::alsa::fast`

**Signature:** `device::list::alsa::fast(result_var, arg1)`

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
device::list::alsa::fast() {
		local -n _ref="$1"
		local -a _out=()
		if [[ -f /proc/asound/cards ]]; then
				while IFS= read -r _line; do
						[[ -n "$_line" ]] && _out+=("$_line")
				done < <(awk '/^[[:space:]]*[0-9]+/ {print $1}' /proc/asound/cards)
		fi
		_ref=("${_out[@]}")
}
```

