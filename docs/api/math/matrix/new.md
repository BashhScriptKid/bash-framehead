# `math::matrix::new`

**Signature:** `math::matrix::new(arg1)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::matrix::new() {
    local dimensions="$1"
    local initial_value="${2:-0}"

    if [[ ! "$dimensions" =~ ^([0-9]+)x([0-9]+)$ ]]; then
        echo "Error: Invalid dimensions format. Use 'rowsxcols' (e.g., '3x4')" >&2
        return 1
    fi

    local rows="${BASH_REMATCH[1]}"
    local cols="${BASH_REMATCH[2]}"

    if [[ "$rows" -eq 0 ]] || [[ "$cols" -eq 0 ]]; then
        echo "Error: rows and cols must be greater than 0" >&2
        return 1
    fi

    # Just output the matrix elements
    for ((i=0; i<rows*cols; i++)); do
        echo "$initial_value"
    done
}
```

