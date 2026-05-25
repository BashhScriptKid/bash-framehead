# `array::clear`

**Signature:** `array::clear(arrname)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- CLEAR ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arrname` | string | Yes | |

## Source

```bash
array::clear() {
		[[ -v "$1" ]] || { echo "array::clear: '$1' is not set" >&2; return 1; }
		if _runtime::min_bash 5.2; then
				unset "$1[@]"
		else
				local -n _array_clear_ref="$1" 2>/dev/null || return 1
				_array_clear_ref=()
		fi
}
```

