# `device::list::block::fast`

**Signature:** `device::list::block::fast(result_var, arg1)`

**Module:** [`device`](../../../device.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

--- EXISTING LISTER FAST VARIANTS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
device::list::block::fast() {
		local -n _ref="$1"
		local -a _out=()
		while IFS= read -r _line; do
				_out+=("$_line")
		done < <(device::list::block)
		_ref=("${_out[@]}")
}
```

