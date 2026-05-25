# `math::matrix::new::fast`

**Signature:** `math::matrix::new::fast(Usage:)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

math::matrix::new::fast - Create a new matrix array using nameref (bash 4.3+)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `Usage:` | string | Yes | |

## Example

```bash
Example:
```

## Source

```bash
math::matrix::new::fast() {
		if [[ $# -lt 2 ]]; then
				echo "Usage: math::matrix::new::fast <array_name> <rows>x<cols> [initial_value]" >&2
				return 1
		fi

		local -n arr_ref="$1"  # nameref to the array
		local dimensions="$2"
		local initial_value="${3:-0}"

		# Validate format and extract dimensions
		if [[ ! "$dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
				echo "Error: Invalid dimensions format. Use 'rowsxcols' (e.g., '3x4')" >&2
				return 1
		fi

		local rows="${BASH_REMATCH[1]}"
		local cols="${BASH_REMATCH[2]}"

		# Validate positive integers
		if [[ "$rows" -eq 0 ]] || [[ "$cols" -eq 0 ]]; then
				echo "Error: rows and cols must be greater than 0" >&2
				return 1
		fi

		# Clear and initialize the array
		arr_ref=()
		local total=$((rows * cols))

		# Populate with initial values
		for ((i=0; i<total; i++)); do
				arr_ref[$i]="$initial_value"
		done
}
```

