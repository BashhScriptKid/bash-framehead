# `device::list::gpu::fast`

**Signature:** `device::list::gpu::fast(result_var, arg1)`

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
device::list::gpu::fast() {
		local -n _ref="$1"
		local -a _out=()
		local _dir
		for _dir in /sys/class/drm/card[0-9]*; do
				[[ -d "$_dir" ]] || continue
				_out+=("$(basename "$_dir")")
		done
		_ref=("${_out[@]}")
}
```

