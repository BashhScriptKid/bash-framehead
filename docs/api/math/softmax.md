# `math::softmax`

**Signature:** `math::softmax(arr_name, [temperature, [scale]])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Softmax — array-primary (singleton is degenerate: softmax of one value is always 1.0)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arr_name` | variable | Yes | |
| `[temperature` | string | Yes | |
| `scale]` | string | No | |

## Source

```bash
math::softmax() {
    local -n _softmax_in="$1"
    local temperature="${2:-1}" scale="${3:-$MATH_SCALE}"
    local -a arr=("${_softmax_in[@]}")

    if ! math::has_bc; then
        echo "Error: math::softmax requires bc for floating point operation."
        return 1
    fi

    if [[ $(math::bc "$temperature < 0") -eq 1 ]]; then
        echo "Error: math::softmax: Temperature cannot be lower than 0." >&2
        return 1
    fi

    ## T=0 is treated as T=1 (neutral temperature, no sharpening or flattening)
    ## Values between 0 and 1 are valid and will sharpen the distribution

    if [[ ${#arr[@]} -lt 2 ]]; then
        echo "Error: math::softmax requires more than 1 value" >&2
        return 1
    fi

    local -a exp_arr
    local exp_x

    for x in "${arr[@]}"; do
        exp_x=$(math::bc "if ($temperature > 0) { e($x / $temperature) } else { e($x) }" $scale)
        exp_arr+=("$exp_x")
    done

    # To maintain reliability and accuracy of normalisation,
    # normaliser_sum will not have scale applied
    local normaliser_sum=0
    for x in "${exp_arr[@]}"; do
        normaliser_sum=$(math::bc "$normaliser_sum + $x")
    done

    local -a softarr
    local softx

    for x in "${exp_arr[@]}"; do
        softx=$(math::bc "$x / $normaliser_sum" $scale)
        softarr+=("$softx")
    done

    echo "${softarr[@]}"
}
```

