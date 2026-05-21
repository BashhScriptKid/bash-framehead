# `math::sigmoid`

**Signature:** `math::sigmoid(arr_name, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sigmoid — array-primary, operates in one awk pass

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arr_name` | variable | Yes | |
| `scale` | string | No | |

## Source

```bash
math::sigmoid() {
    local -n _sig_in="$1"
    local scale="${2:-$MATH_SCALE}"
    local -a _result=()
    for x in "${_sig_in[@]}"; do
        _result+=("$(math::bc "1 / (1 + e(-($x)))" "$scale")")
    done
    echo "${_result[@]}"
}
```

