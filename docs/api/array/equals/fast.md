# `array::equals::fast`

**Signature:** `array::equals::fast(result_var, el1, el2, el1, el2)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |

## Source

```bash
array::equals::fast() {
    local -n _array_equals_result="$1"
    local -a a=($2) b=($3)
    [[ "${#a[@]}" -ne "${#b[@]}" ]] && { _array_equals_result=false; return 1; }
    local i
    for (( i=0; i<${#a[@]}; i++ )); do
        [[ "${a[$i]}" != "${b[$i]}" ]] && { _array_equals_result=false; return 1; }
    done
    _array_equals_result=true
    return 0
}
```

